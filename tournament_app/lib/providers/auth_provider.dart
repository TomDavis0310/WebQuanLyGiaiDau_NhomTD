import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _token != null;

  // Initialize - Check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        _token = await AuthService.getToken();
        _user = await AuthService.getUser();
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi khởi tạo: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password, bool rememberMe) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      final response = await AuthService.login(request);

      if (response.success) {
        _token = response.token;
        _user = response.user;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String userName,
    required String password,
    required String confirmPassword,
    String? fullName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        userName: userName,
        password: password,
        confirmPassword: confirmPassword,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      final response = await AuthService.register(request);

      if (response.success) {
        _token = response.token;
        _user = response.user;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng ký: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await GoogleAuthService.signInWithGoogle();

      if (response.success) {
        _token = response.token;
        _user = response.user;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi đăng nhập Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Link current account with Google
  Future<bool> linkWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await GoogleAuthService.linkWithGoogle();

      if (response.success) {
        // Refresh user info after linking
        await refreshUserInfo();
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi liên kết Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Unlink Google account
  Future<bool> unlinkGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await GoogleAuthService.unlinkGoogle();

      if (response.success) {
        // Refresh user info after unlinking
        await refreshUserInfo();
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi khi hủy liên kết Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    // Logout from Google if signed in
    if (await GoogleAuthService.isSignedIn()) {
      await GoogleAuthService.signOutFromGoogle();
    }

    await AuthService.logout();
    _user = null;
    _token = null;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }

  // Update user info
  void updateUser(User user) {
    _user = user;
    AuthService.saveUser(user);
    notifyListeners();
  }

  // Refresh user info from storage
  Future<void> refreshUserInfo() async {
    try {
      _user = await AuthService.getUser();
      _token = await AuthService.getToken();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khi làm mới thông tin: $e';
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
