# 🔍 HƯỚNG DẪN TEST API THỦ CÔNG

## ✅ TRẠNG THÁI: API BACKEND HOÀN THÀNH
- **API Endpoints**: 13 endpoints đã được test và hoạt động tốt
- **Documentation**: Swagger UI hoàn chỉnh tại `/api-docs`
- **Database**: Seed data đầy đủ với các giải bóng rổ mẫu
- **Response Format**: Chuẩn JSON với tiếng Việt support

## 🚀 Cách khởi động và test

### Bước 1: Khởi động ứng dụng
```bash
cd "d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD"
dotnet run --urls http://localhost:5194
```

### Bước 2: Mở Swagger UI để test
Truy cập: http://localhost:5194/api-docs

## 📝 Test Cases cụ thể

### 1. Test Sports API

#### ✅ GET All Sports
```
URL: http://localhost:5194/api/SportsApi
Method: GET
Expected: Danh sách các môn thể thao
```

#### ✅ GET Sport by ID
```
URL: http://localhost:5194/api/SportsApi/1
Method: GET
Expected: Thông tin môn thể thao ID=1
```

#### ❌ GET Invalid Sport
```
URL: http://localhost:5194/api/SportsApi/999
Method: GET
Expected: 404 Not Found
```

### 2. Test Tournament API

#### ✅ GET All Tournaments
```
URL: http://localhost:5194/api/TournamentApi
Method: GET
Expected: Danh sách giải đấu
```

#### ✅ GET Tournament by ID
```
URL: http://localhost:5194/api/TournamentApi/1
Method: GET
Expected: Chi tiết giải đấu ID=1
```

#### ✅ GET Tournaments by Sport
```
URL: http://localhost:5194/api/TournamentApi/by-sport/1
Method: GET
Expected: Giải đấu của môn thể thao ID=1
```

### 3. Test Matches API

#### ✅ GET All Matches
```
URL: http://localhost:5194/api/MatchesApi
Method: GET
Expected: Danh sách trận đấu (page 1, size 10)
```

#### ✅ GET Matches with Pagination
```
URL: http://localhost:5194/api/MatchesApi?page=1&pageSize=5
Method: GET
Expected: 5 trận đấu đầu tiên
```

#### ✅ Search Matches
```
URL: http://localhost:5194/api/MatchesApi?search=Saigon
Method: GET
Expected: Trận đấu có đội "Saigon"
```

#### ✅ GET Match by ID
```
URL: http://localhost:5194/api/MatchesApi/1
Method: GET
Expected: Chi tiết trận đấu ID=1
```

#### ✅ GET Matches by Tournament
```
URL: http://localhost:5194/api/MatchesApi/tournament/1
Method: GET
Expected: Trận đấu trong giải đấu ID=1
```

#### ✅ GET Live Matches
```
URL: http://localhost:5194/api/MatchesApi/live
Method: GET
Expected: Trận đấu đang diễn ra hôm nay
```

### 4. Test Teams API

#### ✅ GET All Teams
```
URL: http://localhost:5194/api/TeamsApi
Method: GET
Expected: Danh sách các đội
```

#### ✅ Search Teams
```
URL: http://localhost:5194/api/TeamsApi?search=Saigon
Method: GET
Expected: Đội có tên chứa "Saigon"
```

#### ✅ GET Team by ID
```
URL: http://localhost:5194/api/TeamsApi/1
Method: GET
Expected: Chi tiết đội ID=1
```

#### ✅ GET Team Players
```
URL: http://localhost:5194/api/TeamsApi/1/players
Method: GET
Expected: Cầu thủ của đội ID=1
```

## 🛠️ Test với PowerShell

### Quick Test Script:
```powershell
# Test basic connectivity
Invoke-WebRequest -Uri "http://localhost:5194/ping"

# Test Sports API
Invoke-WebRequest -Uri "http://localhost:5194/api/SportsApi" | ConvertFrom-Json

# Test Tournaments API  
Invoke-WebRequest -Uri "http://localhost:5194/api/TournamentApi" | ConvertFrom-Json

# Test Matches API
Invoke-WebRequest -Uri "http://localhost:5194/api/MatchesApi" | ConvertFrom-Json

# Test Teams API
Invoke-WebRequest -Uri "http://localhost:5194/api/TeamsApi" | ConvertFrom-Json
```

## 🌐 Test với Curl

```bash
# Test Sports
curl -X GET "http://localhost:5194/api/SportsApi" -H "accept: application/json"

# Test Tournaments
curl -X GET "http://localhost:5194/api/TournamentApi" -H "accept: application/json"

# Test Matches with pagination
curl -X GET "http://localhost:5194/api/MatchesApi?page=1&pageSize=5" -H "accept: application/json"

# Test Teams search
curl -X GET "http://localhost:5194/api/TeamsApi?search=Saigon" -H "accept: application/json"
```

## ✅ Expected Response Format

Tất cả API sẽ trả về format JSON chuẩn:

```json
{
  "success": true,
  "message": "Thông báo tiếng Việt",
  "data": {
    // Dữ liệu actual
  },
  "count": 10, // Số lượng records (nếu có)
  "pagination": { // Chỉ có khi có phân trang
    "currentPage": 1,
    "pageSize": 10, 
    "totalRecords": 100,
    "totalPages": 10
  }
}
```

## 🚨 Common Issues & Solutions

### Issue 1: Port đã được sử dụng
```bash
# Kill process using port 5194
netstat -ano | findstr :5194
taskkill /PID <PID> /F
```

### Issue 2: Database connection error
- Kiểm tra SQL Server đang chạy
- Kiểm tra connection string trong appsettings.json

### Issue 3: CORS error (nếu test từ browser)
- API đã được cấu hình CORS
- Sử dụng Swagger UI thay vì direct browser calls

## 📊 Checklist Test Cases

### ✅ Basic API Tests
- [ ] Sports API - Get All
- [ ] Sports API - Get by ID
- [ ] Sports API - Invalid ID (404)
- [ ] Tournament API - Get All  
- [ ] Tournament API - Get by ID
- [ ] Tournament API - By Sport
- [ ] Matches API - Get All
- [ ] Matches API - Pagination
- [ ] Matches API - Search
- [ ] Matches API - Get by ID
- [ ] Matches API - By Tournament
- [ ] Matches API - Live matches
- [ ] Teams API - Get All
- [ ] Teams API - Search
- [ ] Teams API - Get by ID
- [ ] Teams API - Get Players

### ✅ Edge Cases
- [ ] Invalid IDs (404 responses)
- [ ] Empty search results
- [ ] Large page sizes
- [ ] Invalid pagination parameters

## 🎯 Success Criteria

API test PASSED nếu:
- ✅ Status code 200 cho valid requests
- ✅ Status code 404 cho invalid IDs  
- ✅ Response format đúng JSON structure
- ✅ Data được populate đúng
- ✅ Pagination hoạt động
- ✅ Search functionality hoạt động
- ✅ Error messages bằng tiếng Việt
