# 🎬 YouTube API Documentation

## Base URL
```
http://localhost:8080/api/YouTube
```

## Endpoints

### 1. Search Videos
Search for YouTube videos by query.

**Endpoint:** `GET /api/YouTube/search`

**Parameters:**
- `query` (required): Search keyword
- `maxResults` (optional): Maximum results to return (default: 10)
- `type` (optional): Content type - "video", "channel", "playlist" (default: "video")

**Example:**
```bash
GET /api/YouTube/search?query=basketball+highlights&maxResults=5
```

**Response:**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "videoId": "abc123",
        "title": "Basketball Highlights",
        "description": "Amazing plays...",
        "thumbnailUrl": "https://...",
        "channelTitle": "Sports Channel",
        "publishedAt": "2024-11-01T00:00:00Z"
      }
    ]
  },
  "query": "basketball highlights",
  "count": 5
}
```

---

### 2. Search Highlights
Search specifically for highlight videos.

**Endpoint:** `GET /api/YouTube/highlights`

**Parameters:**
- `query` (required): Search keyword
- `maxResults` (optional): Maximum results (default: 10)

**Example:**
```bash
GET /api/YouTube/highlights?query=Giải+Bóng+Rổ+3v3&maxResults=10
```

---

### 3. Search Live Streams
Search for live streaming videos.

**Endpoint:** `GET /api/YouTube/livestreams`

**Parameters:**
- `query` (required): Search keyword
- `maxResults` (optional): Maximum results (default: 10)

**Example:**
```bash
GET /api/YouTube/livestreams?query=basketball+game+live
```

---

### 4. Get Video Details
Get detailed information about a specific video.

**Endpoint:** `GET /api/YouTube/video/{videoId}`

**Parameters:**
- `videoId` (path parameter): YouTube video ID

**Example:**
```bash
GET /api/YouTube/video/dQw4w9WgXcQ
```

**Response:**
```json
{
  "success": true,
  "data": {
    "videoId": "dQw4w9WgXcQ",
    "title": "Video Title",
    "description": "Full description...",
    "thumbnailUrl": "https://...",
    "duration": "PT4M33S",
    "viewCount": "1000000",
    "likeCount": "50000",
    "channelTitle": "Channel Name"
  }
}
```

---

### 5. Get Recommended Videos
Get recommended videos based on tournament and sport.

**Endpoint:** `GET /api/YouTube/recommended`

**Parameters:**
- `tournamentName` (required): Tournament name
- `sportName` (required): Sport name
- `maxResults` (optional): Maximum results (default: 5)

**Example:**
```bash
GET /api/YouTube/recommended?tournamentName=Giải+Bóng+Rổ+3v3&sportName=Basketball&maxResults=5
```

---

### 6. Get Tournament Recommended Videos
Get recommended videos for a specific tournament by ID.

**Endpoint:** `GET /api/YouTube/tournament/{tournamentId}/recommended`

**Parameters:**
- `tournamentId` (path parameter): Tournament ID
- `maxResults` (optional): Maximum results (default: 5)

**Example:**
```bash
GET /api/YouTube/tournament/1/recommended?maxResults=5
```

---

### 7. Get Match Videos
Get video URLs associated with a specific match.

**Endpoint:** `GET /api/YouTube/match/{matchId}`

**Parameters:**
- `matchId` (path parameter): Match ID

**Example:**
```bash
GET /api/YouTube/match/123
```

**Response:**
```json
{
  "success": true,
  "matchId": 123,
  "teamA": "Team A",
  "teamB": "Team B",
  "matchDate": "2024-11-01T15:00:00",
  "tournamentName": "Tournament Name",
  "sportName": "Basketball",
  "videos": {
    "highlightsUrl": "https://youtube.com/watch?v=abc123",
    "highlightsVideoId": "abc123",
    "liveStreamUrl": "https://youtube.com/watch?v=xyz789",
    "liveStreamVideoId": "xyz789",
    "description": "Match highlights and livestream"
  }
}
```

---

### 8. Update Match Video (Admin Only)
Update video URLs for a match. Requires Admin role.

**Endpoint:** `POST /api/YouTube/match/{matchId}/video`

**Authentication:** Required (Admin role)

**Parameters:**
- `matchId` (path parameter): Match ID

**Request Body:**
```json
{
  "highlightsUrl": "https://youtube.com/watch?v=abc123",
  "liveStreamUrl": "https://youtube.com/watch?v=xyz789",
  "description": "Optional description"
}
```

**Example:**
```bash
POST /api/YouTube/match/123/video
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "highlightsUrl": "https://youtube.com/watch?v=dQw4w9WgXcQ",
  "description": "Match highlights"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Video URLs updated successfully",
  "data": {
    "matchId": 123,
    "highlightsUrl": "https://youtube.com/watch?v=dQw4w9WgXcQ",
    "highlightsVideoId": "dQw4w9WgXcQ",
    "liveStreamUrl": null,
    "liveStreamVideoId": null,
    "description": "Match highlights"
  }
}
```

---

### 9. Extract Video ID
Extract YouTube video ID from a URL.

**Endpoint:** `GET /api/YouTube/extract-video-id`

**Parameters:**
- `url` (required): YouTube URL

**Example:**
```bash
GET /api/YouTube/extract-video-id?url=https://youtube.com/watch?v=dQw4w9WgXcQ
```

**Response:**
```json
{
  "success": true,
  "videoId": "dQw4w9WgXcQ",
  "embedUrl": "https://www.youtube.com/embed/dQw4w9WgXcQ",
  "watchUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "thumbnailUrl": "https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg"
}
```

---

### 10. Validate URL
Validate if a URL is a valid YouTube URL.

**Endpoint:** `GET /api/YouTube/validate-url`

**Parameters:**
- `url` (required): URL to validate

**Example:**
```bash
GET /api/YouTube/validate-url?url=https://youtube.com/watch?v=dQw4w9WgXcQ
```

**Response:**
```json
{
  "success": true,
  "isValid": true,
  "url": "https://youtube.com/watch?v=dQw4w9WgXcQ",
  "videoId": "dQw4w9WgXcQ",
  "embedUrl": "https://www.youtube.com/embed/dQw4w9WgXcQ"
}
```

---

### 11. Search Match Videos
Search for videos related to a specific match.

**Endpoint:** `GET /api/YouTube/match/{matchId}/search`

**Parameters:**
- `matchId` (path parameter): Match ID
- `maxResults` (optional): Maximum results (default: 5)

**Example:**
```bash
GET /api/YouTube/match/123/search?maxResults=5
```

**Response:**
```json
{
  "success": true,
  "matchId": 123,
  "teamA": "Team A",
  "teamB": "Team B",
  "sport": "Basketball",
  "query": "Team A vs Team B Basketball highlights",
  "data": {
    "items": [...]
  },
  "count": 5
}
```

---

## Error Responses

All endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

**Common HTTP Status Codes:**
- `200 OK`: Success
- `400 Bad Request`: Invalid parameters
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

## Flutter Integration Example

### 1. Search Videos
```dart
Future<List<YouTubeVideo>> searchVideos(String query) async {
  final response = await dio.get(
    '/api/YouTube/search',
    queryParameters: {
      'query': query,
      'maxResults': 10,
    },
  );
  
  if (response.data['success']) {
    return (response.data['data']['items'] as List)
        .map((item) => YouTubeVideo.fromJson(item))
        .toList();
  }
  throw Exception(response.data['message']);
}
```

### 2. Get Match Videos
```dart
Future<MatchVideos> getMatchVideos(int matchId) async {
  final response = await dio.get('/api/YouTube/match/$matchId');
  
  if (response.data['success']) {
    return MatchVideos.fromJson(response.data);
  }
  throw Exception(response.data['message']);
}
```

### 3. Update Match Video (Admin)
```dart
Future<void> updateMatchVideo({
  required int matchId,
  String? highlightsUrl,
  String? liveStreamUrl,
  String? description,
}) async {
  final response = await dio.post(
    '/api/YouTube/match/$matchId/video',
    data: {
      'highlightsUrl': highlightsUrl,
      'liveStreamUrl': liveStreamUrl,
      'description': description,
    },
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );
  
  if (!response.data['success']) {
    throw Exception(response.data['message']);
  }
}
```

---

## Testing with Swagger

Access Swagger UI at: `http://localhost:8080/api-docs`

All YouTube API endpoints are documented and can be tested directly in Swagger.

---

## Notes

1. **YouTube API Key Required**: Some features require a valid YouTube Data API v3 key configured in `appsettings.json`
2. **Rate Limits**: YouTube API has rate limits. Consider caching responses.
3. **Video Embed**: Use the `embedUrl` from responses to embed videos in your app.
4. **Thumbnails**: Multiple thumbnail sizes are available (default, medium, high, standard, maxres).
5. **Admin Only**: The `UpdateMatchVideo` endpoint requires Admin authentication.

---

## Configuration

Make sure YouTube API is configured in `appsettings.json`:

```json
{
  "YouTube": {
    "ApiKey": "YOUR_YOUTUBE_API_KEY_HERE"
  }
}
```

Or set environment variable:
```bash
export YOUTUBE_API_KEY="YOUR_API_KEY"
```
