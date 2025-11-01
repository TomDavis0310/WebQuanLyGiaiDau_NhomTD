import 'package:json_annotation/json_annotation.dart';

part 'tournament_statistics.g.dart';

/// Top Scorer Model
@JsonSerializable()
class TopScorer {
  final int playerId;
  final String playerName;
  final String? playerImage;
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final int totalPoints;
  final int matchesPlayed;
  final double averagePoints;

  TopScorer({
    required this.playerId,
    required this.playerName,
    this.playerImage,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.totalPoints,
    required this.matchesPlayed,
    required this.averagePoints,
  });

  factory TopScorer.fromJson(Map<String, dynamic> json) =>
      _$TopScorerFromJson(json);

  Map<String, dynamic> toJson() => _$TopScorerToJson(this);
}

/// Team Statistics Model
@JsonSerializable()
class TeamStatistics {
  final int? teamId;
  final String teamName;
  final String? teamLogo;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsScored;
  final int goalsConceded;
  final int goalDifference;
  final int points;
  final double winRate;

  TeamStatistics({
    this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsScored,
    required this.goalsConceded,
    required this.goalDifference,
    required this.points,
    required this.winRate,
  });

  factory TeamStatistics.fromJson(Map<String, dynamic> json) =>
      _$TeamStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$TeamStatisticsToJson(this);
}

/// Match Statistics Model
@JsonSerializable()
class MatchStatistics {
  final int totalMatches;
  final int completedMatches;
  final int upcomingMatches;
  final int ongoingMatches;
  final int totalGoals;
  final double averageGoalsPerMatch;
  final HighestScoringMatch? highestScoringMatch;

  MatchStatistics({
    required this.totalMatches,
    required this.completedMatches,
    required this.upcomingMatches,
    required this.ongoingMatches,
    required this.totalGoals,
    required this.averageGoalsPerMatch,
    this.highestScoringMatch,
  });

  factory MatchStatistics.fromJson(Map<String, dynamic> json) =>
      _$MatchStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$MatchStatisticsToJson(this);
}

/// Highest Scoring Match Model
@JsonSerializable()
class HighestScoringMatch {
  final int matchId;
  final String teamA;
  final String teamB;
  final int scoreTeamA;
  final int scoreTeamB;
  final int totalGoals;
  final DateTime matchDate;

  HighestScoringMatch({
    required this.matchId,
    required this.teamA,
    required this.teamB,
    required this.scoreTeamA,
    required this.scoreTeamB,
    required this.totalGoals,
    required this.matchDate,
  });

  factory HighestScoringMatch.fromJson(Map<String, dynamic> json) =>
      _$HighestScoringMatchFromJson(json);

  Map<String, dynamic> toJson() => _$HighestScoringMatchToJson(this);
}

/// Tournament Overview Model
@JsonSerializable()
class TournamentOverview {
  final int tournamentId;
  final String tournamentName;
  final String? sportName;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTeams;
  final int totalPlayers;
  final int totalMatches;
  final int completedMatches;
  final int totalGoals;
  final TopScorerInfo? topScorer;

  TournamentOverview({
    required this.tournamentId,
    required this.tournamentName,
    this.sportName,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalTeams,
    required this.totalPlayers,
    required this.totalMatches,
    required this.completedMatches,
    required this.totalGoals,
    this.topScorer,
  });

  factory TournamentOverview.fromJson(Map<String, dynamic> json) =>
      _$TournamentOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentOverviewToJson(this);
}

/// Top Scorer Info (for Overview)
@JsonSerializable()
class TopScorerInfo {
  final int playerId;
  final String playerName;
  final int totalPoints;

  TopScorerInfo({
    required this.playerId,
    required this.playerName,
    required this.totalPoints,
  });

  factory TopScorerInfo.fromJson(Map<String, dynamic> json) =>
      _$TopScorerInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TopScorerInfoToJson(this);
}
