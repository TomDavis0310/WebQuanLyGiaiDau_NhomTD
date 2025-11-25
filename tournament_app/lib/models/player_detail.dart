import 'package:json_annotation/json_annotation.dart';

part 'player_detail.g.dart';

@JsonSerializable()
class PlayerDetail {
  final int playerId;
  final String fullName;
  final String position;
  final int number;
  final String? imageUrl;
  final PlayerTeam? team;
  final PlayerStatistics statistics;
  final List<PlayerMatch> recentMatches;
  final List<PerformanceData> performanceData;

  PlayerDetail({
    required this.playerId,
    required this.fullName,
    required this.position,
    required this.number,
    this.imageUrl,
    this.team,
    required this.statistics,
    required this.recentMatches,
    required this.performanceData,
  });

  factory PlayerDetail.fromJson(Map<String, dynamic> json) =>
      _$PlayerDetailFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerDetailToJson(this);

  static int _safeIntFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

@JsonSerializable()
class PlayerTeam {
  final int teamId;
  final String name;
  final String? logo;
  final PlayerSport? sport;

  PlayerTeam({
    required this.teamId,
    required this.name,
    this.logo,
    this.sport,
  });

  factory PlayerTeam.fromJson(Map<String, dynamic> json) =>
      _$PlayerTeamFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerTeamToJson(this);

  static int _safeIntFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

@JsonSerializable()
class PlayerSport {
  final int id;
  final String name;
  final String? imageUrl;

  PlayerSport({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory PlayerSport.fromJson(Map<String, dynamic> json) =>
      _$PlayerSportFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerSportToJson(this);

  static int _safeIntFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

@JsonSerializable()
class PlayerStatistics {
  final int totalMatches;
  final int totalPoints;
  final double averagePoints;
  final int highestScore;

  PlayerStatistics({
    required this.totalMatches,
    required this.totalPoints,
    required this.averagePoints,
    required this.highestScore,
  });

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerStatisticsToJson(this);

  static int _safeIntFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _safeDoubleFromJson(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

@JsonSerializable()
class PlayerMatch {
  final int matchId;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamA;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamB;
  final int? scoreA;
  final int? scoreB;
  final DateTime matchDate;
  final String? location;
  final String status;
  final int points;
  final int scoringCount;

  PlayerMatch({
    required this.matchId,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
    required this.matchDate,
    this.location,
    required this.status,
    required this.points,
    required this.scoringCount,
  });

  factory PlayerMatch.fromJson(Map<String, dynamic> json) =>
      _$PlayerMatchFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerMatchToJson(this);

  String get formattedDate {
    final months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];
    return '${matchDate.day} ${months[matchDate.month - 1]}, ${matchDate.year}';
  }

  String get formattedTime {
    final hour = matchDate.hour.toString().padLeft(2, '0');
    final minute = matchDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static int _safeIntFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _safeIntFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _safeStringFromJson(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    return value?.toString() ?? '';
  }
}

@JsonSerializable()
class PerformanceData {
  final int matchId;
  final DateTime matchDate;
  final int points;

  PerformanceData({
    required this.matchId,
    required this.matchDate,
    required this.points,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) =>
      _$PerformanceDataFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceDataToJson(this);

  static int _safeIntFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

@JsonSerializable()
class PlayerStatisticsSummary {
  final int totalMatches;
  final int totalPoints;
  final double averagePoints;
  final int highestScore;
  final double winRate;
  final int currentStreak;
  final List<int> recentForm;

  PlayerStatisticsSummary({
    required this.totalMatches,
    required this.totalPoints,
    required this.averagePoints,
    required this.highestScore,
    required this.winRate,
    required this.currentStreak,
    required this.recentForm,
  });

  factory PlayerStatisticsSummary.fromJson(Map<String, dynamic> json) =>
      _$PlayerStatisticsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerStatisticsSummaryToJson(this);

  static int _safeIntFromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _safeDoubleFromJson(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
