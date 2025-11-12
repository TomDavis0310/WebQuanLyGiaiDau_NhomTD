# 🔧 Hướng Dẫn Cấu Hình Google Sign-in

## ❌ **Lỗi Hiện Tại**
- `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10)`
- Error code 10 nghĩa là `DEVELOPER_ERROR`

## 🔍 **Nguyên Nhân**
1. **SHA-1 fingerprint** chưa được thêm vào Firebase Console
2. **google-services.json** có thể chưa được cấu hình đúng
3. **Package name** không khớp giữa app và Firebase project

## ✅ **Cách Khắc Phục**

### **Bước 1: Lấy SHA-1 Fingerprint**

```bash
# Chạy lệnh này trong thư mục android/ của Flutter project
cd tournament_app/android

# Debug SHA-1
./gradlew signingReport

# Hoặc sử dụng keytool (Windows)
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Lấy SHA-1 fingerprint từ output (dạng: `AA:BB:CC:...`)

### **Bước 2: Cấu Hình Firebase**

1. Mở [Firebase Console](https://console.firebase.google.com/)
2. Chọn project hoặc tạo project mới
3. Vào **Project Settings** → **General**
4. Trong phần **Your apps**, tìm Android app
5. Click **Add fingerprint** và paste SHA-1 vừa lấy
6. Download `google-services.json` mới
7. Thay thế file cũ trong `tournament_app/android/app/`

### **Bước 3: Kiểm Tra Package Name**

Đảm bảo package name trong:
- `android/app/build.gradle.kts`: `com.nhomtd.tournament.tournament_app`
- Firebase Console app configuration
- `android/app/src/main/AndroidManifest.xml`

### **Bước 4: Cấu Hình OAuth Consent Screen**

1. Mở [Google Cloud Console](https://console.cloud.google.com/)
2. Chọn project Firebase
3. Vào **APIs & Services** → **OAuth consent screen**
4. Cấu hình OAuth consent screen
5. Thêm test users nếu cần

### **Bước 5: Tạo OAuth 2.0 Client ID**

1. Vào **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Chọn **Android**
4. Nhập:
   - Name: `TDSports Android`
   - Package name: `com.nhomtd.tournament.tournament_app`
   - SHA-1 fingerprint: (từ bước 1)

### **Bước 6: Cập Nhật Code (Nếu Cần)**

Trong `google_auth_service.dart`, thêm client ID:

```dart
static final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>['email', 'profile'],
  serverClientId: 'YOUR_WEB_CLIENT_ID.googleusercontent.com', // Từ OAuth credentials
);
```

## 🧪 **Test Lại**

1. Clean và rebuild app:
```bash
flutter clean
flutter pub get
flutter run
```

2. Thử Google Sign-in trên thiết bị thật hoặc emulator có Google Play Services

## 📋 **Checklist**

- [ ] SHA-1 fingerprint đã thêm vào Firebase
- [ ] Package name khớp giữa app và Firebase
- [ ] `google-services.json` đã cập nhật
- [ ] OAuth consent screen đã cấu hình
- [ ] OAuth 2.0 Client ID đã tạo
- [ ] Test users đã được thêm (nếu app ở chế độ testing)

## 🚨 **Lưu Ý**

1. **Development vs Production**: SHA-1 của debug và release build khác nhau
2. **Multiple SHA-1**: Có thể thêm nhiều SHA-1 cho các environment khác nhau
3. **App Bundle**: Nếu sử dụng App Bundle, cần thêm upload certificate SHA-1

## 🔄 **Tạm Thời**

Hiện tại app đã được cấu hình để:
- Hiển thị thông báo thân thiện khi Google Sign-in lỗi
- Hướng dẫn user sử dụng đăng nhập email/password thay thế
- Không crash app khi Google Sign-in fail

## 📞 **Support**

Nếu vẫn gặp lỗi sau khi làm theo hướng dẫn:
1. Kiểm tra Firebase Console logs
2. Xem Android logcat để debug chi tiết
3. Đảm bảo Google Play Services được cập nhật

---

**Cập nhật cuối:** 12/11/2025
**Trạng thái:** Google Sign-in tạm vô hiệu hóa, app vẫn hoạt động bình thường