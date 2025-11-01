# 📋 Phân Tích Các Tính Năng Còn Thiếu

**Ngày:** 31/10/2025  
**Trạng thái:** Đang phân tích và bổ sung

---

## ✅ Các Trang Đã Có

### Authentication & User
- ✅ `splash_screen.dart` - Màn hình khởi động
- ✅ `login_screen.dart` - Đăng nhập
- ✅ `register_screen.dart` - Đăng ký
- ✅ `profile_screen.dart` - Hồ sơ người dùng

### Dashboard & Overview
- ✅ `dashboard_screen.dart` - Dashboard tổng quan
- ✅ `sports_list_screen.dart` - Danh sách môn thể thao

### Tournament
- ✅ `tournament_list_screen.dart` - Danh sách giải đấu
- ✅ `tournament_detail_screen.dart` - Chi tiết giải đấu
- ✅ `standings_screen.dart` - Bảng xếp hạng (từ tournament_detail)
- ✅ `tournament_bracket_screen.dart` - Sơ đồ đấu loại

### Match
- ✅ `match_detail_screen.dart` - Chi tiết trận đấu (với SignalR)

### Team & Player
- ✅ `team_detail_screen.dart` - Chi tiết đội bóng
- ✅ `player_detail_screen.dart` - Chi tiết cầu thủ

### News
- ✅ `news_list_screen.dart` - Danh sách tin tức
- ✅ `news_detail_screen.dart` - Chi tiết tin tức

### Search
- ✅ `search_screen.dart` - Tìm kiếm toàn cục

---

## ❌ Các Trang Còn Thiếu

### 1. 📝 Edit Profile Screen
**Mục đích:** Chỉnh sửa thông tin cá nhân
**Backend API:** `PUT /api/Profile/update`
**Chức năng:**
- Cập nhật thông tin cá nhân (tên, email, số điện thoại)
- Upload/thay đổi ảnh đại diện
- Cập nhật thông tin bổ sung

**Trạng thái:** ❌ Chưa có (có TODO trong profile_screen.dart)

---

### 2. 🔐 Change Password Screen
**Mục đích:** Đổi mật khẩu
**Backend API:** `PUT /api/Profile/change-password`
**Chức năng:**
- Nhập mật khẩu cũ
- Nhập mật khẩu mới
- Xác nhận mật khẩu mới
- Validate độ mạnh mật khẩu

**Trạng thái:** ❌ Chưa có (có TODO trong profile_screen.dart)

---

### 3. 🔑 Forgot Password Screen
**Mục đích:** Quên mật khẩu và reset
**Backend API:** `POST /api/Auth/forgot-password`, `POST /api/Auth/reset-password`
**Chức năng:**
- Nhập email
- Gửi mã xác nhận
- Nhập mã OTP
- Đặt mật khẩu mới

**Trạng thái:** ❌ Chưa có (có TODO trong login_screen.dart)

---

### 4. 📋 Tournament Registration Screen
**Mục đích:** Đăng ký đội tham gia giải đấu
**Backend API:** `POST /api/TournamentApi/{id}/register`
**Chức năng:**
- Chọn đội để đăng ký
- Hiển thị thông tin giải đấu
- Xác nhận đăng ký
- Theo dõi trạng thái đăng ký

**Trạng thái:** ❌ Chưa có (có TODO trong tournament_list_screen.dart và tournament_detail_screen.dart)

---

### 5. 👥 Team Management Screens

#### 5.1. My Teams List Screen
**Mục đích:** Quản lý danh sách đội của tôi
**Backend API:** `GET /api/TeamsApi/my-teams`
**Chức năng:**
- Hiển thị danh sách đội mình quản lý
- Thêm đội mới
- Chỉnh sửa/Xóa đội

**Trạng thái:** ❌ Chưa có

#### 5.2. Create/Edit Team Screen
**Mục đích:** Tạo mới hoặc chỉnh sửa đội
**Backend API:** `POST /api/TeamsApi`, `PUT /api/TeamsApi/{id}`
**Chức năng:**
- Nhập thông tin đội (tên, logo, HLV)
- Upload logo đội
- Quản lý thông tin cơ bản

**Trạng thái:** ❌ Chưa có

#### 5.3. Add/Edit Player Screen
**Mục đích:** Thêm hoặc chỉnh sửa cầu thủ trong đội
**Backend API:** `POST /api/PlayersApi`, `PUT /api/PlayersApi/{id}`
**Chức năng:**
- Nhập thông tin cầu thủ (tên, số áo, vị trí)
- Upload ảnh cầu thủ
- Gán cầu thủ vào đội

**Trạng thái:** ❌ Chưa có

---

### 6. 📊 Statistics & Analytics Screens

#### 6.1. Tournament Statistics Screen
**Mục đích:** Thống kê chi tiết giải đấu
**Backend API:** `GET /api/StatisticApi/tournament/{id}`
**Chức năng:**
- Top scorers (vua phá lưới)
- Top assists (kiến tạo)
- Best players
- Team statistics
- Match statistics

**Trạng thái:** ❌ Chưa có (backend có StatisticController)

#### 6.2. Player Performance Chart Screen
**Mục đích:** Biểu đồ thành tích cầu thủ
**Backend API:** `GET /api/PlayersApi/{id}/statistics/summary`
**Chức năng:**
- Biểu đồ điểm số theo thời gian
- Biểu đồ phong độ
- So sánh với các cầu thủ khác

**Trạng thái:** ❌ Chưa có (model có, chưa implement UI)

---

### 7. 📺 Video/Media Screens

#### 7.1. Video Highlights Screen
**Mục đích:** Xem video highlights trận đấu
**Backend API:** Có `YouTubeController` nhưng chưa có API endpoint cụ thể
**Chức năng:**
- Embed YouTube videos
- Danh sách video highlights
- Filter theo giải đấu/trận đấu

**Trạng thái:** ❌ Chưa có

#### 7.2. Photo Gallery Screen
**Mục đích:** Album ảnh giải đấu/trận đấu
**Backend API:** Chưa có
**Chức năng:**
- Grid view ảnh
- Lightbox viewer
- Filter theo giải đấu/trận đấu

**Trạng thái:** ❌ Chưa có

---

### 8. ⚙️ Settings Screen
**Mục đích:** Cài đặt ứng dụng
**Chức năng:**
- Thay đổi ngôn ngữ
- Theme (light/dark mode)
- Thông báo (notification settings)
- Cache management
- About app

**Trạng thái:** ❌ Chưa có

---

### 9. 🔔 Notifications Screen
**Mục đích:** Xem danh sách thông báo
**Backend API:** Cần endpoint mới
**Chức năng:**
- Danh sách thông báo
- Đánh dấu đã đọc
- Filter theo loại thông báo
- Delete notifications

**Trạng thái:** ❌ Chưa có

---

### 10. 📜 Rules & Regulations Screen
**Mục đích:** Xem luật chơi và quy định giải đấu
**Backend API:** `GET /api/RulesApi` (có RulesController)
**Chức năng:**
- Hiển thị luật chơi theo môn thể thao
- Quy định giải đấu
- Download PDF rules

**Trạng thái:** ❌ Chưa có

---

### 11. 🎯 Match Prediction/Voting Screen
**Mục đích:** Dự đoán kết quả trận đấu
**Backend API:** Chưa có
**Chức năng:**
- Dự đoán tỷ số
- Vote cho đội chiến thắng
- Leaderboard dự đoán

**Trạng thái:** ❌ Chưa có (tính năng mở rộng)

---

### 12. 💬 Chat/Comments Screen
**Mục đích:** Chat trực tiếp trong trận đấu
**Backend API:** Chưa có (có thể dùng SignalR)
**Chức năng:**
- Real-time chat
- Comments trận đấu
- Emoji reactions

**Trạng thái:** ❌ Chưa có (tính năng mở rộng)

---

## 🎯 Ưu Tiên Phát Triển

### Mức Độ Cao (Cần thiết)
1. ✅ **Edit Profile Screen** - Quan trọng cho user experience
2. ✅ **Change Password Screen** - Bảo mật cơ bản
3. ✅ **Forgot Password Screen** - Recovery account
4. ✅ **Tournament Registration Screen** - Core feature
5. ✅ **Team Management Screens** - Core feature

### Mức Độ Trung Bình
6. ⚠️ **Statistics & Analytics Screens** - Nâng cao trải nghiệm
7. ⚠️ **Settings Screen** - User preferences
8. ⚠️ **Notifications Screen** - Engagement
9. ⚠️ **Rules Screen** - Informational

### Mức Độ Thấp (Nice to have)
10. 💡 **Video/Media Screens** - Content enhancement
11. 💡 **Match Prediction** - Gamification
12. 💡 **Chat/Comments** - Social features

---

## 📊 Tổng Kết

**Màn hình đã có:** 16 screens  
**Màn hình còn thiếu:** ~15-20 screens (tùy feature)  
**Tỷ lệ hoàn thành:** ~50-60%

**Backend APIs sẵn sàng nhưng chưa có UI:**
- RulesController ✓
- StatisticController ✓
- YouTubeController ✓
- StandingsApiController ✓ (đã có UI riêng)
- DashboardApiController ✓ (đã có dashboard_screen)

---

## 🚀 Kế Hoạch Tiếp Theo

### Phase 1: Core User Features (Tuần 1)
- [ ] Edit Profile Screen
- [ ] Change Password Screen
- [ ] Forgot Password Screen
- [ ] Settings Screen

### Phase 2: Tournament Management (Tuần 2)
- [ ] Tournament Registration Screen
- [ ] Team Management Screens
  - [ ] My Teams List
  - [ ] Create/Edit Team
  - [ ] Add/Edit Player

### Phase 3: Analytics & Content (Tuần 3)
- [ ] Tournament Statistics Screen
- [ ] Player Performance Chart
- [ ] Rules Screen
- [ ] Notifications Screen

### Phase 4: Media & Social (Tuần 4)
- [ ] Video Highlights Screen
- [ ] Photo Gallery Screen
- [ ] Match Prediction (optional)
- [ ] Chat/Comments (optional)

---

**Tác giả:** GitHub Copilot  
**Cập nhật:** 31/10/2025
