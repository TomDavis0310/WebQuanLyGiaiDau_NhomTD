# Demo YouTube URLs cho Test

## Video Highlights Basketball
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://www.youtube.com/watch?v=jNQXAC9IVRw
https://www.youtube.com/watch?v=9bZkp7q19f0
```

## Live Stream Basketball
```
https://www.youtube.com/watch?v=5qap5aO4i9A
https://www.youtube.com/watch?v=l-gQLqv9f4o
```

## Cách test chức năng:

### 1. Test với API key thật:
1. Lấy YouTube API key từ Google Cloud Console
2. Cập nhật `appsettings.json`
3. Restart ứng dụng
4. Vào trang Match Details
5. Click "Quản Lý Video"
6. Test search functionality

### 2. Test với URL có sẵn:
1. Vào trang Match Details
2. Click "Quản Lý Video"  
3. Paste một trong các URL trên
4. Save và xem kết quả

### 3. Test tìm kiếm:
- Từ khóa: "basketball highlights"
- Từ khóa: "football match"
- Từ khóa: "tournament live"

## Lưu ý:
- Không có API key thì chỉ test được với URL có sẵn
- Video phải public mới embed được
- Live stream cần đang phát hoặc đã scheduled
