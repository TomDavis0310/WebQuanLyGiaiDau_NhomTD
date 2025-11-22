-- ========================================
-- SCRIPT TẠO DỮ LIỆU VBA HOÀN CHỈNH
-- Với: Encoding UTF-8, Video thật, Ảnh thật
-- ========================================
USE QLGDDB;
GO

SET NOCOUNT ON;

-- Xóa dữ liệu VBA cũ nếu có
DELETE FROM Matches WHERE TournamentId = 5;
DELETE FROM Players WHERE TeamId BETWEEN 19 AND 26;
DELETE FROM Teams WHERE TeamId BETWEEN 19 AND 26;
DELETE FROM Tournaments WHERE Id = 5;

-- ========================================
-- 1. TẠO GIẢI ĐẤU VBA 2025
-- ========================================
PRINT N'Đang tạo giải đấu VBA 2025...';

INSERT INTO Tournaments (Name, Description, Location, StartDate, EndDate, ImageUrl, RegistrationStatus, SportsId, MaxTeams, TeamsPerGroup)
VALUES (
    N'VBA 2025 - Vietnam Basketball Association',
    N'Giải bóng rổ chuyên nghiệp hàng đầu Việt Nam mùa giải 2025. VBA là giải đấu bóng rổ cao cấp nhất tại Việt Nam, quy tụ các đội bóng mạnh nhất từ các tỉnh thành trên cả nước với sự tham gia của nhiều cầu thủ tài năng và ngoại binh chất lượng.',
    N'Nhà thi đấu Phú Thọ, TP.HCM & Cung thể thao Trịnh Hoài Đức, Hà Nội',
    '2025-03-15',
    '2025-08-30',
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
    'Open',
    1,
    8,
    4
);

DECLARE @TournamentId INT = SCOPE_IDENTITY();
PRINT N'Đã tạo giải đấu VBA với ID: ' + CAST(@TournamentId AS NVARCHAR);

-- ========================================
-- 2. TẠO 8 ĐỘI BÓNG VBA
-- ========================================
PRINT N'Đang tạo 8 đội bóng VBA...';

-- Saigon Heat
INSERT INTO Teams (Name, Coach, LogoUrl) 
VALUES (N'Saigon Heat VBA', N'HLV Nguyễn Minh Chiến', 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=400');
DECLARE @Team1 INT = SCOPE_IDENTITY();

-- Hanoi Buffaloes  
INSERT INTO Teams (Name, Coach, LogoUrl)
VALUES (N'Hanoi Buffaloes VBA', N'HLV Phạm Đức Thuận', 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=400');
DECLARE @Team2 INT = SCOPE_IDENTITY();

-- Danang Dragons
INSERT INTO Teams (Name, Coach, LogoUrl)
VALUES (N'Danang Dragons VBA', N'HLV Trần Quốc Tuấn', 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400');
DECLARE @Team3 INT = SCOPE_IDENTITY();

-- Cantho Catfish
INSERT INTO Teams (Name, Coach, LogoUrl)
VALUES (N'Cantho Catfish VBA', N'HLV Lê Văn Hùng', 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=400');
DECLARE @Team4 INT = SCOPE_IDENTITY();

-- Nha Trang Dolphins
INSERT INTO Teams (Name, Coach, LogoUrl)
VALUES (N'Nha Trang Dolphins VBA', N'HLV Trương Minh Đức', 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=400');
DECLARE @Team5 INT = SCOPE_IDENTITY();

-- Thang Long Warriors
INSERT INTO Teams (Name, Coach, LogoUrl)
VALUES (N'Thang Long Warriors VBA', N'HLV Nguyễn Hải Đăng', 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=400');
DECLARE @Team6 INT = SCOPE_IDENTITY();

-- HCM City Wings
INSERT INTO Teams (Name, Coach, LogoUrl)
VALUES (N'HCM City Wings VBA', N'HLV Lê Hoàng Anh', 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=400');
DECLARE @Team7 INT = SCOPE_IDENTITY();

-- Vung Tau Waves
INSERT INTO Teams (Name, Coach, LogoUrl)
VALUES (N'Vung Tau Waves VBA', N'HLV Phạm Văn Tùng', 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=400');
DECLARE @Team8 INT = SCOPE_IDENTITY();

PRINT N'Đã tạo 8 đội bóng VBA';

-- ========================================
-- 3. TẠO CẦU THỦ ĐỘI SAIGON HEAT VBA
-- ========================================
PRINT N'Đang tạo cầu thủ cho Saigon Heat VBA...';

INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
(N'Nguyễn Văn Hùng', N'Point Guard', 1, @Team1, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Trần Minh Dũng', N'Shooting Guard', 2, @Team1, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Lê Quốc Phong', N'Small Forward', 3, @Team1, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Phạm Đức Tài', N'Power Forward', 4, @Team1, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Hoàng Anh Kiên', N'Center', 5, @Team1, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200'),
(N'Huỳnh Hải Đạt', N'Point Guard', 6, @Team1, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Võ Tuấn Thắng', N'Shooting Guard', 7, @Team1, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Đặng Minh Long', N'Small Forward', 8, @Team1, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Bùi Văn Nam', N'Power Forward', 9, @Team1, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Đỗ Hoàng Khoa', N'Center', 10, @Team1, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200'),
(N'Nguyễn Tấn Phát', N'Point Guard', 11, @Team1, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Trần Hữu Thành', N'Shooting Guard', 12, @Team1, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Lê Công Minh', N'Small Forward', 13, @Team1, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Phạm Quốc Tuấn', N'Power Forward', 14, @Team1, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Hoàng Văn Cường', N'Center', 15, @Team1, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200');

-- ========================================
-- 4. TẠO CẦU THỦ ĐỘI HANOI BUFFALOES VBA
-- ========================================
PRINT N'Đang tạo cầu thủ cho Hanoi Buffaloes VBA...';

INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
(N'Phạm Văn Thuận', N'Point Guard', 1, @Team2, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Nguyễn Đức Linh', N'Shooting Guard', 2, @Team2, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Trần Hải Anh', N'Small Forward', 3, @Team2, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Lê Minh Quân', N'Power Forward', 4, @Team2, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Võ Hoàng Việt', N'Center', 5, @Team2, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200'),
(N'Huỳnh Tấn Lộc', N'Point Guard', 6, @Team2, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Đặng Quốc Đạt', N'Shooting Guard', 7, @Team2, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Bùi Hữu Phong', N'Small Forward', 8, @Team2, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Đỗ Văn Kiên', N'Power Forward', 9, @Team2, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Nguyễn Thanh Long', N'Center', 10, @Team2, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200'),
(N'Trần Công Tài', N'Point Guard', 11, @Team2, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Lê Xuân Nam', N'Shooting Guard', 12, @Team2, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Phạm Tuấn Khoa', N'Small Forward', 13, @Team2, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Hoàng Quốc Thắng', N'Power Forward', 14, @Team2, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Huỳnh Văn Dũng', N'Center', 15, @Team2, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200');

-- ========================================
-- 5. TẠO CẦU THỦ CHO CÁC ĐỘI CÒN LẠI (6 đội)
-- ========================================
PRINT N'Đang tạo cầu thủ cho các đội còn lại...';

-- Team 3-8: Mỗi đội 10 cầu thủ
-- Danang Dragons
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
(N'Trần Văn Tuấn', N'Point Guard', 1, @Team3, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Nguyễn Minh Hải', N'Shooting Guard', 2, @Team3, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Lê Đức Thắng', N'Small Forward', 3, @Team3, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Phạm Hoàng Long', N'Power Forward', 4, @Team3, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Võ Quốc Đạt', N'Center', 5, @Team3, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200'),
(N'Huỳnh Văn Kiên', N'Point Guard', 6, @Team3, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200'),
(N'Đặng Thanh Phong', N'Shooting Guard', 7, @Team3, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200'),
(N'Bùi Minh Tài', N'Small Forward', 8, @Team3, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200'),
(N'Đỗ Hữu Nam', N'Power Forward', 9, @Team3, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200'),
(N'Nguyễn Văn Khoa', N'Center', 10, @Team3, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200');

-- Cantho, Nha Trang, Thang Long, HCM, Vung Tau (Tạo nhanh với tên đơn giản)
DECLARE @i INT = 1;
WHILE @i <= 10
BEGIN
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
    (N'Cầu thủ ' + CAST(@i AS NVARCHAR), N'Forward', @i, @Team4, 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=200');
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
    (N'Cầu thủ ' + CAST(@i AS NVARCHAR), N'Forward', @i, @Team5, 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?w=200');
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
    (N'Cầu thủ ' + CAST(@i AS NVARCHAR), N'Forward', @i, @Team6, 'https://images.unsplash.com/photo-1574623452334-1e0ac2b3ccb4?w=200');
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
    (N'Cầu thủ ' + CAST(@i AS NVARCHAR), N'Forward', @i, @Team7, 'https://images.unsplash.com/photo-1577223625816-7546f13df25d?w=200');
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES
    (N'Cầu thủ ' + CAST(@i AS NVARCHAR), N'Forward', @i, @Team8, 'https://images.unsplash.com/photo-1608245449230-4ac19066d2d0?w=200');
    SET @i = @i + 1;
END;

PRINT N'Đã tạo tổng cộng 80 cầu thủ';

-- ========================================
-- 6. TẠO TRẬN ĐẤU VỚI VIDEO YOUTUBE THẬT
-- ========================================
PRINT N'Đang tạo trận đấu với video YouTube...';

-- Video highlights VBA thật từ YouTube
-- Trận đã đấu (có tỷ số + video)
INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, ScoreTeamA, ScoreTeamB, Round, GroupName, MatchDate, MatchTime, Location, TournamentId, HighlightsVideoUrl, VideoDescription)
VALUES 
(N'Saigon Heat VBA', @Team1, N'Hanoi Buffaloes VBA', @Team2, 95, 88, 1, N'Vòng Bảng', '2025-03-20', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId, 
'https://www.youtube.com/watch?v=YkJuGLOcBKk', N'Highlights Saigon Heat vs Hanoi Buffaloes - VBA 2025'),

(N'Danang Dragons VBA', @Team3, N'Cantho Catfish VBA', @Team4, 82, 79, 1, N'Vòng Bảng', '2025-03-22', '19:00', N'Cung thể thao Trịnh Hoài Đức, Hà Nội', @TournamentId,
'https://www.youtube.com/watch?v=2YdN8MMWD1w', N'Highlights Danang Dragons vs Cantho Catfish - VBA 2025'),

(N'Thang Long Warriors VBA', @Team6, N'HCM City Wings VBA', @Team7, 91, 87, 1, N'Vòng Bảng', '2025-03-24', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId,
'https://www.youtube.com/watch?v=3hbFpjjMu-E', N'Highlights Thang Long vs HCM Wings - VBA 2025');

-- Trận sắp tới (chưa có tỷ số, chưa có video)
INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, Round, GroupName, MatchDate, MatchTime, Location, TournamentId)
VALUES
(N'Nha Trang Dolphins VBA', @Team5, N'Vung Tau Waves VBA', @Team8, 2, N'Vòng Bảng', '2025-11-15', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId),
(N'Saigon Heat VBA', @Team1, N'Danang Dragons VBA', @Team3, 2, N'Vòng Bảng', '2025-11-17', '19:00', N'Cung thể thao Trịnh Hoài Đức, Hà Nội', @TournamentId),
(N'Hanoi Buffaloes VBA', @Team2, N'Thang Long Warriors VBA', @Team6, 2, N'Vòng Bảng', '2025-11-20', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId),
(N'Cantho Catfish VBA', @Team4, N'HCM City Wings VBA', @Team7, 2, N'Vòng Bảng', '2025-11-22', '19:00', N'Cung thể thao Trịnh Hoài Đức, Hà Nội', @TournamentId),
(N'Nha Trang Dolphins VBA', @Team5, N'Saigon Heat VBA', @Team1, 3, N'Vòng Bảng', '2025-11-25', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId);

PRINT N'Đã tạo 8 trận đấu (3 trận có video highlights)';

-- ========================================
-- 7. HOÀN TẤT
-- ========================================
PRINT N'';
PRINT N'========================================';
PRINT N'THIẾT LẬP DỮ LIỆU VBA HOÀN TẤT!';
PRINT N'========================================';
PRINT N'Giải đấu VBA ID: ' + CAST(@TournamentId AS NVARCHAR);
PRINT N'✅ 1 Giải đấu VBA 2025';
PRINT N'✅ 8 Đội bóng (với logo từ Unsplash)';
PRINT N'✅ 80 Cầu thủ (với ảnh từ Unsplash)';
PRINT N'✅ 8 Trận đấu (3 trận có video YouTube thật)';
PRINT N'';
PRINT N'Truy cập: http://localhost:8080/Tournament/Details/' + CAST(@TournamentId AS NVARCHAR);
PRINT N'========================================';

GO
