// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerDetail _$PlayerDetailFromJson(Map<String, dynamic> json) => PlayerDetail(
  playerId: (json['playerId'] as num).toInt(),
  fullName: json['fullName'] as String,
  position: json['position'] as String,
  number: (json['number'] as num).toInt(),
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
  teamId: (json['teamId'] as num).toInt(),
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
  id: (json['id'] as num).toInt(),
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
      totalMatches: (json['totalMatches'] as num).toInt(),
      totalPoints: (json['totalPoints'] as num).toInt(),
      averagePoints: (json['averagePoints'] as num).toDouble(),
      highestScore: (json['highestScore'] as num).toInt(),
    );

Map<String, dynamic> _$PlayerStatisticsToJson(PlayerStatistics instance) =>
    <String, dynamic>{
      'totalMatches': instance.totalMatches,
      'totalPoints': instance.totalPoints,
      'averagePoints': instance.averagePoints,
      'highestScore': instance.highestScore,
    };

PlayerMatch _$PlayerMatchFromJson(Map<String, dynamic> json) => PlayerMatch(
  matchId: (json['matchId'] as num).toInt(),
  teamA: json['teamA'] as String,
  teamB: json['teamB'] as String,
  scoreA: (json['scoreA'] as num?)?.toInt(),
  scoreB: (json['scoreB'] as num?)?.toInt(),
  matchDate: DateTime.parse(json['matchDate'] as String),
  location: json['location'] as String?,
  status: json['status'] as String,
  points: (json['points'] as num).toInt(),
  scoringCount: (json['scoringCount'] as num).toInt(),
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
      matchId: (json['matchId'] as num).toInt(),
      matchDate: DateTime.parse(json['matchDate'] as String),
      points: (json['points'] as num).toInt(),
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
  totalMatches: (json['totalMatches'] as num).toInt(),
  totalPoints: (json['totalPoints'] as num).toInt(),
  averagePoints: (json['averagePoints'] as num).toDouble(),
  highestScore: (json['highestScore'] as num).toInt(),
  winRate: (json['winRate'] as num).toDouble(),
  currentStreak: (json['currentStreak'] as num).toInt(),
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
