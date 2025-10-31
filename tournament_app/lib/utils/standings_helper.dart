import '../models/match.dart';
import '../models/team.dart';

/// Helper class to compute standings from matches
class StandingsHelper {
  /// Compute standings for a group of teams based on their matches
  static List<TeamStanding> computeStandings({
    required List<Team> teams,
    required List<Match> matches,
    String? groupName,
  }) {
    final standings = <TeamStanding>[];

    for (final team in teams) {
      final teamMatches = matches.where((m) => 
        m.teamA == team.name || m.teamB == team.name
      ).toList();

      final completedMatches = teamMatches.where((m) => 
        m.status.toLowerCase() == 'completed' && 
        m.scoreTeamA != null && 
        m.scoreTeamB != null
      ).toList();

      int wins = 0;
      int draws = 0;
      int losses = 0;
      int scored = 0;
      int conceded = 0;

      for (final match in completedMatches) {
        final isTeamA = match.teamA == team.name;
        final teamScore = isTeamA ? match.scoreTeamA! : match.scoreTeamB!;
        final opponentScore = isTeamA ? match.scoreTeamB! : match.scoreTeamA!;

        scored += teamScore;
        conceded += opponentScore;

        if (teamScore > opponentScore) {
          wins++;
        } else if (teamScore < opponentScore) {
          losses++;
        } else {
          draws++;
        }
      }

      // Points calculation: Win = 3 points, Draw = 1 point, Loss = 0 points
      final points = (wins * 3) + (draws * 1);

      standings.add(TeamStanding(
        team: team,
        matchesPlayed: completedMatches.length,
        wins: wins,
        draws: draws,
        losses: losses,
        goalsFor: scored,
        goalsAgainst: conceded,
        goalDifference: scored - conceded,
        points: points,
        groupName: groupName,
      ));
    }

    // Sort by: Points (desc), Goal Difference (desc), Goals For (desc)
    standings.sort((a, b) {
      if (a.points != b.points) return b.points.compareTo(a.points);
      if (a.goalDifference != b.goalDifference) return b.goalDifference.compareTo(a.goalDifference);
      return b.goalsFor.compareTo(a.goalsFor);
    });

    // Assign ranks
    for (int i = 0; i < standings.length; i++) {
      standings[i].rank = i + 1;
    }

    return standings;
  }

  /// Group matches by group name
  static Map<String, List<Match>> groupMatchesByGroup(List<Match> matches) {
    final grouped = <String, List<Match>>{};
    
    for (final match in matches) {
      final group = match.groupName ?? 'Chung';
      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(match);
    }

    return grouped;
  }

  /// Group teams by group (based on their matches)
  static Map<String, List<Team>> groupTeamsByGroup({
    required List<Team> teams,
    required List<Match> matches,
  }) {
    final grouped = <String, List<Team>>{};

    for (final team in teams) {
      final teamMatches = matches.where((m) =>
        m.teamA == team.name || m.teamB == team.name
      );

      if (teamMatches.isEmpty) continue;

      final firstMatch = teamMatches.first;
      final group = firstMatch.groupName ?? 'Chung';

      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(team);
    }

    return grouped;
  }

  /// Group knockout matches by round
  static Map<int, List<Match>> groupMatchesByRound(List<Match> knockoutMatches) {
    final grouped = <int, List<Match>>{};

    for (final match in knockoutMatches) {
      final round = match.round ?? 1;
      if (!grouped.containsKey(round)) {
        grouped[round] = [];
      }
      grouped[round]!.add(match);
    }

    return grouped;
  }

  /// Get round name from round number
  static String getRoundName(int round, int totalRounds) {
    if (round == totalRounds) return 'Chung kết';
    if (round == totalRounds - 1) return 'Bán kết';
    if (round == totalRounds - 2) return 'Tứ kết';
    if (round == totalRounds - 3) return 'Vòng 1/8';
    if (round == totalRounds - 4) return 'Vòng 1/16';
    return 'Vòng $round';
  }
}

/// Team Standing data class
class TeamStanding {
  final Team team;
  int rank;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;
  final String? groupName;

  TeamStanding({
    required this.team,
    this.rank = 0,
    required this.matchesPlayed,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
    this.groupName,
  });
}
