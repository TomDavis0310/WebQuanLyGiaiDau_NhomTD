// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalSearchResults _$GlobalSearchResultsFromJson(Map<String, dynamic> json) =>
    GlobalSearchResults(
      query: json['query'] as String,
      totalResults: (json['totalResults'] as num).toInt(),
      results: SearchResultsByType.fromJson(
        json['results'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$GlobalSearchResultsToJson(
  GlobalSearchResults instance,
) => <String, dynamic>{
  'query': instance.query,
  'totalResults': instance.totalResults,
  'results': instance.results,
};

SearchResultsByType _$SearchResultsByTypeFromJson(Map<String, dynamic> json) =>
    SearchResultsByType(
      teams: (json['teams'] as List<dynamic>?)
          ?.map((e) => TeamSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      players: (json['players'] as List<dynamic>?)
          ?.map((e) => PlayerSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      matches: (json['matches'] as List<dynamic>?)
          ?.map((e) => MatchSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      news: (json['news'] as List<dynamic>?)
          ?.map((e) => NewsSearchResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      tournaments: (json['tournaments'] as List<dynamic>?)
          ?.map(
            (e) => TournamentSearchResult.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$SearchResultsByTypeToJson(
  SearchResultsByType instance,
) => <String, dynamic>{
  'teams': instance.teams,
  'players': instance.players,
  'matches': instance.matches,
  'news': instance.news,
  'tournaments': instance.tournaments,
};

TeamSearchResult _$TeamSearchResultFromJson(Map<String, dynamic> json) =>
    TeamSearchResult(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      coach: json['coach'] as String,
      logo: json['logo'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$TeamSearchResultToJson(TeamSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'coach': instance.coach,
      'logo': instance.logo,
      'type': instance.type,
    };

PlayerSearchResult _$PlayerSearchResultFromJson(Map<String, dynamic> json) =>
    PlayerSearchResult(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String,
      position: json['position'] as String,
      number: (json['number'] as num).toInt(),
      teamName: json['teamName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      type: json['type'] as String,
    );

Map<String, dynamic> _$PlayerSearchResultToJson(PlayerSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'position': instance.position,
      'number': instance.number,
      'teamName': instance.teamName,
      'imageUrl': instance.imageUrl,
      'type': instance.type,
    };

MatchSearchResult _$MatchSearchResultFromJson(Map<String, dynamic> json) =>
    MatchSearchResult(
      id: (json['id'] as num).toInt(),
      teamA: MatchSearchResult._safeStringFromJson(json['teamA']),
      teamB: MatchSearchResult._safeStringFromJson(json['teamB']),
      scoreA: (json['scoreA'] as num?)?.toInt(),
      scoreB: (json['scoreB'] as num?)?.toInt(),
      matchDate: DateTime.parse(json['matchDate'] as String),
      location: json['location'] as String?,
      tournamentName: json['tournamentName'] as String?,
      status: json['status'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$MatchSearchResultToJson(MatchSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamA': instance.teamA,
      'teamB': instance.teamB,
      'scoreA': instance.scoreA,
      'scoreB': instance.scoreB,
      'matchDate': instance.matchDate.toIso8601String(),
      'location': instance.location,
      'tournamentName': instance.tournamentName,
      'status': instance.status,
      'type': instance.type,
    };

NewsSearchResult _$NewsSearchResultFromJson(Map<String, dynamic> json) =>
    NewsSearchResult(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      summary: json['summary'] as String?,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      publishedDate: DateTime.parse(json['publishedDate'] as String),
      isFeatured: json['isFeatured'] as bool,
      type: json['type'] as String,
    );

Map<String, dynamic> _$NewsSearchResultToJson(NewsSearchResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'publishedDate': instance.publishedDate.toIso8601String(),
      'isFeatured': instance.isFeatured,
      'type': instance.type,
    };

TournamentSearchResult _$TournamentSearchResultFromJson(
  Map<String, dynamic> json,
) => TournamentSearchResult(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  imageUrl: json['imageUrl'] as String?,
  sportName: json['sportName'] as String?,
  status: json['status'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$TournamentSearchResultToJson(
  TournamentSearchResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'location': instance.location,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'imageUrl': instance.imageUrl,
  'sportName': instance.sportName,
  'status': instance.status,
  'type': instance.type,
};

SearchSuggestion _$SearchSuggestionFromJson(Map<String, dynamic> json) =>
    SearchSuggestion(
      text: json['text'] as String,
      type: json['type'] as String,
      id: (json['id'] as num).toInt(),
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$SearchSuggestionToJson(SearchSuggestion instance) =>
    <String, dynamic>{
      'text': instance.text,
      'type': instance.type,
      'id': instance.id,
      'subtitle': instance.subtitle,
    };

SearchSuggestionsResponse _$SearchSuggestionsResponseFromJson(
  Map<String, dynamic> json,
) => SearchSuggestionsResponse(
  query: json['query'] as String,
  suggestions: (json['suggestions'] as List<dynamic>)
      .map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SearchSuggestionsResponseToJson(
  SearchSuggestionsResponse instance,
) => <String, dynamic>{
  'query': instance.query,
  'suggestions': instance.suggestions,
};

PopularSearchesResponse _$PopularSearchesResponseFromJson(
  Map<String, dynamic> json,
) => PopularSearchesResponse(
  popularSearches: (json['popularSearches'] as List<dynamic>)
      .map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PopularSearchesResponseToJson(
  PopularSearchesResponse instance,
) => <String, dynamic>{'popularSearches': instance.popularSearches};
