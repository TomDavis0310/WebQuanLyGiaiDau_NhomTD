# 🏆 WebQuanLyGiaiDau_NhomTD - Tournament Management System

[![Status](https://img.shields.io/badge/status-production%20ready-brightgreen)]()
[![API Coverage](https://img.shields.io/badge/API%20coverage-100%25-success)]()
[![Screens](https://img.shields.io/badge/screens-33%2F33-success)]()
[![.NET](https://img.shields.io/badge/.NET-8.0-blue)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)]()

Hệ thống quản lý giải đấu thể thao toàn diện với Web Application và Mobile App.

**🎉 Phase 6 Complete:** Tất cả 33 màn hình đã được tích hợp với hệ thống navigation hoàn chỉnh!

---

## 🎯 Tính Năng Chính

### 🎮 Cho Người Dùng
- ✅ Xem giải đấu, lịch thi đấu
- ✅ **Đăng ký đội tham gia giải** 🆕
- ✅ Theo dõi kết quả trực tiếp (SignalR)
- ✅ Xem thống kê, bảng xếp hạng
- ✅ **Quản lý đội và cầu thủ (CRUD)** 🆕
- ✅ Xem tin tức, video highlights
- ✅ Tìm kiếm video YouTube
- ✅ **Dashboard cá nhân** 🆕

### 👨‍💼 Cho Admin
- ✅ Quản lý giải đấu, đội, cầu thủ
- ✅ Tạo lịch thi đấu tự động
- ✅ Cập nhật tỷ số real-time
- ✅ Quản lý video highlights
- ✅ Phê duyệt đăng ký
- ✅ Quản lý tin tức

### 📱 Mobile App (Flutter)
- ✅ **33 màn hình hoàn chỉnh** 🆕
- ✅ **Navigation system tích hợp** 🆕
- ✅ **Team/Player Management UI** 🆕
- ✅ **Tournament Registration Flow** 🆕
- ✅ Tất cả tính năng web
- ✅ Push notifications
- ✅ Offline support
- ✅ Video player tích hợp

---

## 🏗️ Kiến Trúc

```
WebQuanLyGiaiDau_NhomTD/
├── WebQuanLyGiaiDau_NhomTD/    # Backend (ASP.NET Core)
│   ├── Controllers/
│   │   ├── Api/                # REST API Controllers
│   │   └── ...                 # MVC Controllers
│   ├── Models/
│   ├── Services/
│   ├── Hubs/                   # SignalR Hubs
│   └── Views/
├── tournament_app/             # Mobile App (Flutter)
│   ├── lib/
│   │   ├── models/
│   │   ├── services/
│   │   ├── screens/
│   │   └── widgets/
│   └── assets/
└── docs/                       # Documentation
    ├── api/                    # API Documentation
    ├── reports/                # Completion Reports
    ├── setup/                  # Setup Guides
    ├── guides/                 # User Guides
    └── deployment/             # Deployment Guides
```

---

## 🚀 Quick Start

### Prerequisites
- .NET 8.0 SDK
- SQL Server 2019+
- Flutter 3.0+ (cho mobile app)
- Node.js (optional, cho frontend tooling)

### Backend Setup
```bash
# Clone repository
git clone https://github.com/TomDavis0310/WebQuanLyGiaiDau_NhomTD.git
cd WebQuanLyGiaiDau_NhomTD

# Setup database
# Update connection string in appsettings.json

# Run migrations
cd WebQuanLyGiaiDau_NhomTD
dotnet ef database update

# Run application
dotnet run

# Access at http://localhost:8080
```

### Mobile App Setup
```bash
cd tournament_app

# Get dependencies
flutter pub get

# Run on emulator/device
flutter run
```

**Chi tiết:** Xem [`docs/setup/ENVIRONMENT_SETUP_GUIDE.md`](docs/setup/ENVIRONMENT_SETUP_GUIDE.md)

---

## 📚 Documentation

### 🚀 Quick Links

| Document | Description |
|----------|-------------|
| [📖 Docs Index](docs/README.md) | Tổng quan tất cả tài liệu |
| [🚀 Quick Start](QUICK_START_GUIDE.md) | Hướng dẫn nhanh 🆕 |
| [✅ Phase 6 Report](docs/completion-reports/PHASE_6_ALL_FEATURES_INTEGRATED.md) | Báo cáo hoàn thành 🆕 |
| [📋 Features Checklist](docs/FEATURES_CHECKLIST.md) | Danh sách tính năng |
| [🔧 API Reference](docs/api/QUICK_API_REFERENCE.md) | Tham chiếu nhanh APIs |
| [⚙️ Setup Guide](docs/setup/ENVIRONMENT_SETUP_GUIDE.md) | Hướng dẫn setup |
| [🎬 YouTube API](docs/api/API_YOUTUBE_DOCUMENTATION.md) | YouTube integration |
| [📅 Schedule API](docs/api/API_SCHEDULE_DOCUMENTATION.md) | Auto schedule generation |

### 📖 Full Documentation
Xem tất cả tài liệu tại: [`docs/README.md`](docs/README.md)

---

## 🎬 API Documentation

### Swagger UI
Truy cập: **http://localhost:8080/api-docs**

### API Modules (15 Controllers, 96+ Endpoints)

| Module | Endpoints | Description |
|--------|-----------|-------------|
| Authentication | 6 | Login, Register, JWT |
| Dashboard | 6 | User dashboard, stats |
| Tournaments | 15 | CRUD, registration, schedule |
| Matches | 8 | List, detail, live updates |
| Teams | 10 | CRUD, players |
| Players | 7 | CRUD, statistics |
| Sports | 4 | List, tournaments |
| News | 7 | CRUD, highlights |
| Statistics | 6 | Tournament, team, player stats |
| Standings | 3 | Rankings |
| Profile | 5 | User profile management |
| Search | 2 | Global search |
| Rules | 3 | Sport rules |
| Notifications | 3 | User notifications |
| **YouTube** | 11 | Video search, highlights |

**Total:** 100% API Coverage ✅

---

## 🛠️ Technology Stack

### Backend
- **Framework:** ASP.NET Core 8.0
- **Database:** SQL Server 2019+
- **ORM:** Entity Framework Core
- **Authentication:** ASP.NET Identity + JWT
- **Real-time:** SignalR
- **API Docs:** Swagger/OpenAPI

### Frontend (Web)
- **Framework:** ASP.NET MVC
- **UI:** Bootstrap 5
- **JavaScript:** jQuery, Chart.js
- **Real-time:** SignalR Client

### Mobile App
- **Framework:** Flutter 3.0+
- **State Management:** Provider/Riverpod
- **HTTP Client:** Dio
- **Storage:** SQLite, SharedPreferences
- **Video:** YouTube Player

### External APIs
- **YouTube Data API v3** - Video integration
- **Google OAuth** - Social login

---

## 🎯 Features Implemented

### ✅ Phase 1-6 Complete ✨
- [x] **Phase 1-2:** Authentication & Core Features
- [x] **Phase 3:** Statistics & Tournament Rules
- [x] **Phase 4:** User Dashboard & Core Features
- [x] **Phase 5:** Tournament Management Advanced
- [x] **Phase 6:** Navigation & Team/Player Management 🆕
  - [x] Navigation system với 27 routes
  - [x] Team Management (Create/Edit/Delete)
  - [x] Player Management (Add/Edit/Delete)
  - [x] Tournament Registration UI
  - [x] All APIs integrated and verified

### 🎬 New Features (Nov 2024)
- [x] YouTube API - 11 endpoints
- [x] Auto Schedule Generation
- [x] Complete API documentation
- [x] Flutter integration examples

---

## 🔐 Default Accounts

### Admin
```
Email: admin@example.com
Password: Admin123!
```

### Test Users
Multiple test users are seeded automatically. Check console output on first run.

---

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| **Screens** | **33/33** ✅ |
| **Routes** | **27** 🆕 |
| **Controllers** | 30+ |
| **API Endpoints** | 96+ |
| **Models** | 35+ |
| **Views** | 50+ |
| **Services** | 10+ |
| **Hubs** | 2 |
| **API Coverage** | 100% ✅ |
| **Lines of Code** | 25,000+ |

---

## 🧪 Testing

### Backend
```bash
dotnet test
```

### API Testing
- **Swagger UI:** http://localhost:8080/api-docs
- **Postman:** Import collection from Swagger
- Test guides in [`docs/guides/`](docs/guides/)

### Mobile App
```bash
cd tournament_app
flutter test
```

---

## 🚢 Deployment

### Development
```bash
dotnet run
# http://localhost:8080
```

### Production
Xem hướng dẫn: [`docs/deployment/RENDER_DEPLOYMENT_GUIDE.md`](docs/deployment/RENDER_DEPLOYMENT_GUIDE.md)

**Supported Platforms:**
- Azure App Service
- Render.com
- Docker
- IIS
- Linux (Nginx)

---

## 📱 Mobile App

### Features
- ✅ Complete tournament browsing
- ✅ Team registration
- ✅ Live match updates
- ✅ Statistics & standings
- ✅ Video player (YouTube)
- ✅ User dashboard
- ✅ Push notifications

### Screenshots
Coming soon...

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📝 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 👥 Team

**Nhóm TD**
- TomDavis0310 (Project Lead)
- [Team members...]

---

## 📞 Support

- **Documentation:** [`docs/README.md`](docs/README.md)
- **Issues:** GitHub Issues
- **Email:** [your-email]

---

## 🎉 Acknowledgments

- ASP.NET Core team
- Flutter team
- YouTube Data API
- All open-source contributors

---

## 📈 Roadmap

### Version 2.0 (Current) ✅
- [x] Complete API coverage
- [x] YouTube integration
- [x] Auto schedule generation
- [x] Full documentation

### Version 2.1 (Current - Phase 6) ✅
- [x] Complete navigation system
- [x] Team/Player CRUD UI
- [x] Tournament registration flow
- [x] All 33 screens integrated
- [x] Full mobile app functionality

### Version 2.2 (Planned)
- [ ] Image upload (image_picker)
- [ ] Advanced form validation
- [ ] Enhanced statistics
- [ ] Performance optimizations
- [ ] Dark mode support

### Version 3.0 (Future)
- [ ] AI-powered recommendations
- [ ] Advanced statistics
- [ ] Tournament brackets
- [ ] Sponsor management
- [ ] Ticketing system

---

## ⭐ Star History

If you find this project useful, please consider giving it a star! ⭐

---

**Last Updated:** November 1, 2025  
**Version:** 2.1 (Phase 6 Complete)  
**Status:** Production Ready ✅

---

<div align="center">

Made with ❤️ by Nhóm TD

[Documentation](docs/README.md) • [Quick Start](QUICK_START_GUIDE.md) • [Phase 6 Report](docs/completion-reports/PHASE_6_ALL_FEATURES_INTEGRATED.md)

</div>
