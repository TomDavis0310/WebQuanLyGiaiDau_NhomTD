import 'package:json_annotation/json_annotation.dart';

part 'news.g.dart';

/// News model - Tin tức
@JsonSerializable()
class News {
  final int newsId;
  final String title;
  final String summary;
  final String? content; // Optional for list view
  final String imageUrl;
  final DateTime publishDate;
  final String author;
  final int viewCount;
  final String category;
  final bool isFeatured;
  final NewsSpor? sports;

  News({
    required this.newsId,
    required this.title,
    required this.summary,
    this.content,
    required this.imageUrl,
    required this.publishDate,
    required this.author,
    required this.viewCount,
    required this.category,
    required this.isFeatured,
    this.sports,
  });

  factory News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);
  Map<String, dynamic> toJson() => _$NewsToJson(this);

  // Computed properties
  String get formattedDate {
    final months = [
      'Th1', 'Th2', 'Th3', 'Th4', 'Th5', 'Th6',
      'Th7', 'Th8', 'Th9', 'Th10', 'Th11', 'Th12'
    ];
    return '${publishDate.day} ${months[publishDate.month - 1]}, ${publishDate.year}';
  }

  String get formattedDateTime {
    return '${publishDate.day}/${publishDate.month}/${publishDate.year} ${publishDate.hour}:${publishDate.minute.toString().padLeft(2, '0')}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

/// NewsSpor model (simplified) - Thông tin môn thể thao
@JsonSerializable()
class NewsSpor {
  final int id;
  final String name;
  final String? imageUrl;

  NewsSpor({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory NewsSpor.fromJson(Map<String, dynamic> json) =>
      _$NewsSporFromJson(json);
  Map<String, dynamic> toJson() => _$NewsSporToJson(this);
}

/// News Pagination Response
@JsonSerializable()
class NewsPagination {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  NewsPagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory NewsPagination.fromJson(Map<String, dynamic> json) =>
      _$NewsPaginationFromJson(json);
  Map<String, dynamic> toJson() => _$NewsPaginationToJson(this);

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
