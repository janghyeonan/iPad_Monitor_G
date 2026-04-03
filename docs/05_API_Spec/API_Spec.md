# API 명세서

- 회사명: 모모스테이지 엔터테이먼트
- 담당부서: 서비스개발팀
- 담당자: 안장현
- 현재 문서 버전: v1

## 1. 현재 버전(v1) 정책
- 본 앱은 로컬 처리 중심 구조이며 외부 백엔드 API 의존이 없습니다.
- 핵심 기능은 iOS 캡처/오디오 프레임워크 내부 계약으로 동작합니다.

## 2. 내부 서비스 계약

### 2.1 `CameraService`
- 책임:
  - 외부 비디오 장치 탐색
  - 세션 시작/종료
  - 해상도 적용
  - 오디오 입력 선택 및 토글
- 입력:
  - 권한 요청, 장치 연결 이벤트, 사용자 설정 변경
- 출력:
  - `selectedDevice`
  - `selectedResolution`
  - `isAudioEnabled`
  - `AVCaptureSession`

### 2.2 `PreviewViewModel`
- 책임:
  - UI 액션을 서비스 호출로 변환
  - 반전/회전/배율/비율 상태 저장
- 영속 키:
  - `preview.isPortrait`
  - `preview.selectedAspect`
  - `preview.scale`
  - `preview.isMirrorCorrectionEnabled`
  - `preview.isRotate180Enabled`

## 3. vNext 외부 API(계획)

### POST `/api/v1/streams/sessions`
- 설명: 스트리밍 세션 생성
- Request
```json
{
  "deviceId": "external-camera-1",
  "resolution": "1080p",
  "audioEnabled": true
}
```
- Response
```json
{
  "sessionId": "sess_123",
  "status": "ready"
}
```

### PATCH `/api/v1/streams/sessions/{sessionId}`
- 설명: 반전/회전/비율 등 제어값 갱신

## 4. 에러 규격(계획)
```json
{
  "code": "DEVICE_NOT_AVAILABLE",
  "message": "External capture device is not connected"
}
```
