# 📋 Phase 6 Test Plan - Complete Navigation System Testing

**Tài liệu:** Test Plan cho Phase 6 Integration  
**Ngày tạo:** 2025-06-01  
**Status:** In Progress  

---

## 🎯 Test Objectives

Test tất cả 27 routes được integrate trong Phase 6, verify:
1. **Navigation Routes** - All screens accessible
2. **CRUD Operations** - Create/Edit/Delete functions
3. **API Integration** - Backend communication
4. **Real-time Features** - SignalR updates
5. **Authentication Flow** - Login/Register/Logout

---

## 📱 Test Environment

### Backend
- **URL:** http://localhost:8080
- **Database:** SQL Server LocalDB
- **Status:** ✅ Running (Started in separate PowerShell window)

### Frontend
- **Platform:** Android (SM A346E, Android 14 API 34)
- **Device ID:** RFCW81DX9WD
- **Status:** 🔄 Building (Gradle assembleDebug in progress)
- **Alternative:** Chrome web (port 8081), Windows desktop, Edge web

### API Endpoints
- **Base URL:** http://localhost:8080/api
- **Controllers:** 15 controllers với 50+ endpoints
- **Authentication:** JWT Bearer token

---

## 🧪 Test Cases

### 1️⃣ Authentication Flow (Priority: HIGH)

#### TC-01: Register New User
**Route:** `/register`  
**Steps:**
1. Open app → Redirect to login screen
2. Tap "Đăng ký" button
3. Fill form:
   - Username: `test_user_001`
   - Email: `test001@gmail.com`
   - Password: `Test@123`
   - Confirm Password: `Test@123`
   - Full Name: `Test User 001`
   - Date of Birth: Select date
   - Phone: `0987654321`
   - Role: `User` (default)
4. Submit form
5. Verify: Redirect to login screen with success message

**Expected Result:**
- ✅ User created in database
- ✅ Redirect to login screen
- ✅ Success toast notification

**API Call:** `POST /api/AccountsApi/register`

---

#### TC-02: Login with Registered User
**Route:** `/login`  
**Steps:**
1. Enter username: `test_user_001`
2. Enter password: `Test@123`
3. Tap "Đăng nhập" button
4. Verify: Redirect to dashboard

**Expected Result:**
- ✅ JWT token stored in SharedPreferences
- ✅ AuthProvider updated với user info
- ✅ Redirect to `/dashboard`

**API Call:** `POST /api/AccountsApi/login`

---

### 2️⃣ Dashboard Navigation (Priority: HIGH)

#### TC-03: Dashboard Bottom Navigation
**Route:** `/dashboard`  
**Steps:**
1. After login, verify dashboard displayed
2. Tap "Giải đấu" tab → Verify tournament list
3. Tap "Tin tức" tab → Verify news highlights
4. Tap "Cá nhân" tab → Verify profile screen

**Expected Result:**
- ✅ All 3 tabs functional
- ✅ Smooth tab switching animation
- ✅ Data loaded for each tab

---

#### TC-04: Tournament List Navigation
**Route:** `/tournaments`  
**Steps:**
1. From dashboard, tap tournament tab
2. Verify list of tournaments displayed
3. Tap "Tất cả" filter → Show all tournaments
4. Tap "Sắp diễn ra" → Filter upcoming tournaments
5. Tap "Đang diễn ra" → Filter ongoing tournaments
6. Tap "Đã kết thúc" → Filter completed tournaments

**Expected Result:**
- ✅ Filters work correctly
- ✅ Tournament cards show: name, dates, status, location
- ✅ Search bar functional

**API Call:** `GET /api/TournamentsApi`

---

### 3️⃣ Team Management CRUD (Priority: HIGH)

#### TC-05: View My Teams List
**Route:** `/my-teams`  
**Steps:**
1. From dashboard, tap menu → "Đội của tôi"
2. Verify list of teams displayed (may be empty if new user)

**Expected Result:**
- ✅ Empty state if no teams
- ✅ Team cards show: name, sport, player count
- ✅ FAB button (+) visible for creating team

**API Call:** `GET /api/TeamsApi/my-teams`

---

#### TC-06: Create New Team
**Route:** `/create-team`  
**Steps:**
1. From my-teams screen, tap FAB (+) button
2. Fill form:
   - Team Name: `Test Football Team`
   - Sport: Select `Bóng đá` (Football)
   - Coach Name: `Coach Nguyen`
3. Tap "Lưu" button
4. Verify: Redirect to my-teams with new team

**Expected Result:**
- ✅ Team created in database
- ✅ Team appears in my-teams list
- ✅ Success toast notification

**API Call:** `POST /api/TeamsApi`

---

#### TC-07: Edit Team
**Route:** `/edit-team/:id`  
**Steps:**
1. From my-teams, tap on "Test Football Team"
2. Tap edit icon (pencil)
3. Change:
   - Team Name: `Updated Football Team`
   - Coach Name: `Coach Tran`
4. Tap "Lưu"
5. Verify: Changes saved, redirect to my-teams

**Expected Result:**
- ✅ Team updated in database
- ✅ Updated info displayed
- ✅ Success toast notification

**API Call:** `PUT /api/TeamsApi/{id}`

---

#### TC-08: Delete Team
**Route:** `/my-teams`  
**Steps:**
1. From my-teams, long press on "Updated Football Team"
2. Tap delete icon (trash)
3. Confirm deletion in dialog
4. Verify: Team removed from list

**Expected Result:**
- ✅ Team deleted from database
- ✅ Team removed from UI
- ✅ Success toast notification

**API Call:** `DELETE /api/TeamsApi/{id}`

---

### 4️⃣ Player Management CRUD (Priority: HIGH)

#### TC-09: View Team Players
**Route:** `/team-players/:teamId`  
**Steps:**
1. From my-teams, tap on a team card
2. Verify: Team detail screen with players list

**Expected Result:**
- ✅ Team info displayed (name, sport, coach)
- ✅ Players list (may be empty)
- ✅ FAB button (+) for adding player

**API Call:** `GET /api/TeamsApi/{id}`

---

#### TC-10: Add Player to Team
**Route:** `/add-player/:teamId`  
**Steps:**
1. From team-players screen, tap FAB (+)
2. Fill form:
   - Player Name: `Nguyen Van A`
   - Jersey Number: `10`
   - Position: `Tiền đạo` (Forward)
   - Height: `175` (optional)
   - Weight: `70` (optional)
3. Tap "Lưu"
4. Verify: Player added to team

**Expected Result:**
- ✅ Player created in database
- ✅ Player appears in team-players list
- ✅ Success toast notification

**API Call:** `POST /api/PlayersApi`

---

#### TC-11: Edit Player
**Route:** `/edit-player/:playerId`  
**Steps:**
1. From team-players, tap on "Nguyen Van A"
2. Tap edit icon
3. Change:
   - Jersey Number: `7`
   - Position: `Tiền vệ` (Midfielder)
4. Tap "Lưu"
5. Verify: Changes saved

**Expected Result:**
- ✅ Player updated in database
- ✅ Updated info displayed
- ✅ Success toast notification

**API Call:** `PUT /api/PlayersApi/{id}`

---

#### TC-12: Delete Player
**Route:** `/team-players/:teamId`  
**Steps:**
1. From team-players, long press on player
2. Tap delete icon
3. Confirm deletion
4. Verify: Player removed

**Expected Result:**
- ✅ Player deleted from database
- ✅ Player removed from UI
- ✅ Success toast notification

**API Call:** `DELETE /api/PlayersApi/{id}`

---

### 5️⃣ Tournament Registration (Priority: HIGH)

#### TC-13: Register Team for Tournament
**Route:** `/tournament-registration/:tournamentId`  
**Steps:**
1. From tournament list, tap on a tournament
2. Tap "Đăng ký" button
3. Select team from dropdown
4. Add notes (optional): `Test registration`
5. Tap "Xác nhận đăng ký"
6. Verify: Success message

**Expected Result:**
- ✅ Registration created in database
- ✅ Team added to tournament participants
- ✅ Success toast notification
- ✅ "Đăng ký" button changes to "Đã đăng ký"

**API Call:** `POST /api/TournamentRegistrationsApi`

---

### 6️⃣ Tournament Detail Screens (Priority: MEDIUM)

#### TC-14: View Tournament Detail
**Route:** `/tournament-detail/:id`  
**Steps:**
1. From tournament list, tap on any tournament card
2. Verify: Tournament detail screen with tabs:
   - **Tổng quan** (Overview)
   - **Thể lệ** (Rules)
   - **Lịch thi đấu** (Schedule)
   - **BXH** (Standings)

**Expected Result:**
- ✅ All tabs functional
- ✅ Tournament info displayed correctly
- ✅ Registration button visible/disabled based on status

**API Call:** `GET /api/TournamentsApi/{id}`

---

#### TC-15: View Tournament Bracket
**Route:** `/tournament-bracket/:id`  
**Steps:**
1. From tournament detail, tap "Xem Bracket"
2. Verify: Tournament bracket visualization

**Expected Result:**
- ✅ Bracket tree displayed
- ✅ Match results shown (if available)
- ✅ Scrollable/zoomable view

**API Call:** `GET /api/TournamentsApi/{id}/bracket`

---

#### TC-16: View Match Schedule
**Route:** `/matches`  
**Steps:**
1. From dashboard menu, tap "Lịch thi đấu"
2. Verify: List of all matches
3. Filter by tournament
4. Filter by date

**Expected Result:**
- ✅ Matches grouped by date
- ✅ Filters work correctly
- ✅ Match cards show: teams, time, location, status

**API Call:** `GET /api/MatchesApi`

---

### 7️⃣ Real-time Match Detail (Priority: HIGH)

#### TC-17: Live Match Updates with SignalR
**Route:** `/match-detail/:id`  
**Steps:**
1. From match list, tap on an ongoing match
2. Verify: Real-time score updates
3. Wait for events (goals, cards, etc.) from backend
4. Verify: UI updates automatically without refresh

**Expected Result:**
- ✅ SignalR connection established
- ✅ Score updates in real-time
- ✅ Match events displayed live
- ✅ No manual refresh needed

**SignalR Hub:** `wss://localhost:8080/matchHub`  
**Events:** `ReceiveScoreUpdate`, `ReceiveMatchEvent`

---

### 8️⃣ Statistics & Performance Charts (Priority: MEDIUM)

#### TC-18: View Tournament Statistics
**Route:** `/statistics/:tournamentId`  
**Steps:**
1. From tournament detail, tap "Thống kê"
2. Verify: Charts displayed:
   - Top scorers
   - Team performance
   - Match results distribution

**Expected Result:**
- ✅ Charts rendered correctly
- ✅ Data accurate from API
- ✅ Interactive tooltips on hover/tap

**API Call:** `GET /api/TournamentsApi/{id}/statistics`

---

#### TC-19: View Performance Charts
**Route:** `/performance-charts/:teamId`  
**Steps:**
1. From team detail, tap "Biểu đồ"
2. Verify: Performance charts:
   - Win/Loss ratio
   - Goals scored/conceded
   - Match history

**Expected Result:**
- ✅ Charts rendered correctly
- ✅ Data accurate from API
- ✅ Legends and labels clear

**API Call:** `GET /api/TeamsApi/{id}/performance`

---

### 9️⃣ Profile & Settings (Priority: LOW)

#### TC-20: View User Profile
**Route:** `/profile`  
**Steps:**
1. From dashboard, tap profile tab
2. Verify: User info displayed
3. Tap "Chỉnh sửa" button
4. Update profile (name, phone, avatar)
5. Tap "Lưu"
6. Verify: Changes saved

**Expected Result:**
- ✅ Profile info displayed
- ✅ Edit form functional
- ✅ Avatar upload works (if implemented)
- ✅ Success toast notification

**API Call:** `PUT /api/AccountsApi/update-profile`

---

#### TC-21: Logout
**Route:** `/login`  
**Steps:**
1. From profile screen, tap "Đăng xuất"
2. Confirm logout
3. Verify: Redirect to login screen

**Expected Result:**
- ✅ JWT token cleared
- ✅ AuthProvider reset
- ✅ Redirect to login

---

### 🔟 Search & Filter (Priority: MEDIUM)

#### TC-22: Search Tournaments
**Route:** `/tournaments`  
**Steps:**
1. From tournament list, tap search bar
2. Enter: `Giải`
3. Verify: Results filtered

**Expected Result:**
- ✅ Live search results
- ✅ Debounced API calls
- ✅ Clear button functional

**API Call:** `GET /api/TournamentsApi?search=Giải`

---

#### TC-23: Search Teams
**Route:** `/my-teams`  
**Steps:**
1. From my-teams, tap search bar
2. Enter team name
3. Verify: Filtered results

**Expected Result:**
- ✅ Live search works
- ✅ Case-insensitive search

---

### 1️⃣1️⃣ Error Handling (Priority: HIGH)

#### TC-24: Network Error Handling
**Steps:**
1. Disconnect internet/stop backend
2. Navigate to any screen requiring API
3. Verify: Error message displayed

**Expected Result:**
- ✅ User-friendly error message
- ✅ Retry button available
- ✅ No app crash

---

#### TC-25: 401 Unauthorized Handling
**Steps:**
1. Manually clear token from SharedPreferences
2. Try to access protected route
3. Verify: Redirect to login

**Expected Result:**
- ✅ Auto redirect to login
- ✅ Clear error message

---

#### TC-26: Validation Errors
**Steps:**
1. Try to create team with empty name
2. Try to add player with invalid number (<1 or >99)
3. Verify: Validation error messages

**Expected Result:**
- ✅ Inline validation messages
- ✅ Form submission blocked
- ✅ Red border on error fields

---

### 1️⃣2️⃣ Edge Cases (Priority: LOW)

#### TC-27: Deep Linking
**Steps:**
1. Open app with deep link: `tdsports://tournament-detail/1`
2. Verify: Navigate directly to tournament detail

**Expected Result:**
- ✅ Deep link handled correctly
- ✅ Route with arguments works

---

---

## 📊 Test Results Summary

### Test Execution Status

| Category | Total Tests | Passed | Failed | Skipped | Pass Rate |
|----------|-------------|--------|--------|---------|-----------|
| Authentication | 2 | - | - | - | - |
| Dashboard | 2 | - | - | - | - |
| Team CRUD | 4 | - | - | - | - |
| Player CRUD | 4 | - | - | - | - |
| Tournament Reg | 1 | - | - | - | - |
| Tournament Detail | 3 | - | - | - | - |
| Real-time | 1 | - | - | - | - |
| Statistics | 2 | - | - | - | - |
| Profile | 2 | - | - | - | - |
| Search | 2 | - | - | - | - |
| Error Handling | 3 | - | - | - | - |
| Edge Cases | 1 | - | - | - | - |
| **TOTAL** | **27** | **0** | **0** | **0** | **0%** |

---

## 🐛 Known Issues

### High Priority
- [ ] (None yet - will update during testing)

### Medium Priority
- [ ] 578 Flutter analyzer warnings (style issues, not errors)
- [ ] `withOpacity` deprecated warnings (use `.withValues()` instead)

### Low Priority
- [ ] `prefer_const_constructors` warnings (performance optimizations)

---

## 🚀 Next Steps

### Immediate Actions (During Testing)
1. ✅ Start backend server (`dotnet run`)
2. 🔄 Build Flutter app on Android device (In Progress)
3. ⏳ Execute all 27 test cases
4. ⏳ Document test results
5. ⏳ Fix any critical bugs found

### Post-Testing Actions
1. Update test results table
2. Create bug report for failed tests
3. Implement fixes for critical issues
4. Re-test failed test cases
5. Generate final Phase 6 report

---

## 📝 Test Notes

### Environment Setup Time
- Backend startup: ~10 seconds
- Flutter Android build: ~2-5 minutes (first build)
- Hot reload time: ~1-3 seconds (after first build)

### Performance Benchmarks
- API response time: Target <500ms
- Screen navigation: Target <300ms
- SignalR latency: Target <100ms

### Test Data Requirements
- 3 users (Admin, Coach, User)
- 5 tournaments (various statuses)
- 10 teams (different sports)
- 50 players (distributed across teams)
- 20 matches (various statuses)

---

## 👥 Test Team

- **Tester:** GitHub Copilot (AI Agent)
- **Developer:** NhomTD Team
- **Reviewer:** Project Owner
- **Test Environment Manager:** DevOps

---

## 📞 Support & Issues

- **Project Docs:** `D:\WebQuanLyGiaiDau_NhomTD\docs\`
- **API Docs:** `docs/api/QUICK_API_REFERENCE.md`
- **Test Guides:** `docs/guides/`

---

**Test Plan Status:** 🔄 In Progress  
**Last Updated:** 2025-06-01  
**Next Review:** After first test execution
