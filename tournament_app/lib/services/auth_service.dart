import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/environment.dart';

class AuthService {
  static String get baseUrl => Environment.apiBaseUrl;
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

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        
        if (authResponse.success && authResponse.token != null) {
          // Save token and user data
          await saveToken(authResponse.token!);
          if (authResponse.user != null) {
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
      // Temporary: Return mock success for development
      // TODO: Remove this when backend Auth API is ready
      return _mockLogin(request);
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

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        return AuthResponse(
          success: false,
          message: 'Đăng ký thất bại. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      // Temporary: Return mock success for development
      // TODO: Remove this when backend Auth API is ready
      return _mockRegister(request);
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

  // Mock Login - Temporary for development
  static Future<AuthResponse> _mockLogin(LoginRequest request) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    if (request.email.isEmpty || request.password.isEmpty) {
      return AuthResponse(
        success: false,
        message: 'Email và mật khẩu không được để trống.',
      );
    }

    // Simple validation
    if (request.password.length < 6) {
      return AuthResponse(
        success: false,
        message: 'Mật khẩu phải có ít nhất 6 ký tự.',
      );
    }

    // Mock successful login
    final user = User(
      id: 'mock-user-id-${DateTime.now().millisecondsSinceEpoch}',
      email: request.email,
      userName: request.email.split('@')[0],
      fullName: 'User Demo',
      phoneNumber: '0123456789',
      role: 'User',
      createdAt: DateTime.now(),
    );

    final token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';

    // Save token and user
    await saveToken(token);
    await saveUser(user);

    return AuthResponse(
      success: true,
      message: 'Đăng nhập thành công!',
      token: token,
      user: user,
    );
  }

  // Mock Register - Temporary for development
  static Future<AuthResponse> _mockRegister(RegisterRequest request) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    // Validation
    if (request.email.isEmpty || request.userName.isEmpty || 
        request.password.isEmpty || request.confirmPassword.isEmpty) {
      return AuthResponse(
        success: false,
        message: 'Vui lòng điền đầy đủ thông tin.',
      );
    }

    if (!request.email.contains('@')) {
      return AuthResponse(
        success: false,
        message: 'Email không hợp lệ.',
      );
    }

    if (request.password.length < 6) {
      return AuthResponse(
        success: false,
        message: 'Mật khẩu phải có ít nhất 6 ký tự.',
      );
    }

    if (request.password != request.confirmPassword) {
      return AuthResponse(
        success: false,
        message: 'Mật khẩu xác nhận không khớp.',
      );
    }

    // Mock successful registration
    final user = User(
      id: 'mock-user-id-${DateTime.now().millisecondsSinceEpoch}',
      email: request.email,
      userName: request.userName,
      fullName: request.fullName,
      phoneNumber: request.phoneNumber,
      role: 'User',
      createdAt: DateTime.now(),
    );

    final token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';

    // Save token and user
    await saveToken(token);
    await saveUser(user);

    return AuthResponse(
      success: true,
      message: 'Đăng ký thành công!',
      token: token,
      user: user,
    );
  }
}
