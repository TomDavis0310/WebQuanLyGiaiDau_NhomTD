import 'package:json_annotation/json_annotation.dart';

part 'match.g.dart';

@JsonSerializable()
class Match {
  @JsonKey(fromJson: _safeIntFromJson)
  final int id;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamA;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamB;
  final DateTime matchDate;
  final String? matchTime;
  final String? location;
  @JsonKey(fromJson: _safeIntFromJsonNullable)
  final int? scoreTeamA;
  @JsonKey(fromJson: _safeIntFromJsonNullable)
  final int? scoreTeamB;
  final String? groupName; // Bảng đấu (e.g., "Bảng A", "Bảng B")
  @JsonKey(fromJson: _safeIntFromJsonNullable)
  final int? round; // Vòng đấu (1, 2, 3, ...)

  Match({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.matchDate,
    this.matchTime,
    this.location,
    this.scoreTeamA,
    this.scoreTeamB,
    this.groupName,
    this.round,
  });

  static int _safeIntFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _safeIntFromJsonNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _safeStringFromJson(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    return value?.toString() ?? '';
  }

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);

  String get status {
    if (scoreTeamA != null && scoreTeamB != null) {
      return 'completed';
    } else if (matchDate.isBefore(DateTime.now())) {
      return 'ongoing';
    } else {
      return 'upcoming';
    }
  }

  String? get winner {
    if (scoreTeamA == null || scoreTeamB == null) return null;
    final scoreA = scoreTeamA!;
    final scoreB = scoreTeamB!;
    if (scoreA > scoreB) return teamA;
    if (scoreB > scoreA) return teamB;
    return 'draw';
  }

  @override
  String toString() => 'Match(id: $id, $teamA vs $teamB)';
}
