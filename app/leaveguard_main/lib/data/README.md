# 데이터 계층

SQLite. 앱 안에서 직접 연다. 별도 서버 없음.

## 사용법

앱 시작 시 한 번 연다.

```dart
final database = AppDatabase()..open();
final repo = SqliteRepository(database);
```

이후 repo만 부르면 된다.

```dart
final members = await repo.fetchMembers();
final me = await repo.findMemberByIdentity(method: 'face', identifier: 'jaehyeon');
final items = await repo.fetchChecklistItems(memberId: 1, situationId: 1);
```

## DB 파일 위치

1. 환경변수 `LEAVEGUARD_DB`
2. `/data` 디렉토리가 있으면 `/data/leaveguard.db` (라즈베리파이)
3. 없으면 `$HOME/leaveguard.db` (개발 중인 맥)

파일이 없으면 만들고 스키마를 적용한다. `members`가 비어 있을 때만 시드가 들어간다.

## 테이블

| 테이블 | 내용 |
|---|---|
| `members` | 사용자 |
| `user_identity` | 식별 수단. 행이 없으면 수동 선택 |
| `situation` | 외출 목적 |
| `situation_rule` | 상황 추정 규칙 (요일·시간). 비어 있음 |
| `items` | 트레이에서 객체탐지로 확인하는 물건 |
| `member_checklist_items` | 사용자·상황별 챙길 물건 |
| `weather_items` | 날씨 조건으로 안내만 하는 물건 (우산, 양산) |
| `object_states` | 물건의 현재 상태. 물건당 한 행 |

## 얼굴 인식 연결

인식 결과 ID를 `user_identity`에 넣어두면 `findMemberByIdentity`로 사용자를 찾는다.

```sql
INSERT INTO user_identity (member_id, method, identifier) VALUES (2, 'face', 'jaehyeon');
```

`user_identity`가 비어 있으면 화면에서 수동 선택으로 동작한다.
