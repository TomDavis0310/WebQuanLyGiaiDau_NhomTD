import 'package:json_annotation/json_annotation.dart';
import 'team.dart';
import 'player_scoring.dart';

part 'match_detail.g.dart';

/// Match Detail model - Thông tin chi tiết trận đấu
@JsonSerializable()
class MatchDetail {
  final int id;
  final String teamA;
  final String teamB;
  final DateTime matchDate;
  final String? matchTime;
  final String? location;
  final int? scoreTeamA;
  final int? scoreTeamB;
  final String? groupName;
  final int? round;
  final String status;
  final TournamentInfo tournament;
  final Team? teamAInfo;
  final Team? teamBInfo;
  final List<PlayerScoring> playerScorings;

  MatchDetail({
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
    required this.status,
    required this.tournament,
    this.teamAInfo,
    this.teamBInfo,
    required this.playerScorings,
  });

  /// Check if match is live/ongoing
  bool get isLive => status.toLowerCase() == 'inprogress';

  /// Check if match is completed
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Check if match is upcoming
  bool get isUpcoming => status.toLowerCase() == 'upcoming';

  /// Get winner team name (null if not completed or draw)
  String? get winner {
    if (!isCompleted || scoreTeamA == null || scoreTeamB == null) {
      return null;
    }
    if (scoreTeamA! > scoreTeamB!) return teamA;
    if (scoreTeamB! > scoreTeamA!) return teamB;
    return 'Hòa'; // Draw
  }

  /// Get Team A scorers
  List<PlayerScoring> get teamAScorers {
    // Filter players from Team A (simplified - may need better logic)
    return playerScorings.where((ps) => 
      teamAInfo != null && ps.player.fullName.isNotEmpty
    ).toList();
  }

  /// Get Team B scorers
  List<PlayerScoring> get teamBScorers {
    // Filter players from Team B (simplified - may need better logic)
    return playerScorings.where((ps) => 
      teamBInfo != null && ps.player.fullName.isNotEmpty
    ).toList();
  }

  factory MatchDetail.fromJson(Map<String, dynamic> json) =>
      _$MatchDetailFromJson(json);

  Map<String, dynamic> toJson() => _$MatchDetailToJson(this);
}

/// Tournament Info model (nested in Match Detail)
@JsonSerializable()
class TournamentInfo {
  final int id;
  final String name;
  final String? description;
  final SportInfo sports;

  TournamentInfo({
    required this.id,
    required this.name,
    this.description,
    required this.sports,
  });

  factory TournamentInfo.fromJson(Map<String, dynamic> json) =>
      _$TournamentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentInfoToJson(this);
}

/// Sport Info model (nested in Tournament)
@JsonSerializable()
class SportInfo {
  final int id;
  final String name;
  final String? imageUrl;

  SportInfo({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory SportInfo.fromJson(Map<String, dynamic> json) =>
      _$SportInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SportInfoToJson(this);
}
