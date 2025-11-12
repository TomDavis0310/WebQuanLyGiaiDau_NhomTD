import 'package:json_annotation/json_annotation.dart';
import 'player_scoring.dart'; // Player model
import '../services/api_service.dart';

part 'team_detail.g.dart';

/// Team Detail model - Thông tin chi tiết đội bóng
@JsonSerializable()
class TeamDetail {
  final int teamId;
  final String name;
  final String? coach;
  @JsonKey(fromJson: _logoUrlFromJson)
  final String? logoUrl;
  final String? userId;
  final List<Player> players;
  final List<MatchHistory>? matchHistory;

  TeamDetail({
    required this.teamId,
    required this.name,
    this.coach,
    this.logoUrl,
    this.userId,
    required this.players,
    this.matchHistory,
  });

  static String? _logoUrlFromJson(String? url) => ApiService.convertImageUrl(url);

  factory TeamDetail.fromJson(Map<String, dynamic> json) =>
      _$TeamDetailFromJson(json);

  Map<String, dynamic> toJson() => _$TeamDetailToJson(this);

  // Computed properties
  int get playerCount => players.length;
  int get totalMatches => matchHistory?.length ?? 0;
  int get wins => matchHistory
          ?.where((m) => m.isWin(name))
          .length ?? 0;
  int get losses => matchHistory
          ?.where((m) => m.isLoss(name))
          .length ?? 0;
  int get draws => matchHistory
          ?.where((m) => m.isDraw)
          .length ?? 0;
}

/// Match History model - Lịch sử thi đấu
@JsonSerializable()
class MatchHistory {
  final int id;
  final String teamA;
  final String teamB;
  final DateTime matchDate;
  final int? scoreTeamA;
  final int? scoreTeamB;
  final TournamentInfo tournament;

  MatchHistory({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.matchDate,
    this.scoreTeamA,
    this.scoreTeamB,
    required this.tournament,
  });

  factory MatchHistory.fromJson(Map<String, dynamic> json) =>
      _$MatchHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$MatchHistoryToJson(this);

  // Helper methods
  bool isWin(String teamName) {
    if (scoreTeamA == null || scoreTeamB == null) return false;
    if (teamName == teamA) return scoreTeamA! > scoreTeamB!;
    if (teamName == teamB) return scoreTeamB! > scoreTeamA!;
    return false;
  }

  bool isLoss(String teamName) {
    if (scoreTeamA == null || scoreTeamB == null) return false;
    if (teamName == teamA) return scoreTeamA! < scoreTeamB!;
    if (teamName == teamB) return scoreTeamB! < scoreTeamA!;
    return false;
  }

  bool get isDraw {
    if (scoreTeamA == null || scoreTeamB == null) return false;
    return scoreTeamA == scoreTeamB;
  }

  String getOpponent(String teamName) {
    return teamName == teamA ? teamB : teamA;
  }

  String getResult(String teamName) {
    if (scoreTeamA == null || scoreTeamB == null) return 'TBD';
    if (isWin(teamName)) return 'W';
    if (isLoss(teamName)) return 'L';
    if (isDraw) return 'D';
    return '-';
  }

  String getScore(String teamName) {
    if (scoreTeamA == null || scoreTeamB == null) return '-';
    if (teamName == teamA) return '$scoreTeamA - $scoreTeamB';
    return '$scoreTeamB - $scoreTeamA';
  }
}

/// Tournament Info (simplified)
@JsonSerializable()
class TournamentInfo {
  final String name;
  final String sportsName;

  TournamentInfo({
    required this.name,
    required this.sportsName,
  });

  factory TournamentInfo.fromJson(Map<String, dynamic> json) =>
      _$TournamentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentInfoToJson(this);
}
