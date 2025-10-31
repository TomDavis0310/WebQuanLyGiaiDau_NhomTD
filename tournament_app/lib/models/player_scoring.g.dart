// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_scoring.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerScoring _$PlayerScoringFromJson(Map<String, dynamic> json) =>
    PlayerScoring(
      id: (json['id'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      scoringTime: json['scoringTime'] as String?,
      notes: json['notes'] as String?,
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PlayerScoringToJson(PlayerScoring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'points': instance.points,
      'scoringTime': instance.scoringTime,
      'notes': instance.notes,
      'player': instance.player,
    };

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  playerId: (json['playerId'] as num).toInt(),
  fullName: json['fullName'] as String,
  position: json['position'] as String?,
  number: json['number'] as String?,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'playerId': instance.playerId,
  'fullName': instance.fullName,
  'position': instance.position,
  'number': instance.number,
  'imageUrl': instance.imageUrl,
};
