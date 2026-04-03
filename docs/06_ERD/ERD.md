# ERD - 데이터 설계서

## 1. 현재(v1) 저장 구조
- 서버 DB 없음
- `UserDefaults` 로컬 저장 사용

## 2. 로컬 키 설계
| 키 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `preview.isPortrait` | Bool | true | 기본 화면 방향(세로) |
| `preview.selectedAspect` | String | original | 선택 비율 |
| `preview.scale` | Double | 1.35 | 프리뷰 배율 |
| `preview.isMirrorCorrectionEnabled` | Bool | true | 좌우 반전 보정 |
| `preview.isRotate180Enabled` | Bool | false | 180도 회전 |

## 3. vNext 개념 ERD (계획)
- `users` 1:N `devices`
- `devices` 1:N `stream_sessions`
- `stream_sessions` 1:N `session_events`
- `stream_sessions` 1:1 `stream_settings_snapshot`

## 4. 엔터티 초안 (계획)
### users
| 필드 | 타입 | 제약 |
|---|---|---|
| id | uuid | PK |
| email | varchar(255) | unique |
| created_at | timestamp | not null |

### devices
| 필드 | 타입 | 제약 |
|---|---|---|
| id | uuid | PK |
| user_id | uuid | FK(users.id) |
| model | varchar(120) | not null |
| os_version | varchar(30) | not null |

### stream_sessions
| 필드 | 타입 | 제약 |
|---|---|---|
| id | uuid | PK |
| device_id | uuid | FK(devices.id) |
| resolution | varchar(20) | not null |
| audio_enabled | boolean | not null |
| started_at | timestamp | not null |
| ended_at | timestamp | null |
