// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

News _$NewsFromJson(Map<String, dynamic> json) => News(
  newsId: (json['newsId'] as num).toInt(),
  title: json['title'] as String,
  summary: json['summary'] as String,
  content: json['content'] as String?,
  imageUrl: json['imageUrl'] as String,
  publishDate: DateTime.parse(json['publishDate'] as String),
  author: json['author'] as String,
  viewCount: (json['viewCount'] as num).toInt(),
  category: json['category'] as String,
  isFeatured: json['isFeatured'] as bool,
  sports: json['sports'] == null
      ? null
      : NewsSpor.fromJson(json['sports'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NewsToJson(News instance) => <String, dynamic>{
  'newsId': instance.newsId,
  'title': instance.title,
  'summary': instance.summary,
  'content': instance.content,
  'imageUrl': instance.imageUrl,
  'publishDate': instance.publishDate.toIso8601String(),
  'author': instance.author,
  'viewCount': instance.viewCount,
  'category': instance.category,
  'isFeatured': instance.isFeatured,
  'sports': instance.sports,
};

NewsSpor _$NewsSporFromJson(Map<String, dynamic> json) => NewsSpor(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$NewsSporToJson(NewsSpor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
};

NewsPagination _$NewsPaginationFromJson(Map<String, dynamic> json) =>
    NewsPagination(
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
      totalCount: (json['totalCount'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$NewsPaginationToJson(NewsPagination instance) =>
    <String, dynamic>{
      'page': instance.page,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
      'totalPages': instance.totalPages,
    };
