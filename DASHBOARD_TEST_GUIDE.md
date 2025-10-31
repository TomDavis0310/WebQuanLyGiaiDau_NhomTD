# 🧪 Dashboard Testing Guide

## 📋 Test Credentials

### User 1
- **Email:** `testuser1@example.com`
- **Password:** `Test@123`
- **Name:** Nguyễn Văn Test 1

### User 2
- **Email:** `testuser2@example.com`
- **Password:** `Test@123`
- **Name:** Trần Thị Test 2

---

## 🚀 Testing Steps

### 1️⃣ **Start Applications** (Already Done)
- ✅ Backend: Running at `http://192.168.1.4:8080`
- ✅ Flutter App: Running at `http://localhost:8081`
- ⏳ Wait ~30 seconds for both apps to fully start

### 2️⃣ **Open Application**
1. Open browser
2. Go to: `http://localhost:8081`
3. Wait for app to load (shows Sports List Screen)

### 3️⃣ **Login**
1. Click **Login icon** (👤) in top-right corner
2. Enter credentials:
   - Email: `testuser1@example.com`
   - Password: `Test@123`
3. Click **Đăng nhập**
4. Should redirect back to Sports List Screen
5. Login icon changes to **Person icon** (authenticated)

### 4️⃣ **Access Dashboard**
1. Click **Dashboard icon** (📊) in AppBar
   - Icon appears between Search and News icons
   - Only visible when logged in
2. Dashboard screen opens with 4 tabs

---

## 🧪 Dashboard Features to Test

### Tab 1: **Tổng Quan** (Overview)

#### ✅ Test Stats Cards
- [ ] **Đội Của Tôi** card shows count
- [ ] **Giải Đấu** card shows tournament count
- [ ] **Trận Sắp Tới** card shows upcoming matches count
- [ ] **Đang Thi Đấu** card shows active tournaments count
- [ ] All cards have correct icons and colors

#### ✅ Test My Teams Section
- [ ] Section header "Đội Của Tôi" visible
- [ ] Team cards display:
  - Team name
  - Coach name
  - Player count chip
  - Logo (or placeholder)
- [ ] Tap team card → navigates to Team Detail Screen

#### ✅ Test Upcoming Matches Section (if any)
- [ ] Section header "Trận Đấu Sắp Tới" visible
- [ ] Match cards show:
  - Team A vs Team B
  - Date and time
  - Location
  - Tournament name
  - My teams highlighted in blue
- [ ] Tap match → navigates to Match Detail

#### ✅ Test My Tournaments Section (if registered)
- [ ] Section header "Giải Đấu Đã Đăng Ký" visible
- [ ] Tournament cards show:
  - Tournament name
  - Team name
  - Status badge
- [ ] Tap tournament → navigates to Tournament Detail

#### ✅ Test Pull to Refresh
- [ ] Pull down on screen
- [ ] Loading indicator appears
- [ ] Data refreshes

---

### Tab 2: **Giải Đấu** (My Tournaments)

#### ✅ Test Tournament List
- [ ] Shows all registered tournaments (if any)
- [ ] Each card displays:
  - Tournament image/placeholder
  - Tournament name
  - Team info with logo
  - Sport name
  - Status badge (color-coded)
- [ ] Tap card → navigates to Tournament Detail

#### ✅ Test Empty State
- [ ] If no tournaments: Shows empty state icon + message
- [ ] Message: "Chưa đăng ký giải đấu nào"

#### ✅ Test Pull to Refresh
- [ ] Pull down to refresh list

---

### Tab 3: **Trận Đấu** (My Matches)

#### Sub-tab: **Sắp Tới** (Upcoming)

##### ✅ Test Match List
- [ ] Shows future matches only
- [ ] Match cards display:
  - Team names (my teams in bold blue)
  - VS or score
  - Date and time
  - Location
  - Tournament name
- [ ] Tap match → navigates to Match Detail

##### ✅ Test Empty State
- [ ] If no matches: Shows empty icon + "Chưa có trận đấu sắp tới"

#### Sub-tab: **Lịch Sử** (History)

##### ✅ Test Match History
- [ ] Shows past matches only
- [ ] Match cards display scores
- [ ] Sorted by most recent first
- [ ] Tap match → navigates to Match Detail

##### ✅ Test Empty State
- [ ] If no history: Shows "Chưa có lịch sử trận đấu"

---

### Tab 4: **Hoạt Động** (Activity Timeline)

#### ✅ Test Activity Feed
- [ ] Shows recent activities
- [ ] Activity items display:
  - Icon (colored circle)
  - Title
  - Description
  - Relative time ("X phút trước", "X giờ trước", etc.)
  - Status chip (if applicable)
- [ ] Activities sorted by newest first

#### ✅ Test Activity Types
- [ ] **Tournament Registration** activities show:
  - Orange icon (🏆)
  - Tournament name
  - Team name
  - Registration status

#### ✅ Test Empty State
- [ ] If no activities: Shows "Chưa có hoạt động nào"

#### ✅ Test Pull to Refresh
- [ ] Pull down to refresh

---

## 🐛 Error Scenarios to Test

### ✅ Test Unauthorized Access
1. Logout (click profile icon → logout)
2. Try to access Dashboard URL directly
3. Should show error or redirect to login

### ✅ Test Network Errors
1. Stop backend server
2. Try to refresh Dashboard
3. Should show error message with retry button

### ✅ Test Loading States
1. Slow network: Should show loading spinner
2. Fast network: Should load smoothly

---

## 📊 Expected Data for testuser1@example.com

Based on seed data:

### Teams
- **FC Test User 1**
  - Coach: Nguyễn Văn A
  - Players: 4
  
- **United Test 1**
  - Coach: Trần Thị B
  - Players: 3

### Statistics
- Total Teams: 2
- Total Tournaments: (depends on registrations)
- Upcoming Matches: (depends on schedule)
- Active Tournaments: (depends on dates)

---

## 📊 Expected Data for testuser2@example.com

### Teams
- **FC Test User 2**
  - Coach: Lê Văn C
  - Players: 3
  
- **Stars Test 2**
  - Coach: Phạm Thị D
  - Players: 3

### Statistics
- Total Teams: 2
- Total Tournaments: (depends on registrations)
- Upcoming Matches: (depends on schedule)
- Active Tournaments: (depends on dates)

---

## ✅ Navigation Testing

### From Dashboard to Other Screens
- [ ] Team card → Team Detail Screen
- [ ] Match card → Match Detail Screen
- [ ] Tournament card → Tournament Detail Screen
- [ ] Back button returns to Dashboard
- [ ] AppBar back arrow returns to Sports List

### Dashboard Access Points
- [ ] From Sports List: Dashboard icon (when logged in)
- [ ] Direct URL navigation (if authenticated)

---

## 🎨 UI/UX Testing

### Visual Checks
- [ ] Stats cards have correct colors (blue, orange, green, red)
- [ ] Icons are appropriate for each section
- [ ] Text is readable and properly formatted
- [ ] Cards have proper spacing and shadows
- [ ] Tab bar is visible and functional
- [ ] My teams highlighted in blue in matches

### Responsive Design
- [ ] Works on different browser widths
- [ ] Scrolling works smoothly
- [ ] Cards resize appropriately
- [ ] Images load or show placeholders

### Performance
- [ ] Dashboard loads in < 2 seconds
- [ ] Tab switching is instant
- [ ] Pull to refresh is smooth
- [ ] No lag when scrolling

---

## 🔐 Authentication Testing

### Token Management
- [ ] Dashboard uses auth token from AuthProvider
- [ ] Unauthorized requests show login prompt
- [ ] Token persists across page refreshes
- [ ] Logout clears dashboard access

---

## 📝 Notes

- **Backend URL:** `http://192.168.1.4:8080/api`
- **API Endpoints Used:**
  - `/DashboardApi/overview`
  - `/DashboardApi/my-tournaments`
  - `/DashboardApi/my-teams`
  - `/DashboardApi/upcoming-matches`
  - `/DashboardApi/match-history`
  - `/DashboardApi/activity`

- **All endpoints require:** `Authorization: Bearer {token}` header

---

## ✅ Test Completion Checklist

### Core Functionality
- [ ] Login successful
- [ ] Dashboard accessible
- [ ] All 4 tabs visible
- [ ] Stats cards display correctly
- [ ] Data loads from API

### Tab 1 - Overview
- [ ] Stats grid works
- [ ] My teams section works
- [ ] Upcoming matches section works
- [ ] My tournaments section works
- [ ] Pull to refresh works

### Tab 2 - Tournaments
- [ ] Tournament list loads
- [ ] Cards display correctly
- [ ] Navigation works
- [ ] Empty state works

### Tab 3 - Matches
- [ ] Both sub-tabs work
- [ ] Upcoming matches load
- [ ] Match history loads
- [ ] Team highlighting works
- [ ] Navigation works

### Tab 4 - Activity
- [ ] Activity feed loads
- [ ] Relative time displays
- [ ] Icons and colors correct
- [ ] Empty state works

### Error Handling
- [ ] Handles no data gracefully
- [ ] Shows errors clearly
- [ ] Retry mechanisms work

### Navigation
- [ ] All navigations work
- [ ] Back buttons work
- [ ] Deep linking works (if supported)

---

## 🎯 Success Criteria

✅ **Dashboard is ready for production if:**
1. All tabs load without errors
2. Data displays correctly for both test users
3. Navigation works smoothly
4. Pull to refresh updates data
5. Empty states show appropriately
6. My teams are highlighted in matches
7. Authentication is enforced
8. Performance is acceptable
9. UI is polished and consistent
10. No console errors

---

## 🐛 Bug Reporting Template

If you find issues, report them with:

```
**Bug Title:** [Short description]

**Steps to Reproduce:**
1. Login with testuser1@example.com
2. Open Dashboard
3. Click on X
4. See error

**Expected:** Should show Y

**Actual:** Shows Z error

**Screenshot:** [If applicable]

**Console Errors:** [Copy any errors]

**User:** testuser1@example.com or testuser2@example.com
```

---

## 🎉 Happy Testing!

If everything works, you have a fully functional User Dashboard! 🚀
