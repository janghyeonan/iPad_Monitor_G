import AVFoundation

/// HDMI 오디오 캡처 샘플버퍼 → AVAudioPlayerNode 재생 파이프라인
/// AVAudioEngine.inputNode 를 전혀 사용하지 않으므로 iPad 마이크 하울링 없음
final class AudioMonitor: NSObject {

    private let engine      = AVAudioEngine()
    private let playerNode  = AVAudioPlayerNode()
    private var configured  = false
    private let schedulingQueue = DispatchQueue(label: "audio.monitor.scheduling.queue")
    private var scheduledBufferCount = 0
    private let maxScheduledBuffers = 4

    private(set) var isEnabled = false

    // MARK: - Public

    func enable() {
        isEnabled = true
        if configured && !playerNode.isPlaying { playerNode.play() }
    }

    func disable() {
        isEnabled = false
        playerNode.pause()
    }

    func teardown() {
        isEnabled = false
        schedulingQueue.sync {
            scheduledBufferCount = 0
        }
        playerNode.stop()
        if engine.isRunning { engine.stop() }
        configured = false
    }

    // MARK: - Private

    /// 첫 번째 샘플버퍼가 도착하면 그 포맷으로 엔진을 구성
    private func setupEngine(format: AVAudioFormat) {
        guard !configured else { return }
        do {
            let avSession = AVAudioSession.sharedInstance()
            // USB 디지털 오디오 라우트를 우선 유지하고, 필요 시 시스템이 적절한 출력으로 라우팅.
            try avSession.setCategory(.playAndRecord, mode: .videoRecording,
                                      options: [.allowBluetoothHFP, .allowBluetoothA2DP, .mixWithOthers])
            try avSession.setPreferredSampleRate(format.sampleRate)
            try avSession.setPreferredIOBufferDuration(0.005)
            try avSession.setActive(true)
        } catch {
            print("[AudioMonitor] AVAudioSession 설정 실패: \(error)")
        }

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
            playerNode.play()
            configured = true
        } catch {
            print("[AudioMonitor] AVAudioEngine 시작 실패: \(error)")
        }
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate

extension AudioMonitor: AVCaptureAudioDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard isEnabled else { return }
        guard let pcmBuffer = Self.toPCMBuffer(sampleBuffer) else { return }

        if !configured { setupEngine(format: pcmBuffer.format) }
        guard configured else { return }

        schedulingQueue.async { [weak self] in
            guard let self else { return }
            if self.scheduledBufferCount >= self.maxScheduledBuffers {
                return
            }
            self.scheduledBufferCount += 1
            self.playerNode.scheduleBuffer(pcmBuffer, completionHandler: { [weak self] in
                self?.schedulingQueue.async {
                    self?.scheduledBufferCount = max(0, (self?.scheduledBufferCount ?? 1) - 1)
                }
            })
        }
    }

    /// CMSampleBuffer → AVAudioPCMBuffer 변환
    private static func toPCMBuffer(_ sampleBuffer: CMSampleBuffer) -> AVAudioPCMBuffer? {
        guard let formatDesc = CMSampleBufferGetFormatDescription(sampleBuffer),
              let asbdPtr = CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc) else { return nil }

        var asbd = asbdPtr.pointee
        guard let format = AVAudioFormat(streamDescription: &asbd) else { return nil }

        let frameCount = CMSampleBufferGetNumSamples(sampleBuffer)
        guard frameCount > 0,
              let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format,
                                               frameCapacity: AVAudioFrameCount(frameCount)) else { return nil }
        pcmBuffer.frameLength = AVAudioFrameCount(frameCount)

        let status = CMSampleBufferCopyPCMDataIntoAudioBufferList(
            sampleBuffer, at: 0, frameCount: Int32(frameCount),
            into: pcmBuffer.mutableAudioBufferList
        )
        guard status == noErr else { return nil }
        return pcmBuffer
    }
}
