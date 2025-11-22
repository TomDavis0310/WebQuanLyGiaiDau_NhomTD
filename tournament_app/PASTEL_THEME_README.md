# 🎨 Pastel Theme System - Quick Start

## 🌟 Giới Thiệu

Hệ thống theme mới với **màu sắc Pastel tươi sáng**, hỗ trợ đầy đủ **Dark Mode** và **Light Mode** với trải nghiệm người dùng hiện đại và mượt mà.

## 🎨 Preview

### Light Mode - Pastel Tươi Sáng
- 🔵 Blue Pastel primary
- 🩷 Pink Pastel secondary
- 🌈 6 accent colors (Mint, Peach, Lavender, Yellow, Coral, Green)
- ☀️ Sáng sủa, dễ nhìn, thân thiện

### Dark Mode - Hiện Đại & Tinh Tế
- 🌙 Deep Navy background
- ✨ Bright pastel accents
- 💫 Beautiful glow effects
- 🎯 High contrast, dễ đọc

## 🚀 Quick Start

### 1. Chuyển Đổi Theme

Vào **Settings** → Tìm card **Giao Diện** → Toggle switch

```dart
// Hoặc trong code
final themeProvider = Provider.of<ThemeProvider>(context);
themeProvider.toggleTheme();
```

### 2. Xem Demo

```dart
// Navigate to preview screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ThemePreviewScreen(),
  ),
);
```

### 3. Sử Dụng Trong Code

```dart
// Get theme-aware colors
Color primary = AppTheme.getPrimaryColor(context);
LinearGradient gradient = AppTheme.getPrimaryGradient(context);

// Create card with shadow
Container(
  decoration: AppTheme.cardDecoration(
    isDark: Theme.of(context).brightness == Brightness.dark,
  ),
  child: YourWidget(),
)
```

## 📚 Documentation

- 📖 **[PASTEL_THEME_GUIDE.md](PASTEL_THEME_GUIDE.md)** - Hướng dẫn đầy đủ
- 📝 **[PASTEL_THEME_IMPLEMENTATION.md](PASTEL_THEME_IMPLEMENTATION.md)** - Chi tiết implementation

## ✨ Features

✅ Dark Mode & Light Mode  
✅ 12 Pastel Colors  
✅ 10 Beautiful Gradients  
✅ Soft Shadows với glow effects  
✅ Theme Persistence (tự động lưu)  
✅ One-tap switching  
✅ Material Design 3  
✅ Production Ready  

## 🎯 Files Quan Trọng

```
lib/
├── theme/
│   └── app_theme.dart              # Theme definitions
├── providers/
│   └── theme_provider.dart         # State management
├── screens/
│   ├── settings_screen.dart        # Settings với theme toggle
│   └── theme_preview_screen.dart   # Demo screen
└── widgets/
    └── theme_showcase_widget.dart  # Showcase widget
```

## 🎨 Color Palette Cheat Sheet

### Light Mode
```
Primary:   #7FB3D5  (Blue Pastel)
Secondary: #F8B4D9  (Pink Pastel)
Mint:      #98D8C8
Peach:     #FFCBA4
Lavender:  #D5AAFF
Yellow:    #F7DC6F
Coral:     #FF9A9A
Green:     #A8E6CF
```

### Dark Mode
```
Primary:   #85C1E2  (Bright Blue Pastel)
Secondary: #FFB3D9  (Bright Pink Pastel)
+ Các accent colors sáng hơn
+ Deep Navy background (#1A1F2E)
```

## 💡 Quick Tips

1. **Luôn dùng Helper Methods**: `AppTheme.getPrimaryColor(context)`
2. **Theme-aware widgets**: Check `brightness` với `Theme.of(context)`
3. **Gradients cho buttons**: Đẹp hơn flat colors
4. **Card shadows**: Dùng `AppTheme.cardDecoration()`
5. **Consistent spacing**: Dùng `AppTheme.spaceMedium`, etc.

## 🎉 Demo Commands

```bash
# Run app
flutter run

# Vào Settings → Toggle theme switch
# Hoặc navigate to ThemePreviewScreen để xem full demo
```

---

**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Last Updated**: November 22, 2025
