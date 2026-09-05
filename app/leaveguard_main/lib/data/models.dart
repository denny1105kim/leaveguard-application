// DB 테이블에 대응하는 모델.

/// members
class Member {
  final int id;
  final String name;

  const Member({required this.id, required this.name});

  factory Member.fromRow(Map<String, dynamic> row) {
    return Member(id: row['id'] as int, name: row['name'] as String);
  }
}

/// situation
class Situation {
  final int id;
  final String name;

  const Situation({required this.id, required this.name});

  factory Situation.fromRow(Map<String, dynamic> row) {
    return Situation(id: row['id'] as int, name: row['name'] as String);
  }
}

/// items
class Item {
  final int id;
  final String label;
  final String displayName;

  const Item({
    required this.id,
    required this.label,
    required this.displayName,
  });

  factory Item.fromRow(Map<String, dynamic> row) {
    return Item(
      id: row['id'] as int,
      label: row['label'] as String,
      displayName: row['display_name'] as String,
    );
  }
}
