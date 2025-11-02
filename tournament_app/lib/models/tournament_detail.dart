import 'package:json_annotation/json_annotation.dart';
import 'sport.dart';
import 'team.dart';
import 'match.dart';

part 'tournament_detail.g.dart';

@JsonSerializable()
class TournamentDetail {
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
  final Sport sports;
  final List<Match> matches;
  final List<Team> registeredTeams;

  TournamentDetail({
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
    required this.sports,
    required this.matches,
    required this.registeredTeams,
  });

  factory TournamentDetail.fromJson(Map<String, dynamic> json) => 
      _$TournamentDetailFromJson(json);
  Map<String, dynamic> toJson() => _$TournamentDetailToJson(this);

  int get registeredTeamsCount => registeredTeams.length;
  int get totalMatches => matches.length;
  int get completedMatches => matches.where((m) => m.status == 'completed').length;
  int get upcomingMatches => matches.where((m) => m.status == 'upcoming').length;

  @override
  String toString() => 'TournamentDetail(id: $id, name: $name)';
}
