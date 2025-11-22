class RewardProduct {
  final int id;
  final String name;
  final int pointsCost;
  final String? description;
  final String? imageUrl;

  RewardProduct({
    required this.id,
    required this.name,
    required this.pointsCost,
    this.description,
    this.imageUrl,
  });

  factory RewardProduct.fromJson(Map<String, dynamic> json) {
    return RewardProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      pointsCost: json['pointsCost'] ?? 0,
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pointsCost': pointsCost,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
