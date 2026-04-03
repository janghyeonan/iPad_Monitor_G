import Foundation

@MainActor
final class AppEnvironment: ObservableObject {
    let cameraService = CameraService()

    func makePreviewViewModel() -> PreviewViewModel {
        PreviewViewModel(cameraService: cameraService)
    }
}
