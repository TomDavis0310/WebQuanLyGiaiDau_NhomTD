# 🚀 Quick API Reference - WebQuanLyGiaiDau_NhomTD

## 📍 Base URLs

```
Development: http://localhost:8080/api
Swagger UI:  http://localhost:8080/api-docs
```

---

## 🎬 YouTube API (`/api/YouTube`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/search` | GET | No | Search videos |
| `/highlights` | GET | No | Search highlights |
| `/livestreams` | GET | No | Search live streams |
| `/video/{id}` | GET | No | Get video details |
| `/recommended` | GET | No | Get recommended videos |
| `/tournament/{id}/recommended` | GET | No | Tournament videos |
| `/match/{id}` | GET | No | Get match videos |
| `/match/{id}/video` | POST | Admin | Update match video |
| `/extract-video-id` | GET | No | Extract video ID |
| `/validate-url` | GET | No | Validate YouTube URL |
| `/match/{id}/search` | GET | No | Search match videos |

---

## 📅 Tournament Schedule (`/api/tournament-management`)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/{id}/generate-schedule` | POST | Admin | Generate schedule |
| `/{id}/schedule` | GET | No | Get tournament schedule |

---

## 🏆 All APIs Quick List

### Authentication (`/api/AuthApi`)
- `POST /login` - Login
- `POST /register` - Register
- `POST /logout` - Logout
- `POST /refresh-token` - Refresh JWT
- `GET /user-info` - Get user info
- `POST /change-password` - Change password

### Dashboard (`/api/Dashboard`)
- `GET /overview` - Dashboard overview
- `GET /my-tournaments` - My tournaments
- `GET /my-teams` - My teams
- `GET /upcoming-matches` - Upcoming matches
- `GET /match-history` - Match history
- `GET /activity` - Activity timeline

### Tournaments (`/api/TournamentApi` & `/api/tournament-management`)
- `GET /` - List tournaments
- `GET /{id}` - Get tournament detail
- `GET /sport/{sportId}` - Tournaments by sport
- `POST /` - Create tournament (Admin)
- `PUT /{id}` - Update tournament (Admin)
- `DELETE /{id}` - Delete tournament (Admin)
- `GET /available` - Available for registration
- `POST /{id}/register` - Register team
- `GET /my-registrations` - My registrations
- `GET /{id}/teams` - Tournament teams
- `POST /{id}/generate-schedule` - Generate schedule (Admin)
- `GET /{id}/schedule` - Get schedule

### Matches (`/api/MatchesApi`)
- `GET /` - List matches
- `GET /{id}` - Match detail
- `GET /live` - Live matches
- `GET /tournament/{id}` - Tournament matches
- `GET /team/{id}` - Team matches
- `PUT /{id}/score` - Update score (Admin)

### Teams (`/api/TeamsApi`)
- `GET /` - List teams
- `GET /{id}` - Team detail
- `POST /` - Create team
- `PUT /{id}` - Update team
- `DELETE /{id}` - Delete team
- `GET /{id}/players` - Team players
- `POST /{id}/players` - Add player

### Players (`/api/PlayersApi`)
- `GET /` - List players
- `GET /{id}` - Player detail
- `POST /` - Create player
- `PUT /{id}` - Update player
- `DELETE /{id}` - Delete player
- `GET /{id}/statistics` - Player stats

### Sports (`/api/SportsApi`)
- `GET /` - List sports
- `GET /{id}` - Sport detail
- `GET /{id}/tournaments` - Sport tournaments

### News (`/api/NewsApi`)
- `GET /` - List news
- `GET /{id}` - News detail
- `GET /highlights` - Highlight news
- `POST /` - Create news (Admin)
- `PUT /{id}` - Update news (Admin)
- `DELETE /{id}` - Delete news (Admin)

### Statistics (`/api/StatisticsApi`)
- `GET /tournament/{id}` - Tournament stats
- `GET /team/{id}` - Team stats
- `GET /player/{id}` - Player stats
- `GET /rankings` - Rankings

### Standings (`/api/StandingsApi`)
- `GET /tournament/{id}` - Tournament standings

### Profile (`/api/profile`)
- `GET /` - Get profile
- `PUT /` - Update profile
- `POST /avatar` - Upload avatar
- `POST /change-password` - Change password

### Search (`/api/SearchApi`)
- `GET /` - Global search

### Rules (`/api/RulesApi`)
- `GET /{sport}` - Get rules by sport

### Notifications (`/api/NotificationsApi`)
- `GET /` - Get notifications
- `PUT /{id}/read` - Mark as read

---

## 🔐 Authentication

### For MVC/Web:
Uses Cookie-based authentication (Identity)

### For API/Mobile:
Uses JWT Bearer token

**Headers:**
```http
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Get Token:**
```bash
POST /api/AuthApi/login
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "refreshToken": "...",
  "expiresIn": 3600
}
```

---

## 📊 Standard Response Format

### Success:
```json
{
  "success": true,
  "message": "Success message",
  "data": { ... },
  "count": 10
}
```

### Error:
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error"
}
```

---

## 🎯 Common Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | int | Page number | `?page=1` |
| `pageSize` | int | Items per page | `?pageSize=10` |
| `search` | string | Search keyword | `?search=basketball` |
| `sportId` | int | Filter by sport | `?sportId=1` |
| `status` | string | Filter by status | `?status=active` |
| `maxResults` | int | Max results | `?maxResults=10` |

---

## 🚦 HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Success |
| 201 | Created |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Not authenticated |
| 403 | Forbidden - No permission |
| 404 | Not Found |
| 500 | Server Error |

---

## 📱 Flutter Quick Start

### 1. Setup Dio
```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'http://localhost:8080/api',
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ),
);

// Add JWT interceptor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = getToken(); // Your token storage
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

### 2. Call API
```dart
// Search videos
final response = await dio.get(
  '/YouTube/search',
  queryParameters: {'query': 'basketball', 'maxResults': 10},
);

// Get tournament schedule
final schedule = await dio.get('/tournament-management/1/schedule');

// Update match video (Admin)
await dio.post(
  '/YouTube/match/123/video',
  data: {
    'highlightsUrl': 'https://youtube.com/watch?v=abc',
  },
);
```

---

## 🛠️ Testing with cURL

### YouTube Search:
```bash
curl "http://localhost:8080/api/YouTube/search?query=basketball&maxResults=5"
```

### Get Schedule:
```bash
curl "http://localhost:8080/api/tournament-management/1/schedule"
```

### Generate Schedule (Admin):
```bash
curl -X POST "http://localhost:8080/api/tournament-management/1/generate-schedule" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Login:
```bash
curl -X POST "http://localhost:8080/api/AuthApi/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"Admin123!"}'
```

---

## 🐛 Common Issues

### 1. YouTube API Not Available
**Error:** "YouTube API is not available"  
**Fix:** Set YouTube API key in `appsettings.json`

### 2. CORS Error
**Error:** "CORS policy blocked"  
**Fix:** Check CORS configuration in `Program.cs`

### 3. 401 Unauthorized
**Error:** Unauthorized  
**Fix:** Include JWT token in Authorization header

### 4. 404 Not Found
**Error:** Endpoint not found  
**Fix:** Check base URL and endpoint path

---

## 📚 Documentation Files

- `API_COVERAGE_ANALYSIS.md` - Complete API overview
- `API_COMPLETION_REPORT.md` - Implementation report
- `docs/API_YOUTUBE_DOCUMENTATION.md` - YouTube API details
- `docs/API_SCHEDULE_DOCUMENTATION.md` - Schedule API details
- `API_STATUS_UPDATE.md` - Latest updates

---

## 🎓 Learning Resources

1. **Swagger UI**: Best for exploring APIs
2. **Postman Collection**: Import from Swagger
3. **Code Examples**: Check documentation files
4. **Flutter Examples**: In API docs

---

## 🔧 Development Tips

1. **Use Swagger UI** for quick testing
2. **Check response format** before parsing
3. **Handle errors gracefully** in client code
4. **Cache responses** when appropriate
5. **Use pagination** for large datasets
6. **Test authentication** separately
7. **Log API calls** for debugging

---

## ⚡ Performance Tips

1. **YouTube API**: Cache search results (1 hour)
2. **Schedule API**: Cache tournament schedule (until updated)
3. **News API**: Paginate results
4. **Matches API**: Use filters to limit results
5. **Statistics API**: Cache heavy calculations

---

## 🎯 Quick Commands

```bash
# Start backend
cd WebQuanLyGiaiDau_NhomTD
dotnet run

# Access Swagger
http://localhost:8080/api-docs

# Test endpoint
curl http://localhost:8080/api/YouTube/search?query=test

# Check logs
tail -f logs/app.log
```

---

**Last Updated:** November 1, 2024  
**API Version:** 2.0  
**Status:** ✅ Production Ready
