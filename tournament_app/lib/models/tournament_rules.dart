import 'package:json_annotation/json_annotation.dart';

part 'tournament_rules.g.dart';

@JsonSerializable()
class RuleCategory {
  final String category;
  final String categoryName;
  final String icon;
  final String description;
  final List<Rule> rules;

  RuleCategory({
    required this.category,
    required this.categoryName,
    required this.icon,
    required this.description,
    required this.rules,
  });

  factory RuleCategory.fromJson(Map<String, dynamic> json) =>
      _$RuleCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$RuleCategoryToJson(this);
}

@JsonSerializable()
class Rule {
  final int id;
  final String title;
  final String content;
  final int orderIndex;
  final bool isImportant;

  Rule({
    required this.id,
    required this.title,
    required this.content,
    required this.orderIndex,
    required this.isImportant,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

  Map<String, dynamic> toJson() => _$RuleToJson(this);
}

@JsonSerializable()
class TournamentRulesResponse {
  final int tournamentId;
  final String tournamentName;
  final String sportName;
  final List<RuleCategory> rules;

  TournamentRulesResponse({
    required this.tournamentId,
    required this.tournamentName,
    required this.sportName,
    required this.rules,
  });

  factory TournamentRulesResponse.fromJson(Map<String, dynamic> json) =>
      _$TournamentRulesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentRulesResponseToJson(this);
}
