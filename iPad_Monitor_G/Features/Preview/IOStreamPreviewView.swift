import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let gravity: AVLayerVideoGravity
    let mirrorCorrectionEnabled: Bool

    func makeUIView(context: Context) -> CapturePreviewUIView {
        let view = CapturePreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = gravity
        applyConnectionSettings(to: view.previewLayer)
        applyMirrorTransform(to: view.previewLayer)
        return view
    }

    func updateUIView(_ uiView: CapturePreviewUIView, context: Context) {
        uiView.previewLayer.videoGravity = gravity
        applyConnectionSettings(to: uiView.previewLayer)
        applyMirrorTransform(to: uiView.previewLayer)
    }

    private func applyConnectionSettings(to previewLayer: AVCaptureVideoPreviewLayer) {
        guard let connection = previewLayer.connection else { return }
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = false
        }
        if #available(iOS 17.0, *) {
            if connection.isVideoRotationAngleSupported(0) {
                connection.videoRotationAngle = 0
            }
        } else if connection.isVideoOrientationSupported {
            connection.videoOrientation = .landscapeRight
        }
    }

    private func applyMirrorTransform(to previewLayer: AVCaptureVideoPreviewLayer) {
        previewLayer.transform = mirrorCorrectionEnabled
            ? CATransform3DMakeScale(-1, 1, 1)
            : CATransform3DIdentity
    }
}

final class CapturePreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
