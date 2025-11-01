import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? relatedId;
  final String? relatedType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? imageUrl;
  final String? actionUrl;
  final int priority;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    this.relatedType,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.imageUrl,
    this.actionUrl,
    required this.priority,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

@JsonSerializable()
class NotificationsResponse {
  final List<NotificationModel> data;
  final int total;
  final int unreadCount;
  final int page;
  final int pageSize;
  final int totalPages;

  NotificationsResponse({
    required this.data,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsResponseToJson(this);
}

@JsonSerializable()
class NotificationType {
  final String value;
  final String label;
  final String icon;
  final String color;

  NotificationType({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  factory NotificationType.fromJson(Map<String, dynamic> json) =>
      _$NotificationTypeFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationTypeToJson(this);
}

@JsonSerializable()
class UnreadCountResponse {
  final int unreadCount;

  UnreadCountResponse({
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}
