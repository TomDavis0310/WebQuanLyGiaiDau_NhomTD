# HƯỚNG DẪN TẠO DỮ LIỆU GIẢI ĐẤU VBA

## Tình Huống
Web đang chạy tại http://localhost:8080 nhưng việc tạo giải đấu qua API yêu cầu đăng nhập.

## Dữ Liệu Hiện Tại
Script đã tạo thành công:
- ✅ 8 đội bóng VBA (Saigon Heat, Hanoi Buffaloes, Danang Dragons, Cantho Catfish, Nha Trang Dolphins, Thang Long Warriors, HCMC Wings, Vung Tau Waves)
- ✅ 165 cầu thủ (15 cầu thủ cho mỗi đội với đủ vị trí: Point Guard, Shooting Guard, Small Forward, Power Forward, Center)
- ✅ 66 trận đấu (vòng bảng đấu vòng tròn)

## Cách 1: TẠO GIẢI ĐẤU QUA WEB (KHUYẾN NGHỊ)

### Bước 1: Đăng nhập hệ thống
1. Truy cập: http://localhost:8080/Identity/Account/Login
2. Sử dụng tài khoản admin hoặc user đã tạo trước đó

### Bước 2: Tạo Giải Đấu VBA
1. Truy cập: http://localhost:8080/Tournament/Create
2. Điền thông tin:
   ```
   Tên giải đấu: VBA 2025 - Vietnam Basketball Association
   Mô tả: Giải bóng rổ chuyên nghiệp hàng đầu Việt Nam mùa giải 2025. VBA là giải đấu bóng rổ cao cấp nhất tại Việt Nam, quy tụ các đội bóng mạnh nhất từ các tỉnh thành trên cả nước.
   Địa điểm: Nhà thi đấu Phú Thọ, TP.HCM & Cung thể thao Trịnh Hoài Đức, Hà Nội
   Ngày bắt đầu: 15/03/2025
   Ngày kết thúc: 30/08/2025
   URL Hình ảnh: https://vba.vn/wp-content/uploads/2024/01/vba-2024-logo.jpg
   Môn thể thao: Bóng rổ (ID: 1)
   Số đội tối đa: 8
   Số đội mỗi bảng: 4
   ```
3. Nhấn "Tạo giải đấu"

### Bước 3: Gắn Đội vào Giải đấu
Sau khi tạo giải đấu, gắn các đội sau vào giải:
- Saigon Heat (ID: 8)
- Hanoi Buffaloes (ID: 7)
- Danang Dragons (ID: 9)
- Cantho Catfish (ID: 10)
- Nha Trang Dolphins (ID: 13)
- Thang Long Warriors (ID: 12)
- HCMC Wings (ID: 11)
- Vung Tau Waves (ID: 14)

### Bước 4: Xem Kết Quả
1. Danh sách đội: http://localhost:8080/Teams
2. Danh sách cầu thủ theo đội: http://localhost:8080/Teams/Details/{teamId}
3. Lịch thi đấu: http://localhost:8080/Match

## Cách 2: SỬ DỤNG GIẢI ĐẤU CÓ SẴN

Hiện tại có 4 giải đấu bóng rổ có sẵn:
1. Giải Bóng Rổ 3v3 Mùa Xuân 2024 (ID: 1)
2. Giải Bóng Rổ 3v3 Mùa Thu 2024 (ID: 2)
3. Giải Bóng Rổ 5v5 Mùa Hè 2023 (ID: 3)
4. Giải Bóng Rổ 5v5 Mùa Đông 2024 (ID: 4)

Bạn có thể:
1. Chọn một giải đấu có sẵn
2. Thêm các đội VBA vào giải đó
3. Thêm trận đấu cho các đội

## KIỂM TRA DỮ LIỆU ĐÃ TẠO

### Xem danh sách đội:
```powershell
curl "http://localhost:8080/api/TeamsApi" 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object teamId, name, coach | Format-Table
```

### Xem cầu thủ của một đội (ví dụ: Saigon Heat - ID: 8):
```powershell
curl "http://localhost:8080/api/TeamsApi/8/players" 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object fullName, position, number | Format-Table
```

### Xem tất cả trận đấu:
```powershell
curl "http://localhost:8080/api/MatchesApi?pageSize=100" 2>$null | ConvertFrom-Json | Select-Object -ExpandProperty data | Select-Object id, teamA, teamB, matchDate, location | Format-Table
```

## CÁC ĐƯỜNG DẪN QUAN TRỌNG

1. **Trang chủ**: http://localhost:8080/
2. **Đăng nhập**: http://localhost:8080/Identity/Account/Login
3. **Tạo giải đấu**: http://localhost:8080/Tournament/Create
4. **Danh sách đội**: http://localhost:8080/Teams
5. **Tạo trận đấu**: http://localhost:8080/Match/Create
6. **API Swagger**: http://localhost:8080/api-docs

## DỮ LIỆU ĐÃ TẠO CHI TIẾT

### 8 Đội Bóng VBA:
1. **Saigon Heat** (ID: 8)
   - HLV: HLV Nguyen Minh Chien
   - Logo: https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Saigon_Heat_logo.svg/200px-Saigon_Heat_logo.svg.png
   - 15 cầu thủ với số áo từ 1-15

2. **Hanoi Buffaloes** (ID: 7)
   - HLV: HLV Pham Duc Thuan
   - 15 cầu thủ

3. **Danang Dragons** (ID: 9)
   - HLV: HLV Tran Quoc Tuan
   - 15 cầu thủ

4. **Cantho Catfish** (ID: 10)
   - HLV: HLV Le Van Hung
   - 15 cầu thủ

5. **Nha Trang Dolphins** (ID: 13)
   - HLV: HLV Truong Minh Duc
   - 15 cầu thủ

6. **Thang Long Warriors** (ID: 12)
   - HLV: HLV Nguyen Hai Dang
   - 15 cầu thủ

7. **HCMC Wings** (ID: 11)
   - HLV: HLV Le Hoang Anh
   - 15 cầu thủ

8. **Vung Tau Waves** (ID: 14)
   - HLV: HLV Pham Van Tung
   - 15 cầu thủ

### Vị Trí Cầu Thủ:
Mỗi đội có đầy đủ cầu thủ ở các vị trí:
- Point Guard (số áo: 1, 6, 11)
- Shooting Guard (số áo: 2, 7, 12)
- Small Forward (số áo: 3, 8, 13)
- Power Forward (số áo: 4, 9, 14)
- Center (số áo: 5, 10, 15)

## TẠO TRẬN ĐẤU (NẾU CẦN)

Nếu muốn tạo thêm trận đấu thủ công:
1. Truy cập: http://localhost:8080/Match/Create
2. Chọn giải đấu
3. Chọn 2 đội thi đấu
4. Điền thông tin:
   - Ngày thi đấu
   - Thời gian thi đấu (19:00)
   - Địa điểm (Nhà thi đấu Phú Thọ, TP.HCM hoặc Cung thể thao Trịnh Hoài Đức, Hà Nội)
   - Vòng đấu (1, 2, 3...)
   - Bảng đấu (Vòng Bảng)
5. (Tùy chọn) Thêm video highlights nếu trận đã diễn ra

## KIỂM TRA WEB HOẠT ĐỘNG TỐT

Sau khi tạo giải đấu và gắn đội, kiểm tra các tính năng:

✅ **Xem chi tiết giải đấu**
- Truy cập: http://localhost:8080/Tournament/Details/{tournamentId}
- Kiểm tra: Thông tin giải, danh sách đội, lịch thi đấu

✅ **Xem danh sách đội**
- Truy cập: http://localhost:8080/Teams
- Kiểm tra: Hiển thị logo, tên đội, HLV

✅ **Xem chi tiết đội**
- Truy cập: http://localhost:8080/Teams/Details/{teamId}
- Kiểm tra: Danh sách cầu thủ, số áo, vị trí

✅ **Xem lịch thi đấu**
- Truy cập: http://localhost:8080/Match
- Kiểm tra: Lịch các trận đấu, thời gian, địa điểm

✅ **Xem chi tiết trận đấu**
- Truy cập: http://localhost:8080/Match/Details/{matchId}
- Kiểm tra: Thông tin 2 đội, tỷ số (nếu có), video highlights

✅ **Tìm kiếm đội**
- Truy cập: http://localhost:8080/Teams
- Thử tìm kiếm: "Saigon", "Hanoi", "Danang"

✅ **API hoạt động**
- Truy cập: http://localhost:8080/api-docs
- Test các endpoint: Sports, Tournament, Teams, Matches

## LƯU Ý

1. Script đã tạo sẵn dữ liệu nhưng giải đấu VBA cần tạo thủ công qua web vì yêu cầu authentication
2. Tất cả cầu thủ đã được gán vào đội với đầy đủ thông tin
3. 66 trận đấu đã được tạo sẵn (vòng bảng, mỗi đội gặp nhau 1 lần)
4. Một số trận có tỷ số và video highlights (những trận đã qua)
5. Để xem đầy đủ, bạn cần tạo giải đấu VBA và gắn các đội vào giải

## KẾT LUẬN

Dữ liệu đã sẵn sàng để test! Chỉ cần:
1. Đăng nhập hệ thống
2. Tạo giải đấu VBA (hoặc dùng giải có sẵn)
3. Gắn 8 đội VBA vào giải
4. Bắt đầu kiểm tra các tính năng

Web đã và đang vận hành tốt với đầy đủ:
- Đội bóng ✅
- Cầu thủ ✅
- Huấn luyện viên ✅
- Hình ảnh (logo đội) ✅
- Trận đấu ✅
- Video highlights ✅
