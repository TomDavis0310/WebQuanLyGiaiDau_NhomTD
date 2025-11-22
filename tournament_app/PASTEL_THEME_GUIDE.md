# 🎨 Hướng Dẫn Sử Dụng Pastel Theme System

## 📋 Tổng Quan

Hệ thống theme mới được thiết kế với bảng màu **Pastel tươi sáng**, hỗ trợ đầy đủ **Dark Mode** và **Light Mode** với trải nghiệm người dùng mượt mà và hiện đại.

## 🎨 Bảng Màu Pastel

### Light Mode Colors

#### Màu Chính (Primary)
- **Primary Blue**: `#7FB3D5` - Xanh dương pastel nhẹ nhàng
- **Primary Variant**: `#AED6F1` - Xanh dương pastel sáng hơn
- **Primary Dark**: `#5499C7` - Xanh dương pastel đậm hơn

#### Màu Phụ (Secondary)
- **Secondary Pink**: `#F8B4D9` - Hồng pastel dịu dàng
- **Secondary Variant**: `#FAD7E6` - Hồng pastel nhạt

#### Màu Accent (Pastel Palette)
- 🌿 **Mint**: `#98D8C8` - Xanh mint tươi mát
- 🍑 **Peach**: `#FFCBA4` - Cam đào ngọt ngào
- 💜 **Lavender**: `#D5AAFF` - Tím lavender nhẹ nhàng
- 🌟 **Yellow**: `#F7DC6F` - Vàng pastel ấm áp
- 🌺 **Coral**: `#FF9A9A` - Hồng san hô dịu dàng
- 🍃 **Green**: `#A8E6CF` - Xanh lá pastel tươi mới

### Dark Mode Colors

#### Màu Chính
- **Primary Blue**: `#85C1E2` - Xanh dương pastel sáng
- **Primary Variant**: `#B3D9EC` - Xanh dương pastel rất sáng
- **Primary Dark**: `#5A9DBF` - Xanh dương đậm

#### Màu Phụ
- **Secondary Pink**: `#FFB3D9` - Hồng pastel sáng
- **Secondary Variant**: `#FFCCE5` - Hồng pastel rất sáng

#### Màu Accent
- 🌿 **Mint**: `#7FD4C1` - Xanh mint sáng
- 🍑 **Peach**: `#FFD4A8` - Cam đào sáng
- 💜 **Lavender**: `#DDB3FF` - Tím lavender sáng
- 🌟 **Yellow**: `#FDE992` - Vàng pastel sáng
- 🌺 **Coral**: `#FFADAD` - Hồng san hô sáng
- 🍃 **Green**: `#B8F0D9` - Xanh lá sáng

## 🌈 Gradients

### Light Mode Gradients
```dart
// Primary Gradient - Blue pastel
AppTheme.lightPrimaryGradient

// Secondary Gradient - Pink to Peach
AppTheme.lightSecondaryGradient

// Success Gradient - Green pastel
AppTheme.lightSuccessGradient

// Warning Gradient - Yellow to Peach
AppTheme.lightWarningGradient

// Danger Gradient - Coral to Pink
AppTheme.lightDangerGradient
```

### Dark Mode Gradients
```dart
// Tương tự với prefix "dark"
AppTheme.darkPrimaryGradient
AppTheme.darkSecondaryGradient
// ...
```

## 💻 Cách Sử Dụng

### 1. Toggle Dark/Light Mode

```dart
// Trong widget
final themeProvider = Provider.of<ThemeProvider>(context);

// Toggle theme
themeProvider.toggleTheme();

// Set specific theme
themeProvider.setThemeMode(ThemeMode.dark);
themeProvider.setThemeMode(ThemeMode.light);

// Check current mode
bool isDark = themeProvider.isDarkMode;
```

### 2. Sử Dụng Màu Theme-Aware

```dart
// Tự động lấy màu phù hợp với theme hiện tại
Color primary = AppTheme.getPrimaryColor(context);
Color background = AppTheme.getBackgroundColor(context);
Color textPrimary = AppTheme.getTextPrimaryColor(context);

// Gradient
LinearGradient gradient = AppTheme.getPrimaryGradient(context);
```

### 3. Tạo Card với Shadow Pastel

```dart
Container(
  decoration: AppTheme.cardDecoration(
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
  child: YourWidget(),
)
```

### 4. Tạo Button với Gradient

```dart
Container(
  decoration: AppTheme.gradientDecoration(
    AppTheme.getPrimaryGradient(context),
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Gradient Button'),
      ),
    ),
  ),
)
```

### 5. Typography

```dart
// Light Mode
Text('Title', style: AppTheme.lightHeadlineLarge)
Text('Body', style: AppTheme.lightBodyMedium)

// Dark Mode
Text('Title', style: AppTheme.darkHeadlineLarge)
Text('Body', style: AppTheme.darkBodyMedium)

// Hoặc dùng Theme.of(context)
Text('Auto', style: Theme.of(context).textTheme.headlineLarge)
```

## 🎯 Best Practices

### 1. Luôn Sử Dụng Theme Colors
❌ **Không nên:**
```dart
Container(color: Color(0xFF1E88E5)) // Hard-coded color
```

✅ **Nên:**
```dart
Container(color: AppTheme.getPrimaryColor(context))
```

### 2. Sử Dụng Helper Methods
✅ **Recommended:**
```dart
// Tự động adapt với theme
BoxDecoration decoration = AppTheme.cardDecoration(
  isDark: Theme.of(context).brightness == Brightness.dark,
);
```

### 3. Gradient cho Interactive Elements
✅ **Best for buttons, cards, highlights:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.getPrimaryGradient(context),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### 4. Spacing & Radius Constants
```dart
// Spacing
AppTheme.spaceXSmall   // 4px
AppTheme.spaceSmall    // 8px
AppTheme.spaceMedium   // 16px
AppTheme.spaceLarge    // 24px
AppTheme.spaceXLarge   // 32px
AppTheme.spaceXXLarge  // 48px

// Border Radius
AppTheme.radiusSmall   // 8px
AppTheme.radiusMedium  // 12px
AppTheme.radiusLarge   // 16px
AppTheme.radiusXLarge  // 24px
AppTheme.radiusRound   // 100px (circular)
```

## 🔄 Theme Persistence

Theme preference được tự động lưu vào `SharedPreferences` và sẽ được restore khi app khởi động lại.

```dart
// ThemeProvider tự động load saved preference
class ThemeProvider extends ChangeNotifier {
  // Loads saved preference on init
  ThemeProvider() {
    _loadThemeMode();
  }
  
  // Saves when changed
  Future<void> toggleTheme() async {
    // ... saves to SharedPreferences
  }
}
```

## 🎨 Demo Screen

Để xem preview đầy đủ của theme system:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ThemePreviewScreen(),
  ),
);
```

## 📱 Settings Screen Integration

Theme toggle đã được tích hợp vào Settings Screen với UI gradient đẹp mắt:

```dart
// Trong SettingsScreen
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.getPrimaryGradient(context),
    borderRadius: BorderRadius.circular(12),
  ),
  child: SwitchListTile(
    value: isDark,
    onChanged: (_) => themeProvider.toggleTheme(),
    // ...
  ),
)
```

## 🎯 Kết Quả Đạt Được

✅ **Dark Mode & Light Mode** hoàn chỉnh
✅ **Pastel Colors** tươi sáng, dễ nhìn
✅ **Smooth Gradients** cho interactive elements
✅ **Theme Persistence** tự động lưu preference
✅ **Typography System** nhất quán
✅ **Spacing & Radius** constants chuẩn
✅ **Helper Methods** dễ sử dụng
✅ **Material Design 3** compliance
✅ **Beautiful Shadows** với màu pastel

## 📚 Files Liên Quan

- `lib/theme/app_theme.dart` - Theme definitions
- `lib/providers/theme_provider.dart` - Theme state management
- `lib/screens/settings_screen.dart` - Settings UI with theme toggle
- `lib/screens/theme_preview_screen.dart` - Theme preview/demo
- `lib/widgets/theme_showcase_widget.dart` - Theme showcase widget
- `lib/main.dart` - App entry point with theme support

---

**Created by:** TDSports Team  
**Date:** November 2025  
**Version:** 1.0.0
