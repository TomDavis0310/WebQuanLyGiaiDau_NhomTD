# Cấu Trúc Dự Án - WebQuanLyGiaiDau_NhomTD

## Tổng Quan
Dự án đã được tổ chức lại với cấu trúc thư mục khoa học và sạch sẽ để dễ bảo trì và phát triển.

## Cấu Trúc Thư Mục

### 📁 **Data/** - Dữ liệu và Cơ sở dữ liệu
```
Data/
├── SQL/          # Scripts SQL và PowerShell cho database
│   ├── *.sql     # Các file script SQL
│   └── *.ps1     # Scripts PowerShell
└── Seed/         # Dữ liệu khởi tạo
    ├── Create*.cs     # Tạo bảng
    └── Seed*.cs       # Dữ liệu mẫu
```

### 📁 **Documentation/** - Tài liệu
```
Documentation/
├── Setup/        # Hướng dẫn cài đặt
│   ├── README.md
│   ├── GOOGLE_OAUTH_SETUP.md
│   └── YOUTUBE_API_SETUP.md
├── Reports/      # Báo cáo hoàn thành
│   ├── *_COMPLETE.md
│   ├── *_SUMMARY.md
│   └── *_REPORT.md
├── DEMO_YOUTUBE_URLS.md
├── FINAL_SUCCESS_GUIDE.md
├── YOUTUBE_UI_GUIDE.md
└── ScaffoldingReadMe.txt
```

### 📁 **Core Application** - Ứng dụng chính
```
Controllers/      # Controllers MVC
Models/          # Entity models
Views/           # Razor views
Services/        # Business logic services
Repositories/    # Data access repositories
Hubs/           # SignalR hubs
Migrations/     # Entity Framework migrations
Areas/          # ASP.NET Core Areas (Identity)
wwwroot/        # Static files (CSS, JS, images)
```

### 📁 **Configuration** - Cấu hình
```
Properties/      # Launch settings
appsettings.json # Cấu hình ứng dụng
Program.cs       # Entry point
*.csproj        # Project file
```

## Lợi Ích Của Cấu Trúc Mới

1. **Tổ chức khoa học**: Phân loại file theo chức năng
2. **Dễ tìm kiếm**: File được nhóm theo mục đích sử dụng
3. **Bảo trì tốt hơn**: Cấu trúc rõ ràng, dễ hiểu
4. **Mở rộng dễ dàng**: Thêm file mới vào đúng thư mục
5. **Teamwork hiệu quả**: Mọi người đều hiểu cấu trúc

## Hướng Dẫn Sử dụng

### Thêm SQL Script mới
```bash
# Đặt file *.sql vào Data/SQL/
Data/SQL/new_migration.sql
```

### Thêm Seed Data mới
```bash
# Đặt file Seed*.cs vào Data/Seed/
Data/Seed/SeedNewData.cs
```

### Thêm tài liệu mới
```bash
# Setup guides -> Documentation/Setup/
# Reports -> Documentation/Reports/
# General docs -> Documentation/
```

## Chú Ý
- Không đặt file trực tiếp ở thư mục gốc trừ các file cấu hình chính
- Luôn sử dụng tên file mô tả rõ chức năng
- Cập nhật documentation khi thêm tính năng mới
