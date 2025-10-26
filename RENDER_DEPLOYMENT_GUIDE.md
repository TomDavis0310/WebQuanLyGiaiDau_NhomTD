# 🚀 Hướng Dẫn Deploy lên Render với Docker

## 📋 Các file đã tạo:

1. **`Dockerfile`** - Multi-stage build cho .NET 9.0
2. **`.dockerignore`** - Loại trừ file không cần thiết
3. **`render.yaml`** - Cấu hình tự động cho Render
4. **`Program.cs`** - Đã cập nhật để hỗ trợ PORT động

## 🔧 Bước 1: Commit và Push lên GitHub

```powershell
cd D:\WebQuanLyGiaiDau_NhomTD
git add .
git commit -m "Add Docker support for Render deployment"
git push origin main
```

## 🌐 Bước 2: Deploy trên Render

### Option A: Sử dụng render.yaml (Khuyến nghị)

1. Truy cập [https://dashboard.render.com](https://dashboard.render.com)
2. Click **"New +"** → **"Blueprint"**
3. Connect repository: `TomDavis0310/WebQuanLyGiaiDau_NhomTD`
4. Render sẽ tự động phát hiện `render.yaml` và cấu hình

### Option B: Tạo Web Service thủ công

1. Truy cập [https://dashboard.render.com](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect repository: `TomDavis0310/WebQuanLyGiaiDau_NhomTD`
4. Cấu hình:
   - **Name**: `webquanlygiaidau`
   - **Environment**: `Docker`
   - **Dockerfile Path**: `WebQuanLyGiaiDau_NhomTD/Dockerfile`
   - **Docker Context**: `WebQuanLyGiaiDau_NhomTD`
   - **Instance Type**: `Free` (hoặc chọn tier khác)

## 🔑 Bước 3: Cấu hình Environment Variables

⚠️ **QUAN TRỌNG**: Bạn phải cấu hình database trước!

### 3.1. Tạo PostgreSQL Database (Free trên Render)

1. Trong Render Dashboard → **"New +"** → **"PostgreSQL"**
2. Tên: `webquanlygiaidau-db`
3. Database: `qlgddb`
4. User: `qlgddb_user`
5. Region: Chọn gần nhất
6. Click **"Create Database"**
7. Copy **Internal Database URL** (dạng: `postgresql://...`)

### 3.2. Chuyển đổi Connection String

Vì project dùng SQL Server, bạn cần:

**Option 1: Đổi sang PostgreSQL** (Khuyến nghị cho Render)
- Cài package: `Npgsql.EntityFrameworkCore.PostgreSQL`
- Thay đổi trong `Program.cs`:
  ```csharp
  options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"))
  ```

**Option 2: Dùng Azure SQL Database** (Có phí)
- Tạo Azure SQL Database
- Lấy connection string từ Azure Portal

### 3.3. Set Environment Variables trong Render

Vào **Environment** tab của Web Service, thêm:

```
ASPNETCORE_ENVIRONMENT=Production

# PostgreSQL (nếu dùng Render PostgreSQL)
ConnectionStrings__DefaultConnection=postgresql://user:password@host:5432/database

# Hoặc SQL Server (nếu dùng Azure SQL)
ConnectionStrings__DefaultConnection=Server=tcp:your-server.database.windows.net,1433;Database=QLGDDB;User ID=username;Password=password;Encrypt=True;TrustServerCertificate=False;

# YouTube API
YouTube__ApiKey=YOUR_ACTUAL_YOUTUBE_API_KEY

# Google OAuth
GOOGLE_CLIENT_ID=YOUR_ACTUAL_GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=YOUR_ACTUAL_GOOGLE_CLIENT_SECRET
```

## 📦 Bước 4: Deploy

1. Click **"Create Web Service"** hoặc **"Deploy Blueprint"**
2. Render sẽ:
   - Clone repository
   - Build Docker image
   - Deploy container
   - Assign URL: `https://webquanlygiaidau.onrender.com`

## ✅ Bước 5: Kiểm tra

Sau khi deploy thành công:

1. Truy cập URL được cung cấp
2. Test endpoint: `https://your-app.onrender.com/ping`
3. Xem logs trong Render Dashboard nếu có lỗi

## 🔧 Chuyển đổi sang PostgreSQL (Chi tiết)

### 1. Cập nhật `.csproj`:

```xml
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="9.0.2" />
<!-- Có thể bỏ hoặc giữ SQL Server package cho development -->
```

### 2. Cập nhật `Program.cs`:

```csharp
// Đổi từ:
options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))

// Thành:
options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection"))
```

### 3. Tạo Migration mới:

```powershell
# Xóa folder Migrations (backup trước)
Remove-Item -Path "Migrations" -Recurse

# Tạo migration mới cho PostgreSQL
dotnet ef migrations add InitialPostgreSQL
dotnet ef database update
```

### 4. Cập nhật `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=QLGDDB;Username=postgres;Password=your_password"
  }
}
```

## 🐛 Troubleshooting

### Lỗi: "Build failed"
- Kiểm tra Dockerfile path và context đúng
- Xem logs chi tiết trong Render Dashboard

### Lỗi: "Application failed to start"
- Kiểm tra PORT environment variable
- Xem logs: `ASPNETCORE_URLS` có đúng không

### Lỗi: "Database connection failed"
- Kiểm tra Connection String
- Đảm bảo database đã tạo
- Kiểm tra firewall rules (nếu dùng Azure SQL)

### Render Free Tier tự động sleep
- Service sẽ sleep sau 15 phút không hoạt động
- Khởi động lại khi có request (thời gian boot ~30s)

## 💰 Chi phí

- **Render Free Tier**:
  - Web Service: Free (với giới hạn)
  - PostgreSQL: Free (với giới hạn 1GB)
  - Auto-sleep sau 15 phút không hoạt động

- **Render Paid Tiers**: Từ $7/tháng cho luôn online

## 📚 Tài liệu tham khảo

- [Render Docs - Docker](https://render.com/docs/docker)
- [Render Docs - Environment Variables](https://render.com/docs/environment-variables)
- [ASP.NET Core on Docker](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/)

---

## 🎯 Tóm tắt quy trình:

1. ✅ Đã tạo Dockerfile
2. ✅ Đã cập nhật Program.cs
3. ✅ Đã tạo render.yaml
4. 🔄 Commit & push code
5. 🔄 Tạo PostgreSQL database trên Render
6. 🔄 Cấu hình Environment Variables
7. 🔄 Deploy trên Render

**Bạn đã sẵn sàng deploy! 🚀**
