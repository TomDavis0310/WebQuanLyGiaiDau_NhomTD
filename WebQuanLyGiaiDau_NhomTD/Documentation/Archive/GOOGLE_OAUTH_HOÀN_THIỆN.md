# 🔐 HƯỚNG DẪN HOÀN THIỆN GOOGLE OAUTH CHO TD SPORTS

## 📋 Tình trạng hiện tại
Hiện tại ứng dụng đã được cấu hình sẵn để hỗ trợ Google OAuth, nhưng chưa có thông tin xác thực thực tế. Khi chạy ứng dụng, bạn sẽ thấy thông báo:

```
⚠️ Google OAuth chưa được cấu hình. Vui lòng xem hướng dẫn trong GOOGLE_OAUTH_SETUP.md
   Đăng nhập bằng Google sẽ không hoạt động cho đến khi bạn cấu hình thông tin xác thực.
   Bạn vẫn có thể đăng nhập bằng tài khoản cục bộ.
```

## 🎯 Mục tiêu
Sau khi hoàn thành hướng dẫn này, người dùng sẽ có thể:
- ✅ Đăng nhập bằng tài khoản Google 
- ✅ Đăng ký tài khoản mới bằng Google
- ✅ Thấy nút "Đăng nhập bằng Google" trên trang Login
- ✅ Tự động liên kết tài khoản Google với hệ thống

---

## 🚀 BƯỚC 1: TẠO GOOGLE CLOUD PROJECT

### 1.1 Truy cập Google Cloud Console
1. Mở trình duyệt và đi đến: https://console.cloud.google.com/
2. Đăng nhập bằng tài khoản Google của bạn
3. Nếu chưa có project nào, hệ thống sẽ yêu cầu tạo project đầu tiên

### 1.2 Tạo project mới
1. Click vào dropdown **"Select a project"** ở đầu trang
2. Click **"NEW PROJECT"**
3. Điền thông tin:
   ```
   Project name: TD-Sports-Tournament
   Location: No organization (hoặc chọn organization nếu có)
   ```
4. Click **"CREATE"**
5. Đợi một vài giây để Google tạo project
6. Chắc chắn rằng project mới đã được chọn

---

## 🔧 BƯỚC 2: KÍCH HOẠT GOOGLE+ API

### 2.1 Enable APIs
1. Trong Google Cloud Console, đi đến menu bên trái **"APIs & Services"** > **"Library"**
2. Tìm kiếm **"Google+ API"** (hoặc **"People API"**)
3. Click vào API và nhấn **"Enable"**
4. Cũng tìm và enable **"Google Identity"** nếu có

---

## 🔐 BƯỚC 3: CẤU HÌNH OAUTH CONSENT SCREEN

### 3.1 Thiết lập OAuth Consent Screen
1. Đi đến **"APIs & Services"** > **"OAuth consent screen"**
2. Chọn **"External"** (để cho phép bất kỳ ai có tài khoản Google đăng nhập)
3. Click **"CREATE"**

### 3.2 Điền App Information
```
App name: TD Sports - Quản Lý Giải Đấu
User support email: [email của bạn]
App logo: (tùy chọn - có thể bỏ trống)
App domain:
- Application home page: http://localhost:5194
- Application privacy policy link: http://localhost:5194/privacy (tùy chọn)
- Application terms of service link: (tùy chọn)

Developer contact information:
Email addresses: [email của bạn]
```

### 3.3 Scopes
1. Click **"SAVE AND CONTINUE"** để đến bước Scopes
2. Click **"ADD OR REMOVE SCOPES"**
3. Chọn các scopes sau:
   - ✅ `../auth/userinfo.email`
   - ✅ `../auth/userinfo.profile` 
   - ✅ `openid`
4. Click **"UPDATE"**
5. Click **"SAVE AND CONTINUE"**

### 3.4 Test Users (cho Development)
1. Trong phần Test Users, click **"ADD USERS"**
2. Thêm email của bạn và của những người sẽ test ứng dụng
3. Click **"SAVE AND CONTINUE"**

### 3.5 Summary
1. Review lại thông tin
2. Click **"BACK TO DASHBOARD"**

---

## 🔑 BƯỚC 4: TẠO OAUTH 2.0 CREDENTIALS

### 4.1 Tạo Credentials
1. Đi đến **"APIs & Services"** > **"Credentials"**
2. Click **"+ CREATE CREDENTIALS"**
3. Chọn **"OAuth 2.0 Client IDs"**

### 4.2 Cấu hình Application Type
1. **Application type**: Chọn **"Web application"**
2. **Name**: `TD Sports Web Client`

### 4.3 Authorized JavaScript Origins
Thêm các origins sau:
```
http://localhost:5194
https://localhost:7129
http://127.0.0.1:5194
https://127.0.0.1:7129
```

### 4.4 Authorized Redirect URIs
Thêm các URIs sau:
```
http://localhost:5194/signin-google
https://localhost:7129/signin-google
http://127.0.0.1:5194/signin-google
https://127.0.0.1:7129/signin-google
```

### 4.5 Tạo và lưu thông tin
1. Click **"CREATE"**
2. Sẽ xuất hiện popup với **Client ID** và **Client Secret**
3. **QUAN TRỌNG**: Copy và lưu 2 thông tin này:
   ```
   Client ID: 123456789-abcdef.apps.googleusercontent.com
   Client Secret: GOCSPX-xyz123abc456def789
   ```
4. Click **"OK"**

---

## ⚙️ BƯỚC 5: CẬP NHẬT CẤU HÌNH ỨNG DỤNG

### 5.1 Cập nhật appsettings.json
Mở file `appsettings.json` và thay thế phần Authentication:

```json
{
  "Authentication": {
    "Google": {
      "ClientId": "PASTE_YOUR_CLIENT_ID_HERE",
      "ClientSecret": "PASTE_YOUR_CLIENT_SECRET_HERE"
    }
  }
}
```

**Ví dụ thực tế:**
```json
{
  "Authentication": {
    "Google": {
      "ClientId": "123456789-abcdefghijklmnop.apps.googleusercontent.com",
      "ClientSecret": "GOCSPX-xyz123abc456def789ghi012"
    }
  }
}
```

### 5.2 Cập nhật appsettings.Development.json
Cũng thêm cấu hình vào file Development:

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "Authentication": {
    "Google": {
      "ClientId": "PASTE_YOUR_CLIENT_ID_HERE",
      "ClientSecret": "PASTE_YOUR_CLIENT_SECRET_HERE"
    }
  }
}
```

---

## 🔒 BƯỚC 6: BẢO MẬT (KHUYẾN NGHỊ)

### 6.1 Sử dụng Environment Variables (Tùy chọn)
Thay vì lưu trực tiếp trong file config, bạn có thể sử dụng biến môi trường:

**Windows (PowerShell):**
```powershell
$env:GOOGLE_CLIENT_ID="your_client_id_here"
$env:GOOGLE_CLIENT_SECRET="your_client_secret_here"
```

**Windows (Command Prompt):**
```cmd
setx GOOGLE_CLIENT_ID "your_client_id_here"
setx GOOGLE_CLIENT_SECRET "your_client_secret_here"
```

Sau đó khởi động lại VS Code và terminal.

### 6.2 Kiểm tra .gitignore
Đảm bảo rằng file `.gitignore` không commit secrets:
```gitignore
appsettings.Development.json
*.secret
.env
```

---

## 🧪 BƯỚC 7: TESTING

### 7.1 Khởi động ứng dụng
```bash
cd WebQuanLyGiaiDau_NhomTD
dotnet run
```

### 7.2 Kiểm tra console log
Bạn sẽ thấy thông báo:
```
✅ Google OAuth đã được cấu hình thành công!
```

Thay vì thông báo lỗi như trước.

### 7.3 Test đăng nhập Google
1. Mở trình duyệt: `http://localhost:5194`
2. Đi đến trang **Login**: `http://localhost:5194/Identity/Account/Login`
3. Bạn sẽ thấy nút **"Đăng nhập bằng Google"** với icon Google đẹp mắt
4. Click nút này
5. Sẽ được chuyển đến trang đăng nhập Google
6. Chọn tài khoản Google và cho phép quyền truy cập
7. Được chuyển về ứng dụng và đăng nhập thành công

### 7.4 Kiểm tra account được tạo
1. Đăng nhập với tài khoản admin: `admin@example.com` / `Admin123!`
2. Đi đến trang quản lý người dùng (nếu có)
3. Kiểm tra tài khoản Google đã được tạo tự động

---

## 🚨 TROUBLESHOOTING - SỬA LỖI THƯỜNG GẶP

### ❌ Lỗi: "redirect_uri_mismatch"
**Nguyên nhân**: URL redirect không khớp với cấu hình trong Google Console

**Cách sửa**:
1. Kiểm tra lại **Authorized redirect URIs** trong Google Console
2. Đảm bảo URL chính xác: `http://localhost:5194/signin-google`
3. Chú ý `http` vs `https` và port number

### ❌ Lỗi: "invalid_client"
**Nguyên nhân**: Client ID hoặc Client Secret không đúng

**Cách sửa**:
1. Kiểm tra lại Client ID và Secret đã copy đúng chưa
2. Không có khoảng trống thừa ở đầu/cuối
3. Restart ứng dụng sau khi thay đổi config

### ❌ Lỗi: "access_denied"
**Nguyên nhân**: User không có quyền truy cập

**Cách sửa**:
1. Thêm email vào **Test Users** trong OAuth Consent Screen
2. Hoặc publish app để cho phép public access

### ❌ Không thấy nút Google Login
**Nguyên nhân**: External logins không được load

**Cách kiểm tra**:
1. Kiểm tra console log có thông báo "Google OAuth đã được cấu hình thành công!"
2. Kiểm tra cấu hình trong appsettings.json
3. Restart ứng dụng

---

## 🏁 KIỂM TRA HOÀN TẤT

### ✅ Checklist
- [ ] Google Cloud Project đã tạo
- [ ] OAuth Consent Screen đã cấu hình
- [ ] OAuth 2.0 Credentials đã tạo
- [ ] Client ID và Secret đã cập nhật vào appsettings.json
- [ ] Ứng dụng hiển thị "✅ Google OAuth đã được cấu hình thành công!"
- [ ] Nút "Đăng nhập bằng Google" hiển thị trên trang Login
- [ ] Có thể đăng nhập thành công bằng Google
- [ ] Tài khoản được tạo tự động trong hệ thống

### 🎉 Kết quả
Sau khi hoàn thành, ứng dụng TD Sports sẽ:
- ✅ Hỗ trợ đăng nhập/đăng ký bằng Google
- ✅ Tự động tạo tài khoản từ thông tin Google
- ✅ Liên kết email Google với hệ thống nội bộ
- ✅ Cung cấp trải nghiệm đăng nhập mượt mà cho người dùng

---

## 🔧 PRODUCTION DEPLOYMENT

Khi deploy lên production, nhớ:
1. Cập nhật **Authorized origins** và **redirect URIs** với domain thực
2. Sử dụng HTTPS
3. Lưu credentials trong Azure Key Vault hoặc environment variables
4. Enable monitoring trong Google Cloud Console

---

**📞 Hỗ trợ**: Nếu gặp vấn đề, hãy kiểm tra console logs và làm theo troubleshooting guide trên.