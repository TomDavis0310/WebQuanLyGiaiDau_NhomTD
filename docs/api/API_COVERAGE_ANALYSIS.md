# 📊 Phân Tích Coverage API - WebQuanLyGiaiDau_NhomTD

## ✅ Đã Có API Đầy Đủ

### 1. **Authentication & Authorization**
- ✅ `AuthApiController` - Login, Register, Logout, Refresh Token, User Info
- Route: `/api/AuthApi`

### 2. **Dashboard**
- ✅ `DashboardApiController` - Overview, My Tournaments, My Teams, Upcoming Matches, Match History, Activity
- Route: `/api/Dashboard`
- Endpoints:
  - GET `/overview` - Dashboard tổng quan
  - GET `/my-tournaments` - Giải đấu của tôi
  - GET `/my-teams` - Đội của tôi
  - GET `/upcoming-matches` - Trận đấu sắp tới
  - GET `/match-history` - Lịch sử thi đấu
  - GET `/activity` - Timeline hoạt động

### 3. **Tournaments**
- ✅ `TournamentApiController` - List, Detail, Search, Filter by Sport
- ✅ `TournamentManagementApiController` - Create, Update, Delete, Registrations
- Route: `/api/TournamentApi`, `/api/tournament-management`

### 4. **Matches**
- ✅ `MatchesApiController` - List, Detail, Live Matches, Schedule, Update Scores
- Route: `/api/MatchesApi`

### 5. **Teams**
- ✅ `TeamsApiController` - List, Detail, Create, Update, Delete, Players
- Route: `/api/TeamsApi`

### 6. **Players**
- ✅ `PlayersApiController` - List, Detail, Create, Update, Delete, Statistics
- Route: `/api/PlayersApi`

### 7. **Sports**
- ✅ `SportsApiController` - List, Detail, Tournaments by Sport
- Route: `/api/SportsApi`

### 8. **News**
- ✅ `NewsApiController` - List, Detail, Create, Update, Delete, Highlights
- Route: `/api/NewsApi`

### 9. **Statistics**
- ✅ `StatisticsApiController` - Tournament Stats, Team Stats, Player Stats, Rankings
- Route: `/api/StatisticsApi`

### 10. **Standings**
- ✅ `StandingsApiController` - Tournament Standings, Team Records
- Route: `/api/StandingsApi`

### 11. **Profile**
- ✅ `ProfileApiController` - Get Profile, Update Profile, Change Password, Upload Avatar
- Route: `/api/profile`

### 12. **Search**
- ✅ `SearchApiController` - Global Search (Tournaments, Teams, Players, News)
- Route: `/api/SearchApi`

### 13. **Rules**
- ✅ `RulesApiController` - Get Rules by Sport, Rule Categories
- Route: Chưa có trong Api folder, nhưng có trong root Controllers

### 14. **Notifications**
- ✅ `NotificationsApiController` - Get Notifications, Mark as Read
- Route: Có trong root Controllers

---

## ⚠️ THIẾU API - Cần Bổ Sung

### 1. **YouTube API** ❌
**Controller MVC có:** `YouTubeController.cs`
- Search (YouTube videos)
- SearchHighlights
- SearchLiveStreams
- UpdateMatchVideo
- GetVideoDetails
- GetRecommendedVideos
- ExtractVideoId

**API cần tạo:** `YouTubeApiController.cs`
**Route đề xuất:** `/api/youtube`
**Endpoints cần tạo:**
```csharp
GET  /api/youtube/search?query={query}&maxResults={n}
GET  /api/youtube/highlights?query={query}
GET  /api/youtube/livestreams?query={query}
GET  /api/youtube/video/{videoId}
GET  /api/youtube/recommended?tournament={name}&sport={name}
POST /api/youtube/match/{matchId}/video
GET  /api/youtube/extract-video-id?url={url}
```

### 2. **Home/Landing Page API** ❌ (Optional)
**Controller MVC có:** `HomeController.cs`
- Index (Trang chủ)
- AdminDashboard
- Privacy
- UserGuide

**API cần tạo:** `HomeApiController.cs` hoặc tích hợp vào Dashboard
**Route đề xuất:** `/api/home`
**Endpoints cần tạo:**
```csharp
GET /api/home/landing - Dữ liệu trang chủ (featured tournaments, news, stats)
GET /api/home/quick-stats - Thống kê nhanh cho trang chủ
```

### 3. **Tournament Schedule Generation** ❌
**Controller MVC có:** `TournamentController.GenerateSchedule()`
**Endpoint hiện có:** `/Tournament/GenerateSchedule/{id}`

**Cần thêm vào API:** `TournamentManagementApiController`
```csharp
POST /api/tournament-management/{id}/generate-schedule
```

---

## 📝 Chi Tiết API Cần Tạo

### **YouTubeApiController.cs**

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Services;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class YouTubeApiController : ControllerBase
    {
        private readonly IYouTubeService _youtubeService;
        private readonly ApplicationDbContext _context;

        public YouTubeApiController(IYouTubeService youtubeService, ApplicationDbContext context)
        {
            _youtubeService = youtubeService;
            _context = context;
        }

        /// <summary>
        /// Search YouTube videos
        /// </summary>
        [HttpGet("search")]
        public async Task<ActionResult<object>> SearchVideos(
            [FromQuery] string query,
            [FromQuery] int maxResults = 10,
            [FromQuery] string type = "video")
        {
            if (string.IsNullOrEmpty(query))
            {
                return BadRequest(new { message = "Query is required" });
            }

            try
            {
                var request = new YouTubeSearchRequest
                {
                    Query = query,
                    MaxResults = maxResults,
                    Type = type
                };

                var result = await _youtubeService.SearchVideosAsync(request);
                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API is not available", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Search highlight videos
        /// </summary>
        [HttpGet("highlights")]
        public async Task<ActionResult<object>> SearchHighlights(
            [FromQuery] string query,
            [FromQuery] int maxResults = 10)
        {
            if (string.IsNullOrEmpty(query))
            {
                return BadRequest(new { message = "Query is required" });
            }

            try
            {
                var result = await _youtubeService.SearchHighlightsAsync(query, maxResults);
                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Search live streams
        /// </summary>
        [HttpGet("livestreams")]
        public async Task<ActionResult<object>> SearchLiveStreams(
            [FromQuery] string query,
            [FromQuery] int maxResults = 10)
        {
            if (string.IsNullOrEmpty(query))
            {
                return BadRequest(new { message = "Query is required" });
            }

            try
            {
                var result = await _youtubeService.SearchLiveStreamsAsync(query, maxResults);
                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Get video details by ID
        /// </summary>
        [HttpGet("video/{videoId}")]
        public async Task<ActionResult<object>> GetVideoDetails(string videoId)
        {
            if (string.IsNullOrEmpty(videoId))
            {
                return BadRequest(new { message = "Video ID is required" });
            }

            try
            {
                var video = await _youtubeService.GetVideoDetailsAsync(videoId);
                if (video == null)
                {
                    return NotFound(new { message = "Video not found" });
                }

                return Ok(new { success = true, data = video });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Get recommended videos for tournament
        /// </summary>
        [HttpGet("recommended")]
        public async Task<ActionResult<object>> GetRecommendedVideos(
            [FromQuery] string tournamentName,
            [FromQuery] string sportName,
            [FromQuery] int maxResults = 5)
        {
            if (string.IsNullOrEmpty(tournamentName) || string.IsNullOrEmpty(sportName))
            {
                return BadRequest(new { message = "Tournament name and sport name are required" });
            }

            try
            {
                var result = await _youtubeService.GetRecommendedVideosAsync(
                    tournamentName, sportName, maxResults);
                return Ok(new { success = true, data = result });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "YouTube API error", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Update match video URLs (Admin only)
        /// </summary>
        [HttpPost("match/{matchId}/video")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<object>> UpdateMatchVideo(
            int matchId,
            [FromBody] UpdateMatchVideoRequest request)
        {
            try
            {
                var match = await _context.Matches.FindAsync(matchId);
                if (match == null)
                {
                    return NotFound(new { message = "Match not found" });
                }

                // Validate YouTube URLs
                if (!string.IsNullOrEmpty(request.HighlightsUrl) && 
                    !_youtubeService.IsValidYouTubeUrl(request.HighlightsUrl))
                {
                    return BadRequest(new { message = "Invalid highlights URL" });
                }

                if (!string.IsNullOrEmpty(request.LiveStreamUrl) && 
                    !_youtubeService.IsValidYouTubeUrl(request.LiveStreamUrl))
                {
                    return BadRequest(new { message = "Invalid live stream URL" });
                }

                match.HighlightsVideoUrl = request.HighlightsUrl;
                match.LiveStreamUrl = request.LiveStreamUrl;
                match.VideoDescription = request.Description;

                await _context.SaveChangesAsync();

                return Ok(new 
                { 
                    success = true, 
                    message = "Video URLs updated successfully",
                    data = new
                    {
                        matchId = match.Id,
                        highlightsUrl = match.HighlightsVideoUrl,
                        liveStreamUrl = match.LiveStreamUrl,
                        description = match.VideoDescription
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new 
                { 
                    success = false, 
                    message = "Error updating match video", 
                    error = ex.Message 
                });
            }
        }

        /// <summary>
        /// Extract video ID from YouTube URL
        /// </summary>
        [HttpGet("extract-video-id")]
        public ActionResult<object> ExtractVideoId([FromQuery] string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return BadRequest(new { message = "URL is required" });
            }

            var videoId = _youtubeService.ExtractVideoIdFromUrl(url);
            if (string.IsNullOrEmpty(videoId))
            {
                return BadRequest(new { message = "Invalid YouTube URL" });
            }

            return Ok(new { success = true, videoId = videoId });
        }
    }

    public class UpdateMatchVideoRequest
    {
        public string? HighlightsUrl { get; set; }
        public string? LiveStreamUrl { get; set; }
        public string? Description { get; set; }
    }
}
```

---

## 📊 Tổng Kết

### Coverage hiện tại:
- ✅ **13/15 modules có API đầy đủ** (87%)
- ⚠️ **2 modules thiếu API** (13%):
  1. YouTube (quan trọng cho mobile app)
  2. Home/Landing API (có thể tích hợp vào Dashboard)

### Ưu tiên thực hiện:
1. **🔴 CAO - YouTube API**: Cần thiết cho tính năng video highlights trong app
2. **🟡 TRUNG - Home API**: Có thể dùng Dashboard API thay thế
3. **🟢 THẤP - Generate Schedule API**: Đã có trong MVC, chỉ cần expose qua API

---

## 🎯 Khuyến Nghị

1. **Tạo YouTubeApiController ngay** - đây là tính năng quan trọng cho UX
2. **Thêm endpoint generate-schedule** vào TournamentManagementApiController
3. **Xem xét tạo LandingApiController** nếu mobile app cần dữ liệu trang chủ riêng
4. **Test tất cả API** với Swagger UI tại `/api-docs`
5. **Cập nhật Flutter app** để sử dụng YouTube API mới

---

## 📱 Impact cho Flutter App

### Sau khi có YouTube API:
- ✅ Xem highlight videos trong app
- ✅ Xem livestream trực tiếp
- ✅ Tìm kiếm video liên quan đến giải đấu
- ✅ Nhúng video player trong match details
- ✅ Gợi ý video dựa trên lịch sử xem

### Tính năng mới có thể thêm:
- Video gallery cho mỗi tournament
- Playlist highlight theo đội
- Watch later / Favorites
- Share video to social media
- Picture-in-Picture mode
