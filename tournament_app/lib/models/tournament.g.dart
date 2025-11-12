// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tournament _$TournamentFromJson(Map<String, dynamic> json) => Tournament(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  imageUrl: Tournament._imageUrlFromJson(json['imageUrl'] as String?),
  location: json['location'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  maxTeams: (json['maxTeams'] as num?)?.toInt(),
  teamsPerGroup: (json['teamsPerGroup'] as num?)?.toInt(),
  registrationStatus: json['registrationStatus'] as String,
  sportsId: (json['sportsId'] as num?)?.toInt(),
  tournamentFormatId: (json['tournamentFormatId'] as num?)?.toInt(),
  registeredTeamsCount: (json['registeredTeamsCount'] as num?)?.toInt(),
  totalMatches: (json['totalMatches'] as num?)?.toInt(),
);

Map<String, dynamic> _$TournamentToJson(Tournament instance) =>
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
      'sportsId': instance.sportsId,
      'tournamentFormatId': instance.tournamentFormatId,
      'registeredTeamsCount': instance.registeredTeamsCount,
      'totalMatches': instance.totalMatches,
    };
