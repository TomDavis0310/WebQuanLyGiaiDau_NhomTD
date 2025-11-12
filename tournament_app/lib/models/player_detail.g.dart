// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerDetail _$PlayerDetailFromJson(Map<String, dynamic> json) => PlayerDetail(
  playerId: PlayerDetail._safeIntFromJson(json['playerId']),
  fullName: json['fullName'] as String,
  position: json['position'] as String,
  number: PlayerDetail._safeIntFromJson(json['number']),
  imageUrl: json['imageUrl'] as String?,
  team: json['team'] == null
      ? null
      : PlayerTeam.fromJson(json['team'] as Map<String, dynamic>),
  statistics: PlayerStatistics.fromJson(
    json['statistics'] as Map<String, dynamic>,
  ),
  recentMatches: (json['recentMatches'] as List<dynamic>)
      .map((e) => PlayerMatch.fromJson(e as Map<String, dynamic>))
      .toList(),
  performanceData: (json['performanceData'] as List<dynamic>)
      .map((e) => PerformanceData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlayerDetailToJson(PlayerDetail instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'fullName': instance.fullName,
      'position': instance.position,
      'number': instance.number,
      'imageUrl': instance.imageUrl,
      'team': instance.team,
      'statistics': instance.statistics,
      'recentMatches': instance.recentMatches,
      'performanceData': instance.performanceData,
    };

PlayerTeam _$PlayerTeamFromJson(Map<String, dynamic> json) => PlayerTeam(
  teamId: PlayerTeam._safeIntFromJson(json['teamId']),
  name: json['name'] as String,
  logo: json['logo'] as String?,
  sport: json['sport'] == null
      ? null
      : PlayerSport.fromJson(json['sport'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlayerTeamToJson(PlayerTeam instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'name': instance.name,
      'logo': instance.logo,
      'sport': instance.sport,
    };

PlayerSport _$PlayerSportFromJson(Map<String, dynamic> json) => PlayerSport(
  id: PlayerSport._safeIntFromJson(json['id']),
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$PlayerSportToJson(PlayerSport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };

PlayerStatistics _$PlayerStatisticsFromJson(Map<String, dynamic> json) =>
    PlayerStatistics(
      totalMatches: PlayerStatistics._safeIntFromJson(json['totalMatches']),
      totalPoints: PlayerStatistics._safeIntFromJson(json['totalPoints']),
      averagePoints: PlayerStatistics._safeDoubleFromJson(
        json['averagePoints'],
      ),
      highestScore: PlayerStatistics._safeIntFromJson(json['highestScore']),
    );

Map<String, dynamic> _$PlayerStatisticsToJson(PlayerStatistics instance) =>
    <String, dynamic>{
      'totalMatches': instance.totalMatches,
      'totalPoints': instance.totalPoints,
      'averagePoints': instance.averagePoints,
      'highestScore': instance.highestScore,
    };

PlayerMatch _$PlayerMatchFromJson(Map<String, dynamic> json) => PlayerMatch(
  matchId: PlayerMatch._safeIntFromJson(json['matchId']),
  teamA: json['teamA'] as String,
  teamB: json['teamB'] as String,
  scoreA: PlayerMatch._safeIntFromJsonNullable(json['scoreA']),
  scoreB: PlayerMatch._safeIntFromJsonNullable(json['scoreB']),
  matchDate: DateTime.parse(json['matchDate'] as String),
  location: json['location'] as String?,
  status: json['status'] as String,
  points: PlayerMatch._safeIntFromJson(json['points']),
  scoringCount: PlayerMatch._safeIntFromJson(json['scoringCount']),
);

Map<String, dynamic> _$PlayerMatchToJson(PlayerMatch instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'teamA': instance.teamA,
      'teamB': instance.teamB,
      'scoreA': instance.scoreA,
      'scoreB': instance.scoreB,
      'matchDate': instance.matchDate.toIso8601String(),
      'location': instance.location,
      'status': instance.status,
      'points': instance.points,
      'scoringCount': instance.scoringCount,
    };

PerformanceData _$PerformanceDataFromJson(Map<String, dynamic> json) =>
    PerformanceData(
      matchId: PerformanceData._safeIntFromJson(json['matchId']),
      matchDate: DateTime.parse(json['matchDate'] as String),
      points: PerformanceData._safeIntFromJson(json['points']),
    );

Map<String, dynamic> _$PerformanceDataToJson(PerformanceData instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'matchDate': instance.matchDate.toIso8601String(),
      'points': instance.points,
    };

PlayerStatisticsSummary _$PlayerStatisticsSummaryFromJson(
  Map<String, dynamic> json,
) => PlayerStatisticsSummary(
  totalMatches: PlayerStatisticsSummary._safeIntFromJson(json['totalMatches']),
  totalPoints: PlayerStatisticsSummary._safeIntFromJson(json['totalPoints']),
  averagePoints: PlayerStatisticsSummary._safeDoubleFromJson(
    json['averagePoints'],
  ),
  highestScore: PlayerStatisticsSummary._safeIntFromJson(json['highestScore']),
  winRate: PlayerStatisticsSummary._safeDoubleFromJson(json['winRate']),
  currentStreak: PlayerStatisticsSummary._safeIntFromJson(
    json['currentStreak'],
  ),
  recentForm: (json['recentForm'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$PlayerStatisticsSummaryToJson(
  PlayerStatisticsSummary instance,
) => <String, dynamic>{
  'totalMatches': instance.totalMatches,
  'totalPoints': instance.totalPoints,
  'averagePoints': instance.averagePoints,
  'highestScore': instance.highestScore,
  'winRate': instance.winRate,
  'currentStreak': instance.currentStreak,
  'recentForm': instance.recentForm,
};
