// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_rules.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleCategory _$RuleCategoryFromJson(Map<String, dynamic> json) => RuleCategory(
  category: json['category'] as String,
  categoryName: json['categoryName'] as String,
  icon: json['icon'] as String,
  description: json['description'] as String,
  rules: (json['rules'] as List<dynamic>)
      .map((e) => Rule.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RuleCategoryToJson(RuleCategory instance) =>
    <String, dynamic>{
      'category': instance.category,
      'categoryName': instance.categoryName,
      'icon': instance.icon,
      'description': instance.description,
      'rules': instance.rules,
    };

Rule _$RuleFromJson(Map<String, dynamic> json) => Rule(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  content: json['content'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
  isImportant: json['isImportant'] as bool,
);

Map<String, dynamic> _$RuleToJson(Rule instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'orderIndex': instance.orderIndex,
  'isImportant': instance.isImportant,
};

TournamentRulesResponse _$TournamentRulesResponseFromJson(
  Map<String, dynamic> json,
) => TournamentRulesResponse(
  tournamentId: (json['tournamentId'] as num).toInt(),
  tournamentName: json['tournamentName'] as String,
  sportName: json['sportName'] as String,
  rules: (json['rules'] as List<dynamic>)
      .map((e) => RuleCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TournamentRulesResponseToJson(
  TournamentRulesResponse instance,
) => <String, dynamic>{
  'tournamentId': instance.tournamentId,
  'tournamentName': instance.tournamentName,
  'sportName': instance.sportName,
  'rules': instance.rules,
};
