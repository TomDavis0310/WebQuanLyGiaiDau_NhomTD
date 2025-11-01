class TournamentForRegistration {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final int? maxTeams;
  final String? format;
  final String? status;
  final String? imageUrl;
  final int registeredTeamsCount;
  final bool hasAvailableSlots;

  TournamentForRegistration({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.location,
    this.maxTeams,
    this.format,
    this.status,
    this.imageUrl,
    this.registeredTeamsCount = 0,
    this.hasAvailableSlots = true,
  });

  factory TournamentForRegistration.fromJson(Map<String, dynamic> json) {
    return TournamentForRegistration(
      id: json['id'] as int,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String?,
      maxTeams: json['maxTeams'] as int?,
      format: json['format'] as String?,
      status: json['status'] as String?,
      imageUrl: json['imageUrl'] as String?,
      registeredTeamsCount: json['registeredTeamsCount'] as int? ?? 0,
      hasAvailableSlots: json['hasAvailableSlots'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'maxTeams': maxTeams,
      'format': format,
      'status': status,
      'imageUrl': imageUrl,
      'registeredTeamsCount': registeredTeamsCount,
      'hasAvailableSlots': hasAvailableSlots,
    };
  }
}

class MyTournamentRegistration {
  final int id;
  final String tournamentName;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final String? status;
  final int teamId;
  final String teamName;
  final DateTime registeredAt;

  MyTournamentRegistration({
    required this.id,
    required this.tournamentName,
    required this.startDate,
    required this.endDate,
    this.location,
    this.status,
    required this.teamId,
    required this.teamName,
    required this.registeredAt,
  });

  factory MyTournamentRegistration.fromJson(Map<String, dynamic> json) {
    return MyTournamentRegistration(
      id: json['id'] as int,
      tournamentName: json['tournamentName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String?,
      status: json['status'] as String?,
      teamId: json['teamId'] as int,
      teamName: json['teamName'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentName': tournamentName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'location': location,
      'status': status,
      'teamId': teamId,
      'teamName': teamName,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }
}
