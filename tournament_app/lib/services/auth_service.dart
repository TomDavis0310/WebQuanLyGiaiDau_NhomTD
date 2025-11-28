import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class AuthService {
  static String get baseUrl => AppConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Login
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/login'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(request.toJson()),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        
        if (authResponse.success && authResponse.token != null) {
          // Save token and user data
          await saveToken(authResponse.token!);
          if (authResponse.user != null) {
            print('User role from API: ${authResponse.user!.role}');
            await saveUser(authResponse.user!);
          }
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.',
        );
      }
    } catch (e) {
      print('Login error: $e');
      return AuthResponse(
        success: false,
        message: 'Lỗi kết nối: $e. Vui lòng kiểm tra backend và thử lại.',
      );
    }
  }

  // Register
  static Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/register'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode(request.toJson()),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        
        if (authResponse.success && authResponse.token != null) {
          // Save token and user data
          await saveToken(authResponse.token!);
          if (authResponse.user != null) {
            print('User role from API: ${authResponse.user!.role}');
            await saveUser(authResponse.user!);
          }
        }
        
        return authResponse;
      } else {
        return AuthResponse(
          success: false,
          message: 'Đăng ký thất bại. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      print('Register error: $e');
      return AuthResponse(
        success: false,
        message: 'Lỗi kết nối: $e. Vui lòng kiểm tra backend và thử lại.',
      );
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Save Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save User
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Get User
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Validate Token (call backend to check if token is still valid)
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/Auth/validate'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return await isLoggedIn(); // Fallback for development
    }
  }
}
