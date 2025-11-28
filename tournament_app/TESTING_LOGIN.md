# Hướng Dẫn Test Đăng Nhập/Đăng Ký

## ✅ Các Sửa Đổi Đã Thực Hiện

### 1. Cập nhật URL API
- **File**: `lib/config/environment.dart`
- **Thay đổi**: URL mặc định từ `10.0.2.2` → `192.168.1.4:8080`
- **Lý do**: Để app có thể kết nối đúng với backend

### 2. Loại Bỏ Mock Data
- **File**: `lib/services/auth_service.dart`
- **Thay đổi**: 
  - Xóa hàm `_mockLogin()` và `_mockRegister()`
  - Thêm timeout 10 giây cho các request
  - Thêm logging chi tiết để debug
  - Hiển thị lỗi rõ ràng khi không kết nối được server

### 3. Backend
- ✅ Backend đã có sẵn `AuthApiController.cs`
- ✅ Endpoint `/api/Auth/login` và `/api/Auth/register` hoạt động
- ✅ Backend đang chạy trên `http://0.0.0.0:8080`

## 🧪 Các Bước Test

### Bước 1: Kiểm tra Backend đang chạy
```powershell
# Mở browser và truy cập:
http://192.168.1.4:8080/api/Health
# Hoặc
http://localhost:8080/api/Health

# Nếu thấy response JSON → Backend đang chạy ✅
```

### Bước 2: Test Đăng Ký (Register)
1. Mở app Flutter
2. Click "Tạo Tài Khoản Mới"
3. Điền thông tin:
   - **Email**: test@example.com
   - **Tên đăng nhập**: testuser
   - **Mật khẩu**: Test123 (ít nhất 6 ký tự)
   - **Xác nhận mật khẩu**: Test123
   - **Họ tên** (tùy chọn): Test User
   - **Số điện thoại** (tùy chọn): 0123456789

4. Click "Đăng Ký"

**Kết quả mong đợi:**
- ✅ Hiển thị "Đăng ký thành công"
- ✅ Tự động chuyển đến màn hình chính
- ✅ Token được lưu vào SharedPreferences

**Nếu gặp lỗi:**
- ❌ "Không thể kết nối đến server" → Backend không chạy
- ❌ "Email đã được sử dụng" → Email đã tồn tại trong DB
- ❌ "Timeout" → Kiểm tra IP address và firewall

### Bước 3: Test Đăng Nhập (Login)
1. Quay lại màn hình đăng nhập (nếu đã đăng ký)
2. Nhập:
   - **Email**: test@example.com
   - **Mật khẩu**: Test123

3. Click "Đăng Nhập"

**Kết quả mong đợi:**
- ✅ Hiển thị "Đăng nhập thành công"
- ✅ Chuyển đến màn hình chính

## 🔧 Troubleshooting

### Lỗi: "Không thể kết nối đến server"

**Giải pháp 1: Kiểm tra Backend**
```powershell
# Xem backend có chạy không
Get-Process | Where-Object {$_.ProcessName -like "*WebQuan*"}

# Nếu không chạy, khởi động lại:
cd D:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
dotnet run --project WebQuanLyGiaiDau_NhomTD.csproj
```

**Giải pháp 2: Kiểm tra IP Address**
```powershell
# Xem IP hiện tại
ipconfig | Select-String "IPv4"

# Nếu IP khác 192.168.1.4, cập nhật trong 2 files:
# 1. tournament_app/lib/config/environment.dart
# 2. tournament_app/lib/services/api_service.dart (dòng 23)
```

**Giải pháp 3: Kiểm tra Firewall**
```powershell
# Cho phép port 8080 qua firewall
New-NetFirewallRule -DisplayName "ASP.NET Core 8080" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

**Giải pháp 4: Test kết nối trực tiếp**
```powershell
# Test từ PowerShell
Invoke-WebRequest -Uri "http://192.168.1.4:8080/api/Health" -Method GET
```

### Lỗi: "Email hoặc mật khẩu không đúng"

**Nguyên nhân:**
- Email chưa tồn tại trong database (cần đăng ký trước)
- Mật khẩu sai
- Email/password có khoảng trắng thừa

**Giải pháp:**
1. Đăng ký tài khoản mới trước
2. Kiểm tra không có khoảng trắng ở đầu/cuối
3. Đảm bảo mật khẩu ít nhất 6 ký tự

### Lỗi: "Email đã được sử dụng"

**Giải pháp:**
1. Dùng email khác để đăng ký
2. Hoặc dùng email này để đăng nhập
3. Hoặc xóa user trong database (nếu cần)

## 📊 Xem Log Debug

Khi test, mở Debug Console trong VS Code để xem log:

```
[AuthService] Attempting login for: test@example.com
[AuthService] Login response status: 200
```

## ✨ Tài Khoản Admin Có Sẵn

Backend có thể có tài khoản admin có sẵn:

```
Email: admin@admin.com
Password: Admin@123
```

Thử đăng nhập với tài khoản này nếu các tài khoản test không hoạt động.

## 📝 Checklist Hoàn Chỉnh

- [ ] Backend đang chạy trên port 8080
- [ ] IP address đúng (192.168.1.4)
- [ ] Test endpoint `/api/Health` thành công
- [ ] Đăng ký tài khoản mới thành công
- [ ] Đăng nhập với tài khoản vừa đăng ký thành công
- [ ] Token được lưu và app điều hướng đúng

## 🚀 Các Bước Tiếp Theo

Sau khi đăng nhập/đăng ký thành công:

1. ✅ Profile screen sẽ hiển thị thông tin user
2. ✅ Có thể tạo team
3. ✅ Có thể đăng ký giải đấu
4. ✅ Có thể xem lịch sử

---

**Ghi chú:** Nếu vẫn gặp vấn đề, cung cấp:
1. Log từ Debug Console
2. Screenshot lỗi
3. Kết quả test endpoint Health
