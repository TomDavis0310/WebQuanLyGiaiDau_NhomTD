# 🧪 Test Cases - WebQuanLyGiaiDau_NhomTD

**Project:** Tournament Management System
**Date:** November 28, 2025
**Tester:** GitHub Copilot (AI Assistant)

---

## 📊 Test Summary

| Module | Total TCs | Priority |
|--------|-----------|----------|
| Authentication | 3 | High |
| Team Management | 2 | High |
| Tournament | 2 | High |
| Match | 1 | Medium |
| Search | 1 | Medium |
| Profile | 1 | Medium |
| **Total** | **10** | |

---

## 📝 Detailed Test Cases

### 1. Authentication Module

#### 🆔 TC01: User Registration - Successful
**Description:** Verify that a new user can register successfully with valid information.
**Pre-conditions:** App is installed and launched. User is on the Register screen.
**Test Steps:**
1. Navigate to Register screen.
2. Enter valid Name: "Test User".
3. Enter valid Email: "testuser@example.com" (unique).
4. Enter valid Password: "Password123!".
5. Confirm Password: "Password123!".
6. Tap "Register" button.
**Expected Result:**
- System displays success message.
- User is redirected to Login screen or Dashboard.
- Account is created in the database.

#### 🆔 TC02: User Login - Successful
**Description:** Verify that a registered user can login successfully.
**Pre-conditions:** User account exists. User is on Login screen.
**Test Steps:**
1. Navigate to Login screen.
2. Enter valid Email: "testuser@example.com".
3. Enter valid Password: "Password123!".
4. Tap "Login" button.
**Expected Result:**
- System authenticates user.
- User is redirected to Dashboard.
- JWT token is stored locally.

#### 🆔 TC03: User Login - Invalid Credentials
**Description:** Verify that login fails with incorrect password.
**Pre-conditions:** User account exists. User is on Login screen.
**Test Steps:**
1. Navigate to Login screen.
2. Enter valid Email: "testuser@example.com".
3. Enter invalid Password: "WrongPassword".
4. Tap "Login" button.
**Expected Result:**
- System displays error message "Invalid email or password".
- User remains on Login screen.

---

### 2. Team Management Module

#### 🆔 TC04: Create New Team - Successful
**Description:** Verify that a logged-in user can create a new team.
**Pre-conditions:** User is logged in. Navigate to "My Teams".
**Test Steps:**
1. Tap "Create Team" (FAB button).
2. Enter Team Name: "Golden Warriors".
3. Enter Coach Name: "Steve Kerr".
4. Select Sport: "Basketball".
5. Tap "Create" button.
**Expected Result:**
- System displays success message.
- New team appears in "My Teams" list.
- API returns 201 Created.

#### 🆔 TC05: Add Player to Team - Validation Check
**Description:** Verify validation when adding a player with invalid number (e.g., > 99).
**Pre-conditions:** User has a team. Navigate to Team Detail > Players.
**Test Steps:**
1. Tap "Add Player" button.
2. Enter Name: "Stephen Curry".
3. Enter Number: "100" (Invalid, max is 99).
4. Select Position: "Point Guard".
5. Tap "Save" button.
**Expected Result:**
- System displays validation error "Number must be between 0 and 99".
- Player is NOT added.

---

### 3. Tournament Module

#### 🆔 TC06: Register Team for Tournament - Successful
**Description:** Verify that a user can register their team for an open tournament.
**Pre-conditions:** User has a team. An open tournament exists.
**Test Steps:**
1. Navigate to Tournament List.
2. Select an "Open" tournament.
3. Tap "Register" button.
4. Select "Golden Warriors" from team dropdown.
5. Enter Note: "Ready to win".
6. Tap "Confirm Registration".
**Expected Result:**
- System displays success message "Registration successful".
- Team status in tournament becomes "Pending" or "Registered".

#### 🆔 TC09: View Tournament Standings
**Description:** Verify that standings are displayed correctly for a tournament.
**Pre-conditions:** Tournament has active matches and results.
**Test Steps:**
1. Navigate to Tournament Detail.
2. Tap "Standings" tab.
3. Check the points and ranking of teams.
**Expected Result:**
- Standings table is displayed.
- Teams are sorted by Points (descending).
- Columns (Played, Won, Lost, Points) are accurate.

---

### 4. Match Module

#### 🆔 TC07: View Match Detail & Real-time Score
**Description:** Verify match details are loaded and real-time connection is established.
**Pre-conditions:** A match is currently live or scheduled.
**Test Steps:**
1. Navigate to Match List.
2. Tap on a specific match.
3. Observe the Match Detail screen.
**Expected Result:**
- Match details (Teams, Time, Location) are displayed.
- SignalR connection status shows "Connected" (if visible) or score updates automatically if changed on backend.

---

### 5. Search Module

#### 🆔 TC08: Search Functionality - Valid Keyword
**Description:** Verify global search returns relevant results.
**Pre-conditions:** User is on Dashboard.
**Test Steps:**
1. Tap Search icon.
2. Enter keyword: "Warriors".
3. Tap Search button.
**Expected Result:**
- Search results appear.
- "Golden Warriors" team is listed in Teams section.
- Related news or tournaments containing "Warriors" are listed.

---

### 6. Profile Module

#### 🆔 TC10: Update User Profile
**Description:** Verify user can update their profile information.
**Pre-conditions:** User is logged in. Navigate to Profile.
**Test Steps:**
1. Tap "Edit Profile".
2. Change Full Name to "Test User Updated".
3. Tap "Save".
**Expected Result:**
- System displays success message.
- Profile screen shows updated name "Test User Updated".
- Data is persisted in database.

---

## 🛠️ Test Environment
- **Device:** Android Emulator / Physical Device
- **OS:** Android 10+ / iOS 12+
- **Backend:** Localhost (192.168.1.201:8080)
- **Network:** Wifi/4G
