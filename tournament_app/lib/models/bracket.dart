import 'match.dart';

/// Bracket (Sơ đồ loại trực tiếp) model
class Bracket {
  final int tournamentId;
  final String tournamentName;
  final List<BracketRound> rounds;

  Bracket({
    required this.tournamentId,
    required this.tournamentName,
    required this.rounds,
  });

  /// Get total number of rounds
  int get totalRounds => rounds.length;

  /// Check if bracket is complete (has champion)
  bool get isComplete {
    if (rounds.isEmpty) return false;
    final finalRound = rounds.last;
    if (finalRound.matches.isEmpty) return false;
    final finalMatch = finalRound.matches.first;
    return finalMatch.scoreTeamA != null && finalMatch.scoreTeamB != null;
  }

  /// Get champion team name (if bracket is complete)
  String? get champion {
    if (!isComplete) return null;
    final finalMatch = rounds.last.matches.first;
    if (finalMatch.scoreTeamA! > finalMatch.scoreTeamB!) {
      return finalMatch.teamA;
    } else if (finalMatch.scoreTeamB! > finalMatch.scoreTeamA!) {
      return finalMatch.teamB;
    }
    return null; // Draw (unlikely in knockout)
  }
}

/// Bracket Round (Vòng đấu trong sơ đồ loại trực tiếp)
class BracketRound {
  final int round;
  final String roundName; // e.g., "Round of 16", "Quarter-finals", "Semi-finals", "Final"
  final List<Match> matches;

  BracketRound({
    required this.round,
    required this.roundName,
    required this.matches,
  });

  /// Get localized round name
  String get localizedName {
    switch (roundName.toLowerCase()) {
      case 'final':
        return 'Chung kết';
      case 'semi-finals':
      case 'semifinals':
        return 'Bán kết';
      case 'quarter-finals':
      case 'quarterfinals':
        return 'Tứ kết';
      case 'round of 16':
        return 'Vòng 1/8';
      case 'round of 32':
        return 'Vòng 1/16';
      default:
        return 'Vòng $round';
    }
  }
}
