import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class Team {
  @JsonKey(name: 'teamId', fromJson: _safeIntFromJson)
  final int teamId;
  final String name;
  final String? coach;
  final String? logoUrl;
  @JsonKey(fromJson: _safeIntFromJsonNullable)
  final int? playerCount;

  Team({
    required this.teamId,
    required this.name,
    this.coach,
    this.logoUrl,
    this.playerCount,
  });

  static int _safeIntFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _safeIntFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  String toString() => 'Team(id: $teamId, name: $name)';
}
