// SQLite 스키마.
// 앱 시작 시 없으면 만든다.

const String createSchemaSql = '''
CREATE TABLE IF NOT EXISTS members (
    id    INTEGER PRIMARY KEY AUTOINCREMENT,
    name  TEXT    NOT NULL
);


-- 사용자 식별 수단
-- 행이 없으면 수동 선택으로 동작
CREATE TABLE IF NOT EXISTS user_identity (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id   INTEGER NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    method      TEXT    NOT NULL,
    identifier  TEXT    NOT NULL,
    UNIQUE (method, identifier)
);

CREATE INDEX IF NOT EXISTS idx_identity_member ON user_identity(member_id);


-- 상황 : 외출 목적
CREATE TABLE IF NOT EXISTS situation (
    id    INTEGER PRIMARY KEY AUTOINCREMENT,
    name  TEXT    NOT NULL UNIQUE
);


-- 상황 판단 규칙 : 외출 목적을 추정하는 요일·시간 조건
CREATE TABLE IF NOT EXISTS situation_rule (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id     INTEGER NOT NULL REFERENCES members(id)   ON DELETE CASCADE,
    situation_id  INTEGER NOT NULL REFERENCES situation(id) ON DELETE CASCADE,
    day_of_week   INTEGER CHECK (day_of_week BETWEEN 0 AND 6),
    start_time    TEXT,
    end_time      TEXT
);

CREATE INDEX IF NOT EXISTS idx_rule_member ON situation_rule(member_id);


-- 물건 : 트레이에 올려두고 객체탐지로 확인하는 물건
CREATE TABLE IF NOT EXISTS items (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    label         TEXT    NOT NULL UNIQUE,
    display_name  TEXT    NOT NULL
);


-- 사용자별 상황에 챙겨야 할 물건
CREATE TABLE IF NOT EXISTS member_checklist_items (
    member_id     INTEGER NOT NULL REFERENCES members(id)   ON DELETE CASCADE,
    situation_id  INTEGER NOT NULL REFERENCES situation(id) ON DELETE CASCADE,
    item_id       INTEGER NOT NULL REFERENCES items(id)     ON DELETE CASCADE,
    PRIMARY KEY (member_id, situation_id, item_id)
);


-- 객체탐지가 확인한 물건의 현재 상태
-- 물건당 한 행을 갱신한다
CREATE TABLE IF NOT EXISTS object_states (
    item_id      INTEGER PRIMARY KEY REFERENCES items(id) ON DELETE CASCADE,
    state        TEXT    NOT NULL CHECK (state IN ('PRESENT', 'ABSENT')),
    detected_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);
''';

/// 첫 실행에만 들어가는 테스트 데이터.
const String seedSql = '''
INSERT INTO members (name) VALUES ('준형'), ('재현'), ('치영');

INSERT INTO situation (name) VALUES ('출근'), ('외출');

INSERT INTO items (label, display_name) VALUES
    ('car_key', '차키'),
    ('wallet',  '지갑');
INSERT INTO member_checklist_items (member_id, situation_id, item_id)
SELECT m.id, s.id, i.id
FROM members m, situation s, items i
WHERE s.name = '출근' AND i.label IN ('car_key', 'wallet');

INSERT INTO member_checklist_items (member_id, situation_id, item_id)
SELECT m.id, s.id, i.id
FROM members m, situation s, items i
WHERE s.name = '외출' AND i.label = 'wallet';
''';
