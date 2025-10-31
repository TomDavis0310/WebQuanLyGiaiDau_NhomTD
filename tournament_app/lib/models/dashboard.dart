import 'package:json_annotation/json_annotation.dart';

part 'dashboard.g.dart';

/// Dashboard Overview Response
@JsonSerializable()
class DashboardOverview {
  final DashboardStats stats;
  final List<UserTeam> myTeams;
  final List<UserTournament> myTournaments;
  final List<UpcomingMatch> upcomingMatches;

  DashboardOverview({
    required this.stats,
    required this.myTeams,
    required this.myTournaments,
    required this.upcomingMatches,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) =>
      _$DashboardOverviewFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardOverviewToJson(this);
}

/// Dashboard Statistics
@JsonSerializable()
class DashboardStats {
  final int totalTeams;
  final int totalTournaments;
  final int upcomingMatchesCount;
  final int activeTournaments;

  DashboardStats({
    required this.totalTeams,
    required this.totalTournaments,
    required this.upcomingMatchesCount,
    required this.activeTournaments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsToJson(this);
}

/// User Team
@JsonSerializable()
class UserTeam {
  final int teamId;
  final String name;
  final String? coach;
  final String? logo;
  final int playersCount;
  final List<TeamPlayer>? players;

  UserTeam({
    required this.teamId,
    required this.name,
    this.coach,
    this.logo,
    required this.playersCount,
    this.players,
  });

  factory UserTeam.fromJson(Map<String, dynamic> json) =>
      _$UserTeamFromJson(json);

  Map<String, dynamic> toJson() => _$UserTeamToJson(this);
}

/// Team Player (simplified)
@JsonSerializable()
class TeamPlayer {
  final int playerId;
  final String fullName;
  final String? position;
  final int? number;
  final String? imageUrl;

  TeamPlayer({
    required this.playerId,
    required this.fullName,
    this.position,
    this.number,
    this.imageUrl,
  });

  factory TeamPlayer.fromJson(Map<String, dynamic> json) =>
      _$TeamPlayerFromJson(json);

  Map<String, dynamic> toJson() => _$TeamPlayerToJson(this);
}

/// User Tournament Registration
@JsonSerializable()
class UserTournament {
  final int tournamentId;
  final String tournamentName;
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final String? sportName;
  final String? status;
  final DateTime? registrationDate;
  final String? tournamentStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final String? location;
  final String? imageUrl;

  UserTournament({
    required this.tournamentId,
    required this.tournamentName,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    this.sportName,
    this.status,
    this.registrationDate,
    this.tournamentStatus,
    this.startDate,
    this.endDate,
    this.description,
    this.location,
    this.imageUrl,
  });

  factory UserTournament.fromJson(Map<String, dynamic> json) =>
      _$UserTournamentFromJson(json);

  Map<String, dynamic> toJson() => _$UserTournamentToJson(this);

  String get formattedRegistrationDate {
    if (registrationDate == null) return '';
    return '${registrationDate!.day}/${registrationDate!.month}/${registrationDate!.year}';
  }

  String get formattedStartDate {
    if (startDate == null) return '';
    return '${startDate!.day}/${startDate!.month}/${startDate!.year}';
  }

  String get formattedEndDate {
    if (endDate == null) return '';
    return '${endDate!.day}/${endDate!.month}/${endDate!.year}';
  }
}

/// Upcoming Match
@JsonSerializable()
class UpcomingMatch {
  final int matchId;
  final String? teamA;
  final int? teamAId;
  final String? teamB;
  final int? teamBId;
  final int? scoreA;
  final int? scoreB;
  final DateTime matchDate;
  final String? matchTime;
  final String? location;
  final int? tournamentId;
  final String? tournamentName;
  final String? status;
  final bool? isMyTeamA;
  final bool? isMyTeamB;

  UpcomingMatch({
    required this.matchId,
    this.teamA,
    this.teamAId,
    this.teamB,
    this.teamBId,
    this.scoreA,
    this.scoreB,
    required this.matchDate,
    this.matchTime,
    this.location,
    this.tournamentId,
    this.tournamentName,
    this.status,
    this.isMyTeamA,
    this.isMyTeamB,
  });

  factory UpcomingMatch.fromJson(Map<String, dynamic> json) =>
      _$UpcomingMatchFromJson(json);

  Map<String, dynamic> toJson() => _$UpcomingMatchToJson(this);

  String get formattedDate {
    return '${matchDate.day}/${matchDate.month}/${matchDate.year}';
  }

  String get formattedDateTime {
    String date = formattedDate;
    if (matchTime != null && matchTime!.isNotEmpty) {
      return '$date • $matchTime';
    }
    return date;
  }

  bool get isMyMatch {
    return (isMyTeamA ?? false) || (isMyTeamB ?? false);
  }
}

/// My Tournaments Response
@JsonSerializable()
class MyTournamentsResponse {
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<UserTournament> data;

  MyTournamentsResponse({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.data,
  });

  factory MyTournamentsResponse.fromJson(Map<String, dynamic> json) =>
      _$MyTournamentsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyTournamentsResponseToJson(this);
}

/// My Teams Response
@JsonSerializable()
class MyTeamsResponse {
  final List<UserTeam> data;

  MyTeamsResponse({required this.data});

  factory MyTeamsResponse.fromJson(Map<String, dynamic> json) =>
      _$MyTeamsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyTeamsResponseToJson(this);
}

/// Matches Response
@JsonSerializable()
class MatchesResponse {
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<UpcomingMatch> data;

  MatchesResponse({
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.data,
  });

  factory MatchesResponse.fromJson(Map<String, dynamic> json) =>
      _$MatchesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MatchesResponseToJson(this);
}

/// Activity Item
@JsonSerializable()
class ActivityItem {
  final String type;
  final DateTime date;
  final String title;
  final String? description;
  final String? status;
  final int? tournamentId;
  final int? teamId;

  ActivityItem({
    required this.type,
    required this.date,
    required this.title,
    this.description,
    this.status,
    this.tournamentId,
    this.teamId,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) =>
      _$ActivityItemFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityItemToJson(this);

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

/// Activity Response
@JsonSerializable()
class ActivityResponse {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final List<ActivityItem> data;

  ActivityResponse({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.data,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) =>
      _$ActivityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityResponseToJson(this);
}
