import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Scopes để truy cập thông tin cơ bản của người dùng
    scopes: <String>[
      'email',
      'profile',
    ],
    // Thêm configuration cho development
    serverClientId: null, // Sẽ sử dụng default configuration
  );

  static String get baseUrl => AppConfig.baseUrl;

  /// Đăng nhập bằng Google
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      // Bước 1: Đăng nhập với Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return AuthResponse(
          success: false,
          message: 'Đăng nhập bị hủy',
        );
      }

      // Bước 2: Lấy authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null) {
        return AuthResponse(
          success: false,
          message: 'Không thể lấy access token từ Google',
        );
      }

      // Bước 3: Tạo mock response cho development vì chưa có backend OAuth
      return await _createMockGoogleAuthResponse(googleUser);

    } catch (error) {
      // Nếu có lỗi Google Sign-in, sử dụng mock response để development tiếp tục
      if (error.toString().contains('sign_in_failed') || error.toString().contains('ApiException')) {
        return AuthResponse(
          success: false,
          message: 'Google Sign-in chưa được cấu hình đầy đủ. Vui lòng sử dụng đăng nhập thường.',
        );
      }
      
      return AuthResponse(
        success: false,
        message: 'Lỗi đăng nhập Google: $error',
      );
    }
  }

  /// Đăng xuất khỏi Google
  static Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
  }

  /// Kiểm tra trạng thái đăng nhập Google hiện tại
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Lấy thông tin user hiện tại từ Google (nếu đã đăng nhập)
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  /// Mock Google authentication response cho development
  static Future<AuthResponse> _createMockGoogleAuthResponse(
    GoogleSignInAccount googleUser,
  ) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay

    // Tạo User object từ thông tin Google
    final user = User(
      id: 'google-${googleUser.id}',
      email: googleUser.email,
      userName: googleUser.email.split('@')[0],
      fullName: googleUser.displayName ?? 'Google User',
      phoneNumber: null, // Google không cung cấp số điện thoại mặc định
      role: 'User',
      createdAt: DateTime.now(),
      profilePictureUrl: googleUser.photoUrl,
    );

    final token = 'google-token-${DateTime.now().millisecondsSinceEpoch}';

    // Save token và user
    await AuthService.saveToken(token);
    await AuthService.saveUser(user);

    return AuthResponse(
      success: true,
      message: 'Đăng nhập Google thành công!',
      token: token,
      user: user,
    );
  }

  /// Link tài khoản hiện tại với Google
  static Future<AuthResponse> linkWithGoogle() async {
    try {
      // Kiểm tra xem user đã đăng nhập chưa
      final currentToken = await AuthService.getToken();
      if (currentToken == null) {
        return AuthResponse(
          success: false,
          message: 'Vui lòng đăng nhập trước khi liên kết tài khoản',
        );
      }

      // Đăng nhập với Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return AuthResponse(
          success: false,
          message: 'Liên kết tài khoản bị hủy',
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Gửi request link account đến backend
      final requestBody = {
        'provider': 'Google',
        'accessToken': googleAuth.accessToken,
        'googleId': googleUser.id,
        'email': googleUser.email,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/Auth/link-external-account'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $currentToken',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        return AuthResponse(
          success: false,
          message: 'Không thể liên kết tài khoản Google',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Lỗi khi liên kết với Google: $e',
      );
    }
  }

  /// Unlink Google account
  static Future<AuthResponse> unlinkGoogle() async {
    try {
      final currentToken = await AuthService.getToken();
      if (currentToken == null) {
        return AuthResponse(
          success: false,
          message: 'Vui lòng đăng nhập trước',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/Auth/unlink-external-account'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $currentToken',
        },
        body: json.encode({'provider': 'Google'}),
      );

      if (response.statusCode == 200) {
        // Đăng xuất khỏi Google
        await signOutFromGoogle();
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        return AuthResponse(
          success: false,
          message: 'Không thể hủy liên kết tài khoản Google',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Lỗi khi hủy liên kết Google: $e',
      );
    }
  }
}