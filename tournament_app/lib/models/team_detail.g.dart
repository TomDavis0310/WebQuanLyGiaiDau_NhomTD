// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamDetail _$TeamDetailFromJson(Map<String, dynamic> json) => TeamDetail(
  teamId: (json['teamId'] as num).toInt(),
  name: json['name'] as String,
  coach: json['coach'] as String?,
  logoUrl: json['logoUrl'] as String?,
  userId: json['userId'] as String?,
  players: (json['players'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  matchHistory: (json['matchHistory'] as List<dynamic>?)
      ?.map((e) => MatchHistory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TeamDetailToJson(TeamDetail instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'name': instance.name,
      'coach': instance.coach,
      'logoUrl': instance.logoUrl,
      'userId': instance.userId,
      'players': instance.players,
      'matchHistory': instance.matchHistory,
    };

MatchHistory _$MatchHistoryFromJson(Map<String, dynamic> json) => MatchHistory(
  id: (json['id'] as num).toInt(),
  teamA: json['teamA'] as String,
  teamB: json['teamB'] as String,
  matchDate: DateTime.parse(json['matchDate'] as String),
  scoreTeamA: (json['scoreTeamA'] as num?)?.toInt(),
  scoreTeamB: (json['scoreTeamB'] as num?)?.toInt(),
  tournament: TournamentInfo.fromJson(
    json['tournament'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$MatchHistoryToJson(MatchHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamA': instance.teamA,
      'teamB': instance.teamB,
      'matchDate': instance.matchDate.toIso8601String(),
      'scoreTeamA': instance.scoreTeamA,
      'scoreTeamB': instance.scoreTeamB,
      'tournament': instance.tournament,
    };

TournamentInfo _$TournamentInfoFromJson(Map<String, dynamic> json) =>
    TournamentInfo(
      name: json['name'] as String,
      sportsName: json['sportsName'] as String,
    );

Map<String, dynamic> _$TournamentInfoToJson(TournamentInfo instance) =>
    <String, dynamic>{'name': instance.name, 'sportsName': instance.sportsName};
