import 'package:json_annotation/json_annotation.dart';

part 'sport.g.dart';

@JsonSerializable()
class Sport {
  final int id;
  final String name;
  final String? imageUrl;
  final int tournamentCount;

  Sport({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.tournamentCount,
  });

  factory Sport.fromJson(Map<String, dynamic> json) => _$SportFromJson(json);
  Map<String, dynamic> toJson() => _$SportToJson(this);

  @override
  String toString() => 'Sport(id: $id, name: $name, tournamentCount: $tournamentCount)';
}
