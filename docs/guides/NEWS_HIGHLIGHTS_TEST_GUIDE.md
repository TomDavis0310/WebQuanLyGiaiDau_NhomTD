# 📰 Hướng Dẫn Test Tính Năng News & Highlights

## ✅ Checklist Kiểm Tra

### 1. **Backend API** (đã hoàn thành ✓)
- [x] NewsApiController đã tạo với 5 endpoints
- [x] Backend đang chạy tại `http://0.0.0.0:8080`
- [x] Database đã seed dữ liệu News

### 2. **Frontend Models** (đã hoàn thành ✓)
- [x] News, NewsSpor, NewsPagination models
- [x] JSON serialization với build_runner
- [x] Helpers: timeAgo, formattedDate

### 3. **Screens** (đã hoàn thành ✓)
- [x] NewsListScreen với tabs Featured/All
- [x] NewsDetailScreen với HTML rendering
- [x] Navigation từ SportsListScreen

### 4. **Packages** (đã hoàn thành ✓)
- [x] flutter_html ^3.0.0-beta.2 installed

---

## 🧪 Kịch Bản Test

### Test 1: Mở News List
1. **Bước thực hiện:**
   - Mở app trên Chrome (http://localhost:8081)
   - Đăng nhập nếu cần
   - Nhấn icon **News** (📰) trên AppBar của Sports List

2. **Kết quả mong đợi:**
   - Màn hình NewsListScreen mở ra
   - Hiển thị 2 tabs: "Nổi Bật" và "Tất Cả"
   - Tab "Nổi Bật" active mặc định
   - Hiển thị danh sách tin nổi bật (nếu có)

### Test 2: Xem Featured News Tab
1. **Bước thực hiện:**
   - Ở tab "Nổi Bật"
   - Quan sát danh sách news

2. **Kết quả mong đợi:**
   - Hiển thị cards lớn với:
     - Image hero đầy đủ chiều ngang
     - Badge "⭐ Nổi Bật"
     - Title, summary
     - Category badge
     - Author, publish time, view count

### Test 3: Xem All News Tab
1. **Bước thực hiện:**
   - Nhấn tab "Tất Cả"
   - Scroll danh sách

2. **Kết quả mong đợi:**
   - Hiển thị danh sách compact hơn
   - Cards ngang với image bên trái
   - Có pagination khi scroll xuống cuối
   - Loading indicator khi load thêm

### Test 4: Category Filter
1. **Bước thực hiện:**
   - Ở tab "Tất Cả"
   - Nhấn vào chip category phía trên danh sách
   - Chọn category khác

2. **Kết quả mong đợi:**
   - Danh sách filter theo category
   - Chip được highlight khi selected
   - Loading indicator hiện trong lúc fetch

### Test 5: Pull to Refresh
1. **Bước thực hiện:**
   - Kéo xuống từ đầu danh sách
   - Release để refresh

2. **Kết quả mong đợi:**
   - Refresh indicator xuất hiện
   - Danh sách reload từ đầu
   - Về page 1

### Test 6: Infinite Scroll Pagination
1. **Bước thực hiện:**
   - Scroll xuống cuối danh sách
   - Tiếp tục scroll

2. **Kết quả mong đợi:**
   - Loading indicator ở cuối danh sách
   - Load thêm news từ page tiếp theo
   - Append vào danh sách hiện tại

### Test 7: Open News Detail
1. **Bước thực hiện:**
   - Tap vào bất kỳ news card nào
   - Wait for navigation

2. **Kết quả mong đợi:**
   - Navigate đến NewsDetailScreen
   - Hero image animation smooth
   - Detail screen load đầy đủ

### Test 8: News Detail Content
1. **Bước thực hiện:**
   - Ở NewsDetailScreen
   - Scroll toàn bộ content

2. **Kết quả mong đợi:**
   - Hero image với gradient overlay
   - Category badge
   - Title lớn, rõ ràng
   - Author avatar và name
   - Publish time (timeAgo) + view count
   - HTML content render đúng format:
     - Paragraphs
     - Headings
     - Images (nếu có)
     - Bold, italic, lists

### Test 9: Related News
1. **Bước thực hiện:**
   - Scroll xuống cuối NewsDetailScreen
   - Xem section "Tin Liên Quan"

2. **Kết quả mong đợi:**
   - Hiển thị carousel ngang với 5 tin liên quan
   - Mỗi card có image, title, summary, meta
   - Swipe ngang được

### Test 10: Navigate to Related News
1. **Bước thực hiện:**
   - Tap vào bất kỳ related news card
   - Wait for navigation

2. **Kết quả mong đợi:**
   - Replace current NewsDetailScreen
   - Load tin mới
   - Related news update theo tin mới

### Test 11: Back Navigation
1. **Bước thực hiện:**
   - Từ NewsDetailScreen
   - Nhấn back button hoặc swipe back

2. **Kết quả mong đợi:**
   - Quay về NewsListScreen
   - State của list được preserve (scroll position, selected tab)

---

## 🔧 Test với Backend API

### Test API Endpoints (Manual)

**1. Get All News:**
```bash
curl http://10.15.10.42:8080/api/NewsApi?page=1&pageSize=10
```

**2. Get Featured News:**
```bash
curl http://10.15.10.42:8080/api/NewsApi/featured?count=5
```

**3. Get News Detail:**
```bash
curl http://10.15.10.42:8080/api/NewsApi/1
```

**4. Get Related News:**
```bash
curl http://10.15.10.42:8080/api/NewsApi/1/related?count=5
```

**5. Get Categories:**
```bash
curl http://10.15.10.42:8080/api/NewsApi/categories
```

---

## 🐛 Các Lỗi Có Thể Gặp

### 1. **CORS Error**
- **Triệu chứng:** Console error về CORS policy
- **Fix:** Check backend CORS config cho phép `http://localhost:8081`

### 2. **Image không load**
- **Triệu chứng:** Broken image icons
- **Fix:** Check imageUrl trong database có đúng không, hoặc dùng placeholder

### 3. **HTML không render**
- **Triệu chứng:** Raw HTML text hiện ra
- **Fix:** Verify flutter_html package đã install, rebuild app

### 4. **Pagination không hoạt động**
- **Triệu chứng:** Không load thêm khi scroll xuống
- **Fix:** Check ScrollController listener, check API pagination response

### 5. **Categories không hiện**
- **Triệu chứng:** Category chips trống
- **Fix:** Check API `/api/NewsApi/categories` có trả về data không

---

## 📊 Kết Quả Mong Đợi

### Performance
- [ ] News list load < 2s
- [ ] Detail screen render < 1s
- [ ] Smooth scroll (60fps)
- [ ] Image loading progressive

### UI/UX
- [ ] Responsive trên mọi screen size
- [ ] Touch feedback rõ ràng
- [ ] Loading states proper
- [ ] Error handling graceful

### Functionality
- [ ] All API calls successful
- [ ] Data hiển thị chính xác
- [ ] Navigation smooth
- [ ] State management đúng

---

## 📝 Ghi Chú

- **Backend URL:** `http://10.15.10.42:8080`
- **Frontend URL:** `http://localhost:8081`
- **Test Browser:** Chrome
- **Flutter Version:** 3.8.1+

---

## ✅ Hoàn Thành Test

Sau khi test xong tất cả kịch bản:
1. Ghi nhận bugs (nếu có)
2. Fix bugs
3. Re-test
4. Tạo documentation final trong `NEWS_HIGHLIGHTS_COMPLETED.md`
5. Update `PROJECT_STATUS.md`

---

**Status:** 🟡 Ready for Testing  
**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm")
