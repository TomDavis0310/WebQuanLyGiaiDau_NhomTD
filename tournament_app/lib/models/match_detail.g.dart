// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchDetail _$MatchDetailFromJson(Map<String, dynamic> json) => MatchDetail(
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
  status: json['status'] as String,
  tournament: TournamentInfo.fromJson(
    json['tournament'] as Map<String, dynamic>,
  ),
  teamAInfo: json['teamAInfo'] == null
      ? null
      : Team.fromJson(json['teamAInfo'] as Map<String, dynamic>),
  teamBInfo: json['teamBInfo'] == null
      ? null
      : Team.fromJson(json['teamBInfo'] as Map<String, dynamic>),
  playerScorings: (json['playerScorings'] as List<dynamic>)
      .map((e) => PlayerScoring.fromJson(e as Map<String, dynamic>))
      .toList(),
  highlightsVideoUrl: json['highlightsVideoUrl'] as String?,
  liveStreamUrl: json['liveStreamUrl'] as String?,
  videoDescription: json['videoDescription'] as String?,
);

Map<String, dynamic> _$MatchDetailToJson(MatchDetail instance) =>
    <String, dynamic>{
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
      'status': instance.status,
      'tournament': instance.tournament,
      'teamAInfo': instance.teamAInfo,
      'teamBInfo': instance.teamBInfo,
      'playerScorings': instance.playerScorings,
      'highlightsVideoUrl': instance.highlightsVideoUrl,
      'liveStreamUrl': instance.liveStreamUrl,
      'videoDescription': instance.videoDescription,
    };

TournamentInfo _$TournamentInfoFromJson(Map<String, dynamic> json) =>
    TournamentInfo(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      sports: SportInfo.fromJson(json['sports'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TournamentInfoToJson(TournamentInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sports': instance.sports,
    };

SportInfo _$SportInfoFromJson(Map<String, dynamic> json) => SportInfo(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$SportInfoToJson(SportInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
};
