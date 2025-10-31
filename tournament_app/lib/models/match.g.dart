// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) => Match(
  id: (json['id'] as num).toInt(),
  teamA: json['teamA'] as String,
  teamB: json['teamB'] as String,
  matchDate: DateTime.parse(json['matchDate'] as String),
  matchTime: json['matchTime'] as String?,
  location: json['location'] as String?,
  scoreTeamA: (json['scoreTeamA'] as num?)?.toInt(),
  scoreTeamB: (json['scoreTeamB'] as num?)?.toInt(),
  groupName: json['groupName'] as String?,
  round: (json['round'] as num?)?.toInt(),
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
