import 'package:json_annotation/json_annotation.dart';

part 'match.g.dart';

@JsonSerializable()
class Match {
  final int id;
  final String teamA;
  final String teamB;
  final DateTime matchDate;
  final String? matchTime;
  final String? location;
  final int? scoreTeamA;
  final int? scoreTeamB;
  final String? groupName; // Bảng đấu (e.g., "Bảng A", "Bảng B")
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
    if (scoreTeamA! > scoreTeamB!) return teamA;
    if (scoreTeamB! > scoreTeamA!) return teamB;
    return 'draw';
  }

  @override
  String toString() => 'Match(id: $id, $teamA vs $teamB)';
}
