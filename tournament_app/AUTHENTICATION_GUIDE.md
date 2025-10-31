# 🔐 Hướng Dẫn Hệ Thống Authentication

## ✅ Tính Năng Đã Hoàn Thành

### 1. **Models & Data Structure**
- ✅ `User` - Model người dùng với thông tin đầy đủ
- ✅ `LoginRequest` - Model yêu cầu đăng nhập
- ✅ `RegisterRequest` - Model yêu cầu đăng ký
- ✅ `AuthResponse` - Model phản hồi xác thực
- ✅ JSON Serialization với `json_annotation`

**Files:**
- `lib/models/user.dart`
- `lib/models/user.g.dart` (auto-generated)

### 2. **Authentication Service**
- ✅ API calls cho Login/Register
- ✅ Token management (save/get/remove)
- ✅ User data persistence với SharedPreferences
- ✅ Check login status
- ✅ Mock authentication (development mode)

**Features:**
```dart
AuthService.login(LoginRequest)
AuthService.register(RegisterRequest)
AuthService.logout()
AuthService.getToken()
AuthService.getUser()
AuthService.isLoggedIn()
AuthService.validateToken()
```

**File:** `lib/services/auth_service.dart`

### 3. **State Management với Provider**
- ✅ `AuthProvider` quản lý trạng thái authentication
- ✅ Reactive UI updates khi auth state thay đổi
- ✅ Error handling và loading states
- ✅ Auto-initialize khi app khởi động

**Features:**
```dart
authProvider.login(email, password, rememberMe)
authProvider.register(...)
authProvider.logout()
authProvider.isAuthenticated
authProvider.user
authProvider.errorMessage
```

**File:** `lib/providers/auth_provider.dart`

### 4. **UI Screens**

#### **Login Screen** (`lib/screens/login_screen.dart`)
- ✅ Email và password fields
- ✅ Form validation
- ✅ Show/hide password
- ✅ Remember me checkbox
- ✅ Forgot password button (placeholder)
- ✅ Navigate to Register
- ✅ Skip login option
- ✅ Responsive UI với gradient background
- ✅ Loading indicator khi đang xử lý

#### **Register Screen** (`lib/screens/register_screen.dart`)
- ✅ Full form với tất cả fields:
  - Email (required)
  - Username (required)
  - Password (required)
  - Confirm Password (required)
  - Full Name (optional)
  - Phone Number (optional)
- ✅ Form validation đầy đủ
- ✅ Password match validation
- ✅ Show/hide password
- ✅ Beautiful gradient UI
- ✅ Back to login link

#### **Profile Screen** (`lib/screens/profile_screen.dart`)
- ✅ Display user information
- ✅ Avatar/Profile picture
- ✅ Info cards với icons
- ✅ Edit profile button (placeholder)
- ✅ Change password button (placeholder)
- ✅ Logout with confirmation dialog
- ✅ Show login prompt nếu chưa đăng nhập

### 5. **App Integration**
- ✅ Provider setup trong `main.dart`
- ✅ Splash screen check authentication
- ✅ Auto-navigate dựa trên login status
- ✅ Profile/Login button trong Sports List
- ✅ Persistent login với token

---

## 🎯 Luồng Hoạt Động

### **App Launch Flow:**
```
1. main.dart
   ↓
2. AuthProvider.initialize()
   ↓
3. SplashScreen
   ↓
4. Check isLoggedIn
   ├─ YES → SportsListScreen
   └─ NO → LoginScreen
```

### **Login Flow:**
```
1. User nhập email & password
   ↓
2. Validate form
   ↓
3. AuthProvider.login()
   ↓
4. AuthService.login() → API call
   ↓
5. Save token & user data
   ↓
6. Navigate to SportsListScreen
```

### **Register Flow:**
```
1. User điền form đăng ký
   ↓
2. Validate tất cả fields
   ↓
3. Check password match
   ↓
4. AuthProvider.register()
   ↓
5. AuthService.register() → API call
   ↓
6. Save token & user data
   ↓
7. Navigate to SportsListScreen
```

### **Logout Flow:**
```
1. User click Logout button
   ↓
2. Show confirmation dialog
   ↓
3. AuthProvider.logout()
   ↓
4. Clear token & user data
   ↓
5. Navigate to LoginScreen
```

---

## 🛠️ Backend API Requirements

### **⚠️ CHÚ Ý: Backend API chưa có**

Hiện tại app đang sử dụng **Mock Authentication** (giả lập). Để hoạt động hoàn chỉnh, cần tạo các API endpoints sau trong ASP.NET Core backend:

### 1. **POST /api/Auth/login**

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
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
    "id": "user-id",
    "email": "user@example.com",
    "userName": "username",
    "fullName": "John Doe",
    "phoneNumber": "0123456789",
    "avatarUrl": "https://...",
    "role": "User",
    "createdAt": "2025-10-26T10:00:00Z"
  }
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Email hoặc mật khẩu không đúng"
}
```

### 2. **POST /api/Auth/register**

**Request:**
```json
{
  "email": "newuser@example.com",
  "userName": "newuser",
  "password": "password123",
  "confirmPassword": "password123",
  "fullName": "New User",
  "phoneNumber": "0123456789"
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Đăng ký thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { /* same as login */ }
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Email đã được sử dụng"
}
```

### 3. **GET /api/Auth/validate**

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Token hợp lệ"
}
```

---

## 📦 Dependencies Đã Thêm

```yaml
dependencies:
  provider: ^6.1.1          # State management
  shared_preferences: ^2.2.2 # Local storage
  http: ^1.1.0              # HTTP requests
  json_annotation: ^4.8.1   # JSON serialization

dev_dependencies:
  build_runner: ^2.4.7      # Code generation
  json_serializable: ^6.7.1 # JSON serialization
```

---

## 🔧 Mock Authentication (Development Mode)

Hiện tại app sử dụng mock authentication để test UI mà không cần backend:

### **Mock Login:**
- Chấp nhận bất kỳ email nào có format hợp lệ
- Password tối thiểu 6 ký tự
- Tự động tạo user data và token
- Lưu vào SharedPreferences

### **Mock Register:**
- Validate tất cả fields
- Check password match
- Tự động tạo user và login

### **Tắt Mock Mode:**
Khi backend API sẵn sàng, chỉ cần remove các method `_mockLogin()` và `_mockRegister()` trong `auth_service.dart`. App sẽ tự động sử dụng real API.

---

## 🎨 UI/UX Features

### **Design Elements:**
- ✅ Gradient backgrounds
- ✅ Material Design cards
- ✅ Smooth animations
- ✅ Form validation với error messages
- ✅ Loading indicators
- ✅ Success/Error snackbars
- ✅ Icons và visual feedback
- ✅ Responsive layout

### **User Experience:**
- ✅ Auto-fill previous email (if remembered)
- ✅ Show/hide password toggle
- ✅ Skip login option
- ✅ Logout confirmation
- ✅ Clear error messages tiếng Việt
- ✅ Smooth navigation transitions

---

## 📱 Cách Test Authentication

### **1. Test Login:**
```
1. Chạy app → Màn hình Login
2. Nhập email: test@example.com
3. Nhập password: 123456
4. Click "Đăng Nhập"
5. → Chuyển sang Sports List Screen
6. Click icon Profile (top-right)
7. → Xem thông tin user
```

### **2. Test Register:**
```
1. Màn hình Login → Click "Tạo Tài Khoản Mới"
2. Điền form đăng ký
3. Click "Đăng Ký"
4. → Tự động login và chuyển sang Sports List
5. Click Profile → Xem thông tin vừa đăng ký
```

### **3. Test Logout:**
```
1. Từ Sports List → Click Profile icon
2. Scroll xuống → Click "Đăng Xuất"
3. Confirm → "Đăng Xuất"
4. → Quay về Login screen
5. Restart app → Vẫn ở Login screen (đã logout)
```

### **4. Test Remember Login:**
```
1. Login với "Ghi nhớ" checked
2. Close app hoàn toàn
3. Mở app lại
4. → Tự động đăng nhập, skip Login screen
```

### **5. Test Skip Login:**
```
1. Màn hình Login → Click "Bỏ qua đăng nhập"
2. → Vào Sports List nhưng không có user
3. Click Profile icon → Hiện "Chưa Đăng Nhập"
4. Click "Đăng Nhập Ngay" → Quay về Login screen
```

---

## 🚀 Next Steps - Tích Hợp Backend

### **1. Tạo AuthController trong ASP.NET Core:**
```bash
cd d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD\Controllers\Api
# Tạo file AuthApiController.cs
```

### **2. Implement JWT Authentication:**
- Install `Microsoft.AspNetCore.Authentication.JwtBearer`
- Configure JWT trong `Program.cs`
- Generate và validate tokens

### **3. Tạo User Database:**
- User table với ASP.NET Identity
- Migration và seed data
- Password hashing với BCrypt

### **4. Update Flutter API calls:**
- Remove mock methods từ `auth_service.dart`
- Test với real API endpoints
- Handle các error cases thực tế

### **5. Security Enhancements:**
- HTTPS cho production
- Refresh tokens
- Token expiration handling
- Secure storage cho sensitive data

---

## 📝 Validation Rules

### **Email:**
- Required
- Must contain '@'
- Format: xxx@xxx.xxx

### **Username:**
- Required
- Minimum 3 characters
- Alphanumeric

### **Password:**
- Required
- Minimum 6 characters
- Match with Confirm Password

### **Phone (Optional):**
- Numeric
- Valid phone format

---

## 🎉 Kết Quả

### **✅ Hoàn Thành:**
- Full authentication system với UI đẹp
- Mock data để test mà không cần backend
- Persistent login với SharedPreferences
- State management với Provider
- Form validation đầy đủ
- Profile management UI
- Responsive và user-friendly

### **🔄 Sẵn Sàng Cho:**
- Backend API integration
- Production deployment
- Real user testing
- Feature expansion (edit profile, forgot password, etc.)

---

**🎊 Authentication System đã sẵn sàng để sử dụng!**

Bạn có thể test ngay trên app, và khi backend API sẵn sàng, chỉ cần tích hợp là xong! 🚀
