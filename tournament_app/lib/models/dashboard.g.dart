// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardOverview _$DashboardOverviewFromJson(Map<String, dynamic> json) =>
    DashboardOverview(
      stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>),
      myTeams: (json['myTeams'] as List<dynamic>)
          .map((e) => UserTeam.fromJson(e as Map<String, dynamic>))
          .toList(),
      myTournaments: (json['myTournaments'] as List<dynamic>)
          .map((e) => UserTournament.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingMatches: (json['upcomingMatches'] as List<dynamic>)
          .map((e) => UpcomingMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardOverviewToJson(DashboardOverview instance) =>
    <String, dynamic>{
      'stats': instance.stats,
      'myTeams': instance.myTeams,
      'myTournaments': instance.myTournaments,
      'upcomingMatches': instance.upcomingMatches,
    };

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) =>
    DashboardStats(
      totalTeams: (json['totalTeams'] as num).toInt(),
      totalTournaments: (json['totalTournaments'] as num).toInt(),
      upcomingMatchesCount: (json['upcomingMatchesCount'] as num).toInt(),
      activeTournaments: (json['activeTournaments'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatsToJson(DashboardStats instance) =>
    <String, dynamic>{
      'totalTeams': instance.totalTeams,
      'totalTournaments': instance.totalTournaments,
      'upcomingMatchesCount': instance.upcomingMatchesCount,
      'activeTournaments': instance.activeTournaments,
    };

UserTeam _$UserTeamFromJson(Map<String, dynamic> json) => UserTeam(
  teamId: (json['teamId'] as num).toInt(),
  name: json['name'] as String,
  coach: json['coach'] as String?,
  logo: json['logo'] as String?,
  playersCount: (json['playersCount'] as num).toInt(),
  players: (json['players'] as List<dynamic>?)
      ?.map((e) => TeamPlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserTeamToJson(UserTeam instance) => <String, dynamic>{
  'teamId': instance.teamId,
  'name': instance.name,
  'coach': instance.coach,
  'logo': instance.logo,
  'playersCount': instance.playersCount,
  'players': instance.players,
};

TeamPlayer _$TeamPlayerFromJson(Map<String, dynamic> json) => TeamPlayer(
  playerId: (json['playerId'] as num).toInt(),
  fullName: json['fullName'] as String,
  position: json['position'] as String?,
  number: (json['number'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$TeamPlayerToJson(TeamPlayer instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'fullName': instance.fullName,
      'position': instance.position,
      'number': instance.number,
      'imageUrl': instance.imageUrl,
    };

UserTournament _$UserTournamentFromJson(Map<String, dynamic> json) =>
    UserTournament(
      tournamentId: (json['tournamentId'] as num).toInt(),
      tournamentName: json['tournamentName'] as String,
      teamId: (json['teamId'] as num).toInt(),
      teamName: json['teamName'] as String,
      teamLogo: json['teamLogo'] as String?,
      sportName: json['sportName'] as String?,
      status: json['status'] as String?,
      registrationDate: json['registrationDate'] == null
          ? null
          : DateTime.parse(json['registrationDate'] as String),
      tournamentStatus: json['tournamentStatus'] as String?,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      description: json['description'] as String?,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$UserTournamentToJson(UserTournament instance) =>
    <String, dynamic>{
      'tournamentId': instance.tournamentId,
      'tournamentName': instance.tournamentName,
      'teamId': instance.teamId,
      'teamName': instance.teamName,
      'teamLogo': instance.teamLogo,
      'sportName': instance.sportName,
      'status': instance.status,
      'registrationDate': instance.registrationDate?.toIso8601String(),
      'tournamentStatus': instance.tournamentStatus,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'description': instance.description,
      'location': instance.location,
      'imageUrl': instance.imageUrl,
    };

UpcomingMatch _$UpcomingMatchFromJson(Map<String, dynamic> json) =>
    UpcomingMatch(
      matchId: (json['matchId'] as num).toInt(),
      teamA: json['teamA'] as String?,
      teamAId: (json['teamAId'] as num?)?.toInt(),
      teamB: json['teamB'] as String?,
      teamBId: (json['teamBId'] as num?)?.toInt(),
      scoreA: (json['scoreA'] as num?)?.toInt(),
      scoreB: (json['scoreB'] as num?)?.toInt(),
      matchDate: DateTime.parse(json['matchDate'] as String),
      matchTime: json['matchTime'] as String?,
      location: json['location'] as String?,
      tournamentId: (json['tournamentId'] as num?)?.toInt(),
      tournamentName: json['tournamentName'] as String?,
      status: json['status'] as String?,
      isMyTeamA: json['isMyTeamA'] as bool?,
      isMyTeamB: json['isMyTeamB'] as bool?,
    );

Map<String, dynamic> _$UpcomingMatchToJson(UpcomingMatch instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'teamA': instance.teamA,
      'teamAId': instance.teamAId,
      'teamB': instance.teamB,
      'teamBId': instance.teamBId,
      'scoreA': instance.scoreA,
      'scoreB': instance.scoreB,
      'matchDate': instance.matchDate.toIso8601String(),
      'matchTime': instance.matchTime,
      'location': instance.location,
      'tournamentId': instance.tournamentId,
      'tournamentName': instance.tournamentName,
      'status': instance.status,
      'isMyTeamA': instance.isMyTeamA,
      'isMyTeamB': instance.isMyTeamB,
    };

MyTournamentsResponse _$MyTournamentsResponseFromJson(
  Map<String, dynamic> json,
) => MyTournamentsResponse(
  totalCount: (json['totalCount'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  data: (json['data'] as List<dynamic>)
      .map((e) => UserTournament.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MyTournamentsResponseToJson(
  MyTournamentsResponse instance,
) => <String, dynamic>{
  'totalCount': instance.totalCount,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
  'data': instance.data,
};

MyTeamsResponse _$MyTeamsResponseFromJson(Map<String, dynamic> json) =>
    MyTeamsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => UserTeam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyTeamsResponseToJson(MyTeamsResponse instance) =>
    <String, dynamic>{'data': instance.data};

MatchesResponse _$MatchesResponseFromJson(Map<String, dynamic> json) =>
    MatchesResponse(
      totalCount: (json['totalCount'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => UpcomingMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MatchesResponseToJson(MatchesResponse instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalPages': instance.totalPages,
      'data': instance.data,
    };

ActivityItem _$ActivityItemFromJson(Map<String, dynamic> json) => ActivityItem(
  type: json['type'] as String,
  date: DateTime.parse(json['date'] as String),
  title: json['title'] as String,
  description: json['description'] as String?,
  status: json['status'] as String?,
  tournamentId: (json['tournamentId'] as num?)?.toInt(),
  teamId: (json['teamId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ActivityItemToJson(ActivityItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'date': instance.date.toIso8601String(),
      'title': instance.title,
      'description': instance.description,
      'status': instance.status,
      'tournamentId': instance.tournamentId,
      'teamId': instance.teamId,
    };

ActivityResponse _$ActivityResponseFromJson(Map<String, dynamic> json) =>
    ActivityResponse(
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => ActivityItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActivityResponseToJson(ActivityResponse instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
      'data': instance.data,
    };
