# 🔧 Hướng Dẫn Test Role Fix

## ✅ Đã Sửa

### 1. **Xóa Mock Login/Register**
- ❌ Trước: App dùng mock login → luôn trả về role = "User"
- ✅ Sau: App gọi API thật → nhận đúng role từ backend

### 2. **Cấu Hình API URL**
- ✅ Đã cập nhật `environment.dart` → `http://192.168.1.142:8080/api`
- ✅ Backend đang chạy trên `http://0.0.0.0:8080`

### 3. **Backend API**
- ✅ Backend trả về đúng role từ database
- ✅ Tài khoản admin có sẵn trong database

---

## 🧪 Cách Test

### **Bước 1: Đảm bảo Backend đang chạy**
```powershell
cd "d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD"
dotnet run
```

Chờ thấy dòng:
```
Now listening on: http://0.0.0.0:8080
```

### **Bước 2: Test trên Web (Xác nhận admin hoạt động)**
1. Mở trình duyệt: `http://localhost:8080`
2. Đăng nhập:
   - **Email**: `admin@example.com`
   - **Password**: `Admin123!`
3. ✅ Xác nhận: Thấy menu Admin/quản trị

### **Bước 3: Test trên App**

#### **A. Test với tài khoản Admin**
1. Mở app Flutter:
   ```powershell
   cd "d:\WebQuanLyGiaiDau_NhomTD\tournament_app"
   flutter run
   ```

2. Đăng nhập với:
   - **Email**: `admin@example.com`
   - **Password**: `Admin123!`

3. **Kiểm tra logs**:
   ```
   Login response status: 200
   User role from API: Admin  ✅
   ```

4. **Kiểm tra UI**: Profile screen nên hiển thị role = "Admin"

#### **B. Test với tài khoản User thường**
1. Đăng nhập với tài khoản khác (hoặc tạo tài khoản mới)
2. **Kiểm tra logs**:
   ```
   Login response status: 200
   User role from API: User  ✅
   ```

3. **Kiểm tra UI**: Profile screen nên hiển thị role = "User"

---

## 🔍 Debug Logs

Trong console/terminal khi chạy app, bạn sẽ thấy:

```
Login response status: 200
Login response body: {"success":true,"message":"Đăng nhập thành công","token":"...", "user":{"id":"...","email":"admin@example.com","role":"Admin"}}
User role from API: Admin
```

Nếu thấy role = "Admin" → ✅ **Fix thành công!**

---

## 📋 Tài Khoản Test

| Email | Password | Role | Mục đích |
|-------|----------|------|----------|
| `admin@example.com` | `Admin123!` | **Admin** | Test quyền admin |
| Tài khoản mới đăng ký | (tự đặt) | **User** | Test quyền user thường |

---

## ❓ Troubleshooting

### Lỗi: "Lỗi kết nối"
- ✅ Kiểm tra backend đang chạy: `http://192.168.1.142:8080`
- ✅ Kiểm tra IP đúng (chạy `ipconfig` xem IP máy)
- ✅ Đảm bảo điện thoại và máy tính cùng mạng WiFi

### Lỗi: Vẫn hiện role = "User" cho admin
- ✅ Xóa app và cài lại (xóa cache cũ)
- ✅ Check logs xem `User role from API: Admin` có xuất hiện không

### API trả về 404 hoặc 500
- ✅ Restart backend: Ctrl+C và chạy lại `dotnet run`
- ✅ Check database có dữ liệu admin chưa

---

## 🎯 Kết Quả Mong Đợi

✅ **Trên Web**: Admin login → Thấy menu quản trị
✅ **Trên App**: Admin login → Profile hiển thị role = "Admin"
✅ **Trên App**: User login → Profile hiển thị role = "User"

---

## 📝 Thay Đổi Code

### `auth_service.dart`
- ❌ Xóa: `_mockLogin()` và `_mockRegister()`
- ✅ Thêm: Logs để debug
- ✅ Catch error trả về message rõ ràng thay vì mock

### `environment.dart`
- ✅ Đổi API URL: `http://192.168.1.142:8080/api`

### Backend `AuthApiController.cs`
- ✅ Không đổi (đã hoạt động đúng)
