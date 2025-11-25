import 'package:json_annotation/json_annotation.dart';

part 'standings.g.dart';

@JsonSerializable()
class TournamentStandings {
  final int tournamentId;
  final String tournamentName;
  final String? sportName;
  final bool hasGroups;
  final List<StandingGroup> groups;

  TournamentStandings({
    required this.tournamentId,
    required this.tournamentName,
    this.sportName,
    required this.hasGroups,
    required this.groups,
  });

  factory TournamentStandings.fromJson(Map<String, dynamic> json) =>
      _$TournamentStandingsFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentStandingsToJson(this);
}

@JsonSerializable()
class StandingGroup {
  final String groupName;
  final DateTime? lastUpdated;
  final List<TeamStanding> teams;

  StandingGroup({
    required this.groupName,
    this.lastUpdated,
    required this.teams,
  });

  factory StandingGroup.fromJson(Map<String, dynamic> json) =>
      _$StandingGroupFromJson(json);

  Map<String, dynamic> toJson() => _$StandingGroupToJson(this);
}

@JsonSerializable()
class TeamStanding {
  final int teamId;
  final String? teamName;
  final String? teamLogo;
  final int? rank;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int? goalsFor;
  final int? goalsAgainst;
  final int? goalDifference;
  final int? points;

  TeamStanding({
    required this.teamId,
    this.teamName,
    this.teamLogo,
    this.rank,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    this.goalsFor,
    this.goalsAgainst,
    this.goalDifference,
    this.points,
  });

  factory TeamStanding.fromJson(Map<String, dynamic> json) =>
      _$TeamStandingFromJson(json);

  Map<String, dynamic> toJson() => _$TeamStandingToJson(this);
}

@JsonSerializable()
class TournamentBracket {
  final int tournamentId;
  final String tournamentName;
  final String bracketType;
  final int totalRounds;
  final List<BracketRound> rounds;

  TournamentBracket({
    required this.tournamentId,
    required this.tournamentName,
    required this.bracketType,
    required this.totalRounds,
    required this.rounds,
  });

  factory TournamentBracket.fromJson(Map<String, dynamic> json) =>
      _$TournamentBracketFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentBracketToJson(this);
}

@JsonSerializable()
class BracketRound {
  final int round;
  final String? roundName;
  final List<BracketMatch> matches;

  BracketRound({
    required this.round,
    this.roundName,
    required this.matches,
  });

  factory BracketRound.fromJson(Map<String, dynamic> json) =>
      _$BracketRoundFromJson(json);

  Map<String, dynamic> toJson() => _$BracketRoundToJson(this);
}

@JsonSerializable()
class BracketMatch {
  final int matchId;
  final int? round;
  final String? roundName;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamA;
  final int? teamAId;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamB;
  final int? teamBId;
  final int? scoreA;
  final int? scoreB;
  final DateTime matchDate;
  final String? matchTime;
  final String? location;
  final String status;
  final int? winnerId;

  BracketMatch({
    required this.matchId,
    this.round,
    this.roundName,
    required this.teamA,
    this.teamAId,
    required this.teamB,
    this.teamBId,
    this.scoreA,
    this.scoreB,
    required this.matchDate,
    this.matchTime,
    this.location,
    required this.status,
    this.winnerId,
  });

  factory BracketMatch.fromJson(Map<String, dynamic> json) =>
      _$BracketMatchFromJson(json);

  Map<String, dynamic> toJson() => _$BracketMatchToJson(this);

  static String _safeStringFromJson(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    return value?.toString() ?? '';
  }

  String get formattedDate {
    return '${matchDate.day.toString().padLeft(2, '0')}/${matchDate.month.toString().padLeft(2, '0')}/${matchDate.year}';
  }

  String get formattedTime {
    if (matchTime == null) return '';
    final parts = matchTime!.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return matchTime!;
  }
}

@JsonSerializable()
class HeadToHead {
  final int tournamentId;
  final TeamHeadToHeadInfo teamA;
  final TeamHeadToHeadInfo teamB;
  final int draws;
  final int totalMatches;
  final List<HeadToHeadMatch> matches;

  HeadToHead({
    required this.tournamentId,
    required this.teamA,
    required this.teamB,
    required this.draws,
    required this.totalMatches,
    required this.matches,
  });

  factory HeadToHead.fromJson(Map<String, dynamic> json) =>
      _$HeadToHeadFromJson(json);

  Map<String, dynamic> toJson() => _$HeadToHeadToJson(this);
}

@JsonSerializable()
class TeamHeadToHeadInfo {
  final int teamId;
  final String name;
  final String? logo;
  final int wins;
  final int totalGoals;

  TeamHeadToHeadInfo({
    required this.teamId,
    required this.name,
    this.logo,
    required this.wins,
    required this.totalGoals,
  });

  factory TeamHeadToHeadInfo.fromJson(Map<String, dynamic> json) =>
      _$TeamHeadToHeadInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TeamHeadToHeadInfoToJson(this);
}

@JsonSerializable()
class HeadToHeadMatch {
  final int matchId;
  final DateTime matchDate;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamA;
  final int? teamAId;
  final int? scoreA;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamB;
  final int? teamBId;
  final int? scoreB;
  final String? location;
  final String status;

  HeadToHeadMatch({
    required this.matchId,
    required this.matchDate,
    required this.teamA,
    this.teamAId,
    this.scoreA,
    required this.teamB,
    this.teamBId,
    this.scoreB,
    this.location,
    required this.status,
  });

  factory HeadToHeadMatch.fromJson(Map<String, dynamic> json) =>
      _$HeadToHeadMatchFromJson(json);

  Map<String, dynamic> toJson() => _$HeadToHeadMatchToJson(this);

  static String _safeStringFromJson(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    return value?.toString() ?? '';
  }

  String get formattedDate {
    return '${matchDate.day.toString().padLeft(2, '0')}/${matchDate.month.toString().padLeft(2, '0')}/${matchDate.year}';
  }
}
