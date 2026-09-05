import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:leaveguard_main/data/database.dart';
import 'package:leaveguard_main/data/repository.dart';

void main() {
  late Directory dir;
  late AppDatabase database;
  late SqliteRepository repo;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('leaveguard_test');
    database = AppDatabase()..open(path: '${dir.path}/test.db');
    repo = SqliteRepository(database);
  });

  tearDown(() {
    database.close();
    dir.deleteSync(recursive: true);
  });

  test('첫 실행에 시드가 들어간다', () async {
    expect((await repo.fetchMembers()).length, 3);
    expect((await repo.fetchSituations()).length, 2);
    expect((await repo.fetchItems()).length, 2);
  });

  test('사용자를 추가한다', () async {
    final added = await repo.insertMember('아빠');
    expect(added.name, '아빠');

    final members = await repo.fetchMembers();
    expect(members.length, 4);
    expect(members.last.name, '아빠');
  });

  test('물건을 추가한다. label이 겹치면 null', () async {
    final added = await repo.insertItem(label: 'id_card', displayName: '사원증');
    expect(added, isNotNull);
    expect(added!.displayName, '사원증');

    final again = await repo.insertItem(label: 'id_card', displayName: '사원증');
    expect(again, isNull);
  });

  test('식별값으로 사용자를 찾는다', () async {
    expect(
      await repo.findMemberByIdentity(method: 'face', identifier: 'jaehyeon'),
      isNull,
    );

    final members = await repo.fetchMembers();
    final jaehyeon = members.firstWhere((m) => m.name == '재현');
    database.db.execute(
      'INSERT INTO user_identity (member_id, method, identifier) VALUES (?, ?, ?)',
      [jaehyeon.id, 'face', 'jaehyeon'],
    );

    final found =
        await repo.findMemberByIdentity(method: 'face', identifier: 'jaehyeon');
    expect(found?.name, '재현');
  });

  test('상황별로 챙길 물건이 다르다', () async {
    final members = await repo.fetchMembers();
    final situations = await repo.fetchSituations();
    final work = situations.firstWhere((s) => s.name == '출근');
    final out = situations.firstWhere((s) => s.name == '외출');

    final forWork = await repo.fetchChecklistItems(
      memberId: members.first.id,
      situationId: work.id,
    );
    final forOut = await repo.fetchChecklistItems(
      memberId: members.first.id,
      situationId: out.id,
    );

    expect(forWork.map((i) => i.label), containsAll(['car_key', 'wallet']));
    expect(forOut.map((i) => i.label), ['wallet']);
  });
}
