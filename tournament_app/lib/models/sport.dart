import 'package:json_annotation/json_annotation.dart';
import '../services/api_service.dart';

part 'sport.g.dart';

@JsonSerializable()
class Sport {
  final int id;
  final String name;
  @JsonKey(fromJson: _imageUrlFromJson)
  final String? imageUrl;
  @JsonKey(fromJson: _safeIntFromJson)
  final int tournamentCount;

  Sport({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.tournamentCount,
  });

  static String? _imageUrlFromJson(String? url) => ApiService.convertImageUrl(url);
  
  static int _safeIntFromJson(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory Sport.fromJson(Map<String, dynamic> json) => _$SportFromJson(json);
  Map<String, dynamic> toJson() => _$SportToJson(this);

  @override
  String toString() => 'Sport(id: $id, name: $name, tournamentCount: $tournamentCount)';
}
