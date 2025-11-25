import 'package:json_annotation/json_annotation.dart';

part 'search_result.g.dart';

@JsonSerializable()
class GlobalSearchResults {
  final String query;
  final int totalResults;
  final SearchResultsByType results;

  GlobalSearchResults({
    required this.query,
    required this.totalResults,
    required this.results,
  });

  factory GlobalSearchResults.fromJson(Map<String, dynamic> json) =>
      _$GlobalSearchResultsFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalSearchResultsToJson(this);
}

@JsonSerializable()
class SearchResultsByType {
  final List<TeamSearchResult>? teams;
  final List<PlayerSearchResult>? players;
  final List<MatchSearchResult>? matches;
  final List<NewsSearchResult>? news;
  final List<TournamentSearchResult>? tournaments;

  SearchResultsByType({
    this.teams,
    this.players,
    this.matches,
    this.news,
    this.tournaments,
  });

  factory SearchResultsByType.fromJson(Map<String, dynamic> json) =>
      _$SearchResultsByTypeFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultsByTypeToJson(this);

  int get totalCount =>
      (teams?.length ?? 0) +
      (players?.length ?? 0) +
      (matches?.length ?? 0) +
      (news?.length ?? 0) +
      (tournaments?.length ?? 0);
}

@JsonSerializable()
class TeamSearchResult {
  final int id;
  final String name;
  final String coach;
  final String? logo;
  final String type;

  TeamSearchResult({
    required this.id,
    required this.name,
    required this.coach,
    this.logo,
    required this.type,
  });

  factory TeamSearchResult.fromJson(Map<String, dynamic> json) =>
      _$TeamSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$TeamSearchResultToJson(this);
}

@JsonSerializable()
class PlayerSearchResult {
  final int id;
  final String fullName;
  final String position;
  final int number;
  final String? teamName;
  final String? imageUrl;
  final String type;

  PlayerSearchResult({
    required this.id,
    required this.fullName,
    required this.position,
    required this.number,
    this.teamName,
    this.imageUrl,
    required this.type,
  });

  factory PlayerSearchResult.fromJson(Map<String, dynamic> json) =>
      _$PlayerSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$PlayerSearchResultToJson(this);
}

@JsonSerializable()
class MatchSearchResult {
  final int id;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamA;
  @JsonKey(fromJson: _safeStringFromJson)
  final String teamB;
  final int? scoreA;
  final int? scoreB;
  final DateTime matchDate;
  final String? location;
  final String? tournamentName;
  final String status;
  final String type;

  MatchSearchResult({
    required this.id,
    required this.teamA,
    required this.teamB,
    this.scoreA,
    this.scoreB,
    required this.matchDate,
    this.location,
    this.tournamentName,
    required this.status,
    required this.type,
  });

  factory MatchSearchResult.fromJson(Map<String, dynamic> json) =>
      _$MatchSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$MatchSearchResultToJson(this);

  static String _safeStringFromJson(dynamic value) {
    if (value is String) return value;
    if (value is int) return value.toString();
    return value?.toString() ?? '';
  }

  String get formattedDate {
    return '${matchDate.day.toString().padLeft(2, '0')}/${matchDate.month.toString().padLeft(2, '0')}/${matchDate.year}';
  }
}

@JsonSerializable()
class NewsSearchResult {
  final int id;
  final String title;
  final String? summary;
  final String? category;
  final String? imageUrl;
  final DateTime publishedDate;
  final bool isFeatured;
  final String type;

  NewsSearchResult({
    required this.id,
    required this.title,
    this.summary,
    this.category,
    this.imageUrl,
    required this.publishedDate,
    required this.isFeatured,
    required this.type,
  });

  factory NewsSearchResult.fromJson(Map<String, dynamic> json) =>
      _$NewsSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$NewsSearchResultToJson(this);
}

@JsonSerializable()
class TournamentSearchResult {
  final int id;
  final String name;
  final String? description;
  final String? location;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final String? sportName;
  final String status;
  final String type;

  TournamentSearchResult({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.sportName,
    required this.status,
    required this.type,
  });

  factory TournamentSearchResult.fromJson(Map<String, dynamic> json) =>
      _$TournamentSearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentSearchResultToJson(this);
}

@JsonSerializable()
class SearchSuggestion {
  final String text;
  final String type;
  final int id;
  final String? subtitle;

  SearchSuggestion({
    required this.text,
    required this.type,
    required this.id,
    this.subtitle,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$SearchSuggestionToJson(this);
}

@JsonSerializable()
class SearchSuggestionsResponse {
  final String query;
  final List<SearchSuggestion> suggestions;

  SearchSuggestionsResponse({
    required this.query,
    required this.suggestions,
  });

  factory SearchSuggestionsResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchSuggestionsResponseToJson(this);
}

@JsonSerializable()
class PopularSearchesResponse {
  final List<SearchSuggestion> popularSearches;

  PopularSearchesResponse({
    required this.popularSearches,
  });

  factory PopularSearchesResponse.fromJson(Map<String, dynamic> json) =>
      _$PopularSearchesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PopularSearchesResponseToJson(this);
}
