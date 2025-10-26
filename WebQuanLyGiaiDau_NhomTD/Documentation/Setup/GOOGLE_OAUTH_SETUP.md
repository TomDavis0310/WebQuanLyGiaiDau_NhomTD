# 🔐 Google OAuth Setup Guide

## 📋 Tổng quan
Hướng dẫn cấu hình Google OAuth cho ứng dụng Thể Thao 24/7, cho phép người dùng đăng nhập/đăng ký bằng tài khoản Google.

**⚠️ QUAN TRỌNG**: Hiện tại ứng dụng sẽ hiển thị thông báo "Google OAuth chưa được cấu hình" khi khởi động. Đây là bình thường và ứng dụng vẫn hoạt động với đăng nhập email thông thường.

## 🚀 Hướng dẫn nhanh (Quick Start)

**Nếu bạn muốn bỏ qua Google OAuth và chỉ sử dụng đăng nhập email:**
- Ứng dụng đã sẵn sàng sử dụng! Nút Google sẽ không hiển thị.
- Người dùng có thể đăng ký/đăng nhập bằng email bình thường.

**Nếu bạn muốn kích hoạt Google OAuth:**
1. Làm theo hướng dẫn chi tiết bên dưới
2. Cập nhật `appsettings.json` với Client ID và Client Secret
3. Khởi động lại ứng dụng

---

## 🚀 Bước 1: Tạo Google Cloud Project

### 1.1 Truy cập Google Cloud Console
1. Đi đến [Google Cloud Console](https://console.cloud.google.com/)
2. Đăng nhập bằng tài khoản Google
3. Tạo project mới hoặc chọn project hiện có

### 1.2 Tạo Project mới
1. Click **"Select a project"** → **"New Project"**
2. Nhập tên project: `Sports Tournament Management`
3. Click **"Create"**

---

## 🔧 Bước 2: Cấu hình OAuth Consent Screen

### 2.1 Thiết lập OAuth Consent Screen
1. Trong Google Cloud Console, đi đến **APIs & Services** → **OAuth consent screen**
2. Chọn **External** (cho phép tất cả người dùng Google)
3. Click **"Create"**

### 2.2 Điền thông tin ứng dụng
```
App name: Thể Thao 24/7
User support email: your-email@example.com
Developer contact information: your-email@example.com
```

### 2.3 Thêm Scopes (Phạm vi)
1. Click **"Add or Remove Scopes"**
2. Chọn:
   - `../auth/userinfo.email`
   - `../auth/userinfo.profile`
   - `openid`
3. Click **"Update"**

### 2.4 Test Users (Nếu cần)
- Thêm email test users nếu app đang ở chế độ testing

---

## 🔑 Bước 3: Tạo OAuth 2.0 Credentials

### 3.1 Tạo Credentials
1. Đi đến **APIs & Services** → **Credentials**
2. Click **"+ Create Credentials"** → **"OAuth 2.0 Client IDs"**
3. Chọn **Application type**: **Web application**

### 3.2 Cấu hình Web Application
```
Name: Sports Tournament Web App

Authorized JavaScript origins:
- http://localhost:5194
- https://localhost:7129
- https://yourdomain.com (production)

Authorized redirect URIs:
- http://localhost:5194/signin-google
- https://localhost:7129/signin-google
- https://yourdomain.com/signin-google (production)
```

### 3.3 Lưu Credentials
1. Click **"Create"**
2. Copy **Client ID** và **Client Secret**
3. Lưu thông tin này an toàn

---

## ⚙️ Bước 4: Cấu hình ứng dụng

### 4.1 Cập nhật appsettings.json
```json
{
  "Authentication": {
    "Google": {
      "ClientId": "YOUR_GOOGLE_CLIENT_ID_HERE",
      "ClientSecret": "YOUR_GOOGLE_CLIENT_SECRET_HERE"
    }
  }
}
```

### 4.2 Cập nhật appsettings.Development.json
```json
{
  "Authentication": {
    "Google": {
      "ClientId": "YOUR_GOOGLE_CLIENT_ID_HERE",
      "ClientSecret": "YOUR_GOOGLE_CLIENT_SECRET_HERE"
    }
  }
}
```

---

## 🔒 Bước 5: Bảo mật

### 5.1 Environment Variables (Khuyến nghị)
Thay vì lưu trực tiếp trong appsettings.json:

**Windows:**
```cmd
setx GOOGLE_CLIENT_ID "your_client_id_here"
setx GOOGLE_CLIENT_SECRET "your_client_secret_here"
```

**Linux/Mac:**
```bash
export GOOGLE_CLIENT_ID="your_client_id_here"
export GOOGLE_CLIENT_SECRET="your_client_secret_here"
```

### 5.2 Cập nhật Program.cs để đọc từ Environment
```csharp
.AddGoogle(googleOptions =>
{
    googleOptions.ClientId = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_ID")
        ?? builder.Configuration["Authentication:Google:ClientId"] ?? "";
    googleOptions.ClientSecret = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_SECRET")
        ?? builder.Configuration["Authentication:Google:ClientSecret"] ?? "";
    googleOptions.CallbackPath = "/signin-google";
});
```

---

## 🧪 Bước 6: Testing

### 6.1 Kiểm tra cấu hình
1. Chạy ứng dụng: `dotnet run`
2. Truy cập: `http://localhost:5194/Identity/Account/Login`
3. Kiểm tra nút "Đăng nhập bằng Google" có hiển thị

### 6.2 Test đăng nhập
1. Click nút "Đăng nhập bằng Google"
2. Được redirect đến Google OAuth
3. Chọn tài khoản Google
4. Được redirect về ứng dụng
5. Hoàn tất đăng ký với email

---

## 🚨 Troubleshooting

### Lỗi thường gặp:

**1. "redirect_uri_mismatch"**
- Kiểm tra Authorized redirect URIs trong Google Console
- Đảm bảo URL chính xác (http vs https, port number)

**2. "invalid_client"**
- Kiểm tra Client ID và Client Secret
- Đảm bảo credentials được copy chính xác

**3. "access_denied"**
- Kiểm tra OAuth Consent Screen đã được cấu hình
- Đảm bảo user email được thêm vào test users (nếu app ở chế độ testing)

**4. Không hiển thị nút Google**
- Kiểm tra `Model.ExternalLogins` có dữ liệu
- Kiểm tra Google authentication đã được cấu hình trong Program.cs

---

## 📝 Notes

### Production Deployment:
1. Cập nhật Authorized origins và redirect URIs với domain production
2. Sử dụng HTTPS cho production
3. Lưu credentials trong Azure Key Vault hoặc AWS Secrets Manager
4. Enable logging để debug issues

### Security Best Practices:
1. Không commit credentials vào source control
2. Sử dụng environment variables hoặc secret management
3. Regularly rotate Client Secret
4. Monitor OAuth usage trong Google Cloud Console

---

## ✅ Checklist hoàn thành

- [ ] Tạo Google Cloud Project
- [ ] Cấu hình OAuth Consent Screen
- [ ] Tạo OAuth 2.0 Credentials
- [ ] Cập nhật appsettings.json
- [ ] Test đăng nhập Google
- [ ] Cấu hình production URLs
- [ ] Setup environment variables
- [ ] Test trên production

---

**🎉 Hoàn thành! Người dùng giờ có thể đăng nhập bằng Google vào ứng dụng Thể Thao 24/7.**
