import 'package:json_annotation/json_annotation.dart';

part 'player_scoring.g.dart';

/// Player Scoring model - Thống kê ghi điểm của cầu thủ
@JsonSerializable()
class PlayerScoring {
  final int id;
  final int points;
  final String? scoringTime;
  final String? notes;
  final Player player;

  PlayerScoring({
    required this.id,
    required this.points,
    this.scoringTime,
    this.notes,
    required this.player,
  });

  factory PlayerScoring.fromJson(Map<String, dynamic> json) =>
      _$PlayerScoringFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerScoringToJson(this);
}

/// Player model - Thông tin cầu thủ
@JsonSerializable()
class Player {
  final int playerId;
  final String fullName;
  final String? position;
  final String? number;
  final String? imageUrl;

  Player({
    required this.playerId,
    required this.fullName,
    this.position,
    this.number,
    this.imageUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) =>
      _$PlayerFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
