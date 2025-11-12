// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Team _$TeamFromJson(Map<String, dynamic> json) => Team(
  teamId: Team._safeIntFromJson(json['teamId']),
  name: json['name'] as String,
  coach: json['coach'] as String?,
  logoUrl: json['logoUrl'] as String?,
  playerCount: Team._safeIntFromJsonNullable(json['playerCount']),
);

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
  'teamId': instance.teamId,
  'name': instance.name,
  'coach': instance.coach,
  'logoUrl': instance.logoUrl,
  'playerCount': instance.playerCount,
};
