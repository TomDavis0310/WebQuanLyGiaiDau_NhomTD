// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentDetail _$TournamentDetailFromJson(Map<String, dynamic> json) =>
    TournamentDetail(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: TournamentDetail._imageUrlFromJson(json['imageUrl'] as String?),
      location: json['location'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      maxTeams: TournamentDetail._safeIntFromJson(json['maxTeams']),
      teamsPerGroup: TournamentDetail._safeIntFromJson(json['teamsPerGroup']),
      registrationStatus: json['registrationStatus'] as String,
      sports: Sport.fromJson(json['sports'] as Map<String, dynamic>),
      matches: (json['matches'] as List<dynamic>)
          .map((e) => Match.fromJson(e as Map<String, dynamic>))
          .toList(),
      registeredTeams: (json['registeredTeams'] as List<dynamic>)
          .map((e) => Team.fromJson(e as Map<String, dynamic>))
          .toList(),
      allowChampionVoting: json['allowChampionVoting'] as bool?,
      userHasVoted: json['userHasVoted'] as bool?,
      userVotedTeamName: json['userVotedTeamName'] as String?,
    );

Map<String, dynamic> _$TournamentDetailToJson(TournamentDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'location': instance.location,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'maxTeams': instance.maxTeams,
      'teamsPerGroup': instance.teamsPerGroup,
      'registrationStatus': instance.registrationStatus,
      'sports': instance.sports,
      'matches': instance.matches,
      'registeredTeams': instance.registeredTeams,
      'allowChampionVoting': instance.allowChampionVoting,
      'userHasVoted': instance.userHasVoted,
      'userVotedTeamName': instance.userVotedTeamName,
    };
