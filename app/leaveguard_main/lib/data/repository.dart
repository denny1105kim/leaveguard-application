import 'package:sqlite3/sqlite3.dart';

import 'database.dart';
import 'models.dart';

/// 데이터 접근 인터페이스.
/// 나중에 서버가 생기면 구현체만 교체한다.
abstract class Repository {
  Future<List<Member>> fetchMembers();
  Future<Member> insertMember(String name);

  /// 식별값으로 사용자 찾기. 없으면 null
  Future<Member?> findMemberByIdentity({
    required String method,
    required String identifier,
  });

  Future<List<Situation>> fetchSituations();

  Future<List<Item>> fetchItems();

  /// label이 이미 있으면 null
  Future<Item?> insertItem({
    required String label,
    required String displayName,
  });

  /// 특정 사용자·상황에 챙길 물건 목록
  Future<List<Item>> fetchChecklistItems({
    required int memberId,
    required int situationId,
  });

  Future<List<WeatherItem>> fetchWeatherItems();
}

/// SQLite 구현.
class SqliteRepository implements Repository {
  final AppDatabase _database;

  SqliteRepository(this._database);

  Database get _db => _database.db;

  @override
  Future<List<Member>> fetchMembers() async {
    final rows = _db.select('SELECT id, name FROM members ORDER BY id');
    return rows.map(Member.fromRow).toList();
  }

  @override
  Future<Member> insertMember(String name) async {
    _db.execute('INSERT INTO members (name) VALUES (?)', [name]);
    final rows = _db.select(
      'SELECT id, name FROM members WHERE id = ?',
      [_db.lastInsertRowId],
    );
    return Member.fromRow(rows.first);
  }

  @override
  Future<Member?> findMemberByIdentity({
    required String method,
    required String identifier,
  }) async {
    final rows = _db.select(
      '''
      SELECT m.id, m.name
      FROM user_identity ui
      JOIN members m ON m.id = ui.member_id
      WHERE ui.method = ? AND ui.identifier = ?
      ''',
      [method, identifier],
    );
    if (rows.isEmpty) return null;
    return Member.fromRow(rows.first);
  }

  @override
  Future<List<Situation>> fetchSituations() async {
    final rows = _db.select('SELECT id, name FROM situation ORDER BY id');
    return rows.map(Situation.fromRow).toList();
  }

  @override
  Future<List<Item>> fetchItems() async {
    final rows = _db.select(
      'SELECT id, label, display_name FROM items ORDER BY id',
    );
    return rows.map(Item.fromRow).toList();
  }

  @override
  Future<Item?> insertItem({
    required String label,
    required String displayName,
  }) async {
    final existing = _db.select('SELECT id FROM items WHERE label = ?', [label]);
    if (existing.isNotEmpty) return null;

    _db.execute(
      'INSERT INTO items (label, display_name) VALUES (?, ?)',
      [label, displayName],
    );
    final rows = _db.select(
      'SELECT id, label, display_name FROM items WHERE id = ?',
      [_db.lastInsertRowId],
    );
    return Item.fromRow(rows.first);
  }

  @override
  Future<List<Item>> fetchChecklistItems({
    required int memberId,
    required int situationId,
  }) async {
    final rows = _db.select(
      '''
      SELECT i.id, i.label, i.display_name
      FROM member_checklist_items c
      JOIN items i ON i.id = c.item_id
      WHERE c.member_id = ? AND c.situation_id = ?
      ORDER BY i.display_name
      ''',
      [memberId, situationId],
    );
    return rows.map(Item.fromRow).toList();
  }

  @override
  Future<List<WeatherItem>> fetchWeatherItems() async {
    final rows = _db.select(
      '''
      SELECT id, display_name, precip_type, pop_min, sky_max, temp_max_min
      FROM weather_items
      ORDER BY id
      ''',
    );
    return rows.map(WeatherItem.fromRow).toList();
  }
}
