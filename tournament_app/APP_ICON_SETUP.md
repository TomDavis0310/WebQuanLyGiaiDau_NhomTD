# Thiết Lập Icon và Tên App - TDSports

## ✅ Đã Hoàn Thành

### 1. Cấu Hình Icon App
- ✅ Cài đặt package `flutter_launcher_icons: ^0.13.1`
- ✅ Cấu hình sử dụng `assets/images/LOGO.jpg` làm icon
- ✅ Tạo icon cho Android (mipmap)
- ✅ Tạo adaptive icon cho Android
- ✅ Tạo icon cho iOS

### 2. Đổi Tên App
- ✅ Android: "TDSports" (trong `AndroidManifest.xml`)
- ✅ iOS: "TDSports" (trong `Info.plist`)
- ✅ App Title: "TDSports" (trong `main.dart`)
- ✅ Splash Screen: "TDSports"

## 📱 Để Xem Thay Đổi Trên Điện Thoại

### Bước 1: Clean Build
```powershell
cd tournament_app
flutter clean
```

### Bước 2: Rebuild và Cài Đặt
```powershell
flutter run --release
```

**QUAN TRỌNG:** Phải build lại app hoàn toàn, không thể dùng hot reload/restart!

### Bước 3: Xóa App Cũ (Nếu Cần)
Nếu icon vẫn chưa đổi:
1. Gỡ cài đặt app cũ trên điện thoại
2. Chạy lại: `flutter run --release`

## 📂 Files Đã Thay Đổi

### 1. `pubspec.yaml`
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/LOGO.jpg"
  min_sdk_android: 21
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/LOGO.jpg"
```

### 2. `android/app/src/main/AndroidManifest.xml`
```xml
android:label="TDSports"
```

### 3. `ios/Runner/Info.plist`
```xml
<key>CFBundleDisplayName</key>
<string>TDSports</string>
<key>CFBundleName</key>
<string>TDSports</string>
```

### 4. `lib/main.dart`
```dart
title: 'TDSports',
```

### 5. `lib/screens/splash_screen.dart`
```dart
Text('TDSports', ...)
```

## 🎨 Icon Được Tạo

### Android
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- Adaptive icons (foreground + background)

### iOS
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## 🔄 Cập Nhật Icon Sau Này

Nếu muốn thay đổi icon trong tương lai:

### Cách 1: Thay Đổi File LOGO.jpg
1. Thay thế file `assets/images/LOGO.jpg`
2. Chạy: `flutter pub run flutter_launcher_icons`
3. Rebuild app: `flutter clean && flutter run --release`

### Cách 2: Dùng File Khác
Sửa trong `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  image_path: "assets/images/NEW_ICON.png"
```
Rồi chạy lại các lệnh trên.

## 📋 Kiểm Tra Sau Khi Cài

1. **Tên App:** Kiểm tra trên home screen, phải hiển thị "TDSports"
2. **Icon:** Kiểm tra icon app, phải là hình LOGO.jpg
3. **Splash Screen:** Mở app, màn hình chào phải hiển thị:
   - Logo LOGO.jpg
   - Text "TDSports"
   - Text "Quản Lý Giải Đấu"

## ⚠️ Lưu Ý

### Icon Không Đổi?
- Xóa app cũ trên điện thoại
- Clear cache: `flutter clean`
- Rebuild: `flutter run --release`
- Khởi động lại điện thoại (trong một số trường hợp)

### Debug vs Release Mode
- Debug mode: Icon có thể chưa cập nhật đầy đủ
- **Release mode:** Icon chắc chắn được cập nhật
- Khuyến nghị: Test với `flutter run --release`

### Kích Thước Icon Khuyến Nghị
- Tối thiểu: 512x512 px
- Khuyến nghị: 1024x1024 px
- Format: PNG (trong suốt) hoặc JPG (nền trắng)

## 🚀 Build APK/IPA Với Icon Mới

### Android APK
```powershell
flutter build apk --release
```
File output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (cho Google Play)
```powershell
flutter build appbundle --release
```

### iOS
```powershell
flutter build ios --release
```

---

**Cập nhật:** 26/10/2025  
**Tên App:** TDSports  
**Logo:** assets/images/LOGO.jpg
