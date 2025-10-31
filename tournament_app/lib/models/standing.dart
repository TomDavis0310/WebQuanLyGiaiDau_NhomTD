/// Standing (Bảng xếp hạng) model
class Standing {
  final int standingId;
  final int tournamentId;
  final String? groupName;
  final String? description;
  final DateTime lastUpdated;
  final List<StandingDetail> standingDetails;

  Standing({
    required this.standingId,
    required this.tournamentId,
    this.groupName,
    this.description,
    required this.lastUpdated,
    required this.standingDetails,
  });
}

/// Standing Detail (Chi tiết xếp hạng của từng đội) model
class StandingDetail {
  final int id;
  final int standingId;
  final int teamId;
  final String teamName;
  final String? teamLogoUrl;
  final int numberOfWins;
  final int numberOfLoses;
  final int numberOfDraws;
  final int? pointsScored;
  final int? pointsAgainst;
  final int? rank;
  final int? totalPoints;

  StandingDetail({
    required this.id,
    required this.standingId,
    required this.teamId,
    required this.teamName,
    this.teamLogoUrl,
    required this.numberOfWins,
    required this.numberOfLoses,
    required this.numberOfDraws,
    this.pointsScored,
    this.pointsAgainst,
    this.rank,
    this.totalPoints,
  });

  /// Computed: Point Difference (Hiệu số)
  int? get pointDifference {
    if (pointsScored == null || pointsAgainst == null) return null;
    return pointsScored! - pointsAgainst!;
  }

  /// Computed: Total matches played
  int get matchesPlayed => numberOfWins + numberOfLoses + numberOfDraws;

  /// Computed: Win percentage
  double get winPercentage {
    if (matchesPlayed == 0) return 0;
    return (numberOfWins / matchesPlayed) * 100;
  }
}
