// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopScorer _$TopScorerFromJson(Map<String, dynamic> json) => TopScorer(
  playerId: (json['playerId'] as num).toInt(),
  playerName: json['playerName'] as String,
  playerImage: json['playerImage'] as String?,
  teamId: (json['teamId'] as num).toInt(),
  teamName: json['teamName'] as String,
  teamLogo: json['teamLogo'] as String?,
  totalPoints: (json['totalPoints'] as num).toInt(),
  matchesPlayed: (json['matchesPlayed'] as num).toInt(),
  averagePoints: (json['averagePoints'] as num).toDouble(),
);

Map<String, dynamic> _$TopScorerToJson(TopScorer instance) => <String, dynamic>{
  'playerId': instance.playerId,
  'playerName': instance.playerName,
  'playerImage': instance.playerImage,
  'teamId': instance.teamId,
  'teamName': instance.teamName,
  'teamLogo': instance.teamLogo,
  'totalPoints': instance.totalPoints,
  'matchesPlayed': instance.matchesPlayed,
  'averagePoints': instance.averagePoints,
};

TeamStatistics _$TeamStatisticsFromJson(Map<String, dynamic> json) =>
    TeamStatistics(
      teamId: (json['teamId'] as num?)?.toInt(),
      teamName: json['teamName'] as String,
      teamLogo: json['teamLogo'] as String?,
      matchesPlayed: (json['matchesPlayed'] as num).toInt(),
      wins: (json['wins'] as num).toInt(),
      draws: (json['draws'] as num).toInt(),
      losses: (json['losses'] as num).toInt(),
      goalsScored: (json['goalsScored'] as num).toInt(),
      goalsConceded: (json['goalsConceded'] as num).toInt(),
      goalDifference: (json['goalDifference'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
    );

Map<String, dynamic> _$TeamStatisticsToJson(TeamStatistics instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'teamLogo': instance.teamLogo,
      'matchesPlayed': instance.matchesPlayed,
      'wins': instance.wins,
      'draws': instance.draws,
      'losses': instance.losses,
      'goalsScored': instance.goalsScored,
      'goalsConceded': instance.goalsConceded,
      'goalDifference': instance.goalDifference,
      'points': instance.points,
      'winRate': instance.winRate,
    };

MatchStatistics _$MatchStatisticsFromJson(Map<String, dynamic> json) =>
    MatchStatistics(
      totalMatches: (json['totalMatches'] as num).toInt(),
      completedMatches: (json['completedMatches'] as num).toInt(),
      upcomingMatches: (json['upcomingMatches'] as num).toInt(),
      ongoingMatches: (json['ongoingMatches'] as num).toInt(),
      totalGoals: (json['totalGoals'] as num).toInt(),
      averageGoalsPerMatch: (json['averageGoalsPerMatch'] as num).toDouble(),
      highestScoringMatch: json['highestScoringMatch'] == null
          ? null
          : HighestScoringMatch.fromJson(
              json['highestScoringMatch'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MatchStatisticsToJson(MatchStatistics instance) =>
    <String, dynamic>{
      'totalMatches': instance.totalMatches,
      'completedMatches': instance.completedMatches,
      'upcomingMatches': instance.upcomingMatches,
      'ongoingMatches': instance.ongoingMatches,
      'totalGoals': instance.totalGoals,
      'averageGoalsPerMatch': instance.averageGoalsPerMatch,
      'highestScoringMatch': instance.highestScoringMatch,
    };

HighestScoringMatch _$HighestScoringMatchFromJson(Map<String, dynamic> json) =>
    HighestScoringMatch(
      matchId: (json['matchId'] as num).toInt(),
      teamA: json['teamA'] as String,
      teamB: json['teamB'] as String,
      scoreTeamA: (json['scoreTeamA'] as num).toInt(),
      scoreTeamB: (json['scoreTeamB'] as num).toInt(),
      totalGoals: (json['totalGoals'] as num).toInt(),
      matchDate: DateTime.parse(json['matchDate'] as String),
    );

Map<String, dynamic> _$HighestScoringMatchToJson(
  HighestScoringMatch instance,
) => <String, dynamic>{
  'matchId': instance.matchId,
  'teamA': instance.teamA,
  'teamB': instance.teamB,
  'scoreTeamA': instance.scoreTeamA,
  'scoreTeamB': instance.scoreTeamB,
  'totalGoals': instance.totalGoals,
  'matchDate': instance.matchDate.toIso8601String(),
};

TournamentOverview _$TournamentOverviewFromJson(Map<String, dynamic> json) =>
    TournamentOverview(
      tournamentId: (json['tournamentId'] as num).toInt(),
      tournamentName: json['tournamentName'] as String,
      sportName: json['sportName'] as String?,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalTeams: (json['totalTeams'] as num).toInt(),
      totalPlayers: (json['totalPlayers'] as num).toInt(),
      totalMatches: (json['totalMatches'] as num).toInt(),
      completedMatches: (json['completedMatches'] as num).toInt(),
      totalGoals: (json['totalGoals'] as num).toInt(),
      topScorer: json['topScorer'] == null
          ? null
          : TopScorerInfo.fromJson(json['topScorer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TournamentOverviewToJson(TournamentOverview instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'tournamentName': instance.tournamentName,
      'sportName': instance.sportName,
      'status': instance.status,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'totalTeams': instance.totalTeams,
      'totalPlayers': instance.totalPlayers,
      'totalMatches': instance.totalMatches,
      'completedMatches': instance.completedMatches,
      'totalGoals': instance.totalGoals,
      'topScorer': instance.topScorer,
    };

TopScorerInfo _$TopScorerInfoFromJson(Map<String, dynamic> json) =>
    TopScorerInfo(
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String,
      totalPoints: (json['totalPoints'] as num).toInt(),
    );

Map<String, dynamic> _$TopScorerInfoToJson(TopScorerInfo instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'playerName': instance.playerName,
      'totalPoints': instance.totalPoints,
    };
