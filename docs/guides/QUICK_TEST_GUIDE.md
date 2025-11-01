# 🎯 Quick Start Guide - Testing TDSports App

**For Manual Testers**  
**Duration:** 30-45 minutes for full test suite  
**Difficulty:** Easy  

---

## 📱 Current Status

✅ **Backend:** Running on http://localhost:8080  
✅ **App:** Running on Android device (SM A346E)  
✅ **DevTools:** http://127.0.0.1:9103  
✅ **Test Plan:** 27 test cases ready  

---

## 🚀 How to Start Testing

### Step 1: Find the App on Your Device
Look for the app on the Android device (SM A346E). It should be already open showing the **Login Screen**.

### Step 2: Start with Registration (TC-01)

#### Create Your First Test User
1. **Tap "Đăng ký"** button (Register)
2. **Fill the form:**
   ```
   Username:          test_user_001
   Email:             test001@gmail.com
   Password:          Test@123
   Confirm Password:  Test@123
   Full Name:         Test User 001
   Date of Birth:     (Pick any date, e.g., 2000-01-01)
   Phone:             0987654321
   ```
3. **Tap "Đăng ký"** (Submit)
4. **Expected:** Success message + redirect to login screen

✅ **If successful:** Registration works!  
❌ **If failed:** Note the error message

---

### Step 3: Login (TC-02)

1. **Enter credentials:**
   ```
   Username: test_user_001
   Password: Test@123
   ```
2. **Tap "Đăng nhập"** (Login)
3. **Expected:** Redirect to Dashboard

✅ **If successful:** Login works!  
❌ **If failed:** Check:
   - Is backend running? (Check PowerShell window)
   - Did registration succeed?
   - Any error toast messages?

---

### Step 4: Explore Dashboard (TC-03)

After login, you should see **3 tabs at the bottom:**

1. **Giải đấu** (Tournaments) 🏆
   - Shows list of tournaments
   - Can filter: All / Upcoming / Ongoing / Finished

2. **Tin tức** (News) 📰
   - Shows news/highlights
   - Can scroll through articles

3. **Cá nhân** (Profile) 👤
   - Shows your profile info
   - Can edit profile
   - Can logout

**Test:** Tap each tab and verify it works!

---

### Step 5: Create Your First Team (TC-06)

1. **From Dashboard:**
   - Tap **menu icon** (☰) top-left
   - Select **"Đội của tôi"** (My Teams)

2. **Create Team:**
   - Tap **FAB button (+)** at bottom-right
   - Fill form:
     ```
     Team Name: Test Football Team
     Sport:     Bóng đá (Football)
     Coach:     Coach Nguyen
     ```
   - Tap **"Lưu"** (Save)

3. **Expected:** New team appears in list

---

### Step 6: Add Players to Team (TC-10)

1. **From My Teams:**
   - Tap on **"Test Football Team"** card

2. **Add Player:**
   - Tap **FAB button (+)**
   - Fill form:
     ```
     Player Name:   Nguyen Van A
     Jersey Number: 10
     Position:      Tiền đạo (Forward)
     Height:        175 (optional)
     Weight:        70 (optional)
     ```
   - Tap **"Lưu"** (Save)

3. **Expected:** Player appears in team roster

4. **Repeat:** Add 4-5 more players with different numbers

---

### Step 7: Register Team for Tournament (TC-13)

1. **Go to Tournaments Tab:**
   - Tap **"Giải đấu"** at bottom

2. **Pick a Tournament:**
   - Tap on any tournament card
   - Look for **"Đăng ký"** (Register) button

3. **Register Team:**
   - Tap **"Đăng ký"**
   - Select **"Test Football Team"** from dropdown
   - Add notes (optional): `Test registration`
   - Tap **"Xác nhận đăng ký"** (Confirm)

4. **Expected:** 
   - Success message
   - Button changes to **"Đã đăng ký"** (Registered)

---

### Step 8: View Match Schedule (TC-16)

1. **From Dashboard:**
   - Tap menu (☰)
   - Select **"Lịch thi đấu"** (Schedule)

2. **Explore:**
   - Scroll through matches
   - Try filters (by tournament, by date)
   - Tap on a match to see details

---

### Step 9: Test Real-time Updates (TC-17)

1. **Find an Ongoing Match:**
   - Go to **Schedule** screen
   - Look for matches with status **"Đang diễn ra"** (Ongoing)

2. **Open Match Detail:**
   - Tap on the match card
   - Watch for **real-time score updates**

3. **Expected:**
   - Score updates automatically (without refresh)
   - Match events appear live

**Note:** This requires backend to send SignalR events. If no live matches, skip this test.

---

### Step 10: Test Edit/Delete (TC-07, TC-08)

#### Edit Team
1. Go to **My Teams**
2. Tap on **"Test Football Team"**
3. Tap **edit icon** (pencil) ✏️
4. Change:
   - Team Name: `Updated Football Team`
   - Coach: `Coach Tran`
5. Tap **"Lưu"** (Save)
6. **Expected:** Changes saved

#### Delete Player
1. From team roster screen
2. **Long press** on a player
3. Tap **delete icon** (trash) 🗑️
4. Confirm deletion
5. **Expected:** Player removed

---

## 📋 Quick Checklist

Use this to track your progress:

```
✅ Test Cases Completed:

Authentication:
[ ] TC-01: Register new user
[ ] TC-02: Login with user

Dashboard:
[ ] TC-03: Bottom navigation tabs
[ ] TC-04: Tournament list with filters

Team Management:
[ ] TC-05: View my teams
[ ] TC-06: Create new team
[ ] TC-07: Edit team
[ ] TC-08: Delete team

Player Management:
[ ] TC-09: View team players
[ ] TC-10: Add player
[ ] TC-11: Edit player
[ ] TC-12: Delete player

Tournament:
[ ] TC-13: Register team for tournament
[ ] TC-14: View tournament detail
[ ] TC-15: View tournament bracket
[ ] TC-16: View match schedule

Real-time:
[ ] TC-17: Live match updates (SignalR)

Statistics:
[ ] TC-18: Tournament statistics
[ ] TC-19: Team performance charts

Profile:
[ ] TC-20: View/edit profile
[ ] TC-21: Logout

Search:
[ ] TC-22: Search tournaments
[ ] TC-23: Search teams

Error Handling:
[ ] TC-24: Network error
[ ] TC-25: 401 Unauthorized
[ ] TC-26: Validation errors

Edge Cases:
[ ] TC-27: Deep linking
```

---

## 🐛 What to Look For

### Things That Should Work
✅ Smooth navigation between screens  
✅ Data loads correctly from API  
✅ Forms validate input properly  
✅ Success/error messages appear  
✅ Lists are scrollable  
✅ Buttons respond to taps  
✅ No app crashes  

### Common Issues to Report
❌ **Blank screens** (data not loading)  
❌ **"404 Not Found"** errors (API endpoint issues)  
❌ **"401 Unauthorized"** (token expired)  
❌ **Form validation not working**  
❌ **App crashes** (critical bug!)  
❌ **Slow performance** (>2 seconds to load)  
❌ **UI elements overlapping** (layout issues)  

---

## 🛠️ Troubleshooting

### Problem: Backend not responding
**Solution:**
1. Check PowerShell window (backend should be running)
2. Look for errors in backend logs
3. Verify URL: `http://localhost:8080`
4. Try restart: Stop backend → Run `dotnet run` again

### Problem: App shows blank screen
**Solution:**
1. Pull down to refresh (if available)
2. Hot restart: Type `R` in Flutter terminal
3. Check console logs for errors

### Problem: Login fails with 401
**Solution:**
1. Verify user was registered successfully
2. Check username/password are correct
3. Backend may need database reset

### Problem: "Connection refused" error
**Solution:**
1. Backend not running → Start backend
2. Wrong URL in ApiService → Check `baseUrl` in code
3. Firewall blocking → Allow localhost connections

---

## 📊 How to Report Results

### For Each Test Case:
1. **Mark Status:**
   - ✅ **Pass:** Feature works as expected
   - ❌ **Fail:** Feature broken/not working
   - ⚠️ **Partial:** Works but has minor issues
   - ⏭️ **Skip:** Could not test (dependencies)

2. **Add Notes:** Briefly describe what happened

### Example Test Report:
```markdown
## TC-01: Register New User
**Status:** ✅ Pass
**Notes:** Registration successful. User redirected to login screen.
**Time:** ~30 seconds

## TC-02: Login
**Status:** ❌ Fail
**Notes:** Login button not responding. No API call made.
**Error:** Button tap has no visual feedback.
**Priority:** Critical
```

---

## ⏱️ Estimated Test Times

| Test Category | Estimated Time |
|---------------|----------------|
| Authentication (TC-01, TC-02) | 3 min |
| Dashboard (TC-03, TC-04) | 5 min |
| Team CRUD (TC-05 to TC-08) | 10 min |
| Player CRUD (TC-09 to TC-12) | 10 min |
| Tournament (TC-13 to TC-16) | 8 min |
| Real-time (TC-17) | 5 min |
| Statistics (TC-18, TC-19) | 5 min |
| Profile (TC-20, TC-21) | 3 min |
| Search (TC-22, TC-23) | 4 min |
| Error Handling (TC-24 to TC-26) | 5 min |
| Edge Cases (TC-27) | 2 min |
| **TOTAL** | **~60 min** |

---

## 🎉 Test Completion

After completing all tests:

1. **Count Results:**
   - Total Passed: ___/27
   - Total Failed: ___/27
   - Total Skipped: ___/27

2. **Calculate Pass Rate:**
   - Pass Rate = (Passed / (Passed + Failed)) × 100%
   - Target: ≥85% (23/27 tests pass)

3. **Document Bugs:**
   - List all failed tests
   - Prioritize by severity (Critical > High > Medium > Low)

4. **Share Results:**
   - Update `PHASE_6_TEST_PLAN.md` with results
   - Create bug reports for failures
   - Notify development team

---

## 📞 Need Help?

### Documentation
- **Full Test Plan:** `docs/guides/PHASE_6_TEST_PLAN.md`
- **API Reference:** `docs/api/QUICK_API_REFERENCE.md`
- **Project Status:** `docs/planning/PROJECT_STATUS.md`

### Quick Commands
```powershell
# Hot Reload (in Flutter terminal)
r

# Hot Restart
R

# Quit app
q

# View DevTools
# Open browser: http://127.0.0.1:9103
```

---

**Good luck with testing! 🚀**

---

## 📝 Test Data Reference

### Sample Users
| Username | Password | Role | Email |
|----------|----------|------|-------|
| test_user_001 | Test@123 | User | test001@gmail.com |
| test_coach_001 | Coach@123 | Coach | coach001@gmail.com |
| test_admin_001 | Admin@123 | Admin | admin001@gmail.com |

### Sample Teams
| Team Name | Sport | Coach | Players |
|-----------|-------|-------|---------|
| Test Football Team | Bóng đá | Coach Nguyen | 5-11 |
| Test Basketball Team | Bóng rổ | Coach Tran | 5-7 |

### Sample Players
| Name | Jersey # | Position | Height | Weight |
|------|----------|----------|--------|--------|
| Nguyen Van A | 10 | Tiền đạo | 175 | 70 |
| Tran Van B | 7 | Tiền vệ | 170 | 65 |
| Le Van C | 5 | Hậu vệ | 180 | 75 |

---

**Test Version:** Phase 6 Integration Testing  
**App Version:** Debug Build  
**Last Updated:** 2025-06-01
