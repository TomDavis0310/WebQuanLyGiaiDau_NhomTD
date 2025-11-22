class RewardTransaction {
  final int id;
  final DateTime transactionDate;
  final int pointsSpent;
  final String redemptionCode;
  final String status;
  final String? notes;
  final RewardProductInfo product;

  RewardTransaction({
    required this.id,
    required this.transactionDate,
    required this.pointsSpent,
    required this.redemptionCode,
    required this.status,
    this.notes,
    required this.product,
  });

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    return RewardTransaction(
      id: json['id'] ?? 0,
      transactionDate: DateTime.parse(json['transactionDate'] ?? DateTime.now().toIso8601String()),
      pointsSpent: json['pointsSpent'] ?? 0,
      redemptionCode: json['redemptionCode'] ?? '',
      status: json['status'] ?? 'Pending',
      notes: json['notes'],
      product: RewardProductInfo.fromJson(json['product'] ?? {}),
    );
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'completed':
        return 'Đã hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}

class RewardProductInfo {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  RewardProductInfo({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory RewardProductInfo.fromJson(Map<String, dynamic> json) {
    return RewardProductInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}
