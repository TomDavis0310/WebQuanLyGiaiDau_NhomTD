# 🗓️ KẾ HOẠCH 6 TUẦN PHÁT TRIỂN FLUTTER APP

## 📊 Tình trạng hiện tại (Ngày 3/10/2025)

### ✅ HOÀN THÀNH - API Backend
- ✅ **13 API Endpoints** hoạt động hoàn hảo
- ✅ **Swagger Documentation** tại `/api-docs`
- ✅ **Database** với seed data đầy đủ
- ✅ **Error Handling** chuẩn với tiếng Việt
- ✅ **Response Format** thống nhất JSON
- ✅ **Test Scripts** PowerShell đã sẵn sàng

---

## 🎯 TUẦN 1-2: Hoàn thiện API & Bắt đầu Flutter

### ✅ Đã hoàn thành:
- [x] API Backend hoàn thành
- [x] Test tất cả API endpoints

### 🔄 Đang thực hiện:
- [ ] **Cài đặt Flutter SDK** (Ưu tiên cao)
- [ ] **Tạo project Flutter đầu tiên**
- [ ] **Thiết lập kết nối API từ Flutter**

### 📋 Action Items tuần này:

#### Ngày 3-4/10: Setup Flutter Environment
```bash
# 1. Download Flutter SDK
https://docs.flutter.dev/get-started/install/windows

# 2. Extract và thêm vào PATH
C:\flutter\bin

# 3. Chạy flutter doctor
flutter doctor

# 4. Setup Android Studio/VS Code
```

#### Ngày 5-6/10: Tạo Flutter Project đầu tiên
```bash
# 1. Tạo project mới
flutter create tournament_management_app
cd tournament_management_app

# 2. Test trên emulator
flutter run

# 3. Setup project structure
lib/
  models/
  services/
  screens/
  widgets/
  utils/
```

#### Ngày 7-9/10: Kết nối API
```dart
// 1. Thêm http package
dependencies:
  http: ^1.1.0

// 2. Tạo API service
class ApiService {
  static const baseUrl = 'http://localhost:5194/api';
  
  Future<List<Sport>> getSports() async {
    final response = await http.get(Uri.parse('$baseUrl/SportsApi'));
    // Parse JSON response
  }
}

// 3. Test API calls
```

---

## 🎯 TUẦN 3-4: Phát triển UI Flutter chính

### 📋 Màn hình cần phát triển:

#### Tuần 3 (10-16/10):
- [ ] **🏠 Trang chủ (Home Screen)**
  - GridView hiển thị các môn thể thao
  - Card design đẹp mắt
  - Navigation tới màn hình chi tiết

- [ ] **📋 Trang danh sách giải đấu**
  - ListView với pull-to-refresh
  - Filter theo môn thể thao
  - Search functionality
  - Pagination

#### Tuần 4 (17-23/10):
- [ ] **🏆 Trang chi tiết giải đấu**
  - Hero animation cho ảnh
  - Thông tin chi tiết tournament
  - Danh sách matches
  - Registered teams

- [ ] **🔐 Trang đăng ký/đăng nhập**
  - Form validation
  - Local storage cho token
  - Integration với Identity API

---

## 🎯 TUẦN 5-6: Hoàn thiện & Testing

### Tuần 5 (24-30/10):
- [ ] **👥 Trang quản lý đội bóng**
  - CRUD operations cho teams
  - Player management
  - Team statistics

- [ ] **🔄 Tích hợp đầy đủ API**
  - Error handling
  - Loading states
  - Offline support cơ bản

### Tuần 6 (31/10-6/11):
- [ ] **📱 Test trên thiết bị thật**
  - Android testing
  - Performance profiling
  - UI/UX refinement

- [ ] **🚀 Tối ưu hiệu suất**
  - Image caching
  - API response caching
  - Code optimization

- [ ] **📦 Xây dựng APK cuối cùng**
  - Release build configuration
  - App signing
  - Store-ready APK

---

## 🛠️ Technical Stack Flutter

### 📦 Dependencies cần thiết:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # API & Network
  http: ^1.1.0
  dio: ^5.3.2  # Alternative to http with interceptors
  
  # State Management
  provider: ^6.1.1
  # or bloc: ^8.1.2
  
  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  
  # Navigation
  go_router: ^12.1.1
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # Utils
  intl: ^0.19.0  # Date formatting
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### 🎨 UI Design System:
```dart
// Colors
const primaryColor = Color(0xFF1976D2);  // Blue
const secondaryColor = Color(0xFFFF5722); // Orange
const backgroundColor = Color(0xFFF5F5F5);

// Typography
const headlineStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black87,
);
```

---

## 📋 Weekly Checklist Template

### Tuần hiện tại: **Tuần 1-2** (30/9 - 13/10)

#### 🎯 Mục tiêu chính:
- [ ] Setup Flutter development environment
- [ ] Tạo project structure cơ bản
- [ ] Test API connection đầu tiên

#### 📝 Daily Tasks:
**Thứ 2 (7/10):**
- [ ] Download & install Flutter SDK
- [ ] Setup Android Studio/VS Code
- [ ] Run `flutter doctor`

**Thứ 3 (8/10):**
- [ ] Create new Flutter project
- [ ] Setup project folder structure
- [ ] Configure dependencies

**Thứ 4 (9/10):**
- [ ] Create API service class
- [ ] Test GET /api/SportsApi endpoint
- [ ] Create Sport model class

**Thứ 5 (10/10):**
- [ ] Build basic home screen
- [ ] Display list of sports
- [ ] Add navigation setup

**Thứ 6 (11/10):**
- [ ] Add error handling
- [ ] Implement loading states
- [ ] Test on Android emulator

---

## 🎯 Success Metrics

### Tuần 1-2:
- ✅ Flutter environment hoạt động
- ✅ API calls thành công từ Flutter
- ✅ Basic UI render được data

### Tuần 3-4:
- ✅ 4 main screens hoàn thành
- ✅ Navigation flow hoạt động
- ✅ API integration đầy đủ

### Tuần 5-6:
- ✅ App hoạt động stable trên device
- ✅ Release APK build thành công
- ✅ Performance acceptable (60fps)

---

## 🚀 Quick Start Commands

```bash
# Kiểm tra Flutter installation
flutter doctor -v

# Tạo project mới
flutter create tournament_management_app

# Chạy trên emulator
flutter run

# Build APK
flutter build apk --release

# Test API backend (from previous work)
cd d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
dotnet run --urls http://localhost:5194
```

---

**🎉 Let's build something amazing! Flutter + ASP.NET Core = Perfect combo!**
