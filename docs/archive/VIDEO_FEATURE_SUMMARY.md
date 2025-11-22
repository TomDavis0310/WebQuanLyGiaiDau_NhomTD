# Tính năng Video Trận Đấu - NBA 2024

## ✅ Hoàn thành

### 1. **Cập nhật Model MatchDetail**
- ✅ Thêm 3 trường mới:
  - `highlightsVideoUrl` - Link video highlights
  - `liveStreamUrl` - Link xem trực tiếp
  - `videoDescription` - Mô tả video
- ✅ Thêm helper getters:
  - `hasHighlights` - Kiểm tra có highlights không
  - `hasLiveStream` - Kiểm tra có live stream không
- ✅ Regenerate JSON serialization code với build_runner

### 2. **Cập nhật UI Match Detail Screen**
- ✅ Thêm package `url_launcher: ^6.3.1`
- ✅ Tạo section video card với:
  - Icon play_circle_fill màu đỏ
  - Tiêu đề "Video trận đấu"
  - Mô tả video (nếu có)
  - Nút "XEM TRỰC TIẾP" (đỏ) - hiện khi có live stream
  - Nút "XEM HIGHLIGHTS" (xanh) - hiện khi có highlights
- ✅ Thêm function `_launchVideo()` để mở YouTube
- ✅ Hiển thị video section ngay sau match header

### 3. **Cập nhật Backend API**
- ✅ Thêm 3 fields video vào response của API `/api/matches/{id}`:
  ```csharp
  m.HighlightsVideoUrl,
  m.LiveStreamUrl,
  m.VideoDescription,
  ```

### 4. **Cập nhật Database**
- ✅ Tạo script `update-nba-videos.sql`
- ✅ Thêm link YouTube cho 6 trận đấu NBA:

| Trận đấu | Highlights | Live | Mô tả |
|----------|-----------|------|-------|
| Lakers vs Warriors | ✅ | ❌ | LeBron 28đ, Curry 32đ |
| Celtics vs Bucks | ✅ | ❌ | Tatum 35đ, Giannis 38đ |
| Nuggets vs Suns | ✅ | ❌ | Jokic 41đ triple-double |
| Mavericks vs Clippers | ❌ | ✅ | Luka vs Clippers LIVE |
| 76ers vs Heat | ❌ | ✅ | Embiid vs Heat LIVE |
| Lakers vs Nuggets | ✅ | ✅ | Christmas Game |

## 📱 Giao diện

### Video Section
```
┌─────────────────────────────────┐
│  🎬 Video trận đấu              │
│                                  │
│  🏀 Highlights đầy kịch tính:   │
│  LeBron James ghi 28 điểm...    │
│                                  │
│  ┌──────────────────────────┐  │
│  │ 📺 XEM TRỰC TIẾP         │  │ (Đỏ - nếu có live)
│  └──────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐  │
│  │ 🎬 XEM HIGHLIGHTS        │  │ (Xanh - nếu có highlights)
│  └──────────────────────────┘  │
└─────────────────────────────────┘
```

## 🎥 Link YouTube Sample

### Trận đã kết thúc (Highlights)
- Lakers vs Warriors: `https://www.youtube.com/watch?v=T8DBfY-j79c`
- Celtics vs Bucks: `https://www.youtube.com/watch?v=bJ5ppf0po3k`
- Nuggets vs Suns: `https://www.youtube.com/watch?v=h6VxLsHRYvo`

### Trận sắp diễn ra (Live Stream)
- Mavericks vs Clippers: `https://www.youtube.com/watch?v=live_stream_nba`
- 76ers vs Heat: `https://www.youtube.com/watch?v=live_stream_nba2`

### Christmas Game (Cả 2)
- Lakers vs Nuggets: 
  - Live: `https://www.youtube.com/watch?v=christmas_game_live`
  - Highlights: `https://www.youtube.com/watch?v=christmas_highlights`

## 🔧 Technical Details

### Dependencies
```yaml
dependencies:
  url_launcher: ^6.3.1  # Mở YouTube links
```

### Model Fields
```dart
final String? highlightsVideoUrl;
final String? liveStreamUrl;
final String? videoDescription;

bool get hasHighlights => highlightsVideoUrl != null && highlightsVideoUrl!.isNotEmpty;
bool get hasLiveStream => liveStreamUrl != null && liveStreamUrl!.isNotEmpty;
```

### Launch Video Function
```dart
Future<void> _launchVideo(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

## 📊 Database Schema

Bảng `Matches` có sẵn các cột:
- `HighlightsVideoUrl` (nvarchar)
- `LiveStreamUrl` (nvarchar)
- `VideoDescription` (nvarchar)

## ✨ Features

1. **Tự động ẩn/hiện**: Section video chỉ hiện khi có link video
2. **2 loại nút**: 
   - Đỏ cho Live Stream (đang phát trực tiếp)
   - Xanh cho Highlights (video đã quay)
3. **Mở external app**: Video mở trong YouTube app (mobile) hoặc browser
4. **Error handling**: Hiển thị SnackBar nếu không mở được
5. **Responsive**: Card với gradient và icons đẹp mắt

## 🎯 Use Cases

### Case 1: Trận đã kết thúc
- Hiển thị nút "XEM HIGHLIGHTS" màu xanh
- Click → Mở YouTube app với highlights video

### Case 2: Trận đang diễn ra
- Hiển thị nút "XEM TRỰC TIẾP" màu đỏ
- Click → Mở YouTube app với live stream

### Case 3: Trận đặc biệt (Christmas)
- Hiển thị CẢ 2 nút
- User chọn xem live hoặc highlights

### Case 4: Không có video
- Section video không hiển thị
- Màn hình hiển thị bình thường như cũ

## 🚀 Next Steps (Optional)

1. **Video Player Inline**: Nhúng YouTube player vào app
2. **Video Thumbnails**: Hiển thị preview thumbnail
3. **View Count**: Hiển thị số lượt xem
4. **Related Videos**: Gợi ý video liên quan
5. **Download Option**: Cho phép tải video offline
6. **Share Button**: Chia sẻ link video
7. **Playlist**: Tạo playlist các highlights

## 📝 Notes

- Link YouTube là placeholder, thay bằng link thật khi có
- API backend đã sẵn sàng trả về video fields
- Flutter app đã tích hợp đầy đủ
- Database đã có data mẫu cho NBA 2024

## 🎉 Kết quả

✅ **3 trận đã kết thúc** có highlights
✅ **2 trận sắp diễn ra** có live stream  
✅ **1 trận Christmas** có cả 2 (live + highlights)
✅ **UI đẹp**, dễ sử dụng, responsive
✅ **Error handling** đầy đủ
