class PlayerModel {
  final int id;
  final String name;
  final int? jerseyNumber;
  final String? position;
  final DateTime? dateOfBirth;
  final String? nationality;
  final double? height;
  final double? weight;
  final String? photoUrl;
  final int teamId;
  final String? teamName;

  PlayerModel({
    required this.id,
    required this.name,
    this.jerseyNumber,
    this.position,
    this.dateOfBirth,
    this.nationality,
    this.height,
    this.weight,
    this.photoUrl,
    required this.teamId,
    this.teamName,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      jerseyNumber: json['jerseyNumber'] as int?,
      position: json['position'] as String?,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      nationality: json['nationality'] as String?,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      photoUrl: json['photoUrl'] as String?,
      teamId: json['teamId'] as int,
      teamName: json['teamName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'jerseyNumber': jerseyNumber,
      'position': position,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'nationality': nationality,
      'height': height,
      'weight': weight,
      'photoUrl': photoUrl,
      'teamId': teamId,
      'teamName': teamName,
    };
  }

  PlayerModel copyWith({
    int? id,
    String? name,
    int? jerseyNumber,
    String? position,
    DateTime? dateOfBirth,
    String? nationality,
    double? height,
    double? weight,
    String? photoUrl,
    int? teamId,
    String? teamName,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      position: position ?? this.position,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationality: nationality ?? this.nationality,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
    );
  }
}
