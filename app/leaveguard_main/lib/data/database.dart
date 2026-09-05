import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import 'schema.dart';

/// SQLite 연결 관리.
/// 앱 시작 시 open()을 한 번 부르고, 이후 db로 접근한다.
class AppDatabase {
  Database? _db;

  Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('AppDatabase.open()을 먼저 호출해야 한다');
    }
    return database;
  }

  /// 파일이 없으면 만들고 스키마를 적용한다.
  /// 경로는 LEAVEGUARD_DB 환경변수로 바꿀 수 있다.
  void open({String? path}) {
    if (_db != null) return;

    final file = path ?? _defaultPath();
    Directory(File(file).parent.path).createSync(recursive: true);

    final database = sqlite3.open(file);
    database.execute('PRAGMA foreign_keys = ON');
    database.execute(createSchemaSql);

    final count =
        database.select('SELECT COUNT(*) AS c FROM members').first['c'] as int;
    if (count == 0) {
      database.execute(seedSql);
    }

    _db = database;
  }

  void close() {
    _db?.dispose();
    _db = null;
  }

  /// 라즈베리파이는 /data 아래, 개발 중인 맥은 홈 디렉토리에 둔다.
  String _defaultPath() {
    final fromEnv = Platform.environment['LEAVEGUARD_DB'];
    if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

    if (Directory('/data').existsSync()) return '/data/leaveguard.db';

    final home = Platform.environment['HOME'] ?? '.';
    return '$home/leaveguard.db';
  }
}
