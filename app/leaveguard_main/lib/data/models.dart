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

/// weather_items
class WeatherItem {
  final int id;
  final String displayName;
  final int? precipType;
  final int? popMin;
  final int? skyMax;
  final int? tempMaxMin;

  const WeatherItem({
    required this.id,
    required this.displayName,
    this.precipType,
    this.popMin,
    this.skyMax,
    this.tempMaxMin,
  });

  factory WeatherItem.fromRow(Map<String, dynamic> row) {
    return WeatherItem(
      id: row['id'] as int,
      displayName: row['display_name'] as String,
      precipType: row['precip_type'] as int?,
      popMin: row['pop_min'] as int?,
      skyMax: row['sky_max'] as int?,
      tempMaxMin: row['temp_max_min'] as int?,
    );
  }
}
