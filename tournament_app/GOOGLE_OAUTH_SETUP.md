# Thiết Lập Google OAuth cho Flutter App - TDSports

Hướng dẫn chi tiết để tích hợp Google Sign-In vào ứng dụng Flutter.

## 🔧 Cấu Hình Cơ Bản

### 1. Dependencies đã được thêm vào `pubspec.yaml`:
```yaml
dependencies:
  google_sign_in: ^6.2.1
  firebase_core: ^3.6.0
  sign_in_with_apple: ^6.1.3
  font_awesome_flutter: ^10.7.0
```

### 2. Cấu trúc code đã hoàn thiện:
- ✅ `GoogleAuthService` - Service xử lý Google OAuth
- ✅ `GoogleSignInButton` - Widget nút đăng nhập Google
- ✅ `AuthProvider` - Provider quản lý state xác thực  
- ✅ `LoginScreen` - Màn hình đăng nhập với nút Google

## 🔑 Thiết Lập Google Cloud Console

### Bước 1: Tạo Project Google Cloud
1. Truy cập [Google Cloud Console](https://console.cloud.google.com/)
2. Tạo project mới hoặc chọn project existing
3. Kích hoạt **Google Sign-In API**

### Bước 2: Cấu Hình OAuth Consent Screen
1. Vào **APIs & Services > OAuth consent screen**
2. Chọn **External** (cho testing)
3. Điền thông tin:
   - App name: `TDSports`
   - User support email: email của bạn
   - Developer contact info: email của bạn
4. **Quan trọng**: Bỏ trống các field `App domain` (để tránh lỗi localhost)
5. Save và continue

### Bước 3: Tạo OAuth 2.0 Credentials
1. Vào **APIs & Services > Credentials**
2. Click **Create Credentials > OAuth 2.0 Client IDs**

**Tạo credentials cho Android:**
- Application type: `Android`
- Package name: `com.nhomtd.tournament.tournament_app`  
- SHA-1 certificate fingerprint: Xem cách lấy bên dưới

**Tạo credentials cho Web (cho backend):**
- Application type: `Web application`
- Authorized redirect URIs: `http://localhost:8080/signin-google`

## 📱 Lấy SHA-1 Certificate Fingerprint

### Cho Development (Debug):
```bash
cd d:\WebQuanLyGiaiDau_NhomTD\tournament_app\android
./gradlew signingReport
```

Hoặc sử dụng keytool:
```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey
# Password: android
```

### Cho Production:
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

## 🔧 Cập Nhật File Cấu Hình

### 1. Cập nhật `google-services.json` (Android)
- Download file từ Google Cloud Console
- Thay thế file mock tại: `android/app/google-services.json`

### 2. Cập nhật `GoogleService-Info.plist` (iOS)  
- Download file từ Google Cloud Console
- Thêm vào: `ios/Runner/GoogleService-Info.plist`

### 3. Cập nhật Android Config
Thêm vào `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Thêm dòng này
}
```

Và trong `android/build.gradle.kts`:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0") // Thêm dòng này
}
```

### 4. Cập nhật iOS Config
Trong `ios/Runner/Info.plist`, thêm:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>REVERSED_CLIENT_ID</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

## 🔗 Kết Nối với Backend

### Cập nhật API Base URL
Trong `lib/config/environment.dart`, cập nhật URL phù hợp:

```dart
// Cho Android Emulator
return 'http://10.0.2.2:8080/api';

// Cho thiết bị thật (thay YOUR_PC_IP)
return 'http://192.168.1.XXX:8080/api';
```

### Backend Endpoint
Đảm bảo backend có endpoint `/Auth/external-login` để nhận:
```json
{
  "provider": "Google",
  "accessToken": "ya29.a0...",
  "idToken": "eyJhbGc...",
  "googleId": "123456789",
  "email": "user@gmail.com", 
  "displayName": "User Name",
  "photoUrl": "https://..."
}
```

## 🚀 Chạy và Test

### 1. Chạy Backend
```bash
cd d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
dotnet run
```

### 2. Chạy Flutter App
```bash
cd d:\WebQuanLyGiaiDau_NhomTD\tournament_app
flutter run
```

### 3. Test Google Sign-In
1. Mở app trên emulator/device
2. Click nút "Đăng nhập bằng Google" 
3. Sẽ mở Google Sign-In flow
4. Chọn tài khoản Google
5. Cho phép quyền truy cập
6. App sẽ nhận thông tin user và đăng nhập

## 🔍 Troubleshooting

### Lỗi "Developer Error"
- Kiểm tra SHA-1 certificate fingerprint
- Đảm bảo package name đúng
- Xác minh OAuth client đã enable

### Lỗi "Sign in failed"  
- Kiểm tra internet connection
- Verify Google Cloud project setup
- Check backend API endpoint

### Lỗi Backend Connection
- Verify backend đang chạy
- Kiểm tra API URL trong environment.dart
- Test endpoint `/Auth/external-login` bằng Postman

## 📋 Checklist Hoàn Thiện

- [ ] Google Cloud project created
- [ ] OAuth consent screen configured  
- [ ] Android OAuth client created với SHA-1
- [ ] Web OAuth client created cho backend
- [ ] `google-services.json` downloaded và updated
- [ ] Android build.gradle updated
- [ ] iOS config updated (nếu cần)
- [ ] Backend endpoint `/Auth/external-login` ready
- [ ] Environment API URL configured
- [ ] App tested trên device/emulator

## 🎯 Ghi Chú Quan Trọng

1. **Development vs Production**: File `google-services.json` hiện tại là mock. Cần thay thế bằng file thật.

2. **Security**: Không commit file `google-services.json` thật vào Git. Thêm vào `.gitignore`.

3. **Testing**: Mock system sẽ hoạt động ngay cả khi không có real Google credentials.

4. **Backend Integration**: Real Google OAuth sẽ cần backend endpoint hoạt động.

## 📞 Hỗ Trợ

Nếu gặp vấn đề:
1. Check logs trong Android Studio/Xcode  
2. Verify Google Cloud Console setup
3. Test backend API endpoints
4. Check network connectivity

---

**Tác giả:** GitHub Copilot - TDSports Development Team  
**Ngày cập nhật:** ${new Date().toLocaleDateString('vi-VN')}