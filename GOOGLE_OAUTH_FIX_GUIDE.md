# Hướng Dẫn Sửa Lỗi "Đã chặn quyền truy cập: Lỗi ủy quyền" (Google OAuth)

Lỗi bạn gặp phải (`Error 401: invalid_client`, `The OAuth client was not found`) xuất hiện do ứng dụng chưa được cấu hình đúng **Client ID** và **Client Secret** từ Google Cloud Console. Hiện tại, ứng dụng đang sử dụng giá trị mặc định là `PASTE_YOUR_CLIENT_ID_HERE`.

Để khắc phục, bạn cần thực hiện các bước sau:

## Bước 1: Tạo Project trên Google Cloud Console

1. Truy cập [Google Cloud Console](https://console.cloud.google.com/).
2. Tạo một Project mới (hoặc chọn Project có sẵn).
3. Tìm kiếm và chọn **"APIs & Services"**.
4. Chọn **"OAuth consent screen"**:
   - Chọn **External** (nếu bạn muốn cho phép bất kỳ ai có tài khoản Google đăng nhập) hoặc **Internal** (chỉ trong tổ chức).
   - Điền thông tin App Name (ví dụ: `TDSports`), User support email, và Developer contact information.
   - Nhấn **Save and Continue**.

## Bước 2: Tạo Credentials (Client ID & Secret)

1. Vào mục **"Credentials"** (bên trái menu).
2. Nhấn **"+ CREATE CREDENTIALS"** -> chọn **"OAuth client ID"**.
3. **Application type**: Chọn **Web application**.
4. **Name**: Đặt tên (ví dụ: `TDSports Web Client`).
5. **Authorized redirect URIs**:
   - Thêm URI sau (đây là đường dẫn ứng dụng của bạn sẽ nhận phản hồi từ Google):
     - `https://localhost:7193/signin-google` (nếu chạy HTTPS local)
     - `http://localhost:5173/signin-google` (nếu chạy HTTP local)
     - `https://your-domain.com/signin-google` (nếu đã deploy)
   - *Lưu ý: Kiểm tra port ứng dụng của bạn đang chạy để điền chính xác.*
6. Nhấn **Create**.
7. Một bảng hiện ra chứa **Client ID** và **Client Secret**. Hãy copy 2 giá trị này.

## Bước 3: Cập nhật cấu hình trong Project

Mở file `WebQuanLyGiaiDau_NhomTD/appsettings.json` (và `appsettings.Development.json` nếu cần) và tìm đoạn cấu hình sau:

```json
  "Authentication": {
    "Google": {
      "ClientId": "PASTE_YOUR_CLIENT_ID_HERE",
      "ClientSecret": "PASTE_YOUR_CLIENT_SECRET_HERE"
    }
  }
```

Thay thế bằng thông tin bạn vừa lấy được:

```json
  "Authentication": {
    "Google": {
      "ClientId": "YOUR_REAL_CLIENT_ID_FROM_GOOGLE_CONSOLE.apps.googleusercontent.com",
      "ClientSecret": "YOUR_REAL_CLIENT_SECRET"
    }
  }
```

## Bước 4: (Nếu dùng Mobile App) Cập nhật cho Flutter

Nếu bạn đang test trên ứng dụng di động (Flutter), bạn cần làm thêm:

1. Trong Google Cloud Console, tạo thêm một **OAuth client ID** mới với Application type là **Android**.
2. Điền **Package name**: `com.nhomtd.tournament.tournament_app` (kiểm tra trong `android/app/build.gradle`).
3. Lấy **SHA-1 certificate fingerprint** từ máy của bạn (xem hướng dẫn trong file `tournament_app/GOOGLE_OAUTH_SETUP.md`).
4. Tải file `google-services.json` về và chép đè vào thư mục `tournament_app/android/app/`.

## Bước 5: Khởi động lại ứng dụng

Sau khi lưu file `appsettings.json`, hãy dừng và chạy lại ứng dụng backend (`dotnet run`) để cấu hình mới có hiệu lực.

---
**Lưu ý:** Đừng bao giờ commit `ClientSecret` thực lên GitHub public repository để bảo mật thông tin.
