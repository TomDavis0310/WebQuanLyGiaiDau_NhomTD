# 📋 CẤU HÌNH GOOGLE OAUTH - MẪU COPY PASTE

## 🔧 Cấu hình cho appsettings.json

Sau khi có Client ID và Client Secret từ Google Cloud Console, copy đoạn code sau vào file `appsettings.json`:

```json
"Authentication": {
  "Google": {
    "ClientId": "123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com",
    "ClientSecret": "GOCSPX-abcdefghijklmnopqrstuvwxyz123456"
  }
}
```

## 🔧 Cấu hình cho appsettings.Development.json

Cũng copy vào file `appsettings.Development.json`:

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
      "ClientId": "123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com",
      "ClientSecret": "GOCSPX-abcdefghijklmnopqrstuvwxyz123456"
    }
  }
}
```

## 🔒 Sử dụng Environment Variables (Tùy chọn - Bảo mật cao hơn)

Thay vì lưu trực tiếp trong file config, bạn có thể dùng environment variables:

**PowerShell:**
```powershell
$env:GOOGLE_CLIENT_ID="123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com"
$env:GOOGLE_CLIENT_SECRET="GOCSPX-abcdefghijklmnopqrstuvwxyz123456"
```

**Command Prompt:**
```cmd
setx GOOGLE_CLIENT_ID "123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com"
setx GOOGLE_CLIENT_SECRET "GOCSPX-abcdefghijklmnopqrstuvwxyz123456"
```

Sau đó khởi động lại VS Code và terminal.

## ✅ Kiểm tra cấu hình thành công

Khi chạy `dotnet run`, bạn sẽ thấy:
```
✅ Google OAuth đã được cấu hình thành công!
```

Thay vì:
```
⚠️ Google OAuth chưa được cấu hình
```

## 🎯 URL cần thiết cho Google Cloud Console

**Authorized JavaScript origins:**
```
http://localhost:5194
https://localhost:7129
```

**Authorized redirect URIs:**
```
http://localhost:5194/signin-google
https://localhost:7129/signin-google
```

---

**⚠️ LƯU Ý**: 
- Thay thế `123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com` bằng Client ID thực tế của bạn
- Thay thế `GOCSPX-abcdefghijklmnopqrstuvwxyz123456` bằng Client Secret thực tế của bạn
- Không chia sẻ Client Secret với ai khác