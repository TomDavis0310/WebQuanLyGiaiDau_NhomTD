class PlayerModel {
  final int playerId;
  final String fullName;
  final int? number;
  final String? position;
  final String? imageUrl;
  final int teamId;
  final String? userId;

  PlayerModel({
    required this.playerId,
    required this.fullName,
    this.number,
    this.position,
    this.imageUrl,
    required this.teamId,
    this.userId,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      playerId: json['playerId'] as int,
      fullName: json['fullName'] as String,
      number: json['number'] as int?,
      position: json['position'] as String?,
      imageUrl: json['imageUrl'] as String?,
      teamId: json['teamId'] as int,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'fullName': fullName,
      'number': number,
      'position': position,
      'imageUrl': imageUrl,
      'teamId': teamId,
      'userId': userId,
    };
  }

  PlayerModel copyWith({
    int? playerId,
    String? fullName,
    int? number,
    String? position,
    String? imageUrl,
    int? teamId,
    String? userId,
  }) {
    return PlayerModel(
      playerId: playerId ?? this.playerId,
      fullName: fullName ?? this.fullName,
      number: number ?? this.number,
      position: position ?? this.position,
      imageUrl: imageUrl ?? this.imageUrl,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
    );
  }
}
