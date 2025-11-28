# 🔧 Sửa Lỗi Đăng Nhập - Quick Fix

## ❌ Vấn Đề Gốc Rễ

**Lỗi HTTP 404** - Endpoint không tồn tại

### Nguyên nhân:
1. ❌ Flutter gọi: `http://192.168.1.4:8080/api/Auth/login`
2. ✅ Backend có: `http://10.0.2.2:8080/api/AuthApi/login`

**2 lỗi:**
- IP sai: `192.168.1.4` không work trên Android Emulator (cần `10.0.2.2`)
- Path sai: `/Auth` vs `/AuthApi`

---

## ✅ Giải Pháp Đã Áp Dụng

### Fix 1: Sửa URL (environment.dart)
```dart
// CŨ: http://192.168.1.4:8080/api
// MỚI: http://10.0.2.2:8080/api
```

**Lý do:** Android Emulator dùng `10.0.2.2` để trỏ tới localhost của máy host

### Fix 2: Sửa Endpoint Path (auth_service.dart)
```dart
// CŨ: '$baseUrl/Auth/login'
// MỚI: '$baseUrl/AuthApi/login'

// CŨ: '$baseUrl/Auth/register'
// MỚI: '$baseUrl/AuthApi/register'

// CŨ: '$baseUrl/Auth/validate'
// MỚI: '$baseUrl/AuthApi/validate'
```

**Lý do:** Controller tên `AuthApiController` → route là `/AuthApi`

---

## 🧪 Test Lại

### Bước 1: Đăng Ký Tài Khoản Mới
- Email: test@example.com
- Username: testuser
- Password: Test123 (ít nhất 6 ký tự)

### Bước 2: Đăng Nhập
- Email: test@example.com  
- Password: Test123

### Kết quả mong đợi:
✅ HTTP 200 OK
✅ Token được trả về
✅ Chuyển màn hình thành công

---

## 📊 Log Mẫu

### Trước fix (404):
```
[AuthService] Attempting login for: admin@tdsports.com
[AuthService] Login response status: 404
```

### Sau fix (200):
```
[AuthService] Attempting login for: test@example.com
[AuthService] Login response status: 200
```

---

## 🔍 Kiểm Tra Backend Log

Khi login thành công, backend sẽ log:
```
info: WebQuanLyGiaiDau_NhomTD.Controllers.Api.AuthApiController
      Login attempt for email: test@example.com
info: WebQuanLyGiaiDau_NhomTD.Controllers.Api.AuthApiController
      Login successful for user: test@example.com
```

---

## 📝 Files Đã Sửa

1. ✅ `lib/config/environment.dart` - URL endpoint
2. ✅ `lib/services/auth_service.dart` - API paths

---

## ⚠️ Lưu Ý

### Khi dùng Physical Device:
Cần đổi lại IP trong `environment.dart`:
```dart
return 'http://192.168.1.4:8080/api';
```

### Khi dùng iOS Simulator:
```dart
return 'http://localhost:8080/api';
```

### Khi dùng Android Emulator (hiện tại):
```dart
return 'http://10.0.2.2:8080/api';  // ✅ Đang dùng
```

---

**Status:** 🔄 App đang rebuild...
