# iPad Monitor C - 설정 가이드

- 회사명: 모모스테이지 엔터테이먼트
- 담당부서: 서비스개발팀
- 담당자: 안장현
- 현재 문서 버전: v1

## Xcode 프로젝트 생성 단계

### 1. Xcode 프로젝트 생성
1. Xcode → **File > New > Project**
2. **iOS > App** 선택
3. 설정:
   - Product Name: `iPad_Monitor_G`
   - Bundle Identifier: `com.yourname.iPad-Monitor-C`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployments: **iOS 17.0**

### 2. 소스 파일 추가
`iPad_Monitor_G/` 폴더의 모든 `.swift` 파일을 Xcode 프로젝트에 추가합니다.
(폴더 구조를 유지하며 드래그 & 드롭)

```
App/
  iPad_Monitor_GApp.swift
  AppEnvironment.swift
Core/
  Streaming/
    RTMPStreamingService.swift
    StreamingState.swift
  Camera/
    CameraService.swift
    AudioService.swift
  Settings/
    StreamSettings.swift
    VideoQualitySettings.swift
Features/
  Preview/
    PreviewView.swift
    PreviewViewModel.swift
    IOStreamPreviewView.swift
  Settings/
    SettingsView.swift
    SettingsViewModel.swift
    RTMPSettingsView.swift
    VideoQualityView.swift
  DeviceSelector/
    DeviceSelectorView.swift
Shared/
  Persistence/
    SettingsStore.swift
  Components/
    StreamingStatusBadge.swift
    StatsOverlayView.swift
    ControlBarView.swift
```

### 3. HaishinKit SPM 패키지 추가
1. Xcode → **File > Add Package Dependencies**
2. URL 입력: `https://github.com/shogo4405/HaishinKit.swift`
3. 버전: **1.9.0 이상** (Up to Next Major)
4. **Add to Target**: iPad_Monitor_G

### 4. Info.plist 설정
`Resources/Info.plist`를 프로젝트의 Info.plist와 병합하거나 교체합니다.

또는 Xcode의 Target > Info 탭에서 직접 추가:
- `NSCameraUsageDescription` → "UVC 카메라 및 HDMI 캡처 디바이스로 영상을 촬영합니다."
- `NSMicrophoneUsageDescription` → "오디오를 캡처하여 RTMP 스트리밍합니다."
- `NSLocalNetworkUsageDescription` → "로컬 네트워크의 스트리밍 서버에 연결합니다."

### 5. 앱 설정
Target > General:
- **Deployment Info**: iPad Only (iPhone 체크 해제)
- **Device Orientation**: Landscape Left, Landscape Right만 선택
- **Minimum Deployments**: iOS 17.0

### 6. 빌드 및 실행
- 실기기(iPad)에서 실행 필요 (시뮬레이터는 외부 카메라 미지원)
- Apple Developer 계정 필요 (실기기 테스트)

---

## 앱 사용법

1. iPad USB-C에 UVC 카메라 또는 HDMI 캡처 카드 연결
2. 앱 실행 → 카메라/마이크 권한 허용
3. **카메라 버튼** → 디바이스 선택
4. **설정 버튼** → RTMP URL 및 스트림 키 입력
5. **가운데 버튼** → 스트리밍 시작

## RTMP 스트리밍 대상 예시

| 플랫폼 | RTMP URL |
|--------|----------|
| YouTube Live | `rtmp://a.rtmp.youtube.com/live2` |
| Twitch | `rtmp://live.twitch.tv/app` |
| OBS (로컬) | `rtmp://192.168.x.x/live` |
| Facebook Live | `rtmps://live-api-s.facebook.com:443/rtmp` |

---

## 기술 스택

- **언어**: Swift 5.9+
- **UI**: SwiftUI + MVVM
- **스트리밍**: RTMP via [HaishinKit](https://github.com/shogo4405/HaishinKit.swift)
- **카메라**: AVFoundation (`AVCaptureDevice.DeviceType.external`)
- **오디오**: AVAudioSession
- **최소 버전**: iOS 17.0 (iPad 전용)

## NDI 대신 RTMP를 사용하는 이유

NDI SDK는 Vizrt로부터 별도 라이선스가 필요합니다.
RTMP는 오픈 프로토콜로:
- YouTube, Twitch 등 모든 스트리밍 플랫폼 지원
- OBS, vMix 등 프로 소프트웨어와 호환
- 로컬 네트워크 서버(nginx-rtmp, SRS 등)로 NDI와 유사한 용도 구현 가능
