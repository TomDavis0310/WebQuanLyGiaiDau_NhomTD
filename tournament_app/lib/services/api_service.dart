import 'dart:convert';
import 'dart:io';
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
import '../models/tournament_statistics.dart';
import '../models/tournament_rules.dart';
import '../models/notification.dart';

class ApiService {
  // Sử dụng địa chỉ IP thực của máy tính để điện thoại có thể kết nối
  // Backend API đang chạy trên port 8080
  // IP address updated: 192.168.1.142 (check with ipconfig command)
  static const String baseUrl = 'http://192.168.1.142:8080/api';
  static const String baseWebUrl = 'http://192.168.1.142:8080';
  
  /// Convert relative image URLs to absolute URLs
  static String? convertImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // Normalize path separators
    String normalizedUrl = imageUrl.replaceAll('\\', '/');
    
    if (normalizedUrl.startsWith('http')) return normalizedUrl;
    if (normalizedUrl.startsWith('/')) return '$baseWebUrl$normalizedUrl';
    return '$baseWebUrl/$normalizedUrl';
  }
  
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
          try {
            final tournamentDetail = TournamentDetail.fromJson(jsonData['data']);
            
            return ApiResponse<TournamentDetail>(
              success: true,
              message: jsonData['message'] ?? 'Success',
              data: tournamentDetail,
            );
          } catch (e) {
            // Log the problematic JSON for debugging
            print('TournamentDetail parsing error: $e');
            print('Problematic JSON: ${jsonData['data']}');
            
            return ApiResponse<TournamentDetail>(
              success: false,
              message: 'Lỗi parse dữ liệu: $e',
            );
          }
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
      print('getTournamentDetail error: $e');
      
      // Fallback: Return mock tournament detail to prevent crash
      final mockTournament = TournamentDetail(
        id: tournamentId,
        name: 'Giải Đấu Demo',
        description: 'Giải đấu mẫu để demo ứng dụng',
        imageUrl: null,
        location: 'TP.HCM',
        startDate: DateTime.now().add(Duration(days: 7)),
        endDate: DateTime.now().add(Duration(days: 14)),
        maxTeams: 16,
        teamsPerGroup: 4,
        registrationStatus: 'upcoming',
        sports: Sport(id: 1, name: 'Bóng Rổ', tournamentCount: 1),
        matches: [],
        registeredTeams: [],
      );
      
      return ApiResponse<TournamentDetail>(
        success: true,
        message: 'Sử dụng dữ liệu demo (lỗi kết nối: $e)',
        data: mockTournament,
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
        Uri.parse('$baseUrl/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Extract data from ApiResponse wrapper
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: jsonData['message'] ?? 'Profile loaded successfully',
            data: jsonData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load profile',
          );
        }
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
    String? address,
    int? age,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'address': address,
        'age': age,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      });

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Extract data from ApiResponse wrapper
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: jsonData['message'] ?? 'Profile updated successfully',
            data: jsonData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to update profile',
          );
        }
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
        'oldPassword': currentPassword,
        'newPassword': newPassword,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/profile/change-password'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Extract data from ApiResponse wrapper
        if (jsonData['success'] == true) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: jsonData['message'] ?? 'Password changed successfully',
            data: jsonData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to change password',
          );
        }
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
        Uri.parse('$baseUrl/profile/forgot-password'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Extract data from ApiResponse wrapper
        if (jsonData['success'] == true) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: jsonData['message'] ?? 'Reset code sent to your email',
            data: jsonData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to send reset code',
          );
        }
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
        'code': resetCode,
        'newPassword': newPassword,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/profile/reset-password'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Extract data from ApiResponse wrapper
        if (jsonData['success'] == true) {
          return ApiResponse<Map<String, dynamic>>(
            success: true,
            message: jsonData['message'] ?? 'Password reset successfully',
            data: jsonData['data'],
          );
        } else {
          return ApiResponse<Map<String, dynamic>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to reset password',
          );
        }
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
  /// Add player to team  
  static Future<ApiResponse<Map<String, dynamic>>> addPlayer(
      int teamId, Map<String, dynamic> playerData) async {
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
        Uri.parse('$baseUrl/tournament-management/teams/$teamId/players'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Player added successfully',
          data: jsonData['data'],
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
        Uri.parse('$baseUrl/tournament-management/players/$playerId'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Player updated successfully',
          data: jsonData['data'],
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

  /// Get players for a specific team
  static Future<ApiResponse<List<dynamic>>> getTeamPlayers(int teamId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/tournament-management/teams/$teamId/players'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<List<dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Players loaded successfully',
          data: jsonData['data'] as List<dynamic>?,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<List<dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== TOURNAMENT REGISTRATION APIs ====================

  /// Get available tournaments for registration
  static Future<ApiResponse<List<dynamic>>> getAvailableTournaments() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/tournament-management/available-tournaments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<List<dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Tournaments loaded successfully',
          data: jsonData['data'] as List<dynamic>?,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<List<dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Register a team for a tournament
  static Future<ApiResponse<Map<String, dynamic>>> registerForTournament(
      int tournamentId, int teamId) async {
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

      final body = json.encode({'teamId': teamId});

      final response = await http.post(
        Uri.parse('$baseUrl/tournament-management/tournaments/$tournamentId/register'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Registered successfully',
          data: jsonData['data'] as Map<String, dynamic>?,
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

  /// Unregister a team from a tournament
  static Future<ApiResponse<Map<String, dynamic>>> unregisterFromTournament(
      int tournamentId, int teamId) async {
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

      final body = json.encode({'teamId': teamId});

      final response = await http.delete(
        Uri.parse('$baseUrl/tournament-management/tournaments/$tournamentId/register'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final jsonData = response.body.isNotEmpty 
            ? json.decode(response.body) 
            : {'success': true, 'message': 'Unregistered successfully'};
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Unregistered successfully',
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

  /// Get user's tournament registrations
  static Future<ApiResponse<List<dynamic>>> getMyRegistrations() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse<List<dynamic>>(
          success: false,
          message: 'Not authenticated',
        );
      }

      final headers = {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/tournament-management/my-registrations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ApiResponse<List<dynamic>>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Registrations loaded successfully',
          data: jsonData['data'] as List<dynamic>?,
        );
      } else {
        final Map<String, dynamic>? errorData =
            response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse<List<dynamic>>(
          success: false,
          message: errorData?['message'] ?? 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<dynamic>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== STATISTICS API ====================

  /// Get top scorers for a tournament
  static Future<ApiResponse<List<TopScorer>>> getTopScorers(
    int tournamentId, {
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StatisticsApi/tournament/$tournamentId/top-scorers?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> scorersJson = jsonData['data'] ?? [];
          final List<TopScorer> scorers = scorersJson
              .map((json) => TopScorer.fromJson(json))
              .toList();

          return ApiResponse<List<TopScorer>>(
            success: true,
            message: jsonData['message'],
            data: scorers,
            count: jsonData['count'],
          );
        } else {
          return ApiResponse<List<TopScorer>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load top scorers',
          );
        }
      } else {
        return ApiResponse<List<TopScorer>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<TopScorer>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get team statistics for a tournament
  static Future<ApiResponse<List<TeamStatistics>>> getTeamStatistics(
      int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StatisticsApi/tournament/$tournamentId/team-stats'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> statsJson = jsonData['data'] ?? [];
          final List<TeamStatistics> stats = statsJson
              .map((json) => TeamStatistics.fromJson(json))
              .toList();

          return ApiResponse<List<TeamStatistics>>(
            success: true,
            message: jsonData['message'],
            data: stats,
            count: jsonData['count'],
          );
        } else {
          return ApiResponse<List<TeamStatistics>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load team statistics',
          );
        }
      } else {
        return ApiResponse<List<TeamStatistics>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<TeamStatistics>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get match statistics for a tournament
  static Future<ApiResponse<MatchStatistics>> getMatchStatistics(
      int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StatisticsApi/tournament/$tournamentId/match-stats'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<MatchStatistics>(
            success: true,
            message: jsonData['message'],
            data: MatchStatistics.fromJson(jsonData['data']),
          );
        } else {
          return ApiResponse<MatchStatistics>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load match statistics',
          );
        }
      } else {
        return ApiResponse<MatchStatistics>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<MatchStatistics>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get tournament overview with statistics
  static Future<ApiResponse<TournamentOverview>> getTournamentOverview(
      int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/StatisticsApi/tournament/$tournamentId/overview'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<TournamentOverview>(
            success: true,
            message: jsonData['message'],
            data: TournamentOverview.fromJson(jsonData['data']),
          );
        } else {
          return ApiResponse<TournamentOverview>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load tournament overview',
          );
        }
      } else {
        return ApiResponse<TournamentOverview>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<TournamentOverview>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== TOURNAMENT RULES API ====================

  /// Get all rules for a tournament
  static Future<ApiResponse<TournamentRulesResponse>> getTournamentRules(
      int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rules/$tournamentId'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<TournamentRulesResponse>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: TournamentRulesResponse.fromJson(jsonData['data']),
          );
        } else {
          return ApiResponse<TournamentRulesResponse>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load rules',
          );
        }
      } else {
        return ApiResponse<TournamentRulesResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<TournamentRulesResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get rules by category for a tournament
  static Future<ApiResponse<RuleCategory>> getRulesByCategory(
      int tournamentId, String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rules/$tournamentId/category/$category'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<RuleCategory>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: RuleCategory.fromJson(jsonData['data']),
          );
        } else {
          return ApiResponse<RuleCategory>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load category rules',
          );
        }
      } else {
        return ApiResponse<RuleCategory>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<RuleCategory>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== NOTIFICATIONS API ====================

  /// Get notifications with optional filters
  static Future<ApiResponse<NotificationsResponse>> getNotifications({
    String? type,
    bool? isRead,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (isRead != null) queryParams['isRead'] = isRead.toString();

      final uri = Uri.parse('$baseUrl/notifications')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<NotificationsResponse>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: NotificationsResponse.fromJson(jsonData),
          );
        } else {
          return ApiResponse<NotificationsResponse>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load notifications',
          );
        }
      } else {
        return ApiResponse<NotificationsResponse>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<NotificationsResponse>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get a single notification by ID
  static Future<ApiResponse<NotificationModel>> getNotification(
      int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$id'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<NotificationModel>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: NotificationModel.fromJson(jsonData['data']),
          );
        } else {
          return ApiResponse<NotificationModel>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load notification',
          );
        }
      } else if (response.statusCode == 404) {
        return ApiResponse<NotificationModel>(
          success: false,
          message: 'Notification not found',
        );
      } else {
        return ApiResponse<NotificationModel>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<NotificationModel>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Mark a notification as read
  static Future<ApiResponse<void>> markNotificationAsRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<void>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Marked as read',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Mark a notification as unread
  static Future<ApiResponse<void>> markNotificationAsUnread(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$id/unread'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<void>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Marked as unread',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Mark all notifications as read
  static Future<ApiResponse<int>> markAllNotificationsAsRead() async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<int>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Marked all as read',
          data: jsonData['count'] ?? 0,
        );
      } else {
        return ApiResponse<int>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Delete a notification
  static Future<ApiResponse<void>> deleteNotification(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$id'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<void>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Deleted',
        );
      } else {
        return ApiResponse<void>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Delete all notifications
  static Future<ApiResponse<int>> deleteAllNotifications() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/delete-all'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<int>(
          success: jsonData['success'] ?? true,
          message: jsonData['message'] ?? 'Deleted all',
          data: jsonData['count'] ?? 0,
        );
      } else {
        return ApiResponse<int>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get unread notifications count
  static Future<ApiResponse<int>> getUnreadNotificationsCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread-count'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return ApiResponse<int>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: jsonData['data']['unreadCount'] ?? 0,
          );
        } else {
          return ApiResponse<int>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load count',
          );
        }
      } else {
        return ApiResponse<int>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  /// Get notification types
  static Future<ApiResponse<List<NotificationType>>> getNotificationTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/types'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> typesJson = jsonData['data'] ?? [];
          final types = typesJson
              .map((json) => NotificationType.fromJson(json))
              .toList();

          return ApiResponse<List<NotificationType>>(
            success: true,
            message: jsonData['message'] ?? 'Success',
            data: types,
          );
        } else {
          return ApiResponse<List<NotificationType>>(
            success: false,
            message: jsonData['message'] ?? 'Failed to load types',
          );
        }
      } else {
        return ApiResponse<List<NotificationType>>(
          success: false,
          message: 'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<List<NotificationType>>(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ==================== VOTING API ====================

  /// Vote for tournament champion
  static Future<ApiResponse<Map<String, dynamic>>> voteTournamentChampion({
    required int tournamentId,
    required String votedTeamName,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/VotingApi/tournament'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'tournamentId': tournamentId,
          'votedTeamName': votedTeamName,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? 'Unknown error',
          data: jsonData['data'],
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

  /// Vote for match winner
  static Future<ApiResponse<Map<String, dynamic>>> voteMatchWinner({
    required int matchId,
    required String votedTeam,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/VotingApi/match'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'matchId': matchId,
          'votedTeam': votedTeam,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? 'Unknown error',
          data: jsonData['data'],
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

  /// Get user's tournament vote
  static Future<ApiResponse<Map<String, dynamic>>> getTournamentVote({
    required int tournamentId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/VotingApi/tournament/$tournamentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? 'Unknown error',
          data: jsonData['data'],
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

  /// Get user's match vote
  static Future<ApiResponse<Map<String, dynamic>>> getMatchVote({
    required int matchId,
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/VotingApi/match/$matchId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? 'Unknown error',
          data: jsonData['data'],
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

  /// Get tournament voting statistics
  static Future<ApiResponse<Map<String, dynamic>>> getTournamentVoteStatistics(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/VotingApi/tournament/$tournamentId/statistics'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? 'Unknown error',
          data: jsonData['data'],
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

  /// Get match voting statistics
  static Future<ApiResponse<Map<String, dynamic>>> getMatchVoteStatistics(int matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/VotingApi/match/$matchId/statistics'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? 'Unknown error',
          data: jsonData['data'],
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

  // ==================== IMAGE UPLOAD ====================

  /// Upload image to server
  /// uploadType: 'ProfileImage', 'TeamLogo', 'PlayerPhoto', etc.
  static Future<ApiResponse<Map<String, dynamic>>> uploadImage({
    required File file,
    required String uploadType,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/ImageUpload/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add upload type field
      request.fields['uploadType'] = uploadType;

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? 'Upload successful',
          data: jsonData['data'],
        );
      } else {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: jsonData['message'] ?? 'Upload failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error uploading image: $e',
      );
    }
  }

  // ==================== YOUTUBE API ====================

  /// Search YouTube videos
  static Future<ApiResponse<Map<String, dynamic>>> searchVideos({
    required String query,
    int maxResults = 10,
    String type = 'video',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/YouTubeApi/search').replace(
        queryParameters: {
          'query': query,
          'maxResults': maxResults.toString(),
          'type': type,
        },
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? '',
          data: jsonData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Failed to search videos: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error searching videos: $e',
      );
    }
  }

  /// Search highlight videos
  static Future<ApiResponse<Map<String, dynamic>>> searchHighlights({
    required String query,
    int maxResults = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/YouTubeApi/highlights').replace(
        queryParameters: {
          'query': query,
          'maxResults': maxResults.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse<Map<String, dynamic>>(
          success: jsonData['success'] ?? false,
          message: jsonData['message'] ?? '',
          data: jsonData['data'],
        );
      } else {
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: 'Failed to search highlights: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Error searching highlights: $e',
      );
    }
  }

  /// Get match videos by match ID
  static Future<ApiResponse<List<Map<String, dynamic>>>> getMatchVideos(int matchId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/YouTubeApi/match/$matchId/videos'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> videos = jsonData['data'] ?? [];
          final List<Map<String, dynamic>> videosList = videos.cast<Map<String, dynamic>>();
          return ApiResponse<List<Map<String, dynamic>>>(
            success: true,
            message: jsonData['message'] ?? '',
            data: videosList,
          );
        }
      }
      
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: 'Failed to fetch match videos',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: 'Error fetching match videos: $e',
        data: [],
      );
    }
  }

  /// Get tournament highlights
  static Future<ApiResponse<List<Map<String, dynamic>>>> getTournamentHighlights(int tournamentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/YouTubeApi/tournament/$tournamentId/highlights'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          final List<dynamic> videos = jsonData['data'] ?? [];
          final List<Map<String, dynamic>> videosList = videos.cast<Map<String, dynamic>>();
          return ApiResponse<List<Map<String, dynamic>>>(
            success: true,
            message: jsonData['message'] ?? '',
            data: videosList,
          );
        }
      }
      
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: 'Failed to fetch tournament highlights',
        data: [],
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(
        success: false,
        message: 'Error fetching tournament highlights: $e',
        data: [],
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

