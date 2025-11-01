class TeamModel {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? userId;
  final DateTime createdAt;
  final int playerCount;

  TeamModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.userId,
    required this.createdAt,
    this.playerCount = 0,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      userId: json['userId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      playerCount: json['playerCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'playerCount': playerCount,
    };
  }

  TeamModel copyWith({
    int? id,
    String? name,
    String? description,
    String? logoUrl,
    String? userId,
    DateTime? createdAt,
    int? playerCount,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      playerCount: playerCount ?? this.playerCount,
    );
  }
}
