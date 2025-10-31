import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/sport.dart';
import '../models/tournament.dart';
import '../models/tournament_detail.dart';
import '../models/match_detail.dart';
import '../models/team_detail.dart';
import '../models/news.dart';
import '../models/player_detail.dart';
import '../models/standings.dart';
import '../models/search_result.dart';
import '../models/dashboard.dart';

class ApiService {
  // Sử dụng địa chỉ IP thực của máy tính để điện thoại có thể kết nối
  // Backend API đang chạy trên port 8080
  // IP address updated: 192.168.1.9 (check with ipconfig command)
  static const String baseUrl = 'http://192.168.1.9:8080/api';
  
  // Sports API
  static Future<ApiResponse<List<Sport>>> getSports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/SportsApi'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> sportsJson = jsonData['data'] ?? [];
          final List<Sport> sports = sportsJson
              .map((json) => Sport.fromJson(json))
              .toList();
          
          return ApiResponse<List<Sport>>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: sports,
            count: jsonData['count'],
          );
        } else {
          return ApiResponse<List<Sport>>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<List<Sport>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<Sport>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Tournament API
  static Future<ApiResponse<List<Tournament>>> getTournaments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/TournamentApi'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> tournamentsJson = jsonData['data'] ?? [];
          final List<Tournament> tournaments = tournamentsJson
              .map((json) => Tournament.fromJson(json))
              .toList();
          
          return ApiResponse<List<Tournament>>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: tournaments,
            count: jsonData['count'],
          );
        } else {
          return ApiResponse<List<Tournament>>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<List<Tournament>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<Tournament>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get Tournaments by Sport
  static Future<ApiResponse<List<Tournament>>> getTournamentsBySport(int sportId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/TournamentApi/by-sport/$sportId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> tournamentsJson = jsonData['data'] ?? [];
          final List<Tournament> tournaments = tournamentsJson
              .map((json) => Tournament.fromJson(json))
              .toList();
          
          return ApiResponse<List<Tournament>>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: tournaments,
            count: jsonData['count'],
          );
        } else {
          return ApiResponse<List<Tournament>>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<List<Tournament>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<Tournament>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get Tournament Detail
  static Future<ApiResponse<TournamentDetail>> getTournamentDetail(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/TournamentApi/$tournamentId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final tournamentDetail = TournamentDetail.fromJson(jsonData['data']);
          
          return ApiResponse<TournamentDetail>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: tournamentDetail,
          );
        } else {
          return ApiResponse<TournamentDetail>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<TournamentDetail>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<TournamentDetail>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get Match Detail
  static Future<ApiResponse<MatchDetail>> getMatchDetail(int matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/MatchesApi/$matchId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final matchDetail = MatchDetail.fromJson(jsonData['data']);
          
          return ApiResponse<MatchDetail>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: matchDetail,
          );
        } else {
          return ApiResponse<MatchDetail>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<MatchDetail>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<MatchDetail>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get Team Detail
  static Future<ApiResponse<TeamDetail>> getTeamDetail(int teamId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/TeamsApi/$teamId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final teamDetail = TeamDetail.fromJson(jsonData['data']);
          
          return ApiResponse<TeamDetail>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: teamDetail,
          );
        } else {
          return ApiResponse<TeamDetail>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<TeamDetail>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<TeamDetail>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // News API

  // Get News List with pagination and filters
  static Future<Map<String, dynamic>> getNews({
    String? category,
    bool? isFeatured,
    int? sportsId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/NewsApi');
      var queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (isFeatured != null) queryParams['isFeatured'] = isFeatured.toString();
      if (sportsId != null) queryParams['sportsId'] = sportsId.toString();

      uri = uri.replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> newsJson = jsonData['data'] ?? [];
          final List<News> news = newsJson
              .map((json) => News.fromJson(json))
              .toList();
          
          NewsPagination? pagination;
          if (jsonData['pagination'] != null) {
            pagination = NewsPagination.fromJson(jsonData['pagination']);
          }

          return {
            'success': true,
            'message': jsonData['message'] ?? 'Success',
            'data': news,
            'pagination': pagination,
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to load news',
        'data': <News>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'data': <News>[],
      };
    }
  }

  // Get Featured News
  static Future<ApiResponse<List<News>>> getFeaturedNews({int count = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/NewsApi/featured?count=$count'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> newsJson = jsonData['data'] ?? [];
          final List<News> news = newsJson
              .map((json) => News.fromJson(json))
              .toList();
          
          return ApiResponse<List<News>>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: news,
            count: jsonData['count'],
          );
        } else {
          return ApiResponse<List<News>>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<List<News>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<News>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get News Detail
  static Future<ApiResponse<News>> getNewsDetail(int newsId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/NewsApi/$newsId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final news = News.fromJson(jsonData['data']);
          
          return ApiResponse<News>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: news,
          );
        } else {
          return ApiResponse<News>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<News>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<News>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get Related News
  static Future<ApiResponse<List<News>>> getRelatedNews(int newsId, {int count = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/NewsApi/$newsId/related?count=$count'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> newsJson = jsonData['data'] ?? [];
          final List<News> news = newsJson
              .map((json) => News.fromJson(json))
              .toList();
          
          return ApiResponse<List<News>>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: news,
            count: jsonData['count'],
          );
        } else {
          return ApiResponse<List<News>>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<List<News>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<News>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Get News Categories
  static Future<ApiResponse<List<String>>> getNewsCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/NewsApi/categories'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> categoriesJson = jsonData['data'] ?? [];
          final List<String> categories = categoriesJson
              .map((cat) => cat.toString())
              .toList();
          
          return ApiResponse<List<String>>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: categories,
          );
        } else {
          return ApiResponse<List<String>>(
            success: false,
            message: jsonData['message'] ?? 'API returned false',
          );
        }
      } else {
        return ApiResponse<List<String>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<String>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Player API
  static Future<ApiResponse<PlayerDetail>> getPlayerDetail(int playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/PlayersApi/$playerId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<PlayerDetail>(
            success: true,
            message: jsonData['message'],
            data: PlayerDetail.fromJson(jsonData['data']),
          );
        } else {
          return ApiResponse<PlayerDetail>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load player detail',
          );
        }
      } else {
        return ApiResponse<PlayerDetail>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<PlayerDetail>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  static Future<Map<String, dynamic>> getPlayerMatches(
    int playerId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/PlayersApi/$playerId/matches?page=$page&pageSize=$pageSize'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final matches = (jsonData['data'] as List)
              .map((item) => PlayerMatch.fromJson(item))
              .toList();

          return {
            'success': true,
            'data': matches,
            'pagination': jsonData['pagination'],
          };
        } else {
          return {
            'success': false,
            'message': jsonData['message'] ?? 'Failed to load matches',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'HTTP Error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<ApiResponse<PlayerStatisticsSummary>> getPlayerStatisticsSummary(int playerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/PlayersApi/$playerId/statistics/summary'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<PlayerStatisticsSummary>(
            success: true,
            message: jsonData['message'],
            data: PlayerStatisticsSummary.fromJson(jsonData['data']),
          );
        } else {
          return ApiResponse<PlayerStatisticsSummary>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load statistics',
          );
        }
      } else {
        return ApiResponse<PlayerStatisticsSummary>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<PlayerStatisticsSummary>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Standings & Bracket API

  /// Get tournament standings
  static Future<ApiResponse<TournamentStandings>> getTournamentStandings(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StandingsApi/tournament/$tournamentId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final standings = TournamentStandings.fromJson(jsonData);
        
        return ApiResponse<TournamentStandings>(
          success: true,
          message: 'Standings loaded successfully',
          data: standings,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse<TournamentStandings>(
          success: false,
          message: 'Tournament not found',
        );
      } else {
        return ApiResponse<TournamentStandings>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<TournamentStandings>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get tournament bracket (knockout phase)
  static Future<ApiResponse<TournamentBracket>> getTournamentBracket(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StandingsApi/tournament/$tournamentId/bracket'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final bracket = TournamentBracket.fromJson(jsonData);
        
        return ApiResponse<TournamentBracket>(
          success: true,
          message: 'Bracket loaded successfully',
          data: bracket,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse<TournamentBracket>(
          success: false,
          message: 'Tournament not found',
        );
      } else {
        return ApiResponse<TournamentBracket>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<TournamentBracket>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get head-to-head record between two teams
  static Future<ApiResponse<HeadToHead>> getHeadToHead(
    int tournamentId, 
    int teamAId, 
    int teamBId
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StandingsApi/tournament/$tournamentId/head-to-head?teamAId=$teamAId&teamBId=$teamBId'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final headToHead = HeadToHead.fromJson(jsonData);
        
        return ApiResponse<HeadToHead>(
          success: true,
          message: 'Head-to-head loaded successfully',
          data: headToHead,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse<HeadToHead>(
          success: false,
          message: 'Teams not found',
        );
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<HeadToHead>(
          success: false,
          message: jsonData['message'] ?? 'Bad request',
        );
      } else {
        return ApiResponse<HeadToHead>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<HeadToHead>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // Search API

  /// Global search across all content types
  static Future<ApiResponse<GlobalSearchResults>> globalSearch(
    String query, {
    List<String>? types,
    int limit = 10,
  }) async {
    try {
      final typesParam = types != null && types.isNotEmpty 
          ? '&types=${types.join(',')}' 
          : '';
      
      final response = await http.get(
        Uri.parse('$baseUrl/SearchApi?query=$query$typesParam&limit=$limit'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final results = GlobalSearchResults.fromJson(jsonData);
        
        return ApiResponse<GlobalSearchResults>(
          success: true,
          message: 'Search completed successfully',
          data: results,
        );
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<GlobalSearchResults>(
          success: false,
          message: jsonData['message'] ?? 'Bad request',
        );
      } else {
        return ApiResponse<GlobalSearchResults>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<GlobalSearchResults>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get search suggestions (autocomplete)
  static Future<ApiResponse<SearchSuggestionsResponse>> getSearchSuggestions(
    String query, {
    int limit = 5,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/SearchApi/suggestions?query=$query&limit=$limit'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final suggestions = SearchSuggestionsResponse.fromJson(jsonData);
        
        return ApiResponse<SearchSuggestionsResponse>(
          success: true,
          message: 'Suggestions loaded successfully',
          data: suggestions,
        );
      } else {
        return ApiResponse<SearchSuggestionsResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<SearchSuggestionsResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get popular searches
  static Future<ApiResponse<PopularSearchesResponse>> getPopularSearches() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/SearchApi/popular'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final popular = PopularSearchesResponse.fromJson(jsonData);
        
        return ApiResponse<PopularSearchesResponse>(
          success: true,
          message: 'Popular searches loaded successfully',
          data: popular,
        );
      } else {
        return ApiResponse<PopularSearchesResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<PopularSearchesResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ========== DASHBOARD ENDPOINTS ==========

  /// Get dashboard overview
  static Future<ApiResponse<DashboardOverview>> getDashboardOverview({String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/DashboardApi/overview'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final overview = DashboardOverview.fromJson(jsonData);
          
          return ApiResponse<DashboardOverview>(
            success: true,
            message: 'Dashboard loaded successfully',
            data: overview,
          );
        } catch (e) {
          return ApiResponse<DashboardOverview>(
            success: false,
            message: 'Invalid JSON response: $e',
          );
        }
      } else if (response.statusCode == 401) {
        return ApiResponse<DashboardOverview>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        return ApiResponse<DashboardOverview>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<DashboardOverview>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get user's tournaments
  static Future<ApiResponse<MyTournamentsResponse>> getMyTournaments({
    int page = 1,
    int pageSize = 10,
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final uri = Uri.parse('$baseUrl/DashboardApi/my-tournaments')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final tournaments = MyTournamentsResponse.fromJson(jsonData);
        
        return ApiResponse<MyTournamentsResponse>(
          success: true,
          message: 'My tournaments loaded successfully',
          data: tournaments,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<MyTournamentsResponse>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        return ApiResponse<MyTournamentsResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<MyTournamentsResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get user's teams
  static Future<ApiResponse<MyTeamsResponse>> getMyTeams({String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/DashboardApi/my-teams'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final teams = MyTeamsResponse.fromJson(jsonData);
        
        return ApiResponse<MyTeamsResponse>(
          success: true,
          message: 'My teams loaded successfully',
          data: teams,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<MyTeamsResponse>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        return ApiResponse<MyTeamsResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<MyTeamsResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get upcoming matches
  static Future<ApiResponse<MatchesResponse>> getUpcomingMatches({
    int page = 1,
    int pageSize = 10,
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final uri = Uri.parse('$baseUrl/DashboardApi/upcoming-matches')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final matches = MatchesResponse.fromJson(jsonData);
        
        return ApiResponse<MatchesResponse>(
          success: true,
          message: 'Upcoming matches loaded successfully',
          data: matches,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<MatchesResponse>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        return ApiResponse<MatchesResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<MatchesResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get match history
  static Future<ApiResponse<MatchesResponse>> getMatchHistory({
    int page = 1,
    int pageSize = 10,
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final uri = Uri.parse('$baseUrl/DashboardApi/match-history')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final matches = MatchesResponse.fromJson(jsonData);
        
        return ApiResponse<MatchesResponse>(
          success: true,
          message: 'Match history loaded successfully',
          data: matches,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<MatchesResponse>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        return ApiResponse<MatchesResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<MatchesResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get activity timeline
  static Future<ApiResponse<ActivityResponse>> getActivity({
    int page = 1,
    int pageSize = 20,
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final uri = Uri.parse('$baseUrl/DashboardApi/activity')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final activity = ActivityResponse.fromJson(jsonData);
        
        return ApiResponse<ActivityResponse>(
          success: true,
          message: 'Activity loaded successfully',
          data: activity,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<ActivityResponse>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        return ApiResponse<ActivityResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<ActivityResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get user profile
  static Future<ApiResponse<Map<String, dynamic>>> getUserProfile(String token) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/Profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Profile loaded successfully',
          data: jsonData,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Update user profile
  static Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
    required String token,
    required String fullName,
    required String email,
    String? phoneNumber,
    String? bio,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber ?? '',
        'bio': bio ?? '',
      });

      final response = await http.put(
        Uri.parse('$baseUrl/Profile/update'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Profile updated successfully',
          data: jsonData,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        final Map<String, dynamic>? errorData = 
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Change password
  static Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/Profile/change-password'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Password changed successfully',
          data: jsonData,
        );
      } else if (response.statusCode == 401) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Unauthorized - Please login',
        );
      } else {
        final Map<String, dynamic>? errorData = 
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Forgot password - send reset code
  static Future<ApiResponse<Map<String, dynamic>>> forgotPassword({
    required String email,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
      };

      final body = json.encode({
        'email': email,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/Auth/forgot-password'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Reset code sent to your email',
          data: jsonData,
        );
      } else {
        final Map<String, dynamic>? errorData = 
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Reset password with code
  static Future<ApiResponse<Map<String, dynamic>>> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
      };

      final body = json.encode({
        'email': email,
        'resetCode': resetCode,
        'newPassword': newPassword,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/Auth/reset-password'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Password reset successfully',
          data: jsonData,
        );
      } else {
        final Map<String, dynamic>? errorData = 
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== TOURNAMENT MANAGEMENT APIs (Phase 2) ====================

  /// Register tournament with a team
  static Future<ApiResponse<Map<String, dynamic>>> registerTournament({
    required int tournamentId,
    required int teamId,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'tournamentId': tournamentId,
        'teamId': teamId,
        'notes': notes ?? '',
      });

      final response = await http.post(
        Uri.parse('$baseUrl/TournamentApi/$tournamentId/register'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Đăng ký thành công',
          data: jsonData,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== TEAM MANAGEMENT APIs (Phase 2) ====================

  /// Create new team
  static Future<ApiResponse<Map<String, dynamic>>> createTeam(
      Map<String, dynamic> teamData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode(teamData);

      final response = await http.post(
        Uri.parse('$baseUrl/TeamsApi'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Team created successfully',
          data: jsonData,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Update team
  static Future<ApiResponse<Map<String, dynamic>>> updateTeam(
      int teamId, Map<String, dynamic> teamData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode(teamData);

      final response = await http.put(
        Uri.parse('$baseUrl/TeamsApi/$teamId'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Team updated successfully',
          data: jsonData,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Delete team
  static Future<ApiResponse<Map<String, dynamic>>> deleteTeam(int teamId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final response = await http.delete(
        Uri.parse('$baseUrl/TeamsApi/$teamId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Team deleted successfully',
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== PLAYER MANAGEMENT APIs ====================

  /// Add new player to team
  static Future<ApiResponse<Map<String, dynamic>>> addPlayer(
      Map<String, dynamic> playerData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode(playerData);

      final response = await http.post(
        Uri.parse('$baseUrl/PlayersApi'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Player added successfully',
          data: jsonData,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Update player
  static Future<ApiResponse<Map<String, dynamic>>> updatePlayer(
      int playerId, Map<String, dynamic> playerData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode(playerData);

      final response = await http.put(
        Uri.parse('$baseUrl/PlayersApi/$playerId'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Player updated successfully',
          data: jsonData,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Delete player
  static Future<ApiResponse<Map<String, dynamic>>> deletePlayer(int playerId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final response = await http.delete(
        Uri.parse('$baseUrl/PlayersApi/$playerId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Player deleted successfully',
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== HELPER METHOD ====================

  /// Helper method to get token from storage
  static Future<String?> _getToken() async {
    // TODO: Implement token retrieval from secure storage
    // For now, return null (will be implemented with authentication)
    return null;
  }
}

