import SwiftUI

struct PreviewView: View {
    @StateObject var viewModel: PreviewViewModel

    init(viewModel: PreviewViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            cameraPreview

            if viewModel.isUIHidden {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.toggleUI() }
                    .ignoresSafeArea()
            }

            if viewModel.selectedCamera == nil && !viewModel.isUIHidden {
                noCameraPlaceholder
            }

            VStack {
                Spacer()
                ControlBarView(
                    isPortrait: viewModel.isPortrait,
                    selectedResolution: viewModel.selectedResolution,
                    selectedAspect: viewModel.selectedAspect,
                    isAudioEnabled: viewModel.isAudioEnabled,
                    isMirrorCorrectionEnabled: viewModel.isMirrorCorrectionEnabled,
                    isRotate180Enabled: viewModel.isRotate180Enabled,
                    scale: $viewModel.scale,
                    onToggleOrientation: { viewModel.toggleOrientation() },
                    onToggleUI: { viewModel.toggleUI() },
                    onSelectResolution: { viewModel.selectResolution($0) },
                    onSelectAspect: { viewModel.selectAspect($0) },
                    onToggleAudio: { viewModel.toggleAudio() },
                    onToggleMirrorCorrection: { viewModel.toggleMirrorCorrection() },
                    onToggleRotate180: { viewModel.toggleRotate180() }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .opacity(viewModel.isUIHidden ? 0 : 1)
            .animation(.easeInOut(duration: 0.25), value: viewModel.isUIHidden)
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
    }

    @ViewBuilder
    private var cameraPreview: some View {
        let cam = CameraPreviewView(
            session: viewModel.session,
            gravity: viewModel.selectedAspect.videoGravity,
            mirrorCorrectionEnabled: viewModel.isMirrorCorrectionEnabled
        )
        .rotationEffect(viewModel.isRotate180Enabled ? .degrees(180) : .degrees(0))
        .rotationEffect(viewModel.isPortrait ? .degrees(90) : .degrees(0))

        if let ratio = viewModel.selectedAspect.aspectRatio {
            cam
                .aspectRatio(ratio, contentMode: .fit)
                .scaleEffect(viewModel.scale)
        } else {
            cam
                .scaleEffect(viewModel.scale)
                .ignoresSafeArea()
        }
    }

    private var noCameraPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "cable.connector")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.4))
            Text("외부 입력을 연결하세요")
                .font(.title2)
                .foregroundColor(.white.opacity(0.5))
            Text("iPad USB-C에 UVC 카메라 또는\nHDMI 캡처 디바이스를 연결하세요")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.35))
                .multilineTextAlignment(.center)
        }
    }
}
