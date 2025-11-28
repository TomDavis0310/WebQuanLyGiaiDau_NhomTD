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
    final points = json['points'];
    final pointsInt = points is int ? points : (points is double ? points.toInt() : (points is String ? int.tryParse(points) ?? 0 : 0));
    
    return PointsHistory(
      type: json['type'] ?? 'earn',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      points: pointsInt,
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
    int _parseToInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return PointsStatistics(
      currentPoints: _parseToInt(json['currentPoints']),
      totalEarned: _parseToInt(json['totalEarned']),
      totalSpent: _parseToInt(json['totalSpent']),
      totalRewards: _parseToInt(json['totalRewards']),
      totalVotes: _parseToInt(json['totalVotes']),
      userRank: _parseToInt(json['userRank']),
    );
  }
}
