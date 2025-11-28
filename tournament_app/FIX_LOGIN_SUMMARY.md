# Tóm Tắt Sửa Lỗi Đăng Nhập/Đăng Ký

## 🔍 Vấn Đề Phát Hiện

1. **URL API không nhất quán**
   - `environment.dart` dùng `10.0.2.2:8080` (Android Emulator)
   - `api_service.dart` dùng `192.168.1.4:8080` (IP thực)
   - → Gây mâu thuẫn và lỗi kết nối

2. **Auth Service dùng Mock Data**
   - Khi backend không kết nối được, `auth_service.dart` tự động chạy mock login
   - → User không biết backend có hoạt động hay không
   - → Dữ liệu không được lưu vào database thật

3. **Thiếu Thông Báo Lỗi Rõ Ràng**
   - Khi không kết nối được, không có message chi tiết
   - Không có timeout cho request
   - → Khó debug

## ✅ Các Thay Đổi Đã Thực Hiện

### 1. File: `lib/config/environment.dart`
**Trước:**
```dart
// For Android Emulator:
return 'http://10.0.2.2:8080/api';
```

**Sau:**
```dart
// Using actual PC IP address for physical devices and emulators
return 'http://192.168.1.4:8080/api';
```

**Giải thích:** Thay đổi URL mặc định để khớp với IP thực tế của máy backend

---

### 2. File: `lib/services/auth_service.dart`

#### Thay đổi 1: Xóa Mock Login
**Trước:**
```dart
} catch (e) {
  print('Login error: $e');
  return _mockLogin(request); // ← Fallback sang mock
}
```

**Sau:**
```dart
} catch (e) {
  _log('Login error: $e');
  return AuthResponse(
    success: false,
    message: 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và đảm bảo backend đang chạy.\n\nChi tiết lỗi: $e',
  );
}
```

#### Thay đổi 2: Thêm Timeout
**Trước:**
```dart
final response = await http.post(
  Uri.parse('$baseUrl/Auth/login'),
  headers: {'Content-Type': 'application/json; charset=utf-8'},
  body: json.encode(request.toJson()),
);
```

**Sau:**
```dart
final response = await http.post(
  Uri.parse('$baseUrl/Auth/login'),
  headers: {'Content-Type': 'application/json; charset=utf-8'},
  body: json.encode(request.toJson()),
).timeout(Duration(seconds: 10)); // ← Thêm timeout
```

#### Thay đổi 3: Thêm Logging
**Trước:**
```dart
print('Login error: $e');
```

**Sau:**
```dart
static void _log(String message) {
  print('[AuthService] $message');
}

// Sử dụng:
_log('Attempting login for: ${request.email}');
_log('Login response status: ${response.statusCode}');
```

#### Thay đổi 4: Xóa Mock Functions
**Đã xóa:**
- `_mockLogin()` (~60 dòng code)
- `_mockRegister()` (~70 dòng code)

**Lý do:** Backend đã có Auth API hoàn chỉnh, không cần mock nữa

---

## 🎯 Kết Quả

### Trước Sửa
❌ User đăng nhập "thành công" nhưng dữ liệu không lưu vào DB
❌ Không biết backend có chạy hay không
❌ Khó debug khi có lỗi
❌ URL không nhất quán giữa các file

### Sau Sửa
✅ Kết nối thẳng với backend thật
✅ Báo lỗi rõ ràng khi không kết nối được
✅ Có timeout để tránh đợi mãi
✅ Log chi tiết để debug
✅ URL nhất quán (192.168.1.4:8080)

---

## 🧪 Cách Test

1. **Đảm bảo backend chạy:**
   ```powershell
   cd D:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
   dotnet run --project WebQuanLyGiaiDau_NhomTD.csproj
   ```

2. **Test endpoint Health:**
   ```
   http://192.168.1.4:8080/api/Health
   ```

3. **Chạy Flutter app:**
   ```powershell
   cd D:\WebQuanLyGiaiDau_NhomTD\tournament_app
   flutter run
   ```

4. **Test đăng ký:**
   - Email: test@example.com
   - Username: testuser
   - Password: Test123

5. **Test đăng nhập:**
   - Email: test@example.com
   - Password: Test123

---

## 📊 Debug Console Output

Khi test thành công, bạn sẽ thấy:
```
[AuthService] Attempting login for: test@example.com
[AuthService] Login response status: 200
```

Khi lỗi kết nối:
```
[AuthService] Login error: SocketException: Failed to connect...
```

---

## 🔐 Backend API Details

### Endpoint: POST /api/Auth/login
**Request:**
```json
{
  "email": "test@example.com",
  "password": "Test123",
  "rememberMe": true
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-id-guid",
    "email": "test@example.com",
    "userName": "testuser",
    "fullName": "Test User",
    "phoneNumber": "0123456789",
    "role": "User"
  }
}
```

**Response (Failure):**
```json
{
  "success": false,
  "message": "Email hoặc mật khẩu không đúng"
}
```

### Endpoint: POST /api/Auth/register
**Request:**
```json
{
  "email": "test@example.com",
  "userName": "testuser",
  "password": "Test123",
  "confirmPassword": "Test123",
  "fullName": "Test User",
  "phoneNumber": "0123456789"
}
```

**Response:** Giống như Login response

---

## 📝 Files Đã Thay Đổi

1. ✅ `lib/config/environment.dart` - Cập nhật URL mặc định
2. ✅ `lib/services/auth_service.dart` - Xóa mock, thêm timeout & logging
3. ✅ `TESTING_LOGIN.md` - Hướng dẫn test chi tiết (file mới)
4. ✅ `FIX_LOGIN_SUMMARY.md` - Tóm tắt các sửa đổi (file này)

---

## 🚀 Next Steps

Sau khi đăng nhập thành công:
1. ✅ Token được lưu vào SharedPreferences
2. ✅ User info được cache local
3. ✅ Các API khác có thể dùng token để authenticate
4. ✅ Profile screen hiển thị thông tin user

---

**Lưu ý:** Nếu IP của máy thay đổi (ví dụ khi chuyển mạng WiFi), cần cập nhật lại IP trong `environment.dart`
