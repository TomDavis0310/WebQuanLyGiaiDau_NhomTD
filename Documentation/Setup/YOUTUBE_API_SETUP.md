# Hướng dẫn thiết lập YouTube API

## 1. Tạo YouTube API Key

### Bước 1: Truy cập Google Cloud Console
1. Đi đến [Google Cloud Console](https://console.cloud.google.com/)
2. Đăng nhập bằng tài khoản Google của bạn

### Bước 2: Tạo hoặc chọn Project
1. Tạo project mới hoặc chọn project hiện có
2. Đặt tên project: "Sports Tournament Management"

### Bước 3: Kích hoạt YouTube Data API v3
1. Vào **APIs & Services** > **Library**
2. Tìm kiếm "YouTube Data API v3"
3. Click vào **YouTube Data API v3**
4. Click **Enable**

### Bước 4: Tạo API Key
1. Vào **APIs & Services** > **Credentials**
2. Click **+ CREATE CREDENTIALS**
3. Chọn **API key**
4. Copy API key được tạo

### Bước 5: Hạn chế API Key (Khuyến nghị)
1. Click vào API key vừa tạo
2. Trong **Application restrictions**, chọn **HTTP referrers**
3. Thêm domain của website (ví dụ: `localhost:*`, `yourdomain.com/*`)
4. Trong **API restrictions**, chọn **Restrict key**
5. Chọn **YouTube Data API v3**
6. Click **Save**

## 2. Cấu hình trong ứng dụng

### Cập nhật appsettings.json
```json
{
  "YouTube": {
    "ApiKey": "YOUR_YOUTUBE_API_KEY_HERE"
  }
}
```

### Cập nhật appsettings.Development.json
```json
{
  "YouTube": {
    "ApiKey": "YOUR_YOUTUBE_API_KEY_HERE"
  }
}
```

## 3. Chức năng đã được tích hợp

### Cho Admin:
- **Quản lý Video YouTube**: Thêm/sửa URL video highlights và live stream cho từng trận đấu
- **Tìm kiếm Video**: Tự động tìm kiếm video highlights và live stream trên YouTube
- **Chọn Video**: Chọn video từ kết quả tìm kiếm và gán cho trận đấu

### Cho User:
- **Xem Video Highlights**: Xem video highlights được nhúng trực tiếp trong trang chi tiết trận đấu
- **Xem Live Stream**: Xem live stream trực tiếp (nếu có)
- **Video Đề Xuất**: Xem các video đề xuất liên quan đến giải đấu và môn thể thao

## 4. Cách sử dụng

### Đối với Admin:
1. Vào trang **Chi tiết trận đấu**
2. Click nút **"Quản Lý Video"** (màu đỏ với icon YouTube)
3. Trong modal popup:
   - Nhập URL video highlights hoặc live stream
   - Hoặc click **"Tìm Video Highlights"** / **"Tìm Live Stream"** để tự động tìm kiếm
   - Chọn video từ kết quả tìm kiếm
   - Thêm mô tả video (tùy chọn)
4. Click **"Lưu Thay Đổi"**

### Đối với User:
1. Vào trang **Chi tiết trận đấu**
2. Cuộn xuống phần **"Video Highlights & Live Stream"**
3. Xem video được nhúng trực tiếp hoặc click để xem trên YouTube
4. Xem các video đề xuất ở phía dưới

## 5. Lưu ý quan trọng

### Giới hạn API:
- YouTube Data API v3 có giới hạn quota hàng ngày
- Quota miễn phí: 10,000 units/ngày
- Mỗi search request tiêu tốn ~100 units
- Mỗi video details request tiêu tốn ~1 unit

### Bảo mật:
- Không commit API key vào source code
- Sử dụng environment variables hoặc Azure Key Vault cho production
- Hạn chế API key theo domain và API cụ thể

### Performance:
- Kết quả tìm kiếm được cache trong session
- Video details được load async để không ảnh hưởng tốc độ trang

## 6. Troubleshooting

### Lỗi "API key not configured":
- Kiểm tra API key trong appsettings.json
- Đảm bảo API key đúng format

### Lỗi "Quota exceeded":
- Kiểm tra usage trong Google Cloud Console
- Chờ reset quota (00:00 UTC hàng ngày)
- Hoặc upgrade plan nếu cần

### Video không load:
- Kiểm tra URL video có hợp lệ không
- Kiểm tra video có bị private/deleted không
- Kiểm tra network connection

### Tìm kiếm không có kết quả:
- Thử từ khóa khác
- Kiểm tra API key có quyền truy cập YouTube Data API v3
- Kiểm tra quota còn lại
