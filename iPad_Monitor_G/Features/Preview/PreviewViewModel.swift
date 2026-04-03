import AVFoundation
import Combine

enum DisplayAspect: String, CaseIterable {
    case original = "원본"
    case fill     = "채우기"
    case r4_3     = "4:3"
    case r16_9    = "16:9"
    case r21_9    = "21:9"

    /// 프리뷰 레이어 gravity
    var videoGravity: AVLayerVideoGravity {
        switch self {
        case .original: return .resizeAspect
        default:        return .resizeAspectFill
        }
    }

    /// nil → 전체 화면에 맞춤 / CGFloat → 해당 비율로 프레임 고정
    var aspectRatio: CGFloat? {
        switch self {
        case .original, .fill: return nil
        case .r4_3:  return 4.0 / 3.0
        case .r16_9: return 16.0 / 9.0
        case .r21_9: return 21.0 / 9.0
        }
    }
}

@MainActor
final class PreviewViewModel: ObservableObject {
    private enum DefaultsKey {
        static let isPortrait = "preview.isPortrait"
        static let selectedAspect = "preview.selectedAspect"
        static let scale = "preview.scale"
        static let isMirrorCorrectionEnabled = "preview.isMirrorCorrectionEnabled"
        static let isRotate180Enabled = "preview.isRotate180Enabled"
    }

    @Published var isPortrait: Bool = true {
        didSet { defaults.set(isPortrait, forKey: DefaultsKey.isPortrait) }
    }
    @Published var isUIHidden: Bool = false
    @Published var selectedAspect: DisplayAspect = .original {
        didSet { defaults.set(selectedAspect.rawValue, forKey: DefaultsKey.selectedAspect) }
    }
    @Published var scale: CGFloat = 1.35 {
        didSet { defaults.set(Double(scale), forKey: DefaultsKey.scale) }
    }
    @Published var isMirrorCorrectionEnabled: Bool = true {
        didSet { defaults.set(isMirrorCorrectionEnabled, forKey: DefaultsKey.isMirrorCorrectionEnabled) }
    }
    @Published var isRotate180Enabled: Bool = false {
        didSet { defaults.set(isRotate180Enabled, forKey: DefaultsKey.isRotate180Enabled) }
    }
    @Published private(set) var selectedCamera: AVCaptureDevice?
    @Published private(set) var selectedResolution: VideoResolution = .r1080p
    @Published private(set) var isAudioEnabled: Bool = true

    let cameraService: CameraService
    var session: AVCaptureSession { cameraService.session }
    private let defaults: UserDefaults

    private var cancellables = Set<AnyCancellable>()

    init(cameraService: CameraService, defaults: UserDefaults = .standard) {
        self.cameraService = cameraService
        self.defaults = defaults

        selectedCamera = cameraService.selectedDevice
        selectedResolution = cameraService.selectedResolution
        isAudioEnabled = cameraService.isAudioEnabled
        restorePersistedUIState()

        cameraService.$selectedDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.selectedCamera = $0 }
            .store(in: &cancellables)

        cameraService.$selectedResolution
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.selectedResolution = $0 }
            .store(in: &cancellables)

        cameraService.$isAudioEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.isAudioEnabled = $0 }
            .store(in: &cancellables)
    }

    func onAppear() {
        Task {
            let granted = await cameraService.requestPermission()
            guard granted else { return }
            cameraService.start()
        }
    }

    func onDisappear() {
        cameraService.stop()
    }

    func toggleOrientation() {
        isPortrait.toggle()
    }

    func toggleUI() {
        isUIHidden.toggle()
    }

    func selectResolution(_ resolution: VideoResolution) {
        cameraService.setResolution(resolution)
    }

    func selectAspect(_ aspect: DisplayAspect) {
        selectedAspect = aspect
    }

    func toggleAudio() {
        cameraService.toggleAudio()
    }

    func toggleMirrorCorrection() {
        isMirrorCorrectionEnabled.toggle()
    }

    func toggleRotate180() {
        isRotate180Enabled.toggle()
    }

    private func restorePersistedUIState() {
        if defaults.object(forKey: DefaultsKey.isPortrait) != nil {
            isPortrait = defaults.bool(forKey: DefaultsKey.isPortrait)
        }

        if let raw = defaults.string(forKey: DefaultsKey.selectedAspect),
           let aspect = DisplayAspect(rawValue: raw) {
            selectedAspect = aspect
        }

        if defaults.object(forKey: DefaultsKey.scale) != nil {
            let savedScale = CGFloat(defaults.double(forKey: DefaultsKey.scale))
            scale = min(3.0, max(0.5, savedScale))
        }

        if defaults.object(forKey: DefaultsKey.isMirrorCorrectionEnabled) != nil {
            isMirrorCorrectionEnabled = defaults.bool(forKey: DefaultsKey.isMirrorCorrectionEnabled)
        }

        if defaults.object(forKey: DefaultsKey.isRotate180Enabled) != nil {
            isRotate180Enabled = defaults.bool(forKey: DefaultsKey.isRotate180Enabled)
        }
    }
}
