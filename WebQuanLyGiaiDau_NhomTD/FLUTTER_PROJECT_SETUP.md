# 📱 FLUTTER PROJECT SETUP GUIDE

## 🎯 Tạo Flutter Project cho Tournament Management

### 1. Prerequisites
```bash
# Download Flutter SDK từ: https://docs.flutter.dev/get-started/install/windows
# Extract vào: C:\flutter
# Add C:\flutter\bin vào PATH

# Verify installation
flutter doctor
```

### 2. Tạo Project
```bash
# Navigate tới thư mục development
cd D:\

# Tạo Flutter project
flutter create tournament_management_app
cd tournament_management_app

# Test project
flutter run
```

### 3. Project Structure được đề xuất
```
tournament_management_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── sport.dart
│   │   ├── tournament.dart
│   │   ├── match.dart
│   │   ├── team.dart
│   │   └── api_response.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── sports_service.dart
│   │   ├── tournament_service.dart
│   │   └── auth_service.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── sports/
│   │   │   ├── sports_list_screen.dart
│   │   │   └── sport_detail_screen.dart
│   │   ├── tournaments/
│   │   │   ├── tournament_list_screen.dart
│   │   │   └── tournament_detail_screen.dart
│   │   ├── matches/
│   │   │   ├── match_list_screen.dart
│   │   │   └── match_detail_screen.dart
│   │   ├── teams/
│   │   │   ├── team_list_screen.dart
│   │   │   └── team_detail_screen.dart
│   │   └── auth/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   └── custom_card.dart
│   │   └── sport_card.dart
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── app_colors.dart
│   │   └── date_helper.dart
│   └── providers/ (if using Provider for state management)
│       ├── sports_provider.dart
│       ├── tournament_provider.dart
│       └── auth_provider.dart
├── assets/
│   ├── images/
│   └── icons/
├── android/
├── ios/
└── pubspec.yaml
```

### 4. pubspec.yaml Configuration
```yaml
name: tournament_management_app
description: Ứng dụng quản lý giải đấu thể thao
version: 1.0.0+1

environment:
  sdk: '>=3.1.0 <4.0.0'
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter
  
  # API & Network
  http: ^1.1.0
  dio: ^5.3.2
  
  # State Management
  provider: ^6.1.1
  
  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # Navigation
  go_router: ^12.1.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # Utils
  intl: ^0.19.0
  
  # UI
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
```

### 5. API Configuration Constants
```dart
// lib/utils/constants.dart
class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5194/api'; // For Android Emulator
  // static const String baseUrl = 'http://localhost:5194/api'; // For iOS Simulator
  
  static const String sportsEndpoint = '/SportsApi';
  static const String tournamentsEndpoint = '/TournamentApi';
  static const String matchesEndpoint = '/MatchesApi';
  static const String teamsEndpoint = '/TeamsApi';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFFFF5722);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
}
```

### 6. API Response Model
```dart
// lib/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? count;
  final Pagination? pagination;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.count,
    this.pagination,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      count: json['count'],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }
}

class Pagination {
  final int currentPage;
  final int pageSize;
  final int totalRecords;
  final int totalPages;

  Pagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalRecords: json['totalRecords'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
```

### 7. Sport Model Example
```dart
// lib/models/sport.dart
class Sport {
  final int id;
  final String name;
  final String? imageUrl;
  final int? tournamentCount;

  Sport({
    required this.id,
    required this.name,
    this.imageUrl,
    this.tournamentCount,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      tournamentCount: json['tournamentCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'tournamentCount': tournamentCount,
    };
  }
}
```

### 8. API Service Base
```dart
// lib/services/api_service.dart
import 'package:dio/dio.dart';
import '../utils/constants.dart';

class ApiService {
  late Dio _dio;
  
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  Dio get dio => _dio;
  
  // Common GET method
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Common POST method
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Exception('Kết nối timeout');
        case DioExceptionType.receiveTimeout:
          return Exception('Timeout khi nhận dữ liệu');
        case DioExceptionType.badResponse:
          return Exception('Lỗi server: ${error.response?.statusCode}');
        default:
          return Exception('Lỗi kết nối mạng');
      }
    }
    return Exception('Lỗi không xác định');
  }
}
```

### 9. Sports Service Example
```dart
// lib/services/sports_service.dart
import '../models/sport.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class SportsService {
  final ApiService _apiService = ApiService();
  
  Future<List<Sport>> getAllSports() async {
    try {
      final response = await _apiService.get('/SportsApi');
      
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<List<dynamic>>.fromJson(
          response.data,
          (data) => data as List<dynamic>,
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return apiResponse.data!
              .map((json) => Sport.fromJson(json))
              .toList();
        }
      }
      
      throw Exception('Không thể lấy danh sách môn thể thao');
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách môn thể thao: $e');
    }
  }
  
  Future<Sport> getSportById(int id) async {
    try {
      final response = await _apiService.get('/SportsApi/$id');
      
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
          response.data,
          (data) => data as Map<String, dynamic>,
        );
        
        if (apiResponse.success && apiResponse.data != null) {
          return Sport.fromJson(apiResponse.data!);
        }
      }
      
      throw Exception('Không tìm thấy môn thể thao');
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin môn thể thao: $e');
    }
  }
}
```

### 10. Simple Home Screen
```dart
// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/sports_service.dart';
import '../../models/sport.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SportsService _sportsService = SportsService();
  List<Sport> _sports = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadSports();
  }
  
  Future<void> _loadSports() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final sports = await _sportsService.getAllSports();
      
      setState(() {
        _sports = sports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý giải đấu'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lỗi: $_error'),
            ElevatedButton(
              onPressed: _loadSports,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _sports.length,
      itemBuilder: (context, index) {
        final sport = _sports[index];
        return Card(
          child: InkWell(
            onTap: () {
              // Navigate to sport detail
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 8),
                  Text(
                    sport.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (sport.tournamentCount != null)
                    Text(
                      '${sport.tournamentCount} giải đấu',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

## 🚀 Next Steps

1. **Install Flutter SDK** theo hướng dẫn trên
2. **Tạo project** với structure đã đề xuất
3. **Copy các file template** vào project
4. **Test API connection** với Sports endpoint đầu tiên
5. **Iterate và improve** từng màn hình

**🎯 Goal**: Trong 1 tuần tới, có được Flutter app cơ bản kết nối được với API backend!
