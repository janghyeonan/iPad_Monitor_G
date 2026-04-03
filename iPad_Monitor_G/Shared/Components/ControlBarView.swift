import SwiftUI

struct ControlBarView: View {
    let isPortrait: Bool
    let selectedResolution: VideoResolution
    let selectedAspect: DisplayAspect
    let isAudioEnabled: Bool
    let isMirrorCorrectionEnabled: Bool
    let isRotate180Enabled: Bool
    @Binding var scale: CGFloat
    let onToggleOrientation: () -> Void
    let onToggleUI: () -> Void
    let onSelectResolution: (VideoResolution) -> Void
    let onSelectAspect: (DisplayAspect) -> Void
    let onToggleAudio: () -> Void
    let onToggleMirrorCorrection: () -> Void
    let onToggleRotate180: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            // 비율 + 해상도 선택 (한 줄)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    selectorGroupLabel("비율")
                    selectorRow(
                        items: DisplayAspect.allCases,
                        selected: selectedAspect,
                        label: \.rawValue,
                        action: onSelectAspect
                    )
                    selectorGroupLabel("해상도")
                    selectorRow(
                        items: VideoResolution.allCases,
                        selected: selectedResolution,
                        label: \.rawValue,
                        action: onSelectResolution
                    )
                }
                .padding(.horizontal, 2)
            }

            // 줌 슬라이더
            HStack(spacing: 10) {
                Button(action: { scale = max(0.5, scale - 0.1) }) {
                    Image(systemName: "minus.magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
                Slider(value: $scale, in: 0.5...3.0, step: 0.05)
                    .tint(.white)
                Button(action: { scale = min(3.0, scale + 0.1) }) {
                    Image(systemName: "plus.magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
                Text(String(format: "%.2fx", scale))
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 52, alignment: .leading)
                Button(action: { scale = 1.0 }) {
                    Text("리셋")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.15)))
                }
            }

            // 방향 전환 / 오디오 / 미러보정 / 180도 / UI 숨기기
            HStack(spacing: 20) {
                controlButton(
                    icon: isPortrait ? "rectangle.portrait.rotate" : "rectangle.rotate.to.portrait",
                    label: isPortrait ? "가로로" : "세로로",
                    action: onToggleOrientation
                )
                Spacer()
                controlButton(
                    icon: isAudioEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                    label: isAudioEnabled ? "소리 켜짐" : "소리 꺼짐",
                    action: onToggleAudio
                )
                controlButton(
                    icon: isMirrorCorrectionEnabled ? "rectangle.lefthalf.filled" : "rectangle.righthalf.filled",
                    label: isMirrorCorrectionEnabled ? "반전 보정 ON" : "반전 보정 OFF",
                    action: onToggleMirrorCorrection
                )
                controlButton(
                    icon: "rotate.right.fill",
                    label: isRotate180Enabled ? "180도 ON" : "180도 OFF",
                    action: onToggleRotate180
                )
                controlButton(icon: "eye.slash.fill", label: "숨기기", action: onToggleUI)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 20).fill(.ultraThinMaterial))
    }

    private func selectorRow<T: Hashable>(
        items: [T],
        selected: T,
        label: KeyPath<T, String>,
        action: @escaping (T) -> Void
    ) -> some View {
        HStack(spacing: 6) {
            ForEach(items, id: \.self) { item in
                Button(action: { action(item) }) {
                    Text(item[keyPath: label])
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selected == item ? .black : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(selected == item ? Color.white : Color.white.opacity(0.18))
                        )
                }
            }
        }
    }

    private func selectorGroupLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white.opacity(0.7))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(0.12)))
    }

    private func controlButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}
