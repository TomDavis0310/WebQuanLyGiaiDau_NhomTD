import 'package:json_annotation/json_annotation.dart';
import 'sport.dart';
import 'team.dart';
import 'match.dart';
import '../services/api_service.dart';

part 'tournament_detail.g.dart';

@JsonSerializable()
class TournamentDetail {
  final int id;
  final String name;
  final String? description;
  @JsonKey(fromJson: _imageUrlFromJson)
  final String? imageUrl;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  @JsonKey(fromJson: _safeIntFromJson)
  final int maxTeams;
  @JsonKey(fromJson: _safeIntFromJson)
  final int teamsPerGroup;
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
    required this.maxTeams,
    required this.teamsPerGroup,
    required this.registrationStatus,
    required this.sports,
    required this.matches,
    required this.registeredTeams,
  });

  static String? _imageUrlFromJson(String? url) => ApiService.convertImageUrl(url);
  
  static int _safeIntFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

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
