class PointsHistory {
  final String type; // 'earn' or 'spend'
  final DateTime date;
  final int points;
  final String description;
  final Map<String, dynamic>? details;

  PointsHistory({
    required this.type,
    required this.date,
    required this.points,
    required this.description,
    this.details,
  });

  factory PointsHistory.fromJson(Map<String, dynamic> json) {
    return PointsHistory(
      type: json['type'] ?? 'earn',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      details: json['details'],
    );
  }

  bool get isEarn => type == 'earn';
  bool get isSpend => type == 'spend';
}

class PointsStatistics {
  final int currentPoints;
  final int totalEarned;
  final int totalSpent;
  final int totalRewards;
  final int totalVotes;
  final int userRank;

  PointsStatistics({
    required this.currentPoints,
    required this.totalEarned,
    required this.totalSpent,
    required this.totalRewards,
    required this.totalVotes,
    required this.userRank,
  });

  factory PointsStatistics.fromJson(Map<String, dynamic> json) {
    return PointsStatistics(
      currentPoints: json['currentPoints'] ?? 0,
      totalEarned: json['totalEarned'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
      totalRewards: json['totalRewards'] ?? 0,
      totalVotes: json['totalVotes'] ?? 0,
      userRank: json['userRank'] ?? 0,
    );
  }
}
