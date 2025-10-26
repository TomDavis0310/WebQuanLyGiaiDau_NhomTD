import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/sport.dart';
import '../models/tournament.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5194/api';
  
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
        Uri.parse('$baseUrl/TournamentApi/sport/$sportId'),
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
}
