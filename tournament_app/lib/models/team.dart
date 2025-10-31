import 'package:json_annotation/json_annotation.dart';

part 'team.g.dart';

@JsonSerializable()
class Team {
  final int teamId;
  final String name;
  final String? coach;
  final String? logoUrl;
  final int? playerCount;

  Team({
    required this.teamId,
    required this.name,
    this.coach,
    this.logoUrl,
    this.playerCount,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
  Map<String, dynamic> toJson() => _$TeamToJson(this);

  @override
  String toString() => 'Team(id: $teamId, name: $name)';
}
