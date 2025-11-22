# 🚀 QUICK START - KÍCH HOẠT GOOGLE OAUTH

## ⚡ Hướng dẫn nhanh 5 phút

### Bước 1: Tạo Google Cloud Project
1. Đi đến: https://console.cloud.google.com/
2. Tạo project mới: **"TD-Sports-Tournament"**

### Bước 2: Cấu hình OAuth
1. **APIs & Services** → **OAuth consent screen**
2. Chọn **External** → Điền app name: **"TD Sports"**
3. Thêm email support và developer contact

### Bước 3: Tạo Credentials
1. **APIs & Services** → **Credentials**
2. **CREATE CREDENTIALS** → **OAuth 2.0 Client IDs**
3. **Web application**
4. **Authorized redirect URIs**: `http://localhost:5194/signin-google`
5. Copy **Client ID** và **Client Secret**

### Bước 4: Cập nhật cấu hình
Mở `appsettings.json` và thay thế:
```json
"Authentication": {
  "Google": {
    "ClientId": "PASTE_YOUR_CLIENT_ID_HERE",
    "ClientSecret": "PASTE_YOUR_CLIENT_SECRET_HERE"
  }
}
```

### Bước 5: Test
```bash
dotnet run
```

Truy cập: http://localhost:5194/Identity/Account/Login

**✅ Thành công**: Sẽ thấy nút "Đăng nhập bằng Google"

---

📖 **Xem hướng dẫn chi tiết**: `GOOGLE_OAUTH_HOÀN_THIỆN.md`