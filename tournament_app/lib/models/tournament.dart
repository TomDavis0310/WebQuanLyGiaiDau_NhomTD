import 'package:json_annotation/json_annotation.dart';

part 'tournament.g.dart';

@JsonSerializable()
class Tournament {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final int? maxTeams;
  final int? teamsPerGroup;
  final String registrationStatus;
  final int? sportsId;
  final int? tournamentFormatId;
  final int? registeredTeamsCount;
  final int? totalMatches;

  Tournament({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.location,
    required this.startDate,
    required this.endDate,
    this.maxTeams,
    this.teamsPerGroup,
    required this.registrationStatus,
    this.sportsId,
    this.tournamentFormatId,
    this.registeredTeamsCount,
    this.totalMatches,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) => _$TournamentFromJson(json);
  Map<String, dynamic> toJson() => _$TournamentToJson(this);

  @override
  String toString() => 'Tournament(id: $id, name: $name, status: $registrationStatus)';
}
