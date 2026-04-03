import AVFoundation
import Combine

enum VideoResolution: String, CaseIterable, Sendable {
    case r480p  = "480p"
    case r720p  = "720p"
    case r1080p = "1080p"
    case r4K    = "4K"

    var sessionPreset: AVCaptureSession.Preset {
        switch self {
        case .r480p:  return .vga640x480
        case .r720p:  return .hd1280x720
        case .r1080p: return .hd1920x1080
        case .r4K:    return .hd4K3840x2160
        }
    }
}

actor CaptureSessionCoordinator {
    nonisolated(unsafe) let previewSession = AVCaptureSession()

    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    private let audioQueue = DispatchQueue(label: "audio.capture.queue")
    private let audioMonitor = AudioMonitor()
    private let audioOutput = AVCaptureAudioDataOutput()
    private var hasAttachedAudioOutput = false

    func start(resolution: VideoResolution, audioEnabled: Bool) {
        previewSession.beginConfiguration()
        let preset = resolution.sessionPreset
        previewSession.sessionPreset = previewSession.canSetSessionPreset(preset) ? preset : .hd1920x1080

        if !hasAttachedAudioOutput, previewSession.canAddOutput(audioOutput) {
            previewSession.addOutput(audioOutput)
            audioOutput.setSampleBufferDelegate(audioMonitor, queue: audioQueue)
            hasAttachedAudioOutput = true
        }

        previewSession.commitConfiguration()
        if !previewSession.isRunning {
            previewSession.startRunning()
        }

        if audioEnabled {
            audioMonitor.enable()
        } else {
            audioMonitor.disable()
        }
    }

    func stop() {
        audioMonitor.teardown()
        if previewSession.isRunning {
            previewSession.stopRunning()
        }
    }

    func setResolution(_ resolution: VideoResolution) {
        previewSession.beginConfiguration()
        let preset = resolution.sessionPreset
        if previewSession.canSetSessionPreset(preset) {
            previewSession.sessionPreset = preset
        }
        previewSession.commitConfiguration()
    }

    func setAudioEnabled(_ enabled: Bool) {
        if enabled {
            audioMonitor.enable()
        } else {
            audioMonitor.disable()
        }
    }

    func connect(videoDeviceID: String, preferredAudioDeviceID: String?) {
        previewSession.beginConfiguration()

        if let old = videoInput {
            previewSession.removeInput(old)
            videoInput = nil
        }
        if let old = audioInput {
            previewSession.removeInput(old)
            audioInput = nil
        }

        if let videoDevice = findVideoDevice(uniqueID: videoDeviceID),
           let input = try? AVCaptureDeviceInput(device: videoDevice),
           previewSession.canAddInput(input) {
            previewSession.addInput(input)
            videoInput = input
        }

        if let preferredAudioDeviceID,
           let audioDevice = findAudioDevice(uniqueID: preferredAudioDeviceID),
           let audioIn = try? AVCaptureDeviceInput(device: audioDevice),
           previewSession.canAddInput(audioIn) {
            previewSession.addInput(audioIn)
            audioInput = audioIn
        }

        previewSession.commitConfiguration()

        for output in previewSession.outputs {
            for connection in output.connections where connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = false
            }
        }
    }

    func disconnect() {
        audioMonitor.disable()

        previewSession.beginConfiguration()
        if let old = videoInput {
            previewSession.removeInput(old)
            videoInput = nil
        }
        if let old = audioInput {
            previewSession.removeInput(old)
            audioInput = nil
        }
        previewSession.commitConfiguration()
    }

    private func findVideoDevice(uniqueID: String) -> AVCaptureDevice? {
        if #available(iOS 17.0, *) {
            return AVCaptureDevice.DiscoverySession(
                deviceTypes: [.external],
                mediaType: .video,
                position: .unspecified
            ).devices.first(where: { $0.uniqueID == uniqueID })
        }
        return nil
    }

    private func findAudioDevice(uniqueID: String) -> AVCaptureDevice? {
        if #available(iOS 17.0, *) {
            let external = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.external],
                mediaType: .audio,
                position: .unspecified
            ).devices
            if let device = external.first(where: { $0.uniqueID == uniqueID }) {
                return device
            }
        }

        return AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone],
            mediaType: .audio,
            position: .unspecified
        ).devices.first(where: { $0.uniqueID == uniqueID })
    }
}

@MainActor
final class CameraService: ObservableObject {

    @Published private(set) var externalDevices: [AVCaptureDevice] = []
    @Published private(set) var selectedDevice: AVCaptureDevice?
    @Published var selectedResolution: VideoResolution = .r1080p
    @Published private(set) var isAudioEnabled = true

    var session: AVCaptureSession { sessionCoordinator.previewSession }

    private var notificationObservers: [NSObjectProtocol] = []
    private let sessionCoordinator = CaptureSessionCoordinator()

    // MARK: - Public

    func requestPermission() async -> Bool {
        let video = await AVCaptureDevice.requestAccess(for: .video)
        _ = await AVCaptureDevice.requestAccess(for: .audio)
        return video
    }

    func start() {
        let resolution = selectedResolution
        let audioEnabled = isAudioEnabled

        Task {
            await sessionCoordinator.start(resolution: resolution, audioEnabled: audioEnabled)
        }

        refresh()
        subscribeToHotplug()
    }

    func stop() {
        Task {
            await sessionCoordinator.stop()
        }

        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers.removeAll()
    }

    func setResolution(_ resolution: VideoResolution) {
        selectedResolution = resolution
        Task {
            await sessionCoordinator.setResolution(resolution)
        }
    }

    func toggleAudio() {
        isAudioEnabled.toggle()
        let enabled = isAudioEnabled
        Task {
            await sessionCoordinator.setAudioEnabled(enabled)
        }
    }

    // MARK: - Private

    private func refresh() {
        guard #available(iOS 17.0, *) else { return }

        let devices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.external],
            mediaType: .video,
            position: .unspecified
        ).devices
        externalDevices = devices

        if let device = devices.first {
            if selectedDevice?.uniqueID != device.uniqueID {
                connectDevice(device)
            }
        } else {
            disconnectCurrentDevice()
        }
    }

    private func connectDevice(_ device: AVCaptureDevice) {
        let audioID = selectBestAudioInputID()
        let videoID = device.uniqueID

        Task {
            await sessionCoordinator.connect(videoDeviceID: videoID, preferredAudioDeviceID: audioID)
        }
        selectedDevice = device
    }

    private func disconnectCurrentDevice() {
        Task {
            await sessionCoordinator.disconnect()
        }
        selectedDevice = nil
    }

    private func subscribeToHotplug() {
        guard notificationObservers.isEmpty else { return }

        let connectedName: Notification.Name
        let disconnectedName: Notification.Name
        if #available(iOS 18.0, *) {
            connectedName = AVCaptureDevice.wasConnectedNotification
            disconnectedName = AVCaptureDevice.wasDisconnectedNotification
        } else {
            connectedName = .AVCaptureDeviceWasConnected
            disconnectedName = .AVCaptureDeviceWasDisconnected
        }

        let conn = NotificationCenter.default.addObserver(
            forName: connectedName, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        let disc = NotificationCenter.default.addObserver(
            forName: disconnectedName, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        notificationObservers = [conn, disc]
    }

    private func selectBestAudioInputID() -> String? {
        if #available(iOS 17.0, *) {
            let external = AVCaptureDevice.DiscoverySession(
                deviceTypes: [.external],
                mediaType: .audio,
                position: .unspecified
            ).devices
            if let bestExternal = external.first {
                return bestExternal.uniqueID
            }
        }

        let microphones = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone],
            mediaType: .audio,
            position: .unspecified
        ).devices
        return microphones.first?.uniqueID
    }
}
