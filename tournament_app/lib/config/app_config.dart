import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // Default IP address - change this if the default changes
  static const String _defaultIp = '10.15.10.42';
  static const String _port = '8080';
  static const String _prefKeyIp = 'server_ip';
  
  static String _currentIp = _defaultIp;
  
  // Getters for URLs
  static String get baseUrl => 'http://$_currentIp:$_port/api';
  static String get baseWebUrl => 'http://$_currentIp:$_port';
  static String get hubUrl => 'http://$_currentIp:$_port/matchHub';
  
  static String get currentIp => _currentIp;

  /// Load configuration from SharedPreferences
  static Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentIp = prefs.getString(_prefKeyIp) ?? _defaultIp;
      print('AppConfig: Loaded IP $_currentIp');
    } catch (e) {
      print('AppConfig: Error loading config: $e');
      _currentIp = _defaultIp;
    }
  }

  /// Update the IP address and save to SharedPreferences
  static Future<void> updateIp(String newIp) async {
    if (newIp.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyIp, newIp);
      _currentIp = newIp;
      print('AppConfig: Updated IP to $_currentIp');
    } catch (e) {
      print('AppConfig: Error saving config: $e');
    }
  }
  
  /// Reset IP to default
  static Future<void> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyIp);
      _currentIp = _defaultIp;
      print('AppConfig: Reset IP to default $_defaultIp');
    } catch (e) {
      print('AppConfig: Error resetting config: $e');
    }
  }
}
