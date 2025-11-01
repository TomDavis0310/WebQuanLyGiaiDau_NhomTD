# 📝 Hướng Dẫn Tạo Users Cho Hệ Thống

## 🎯 Có 3 Cách Tạo Users

### **Cách 1: Chạy Backend và Tự Động Seed (Khuyến nghị)**

Khi khởi động backend, hệ thống sẽ tự động tạo users mặc định.

```powershell
# 1. Mở terminal và chạy backend
cd d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
dotnet run

# Backend sẽ tự động:
# - Tạo roles (Admin, User, Organizer)
# - Tạo admin user mặc định
# - Tạo tất cả users từ SeedUsersData
```

✅ **Users được tạo tự động:**
- Admin accounts
- Organizer accounts  
- Regular user accounts
- Test accounts

---

### **Cách 2: Sử Dụng PowerShell Script (Nếu Backend Đang Chạy)**

Nếu backend đã chạy nhưng chưa seed users, dùng script:

```powershell
# Chắc chắn backend đang chạy trên http://localhost:5194
cd d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
.\create-users.ps1
```

Script sẽ gọi API `/api/Auth/register` để tạo từng user.

---

### **Cách 3: Đăng Ký Thủ Công Qua API**

Sử dụng Postman, Swagger, hoặc PowerShell để gọi API:

```powershell
# Ví dụ tạo 1 user
$userData = @{
    email = "newuser@example.com"
    userName = "newuser"
    password = "Password@123"
    confirmPassword = "Password@123"
    fullName = "New User"
    phoneNumber = "0123456789"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5194/api/Auth/register" `
    -Method POST `
    -Body $userData `
    -ContentType "application/json"
```

---

## 📋 Danh Sách Tài Khoản Mặc Định

### 🔑 **Admin Accounts**

| Email | Username | Password | Full Name |
|-------|----------|----------|-----------|
| `admin@example.com` | `admin@example.com` | `Admin123!` | Admin User |
| `admin@tdsports.com` | `admin@tdsports.com` | `Admin@123` | Quản Trị Viên TD Sports |

### 🎯 **Organizer Accounts**

| Email | Username | Password | Full Name |
|-------|----------|----------|-----------|
| `organizer1@tdsports.com` | `organizer1@tdsports.com` | `Organizer@123` | Ban Tổ Chức 1 |
| `organizer2@tdsports.com` | `organizer2@tdsports.com` | `Organizer@123` | Ban Tổ Chức 2 |

### 👥 **User Accounts**

| Email | Username | Password | Full Name |
|-------|----------|----------|-----------|
| `user1@example.com` | `user1@example.com` | `User@123` | Nguyễn Văn A |
| `user2@example.com` | `user2@example.com` | `User@123` | Trần Thị B |
| `user3@example.com` | `user3@example.com` | `User@123` | Lê Văn C |
| `user4@example.com` | `user4@example.com` | `User@123` | Phạm Thị D |
| `user5@example.com` | `user5@example.com` | `User@123` | Hoàng Văn E |

### 🧪 **Test Accounts**

| Email | Username | Password | Full Name |
|-------|----------|----------|-----------|
| `test@example.com` | `test@example.com` | `Test@123` | Test User |
| `demo@tdsports.com` | `demo@tdsports.com` | `Demo@123` | Demo User |

---

## 🔧 Kiểm Tra Users Đã Tạo

### **Cách 1: Qua Database**

```sql
-- Xem tất cả users
SELECT Id, UserName, Email, FullName, PhoneNumber, EmailConfirmed
FROM AspNetUsers
ORDER BY Email;

-- Xem users và roles của họ
SELECT u.Email, u.FullName, r.Name as RoleName
FROM AspNetUsers u
LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id
ORDER BY u.Email;
```

### **Cách 2: Qua API Login**

```powershell
# Test login với một user
$loginData = @{
    email = "admin@tdsports.com"
    password = "Admin@123"
    rememberMe = $true
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5194/api/Auth/login" `
    -Method POST `
    -Body $loginData `
    -ContentType "application/json"

Write-Host "Login successful: $($response.success)"
Write-Host "Token: $($response.token)"
Write-Host "User: $($response.user | ConvertTo-Json)"
```

---

## ⚙️ Cấu Hình Seed Users

File seed users: `Data/Seed/SeedUsersData.cs`

Để thêm/sửa users, chỉnh sửa danh sách `usersToCreate` trong file này.

---

## 🚀 Quick Start

```powershell
# 1. Khởi động backend
cd d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
dotnet run

# 2. Đợi seed hoàn tất (xem console log)

# 3. Test login
$loginData = @{
    email = "admin@tdsports.com"
    password = "Admin@123"
    rememberMe = $true
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5194/api/Auth/login" `
    -Method POST `
    -Body $loginData `
    -ContentType "application/json"
```

---

## 🐛 Troubleshooting

### **Vấn đề: Users không được tạo**

✅ **Giải pháp:**
1. Kiểm tra console log khi start backend
2. Xem có lỗi seed không
3. Kiểm tra connection string database
4. Xem AspNetUsers table đã có users chưa

### **Vấn đề: Không login được**

✅ **Giải pháp:**
1. Kiểm tra email và password đúng chưa
2. Kiểm tra backend có chạy không
3. Xem EmailConfirmed = true chưa
4. Kiểm tra password hash trong database

### **Vấn đề: Script PowerShell báo lỗi**

✅ **Giải pháp:**
1. Kiểm tra backend đang chạy: `netstat -ano | findstr :5194`
2. Test API endpoint: `curl http://localhost:5194/api/Auth/validate`
3. Kiểm tra firewall không block port 5194

---

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. Backend console log
2. Database AspNetUsers table
3. API response messages
4. Network connectivity

---

**✅ Tất cả users đã được cấu hình và sẵn sàng sử dụng!**
