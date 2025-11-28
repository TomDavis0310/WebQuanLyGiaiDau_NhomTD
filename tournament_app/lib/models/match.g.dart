// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
  id: Match._safeIntFromJson(json['id']),
  teamA: Match._safeStringFromJson(json['teamA']),
  teamB: Match._safeStringFromJson(json['teamB']),
  matchDate: DateTime.parse(json['matchDate'] as String),
  matchTime: json['matchTime'] as String?,
  location: json['location'] as String?,
  scoreTeamA: Match._safeIntFromJsonNullable(json['scoreTeamA']),
  scoreTeamB: Match._safeIntFromJsonNullable(json['scoreTeamB']),
  groupName: json['groupName'] as String?,
  round: Match._safeIntFromJsonNullable(json['round']),
);

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
  'id': instance.id,
  'teamA': instance.teamA,
  'teamB': instance.teamB,
  'matchDate': instance.matchDate.toIso8601String(),
  'matchTime': instance.matchTime,
  'location': instance.location,
  'scoreTeamA': instance.scoreTeamA,
  'scoreTeamB': instance.scoreTeamB,
  'groupName': instance.groupName,
  'round': instance.round,
};
