# 📱 Navigation Rail - Thanh Menu Bên Trái

## ✅ Đã Hoàn Thành

### 🎯 Tính Năng Mới
- **Navigation Rail** (thanh menu dọc) ở bên trái màn hình
- Có thể **mở rộng/thu nhỏ** menu
- **Logo TD** ở đầu menu
- **Icon động** thay đổi theo trạng thái đăng nhập

---

## 📂 Files Đã Tạo/Sửa

### Mới:
- ✅ `lib/screens/main_navigation_screen.dart` - Màn hình chính với Navigation Rail

### Đã Cập Nhật:
- ✅ `lib/screens/splash_screen.dart` - Chuyển đến MainNavigationScreen
- ✅ `lib/screens/sports_list_screen.dart` - Thêm tham số showAppBar
- ✅ `lib/screens/news_list_screen.dart` - Thêm tham số showAppBar
- ✅ `lib/screens/search_screen.dart` - Thêm tham số showAppBar
- ✅ `lib/screens/dashboard_screen.dart` - Thêm tham số showAppBar
- ✅ `lib/screens/profile_screen.dart` - Thêm tham số showAppBar
- ✅ `lib/screens/shop_screen.dart` - Thêm tham số showAppBar

---

## 🎨 Thiết Kế

### Layout:
```
┌─────────────────────────────────────┐
│  [Navigation Rail]  │  [Content]    │
│                     │               │
│   [TD Logo]         │               │
│                     │               │
│   🏠 Trang Chủ     │  Màn hình     │
│   📰 Tin Tức       │  tương ứng    │
│   🔍 Tìm Kiếm      │               │
│   📊 Dashboard     │               │
│   🛒 Cửa Hàng      │               │
│   👤 Cá Nhân       │               │
│                     │               │
│   [◀/▶ Toggle]     │               │
└─────────────────────────────────────┘
```

### Menu Items (Khi đăng nhập):
1. 🏠 **Trang Chủ** - Sports List
2. 📰 **Tin Tức** - News List
3. 🔍 **Tìm Kiếm** - Search
4. 📊 **Dashboard** - Dashboard (chỉ khi đã đăng nhập)
5. 🛒 **Cửa Hàng** - Shop (chỉ khi đã đăng nhập)
6. 👤 **Cá Nhân** - Profile (chỉ khi đã đăng nhập)

### Menu Items (Khi chưa đăng nhập):
1. 🏠 **Trang Chủ** - Sports List
2. 📰 **Tin Tức** - News List
3. 🔍 **Tìm Kiếm** - Search
4. 🔑 **Đăng Nhập** - Login Screen

---

## 🎮 Cách Sử Dụng

### 1. Thu nhỏ/Mở rộng Menu
- Click vào nút **◀** (mũi tên) ở cuối thanh menu
- Thu nhỏ: Chỉ hiển thị icon
- Mở rộng: Hiển thị cả icon và label

### 2. Chuyển Màn Hình
- Click vào bất kỳ item nào trong menu
- Màn hình sẽ thay đổi ngay lập tức
- Item đang active được highlight

### 3. Logo TD
- Hiển thị ở đầu thanh menu
- Background màu primary
- Text "TD" màu trắng, bold

---

## 🔧 Cấu Trúc Code

### MainNavigationScreen
```dart
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;  // Màn hình mặc định khi mở
  
  const MainNavigationScreen({
    Key? key,
    this.initialIndex = 0,  // 0 = Trang Chủ
  }) : super(key: key);
}
```

### Navigation Rail
- **Extended**: `false` (mặc định thu nhỏ)
- **LabelType**: `NavigationRailLabelType.selected` (hiển thị label cho item được chọn)
- **Leading**: Logo TD
- **Trailing**: Nút toggle mở rộng/thu nhỏ

---

## 🎯 Màn Hình Tương Thích

Tất cả màn hình đều có tham số `showAppBar`:
- `showAppBar = true`: Hiển thị AppBar bình thường (khi navigate trực tiếp)
- `showAppBar = false`: Ẩn AppBar (khi hiển thị trong MainNavigationScreen)

### Ví dụ:
```dart
// Với AppBar
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NewsListScreen(showAppBar: true),
  ),
);

// Không AppBar (dùng trong MainNavigationScreen)
const NewsListScreen(showAppBar: false)
```

---

## 🚀 Chạy App

```bash
cd tournament_app
flutter run
```

### Kết Quả:
1. ✅ App khởi động với SplashScreen
2. ✅ Tự động chuyển sang MainNavigationScreen
3. ✅ Thanh menu hiển thị bên trái
4. ✅ Màn hình Trang Chủ hiển thị ở bên phải
5. ✅ Click vào menu items để chuyển màn hình

---

## 🎨 Theme Integration

Navigation Rail tự động sử dụng theme của app:
- **Primary Color**: Màu highlight cho item được chọn
- **Grey**: Màu cho item không được chọn
- **Background**: Màu nền scaffold

---

## 📱 Responsive

- **Desktop/Tablet**: Navigation Rail hiển thị tốt
- **Mobile**: Có thể thu nhỏ để tăng diện tích màn hình
- **Extend Toggle**: Cho phép user điều chỉnh theo nhu cầu

---

## 🔄 Navigation Flow

```
SplashScreen (3s)
    ↓
MainNavigationScreen (initialIndex: 0)
    ↓
┌─────────────────────────────────┐
│ Navigation Rail │ SportsListScreen │
│                 │ (showAppBar: false)│
└─────────────────────────────────┘
```

---

## 💡 Tips

1. **Logo Custom**: Có thể thay icon TD bằng logo từ assets
2. **More Items**: Dễ dàng thêm items mới vào menu
3. **Icons**: Sử dụng Material Icons hoặc custom icons
4. **Colors**: Tùy chỉnh colors trong theme

---

## ✨ Features

- ✅ Persistent navigation (menu luôn hiển thị)
- ✅ State management với Provider (AuthProvider)
- ✅ Dynamic menu items (thay đổi theo auth state)
- ✅ Smooth transitions
- ✅ Material Design 3 compliant
- ✅ Full screen content area
- ✅ Professional look & feel

---

## 🎉 Hoàn Thành!

App hiện có **Navigation Rail** hoàn chỉnh ở bên trái màn hình, giúp người dùng dễ dàng di chuyển giữa các màn hình chính!
