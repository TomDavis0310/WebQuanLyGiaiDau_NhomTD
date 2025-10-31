// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentStandings _$TournamentStandingsFromJson(Map<String, dynamic> json) =>
    TournamentStandings(
      tournamentId: (json['tournamentId'] as num).toInt(),
      tournamentName: json['tournamentName'] as String,
      sportName: json['sportName'] as String?,
      hasGroups: json['hasGroups'] as bool,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => StandingGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TournamentStandingsToJson(
  TournamentStandings instance,
) => <String, dynamic>{
  'tournamentId': instance.tournamentId,
  'tournamentName': instance.tournamentName,
  'sportName': instance.sportName,
  'hasGroups': instance.hasGroups,
  'groups': instance.groups,
};

StandingGroup _$StandingGroupFromJson(Map<String, dynamic> json) =>
    StandingGroup(
      groupName: json['groupName'] as String,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      teams: (json['teams'] as List<dynamic>)
          .map((e) => TeamStanding.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StandingGroupToJson(StandingGroup instance) =>
    <String, dynamic>{
      'groupName': instance.groupName,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'teams': instance.teams,
    };

TeamStanding _$TeamStandingFromJson(Map<String, dynamic> json) => TeamStanding(
  teamId: (json['teamId'] as num).toInt(),
  teamName: json['teamName'] as String?,
  teamLogo: json['teamLogo'] as String?,
  rank: (json['rank'] as num?)?.toInt(),
  played: (json['played'] as num).toInt(),
  won: (json['won'] as num).toInt(),
  drawn: (json['drawn'] as num).toInt(),
  lost: (json['lost'] as num).toInt(),
  goalsFor: (json['goalsFor'] as num?)?.toInt(),
  goalsAgainst: (json['goalsAgainst'] as num?)?.toInt(),
  goalDifference: (json['goalDifference'] as num?)?.toInt(),
  points: (json['points'] as num?)?.toInt(),
);

Map<String, dynamic> _$TeamStandingToJson(TeamStanding instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'teamLogo': instance.teamLogo,
      'rank': instance.rank,
      'played': instance.played,
      'won': instance.won,
      'drawn': instance.drawn,
      'lost': instance.lost,
      'goalsFor': instance.goalsFor,
      'goalsAgainst': instance.goalsAgainst,
      'goalDifference': instance.goalDifference,
      'points': instance.points,
    };

TournamentBracket _$TournamentBracketFromJson(Map<String, dynamic> json) =>
    TournamentBracket(
      tournamentId: (json['tournamentId'] as num).toInt(),
      tournamentName: json['tournamentName'] as String,
      bracketType: json['bracketType'] as String,
      totalRounds: (json['totalRounds'] as num).toInt(),
      rounds: (json['rounds'] as List<dynamic>)
          .map((e) => BracketRound.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TournamentBracketToJson(TournamentBracket instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'tournamentName': instance.tournamentName,
      'bracketType': instance.bracketType,
      'totalRounds': instance.totalRounds,
      'rounds': instance.rounds,
    };

BracketRound _$BracketRoundFromJson(Map<String, dynamic> json) => BracketRound(
  round: (json['round'] as num).toInt(),
  roundName: json['roundName'] as String?,
  matches: (json['matches'] as List<dynamic>)
      .map((e) => BracketMatch.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BracketRoundToJson(BracketRound instance) =>
    <String, dynamic>{
      'round': instance.round,
      'roundName': instance.roundName,
      'matches': instance.matches,
    };

BracketMatch _$BracketMatchFromJson(Map<String, dynamic> json) => BracketMatch(
  matchId: (json['matchId'] as num).toInt(),
  round: (json['round'] as num?)?.toInt(),
  roundName: json['roundName'] as String?,
  teamA: json['teamA'] as String,
  teamAId: (json['teamAId'] as num?)?.toInt(),
  teamB: json['teamB'] as String,
  teamBId: (json['teamBId'] as num?)?.toInt(),
  scoreA: (json['scoreA'] as num?)?.toInt(),
  scoreB: (json['scoreB'] as num?)?.toInt(),
  matchDate: DateTime.parse(json['matchDate'] as String),
  matchTime: json['matchTime'] as String?,
  location: json['location'] as String?,
  status: json['status'] as String,
  winnerId: (json['winnerId'] as num?)?.toInt(),
);

Map<String, dynamic> _$BracketMatchToJson(BracketMatch instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'round': instance.round,
      'roundName': instance.roundName,
      'teamA': instance.teamA,
      'teamAId': instance.teamAId,
      'teamB': instance.teamB,
      'teamBId': instance.teamBId,
      'scoreA': instance.scoreA,
      'scoreB': instance.scoreB,
      'matchDate': instance.matchDate.toIso8601String(),
      'matchTime': instance.matchTime,
      'location': instance.location,
      'status': instance.status,
      'winnerId': instance.winnerId,
    };

HeadToHead _$HeadToHeadFromJson(Map<String, dynamic> json) => HeadToHead(
  tournamentId: (json['tournamentId'] as num).toInt(),
  teamA: TeamHeadToHeadInfo.fromJson(json['teamA'] as Map<String, dynamic>),
  teamB: TeamHeadToHeadInfo.fromJson(json['teamB'] as Map<String, dynamic>),
  draws: (json['draws'] as num).toInt(),
  totalMatches: (json['totalMatches'] as num).toInt(),
  matches: (json['matches'] as List<dynamic>)
      .map((e) => HeadToHeadMatch.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HeadToHeadToJson(HeadToHead instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'teamA': instance.teamA,
      'teamB': instance.teamB,
      'draws': instance.draws,
      'totalMatches': instance.totalMatches,
      'matches': instance.matches,
    };

TeamHeadToHeadInfo _$TeamHeadToHeadInfoFromJson(Map<String, dynamic> json) =>
    TeamHeadToHeadInfo(
      teamId: (json['teamId'] as num).toInt(),
      name: json['name'] as String,
      logo: json['logo'] as String?,
      wins: (json['wins'] as num).toInt(),
      totalGoals: (json['totalGoals'] as num).toInt(),
    );

Map<String, dynamic> _$TeamHeadToHeadInfoToJson(TeamHeadToHeadInfo instance) =>
    <String, dynamic>{
      'teamId': instance.teamId,
      'name': instance.name,
      'logo': instance.logo,
      'wins': instance.wins,
      'totalGoals': instance.totalGoals,
    };

HeadToHeadMatch _$HeadToHeadMatchFromJson(Map<String, dynamic> json) =>
    HeadToHeadMatch(
      matchId: (json['matchId'] as num).toInt(),
      matchDate: DateTime.parse(json['matchDate'] as String),
      teamA: json['teamA'] as String,
      teamAId: (json['teamAId'] as num?)?.toInt(),
      scoreA: (json['scoreA'] as num?)?.toInt(),
      teamB: json['teamB'] as String,
      teamBId: (json['teamBId'] as num?)?.toInt(),
      scoreB: (json['scoreB'] as num?)?.toInt(),
      location: json['location'] as String?,
      status: json['status'] as String,
    );

Map<String, dynamic> _$HeadToHeadMatchToJson(HeadToHeadMatch instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'matchDate': instance.matchDate.toIso8601String(),
      'teamA': instance.teamA,
      'teamAId': instance.teamAId,
      'scoreA': instance.scoreA,
      'teamB': instance.teamB,
      'teamBId': instance.teamBId,
      'scoreB': instance.scoreB,
      'location': instance.location,
      'status': instance.status,
    };
