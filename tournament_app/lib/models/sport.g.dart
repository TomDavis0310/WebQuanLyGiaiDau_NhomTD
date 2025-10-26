// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sport _$SportFromJson(Map<String, dynamic> json) => Sport(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String?,
  tournamentCount: (json['tournamentCount'] as num).toInt(),
);

Map<String, dynamic> _$SportToJson(Sport instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'tournamentCount': instance.tournamentCount,
};
