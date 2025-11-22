-- ========================================
-- SCRIPT TẠO DỮ LIỆU VBA (SIMPLE VERSION)
-- ========================================
USE QLGDDB;
GO

-- ========================================
-- 1. TẠO GIẢI ĐẤU VBA 2025
-- ========================================
PRINT 'Creating VBA 2025 Tournament...';

INSERT INTO Tournaments (Name, Description, Location, StartDate, EndDate, ImageUrl, RegistrationStatus, SportsId, MaxTeams, TeamsPerGroup)
VALUES (
    N'VBA 2025 - Vietnam Basketball Association',
    N'Giải bóng rổ chuyên nghiệp hàng đầu Việt Nam mùa giải 2025',
    N'Nhà thi đấu Phú Thọ, TP.HCM',
    '2025-03-15',
    '2025-08-30',
    'https://vba.vn/wp-content/uploads/2024/01/vba-2024-logo.jpg',
    'Open',
    1,
    8,
    4
);

DECLARE @TournamentId INT = SCOPE_IDENTITY();
PRINT 'Tournament ID: ' + CAST(@TournamentId AS VARCHAR);

-- ========================================
-- 2. TẠO 8 ĐỘI BÓNG VBA
-- ========================================
PRINT 'Creating Teams...';

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'Saigon Heat VBA', N'HLV Nguyễn Minh Chiến', 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Saigon_Heat_logo.svg/200px-Saigon_Heat_logo.svg.png');
DECLARE @Team1 INT = SCOPE_IDENTITY();

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'Hanoi Buffaloes VBA', N'HLV Phạm Đức Thuận', 'https://vba.vn/wp-content/uploads/2023/01/hanoi-buffaloes-logo.png');
DECLARE @Team2 INT = SCOPE_IDENTITY();

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'Danang Dragons VBA', N'HLV Trần Quốc Tuấn', 'https://vba.vn/wp-content/uploads/2023/01/danang-dragons-logo.png');
DECLARE @Team3 INT = SCOPE_IDENTITY();

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'Cantho Catfish VBA', N'HLV Lê Văn Hùng', 'https://vba.vn/wp-content/uploads/2023/01/cantho-catfish-logo.png');
DECLARE @Team4 INT = SCOPE_IDENTITY();

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'Nha Trang Dolphins VBA', N'HLV Trương Minh Đức', 'https://vba.vn/wp-content/uploads/2023/01/nhatrang-dolphins-logo.png');
DECLARE @Team5 INT = SCOPE_IDENTITY();

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'Thang Long Warriors VBA', N'HLV Nguyễn Hải Đăng', 'https://vba.vn/wp-content/uploads/2023/01/thanglong-warriors-logo.png');
DECLARE @Team6 INT = SCOPE_IDENTITY();

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'HCM City Wings VBA', N'HLV Lê Hoàng Anh', 'https://vba.vn/wp-content/uploads/2023/01/hcmc-wings-logo.png');
DECLARE @Team7 INT = SCOPE_IDENTITY();

INSERT INTO Teams (Name, Coach, LogoUrl) VALUES (N'Vung Tau Waves VBA', N'HLV Phạm Văn Tùng', 'https://vba.vn/wp-content/uploads/2023/01/vungtau-waves-logo.png');
DECLARE @Team8 INT = SCOPE_IDENTITY();

PRINT 'Created 8 teams';

-- ========================================
-- 3. TẠO CẦU THỦ CHO ĐỘI 1 (Saigon Heat)
-- ========================================
PRINT 'Creating players for Saigon Heat...';
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Văn Hùng', N'Point Guard', 1, @Team1, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trần Minh Dũng', N'Shooting Guard', 2, @Team1, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Quốc Phong', N'Small Forward', 3, @Team1, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Đức Tài', N'Power Forward', 4, @Team1, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Hoàng Anh Kiên', N'Center', 5, @Team1, 'https://via.placeholder.com/200?text=5');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Huỳnh Hải Đạt', N'Point Guard', 6, @Team1, 'https://via.placeholder.com/200?text=6');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Võ Tuấn Thắng', N'Shooting Guard', 7, @Team1, 'https://via.placeholder.com/200?text=7');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Đặng Minh Long', N'Small Forward', 8, @Team1, 'https://via.placeholder.com/200?text=8');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Bùi Văn Nam', N'Power Forward', 9, @Team1, 'https://via.placeholder.com/200?text=9');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Đỗ Hoàng Khoa', N'Center', 10, @Team1, 'https://via.placeholder.com/200?text=10');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Tấn Phát', N'Point Guard', 11, @Team1, 'https://via.placeholder.com/200?text=11');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trần Hữu Thành', N'Shooting Guard', 12, @Team1, 'https://via.placeholder.com/200?text=12');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Công Minh', N'Small Forward', 13, @Team1, 'https://via.placeholder.com/200?text=13');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Quốc Tuấn', N'Power Forward', 14, @Team1, 'https://via.placeholder.com/200?text=14');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Hoàng Văn Cường', N'Center', 15, @Team1, 'https://via.placeholder.com/200?text=15');

-- ========================================
-- 4. TẠO CẦU THỦ CHO ĐỘI 2 (Hanoi Buffaloes)
-- ========================================
PRINT 'Creating players for Hanoi Buffaloes...';
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Văn Thuận', N'Point Guard', 1, @Team2, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Đức Linh', N'Shooting Guard', 2, @Team2, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trần Hải Anh', N'Small Forward', 3, @Team2, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Minh Quân', N'Power Forward', 4, @Team2, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Võ Hoàng Việt', N'Center', 5, @Team2, 'https://via.placeholder.com/200?text=5');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Huỳnh Tấn Lộc', N'Point Guard', 6, @Team2, 'https://via.placeholder.com/200?text=6');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Đặng Quốc Đạt', N'Shooting Guard', 7, @Team2, 'https://via.placeholder.com/200?text=7');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Bùi Hữu Phong', N'Small Forward', 8, @Team2, 'https://via.placeholder.com/200?text=8');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Đỗ Văn Kiên', N'Power Forward', 9, @Team2, 'https://via.placeholder.com/200?text=9');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Thanh Long', N'Center', 10, @Team2, 'https://via.placeholder.com/200?text=10');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trần Công Tài', N'Point Guard', 11, @Team2, 'https://via.placeholder.com/200?text=11');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Xuân Nam', N'Shooting Guard', 12, @Team2, 'https://via.placeholder.com/200?text=12');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Tuấn Khoa', N'Small Forward', 13, @Team2, 'https://via.placeholder.com/200?text=13');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Hoàng Quốc Thắng', N'Power Forward', 14, @Team2, 'https://via.placeholder.com/200?text=14');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Huỳnh Văn Dũng', N'Center', 15, @Team2, 'https://via.placeholder.com/200?text=15');

-- ========================================
-- 5. TẠO CẦU THỦ CHO ĐỘI 3 (Danang Dragons)
-- ========================================
PRINT 'Creating players for Danang Dragons...';
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trần Văn Tuấn', N'Point Guard', 1, @Team3, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Minh Hải', N'Shooting Guard', 2, @Team3, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Đức Thắng', N'Small Forward', 3, @Team3, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Hoàng Long', N'Power Forward', 4, @Team3, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Võ Quốc Đạt', N'Center', 5, @Team3, 'https://via.placeholder.com/200?text=5');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Huỳnh Văn Kiên', N'Point Guard', 6, @Team3, 'https://via.placeholder.com/200?text=6');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Đặng Thanh Phong', N'Shooting Guard', 7, @Team3, 'https://via.placeholder.com/200?text=7');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Bùi Minh Tài', N'Small Forward', 8, @Team3, 'https://via.placeholder.com/200?text=8');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Đỗ Hữu Nam', N'Power Forward', 9, @Team3, 'https://via.placeholder.com/200?text=9');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Văn Khoa', N'Center', 10, @Team3, 'https://via.placeholder.com/200?text=10');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trần Quốc Cường', N'Point Guard', 11, @Team3, 'https://via.placeholder.com/200?text=11');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn Dũng', N'Shooting Guard', 12, @Team3, 'https://via.placeholder.com/200?text=12');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Hải Anh', N'Small Forward', 13, @Team3, 'https://via.placeholder.com/200?text=13');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Hoàng Minh Tuấn', N'Power Forward', 14, @Team3, 'https://via.placeholder.com/200?text=14');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Huỳnh Đức Phát', N'Center', 15, @Team3, 'https://via.placeholder.com/200?text=15');

-- Continue for remaining teams...
PRINT 'Creating players for remaining teams (4-8)...';

-- Team 4-8 players (simplified - 5 key players each)
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn A', N'Point Guard', 1, @Team4, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn B', N'Shooting Guard', 2, @Team4, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn C', N'Small Forward', 3, @Team4, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn D', N'Power Forward', 4, @Team4, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn E', N'Center', 5, @Team4, 'https://via.placeholder.com/200?text=5');

INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trương Văn A', N'Point Guard', 1, @Team5, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trương Văn B', N'Shooting Guard', 2, @Team5, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trương Văn C', N'Small Forward', 3, @Team5, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trương Văn D', N'Power Forward', 4, @Team5, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Trương Văn E', N'Center', 5, @Team5, 'https://via.placeholder.com/200?text=5');

INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Văn F', N'Point Guard', 1, @Team6, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Văn G', N'Shooting Guard', 2, @Team6, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Văn H', N'Small Forward', 3, @Team6, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Văn I', N'Power Forward', 4, @Team6, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Nguyễn Văn J', N'Center', 5, @Team6, 'https://via.placeholder.com/200?text=5');

INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn K', N'Point Guard', 1, @Team7, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn L', N'Shooting Guard', 2, @Team7, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn M', N'Small Forward', 3, @Team7, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn N', N'Power Forward', 4, @Team7, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Lê Văn O', N'Center', 5, @Team7, 'https://via.placeholder.com/200?text=5');

INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Văn P', N'Point Guard', 1, @Team8, 'https://via.placeholder.com/200?text=1');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Văn Q', N'Shooting Guard', 2, @Team8, 'https://via.placeholder.com/200?text=2');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Văn R', N'Small Forward', 3, @Team8, 'https://via.placeholder.com/200?text=3');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Văn S', N'Power Forward', 4, @Team8, 'https://via.placeholder.com/200?text=4');
INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl) VALUES (N'Phạm Văn T', N'Center', 5, @Team8, 'https://via.placeholder.com/200?text=5');

-- ========================================
-- 6. TẠO MỘT SỐ TRẬN ĐẤU MẪU
-- ========================================
PRINT 'Creating matches...';

INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, ScoreTeamA, ScoreTeamB, Round, GroupName, MatchDate, MatchTime, Location, TournamentId, HighlightsVideoUrl, VideoDescription)
VALUES (N'Saigon Heat VBA', @Team1, N'Hanoi Buffaloes VBA', @Team2, 95, 88, 1, N'Vòng Bảng', '2025-03-20', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId, 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', N'Highlights Saigon vs Hanoi');

INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, ScoreTeamA, ScoreTeamB, Round, GroupName, MatchDate, MatchTime, Location, TournamentId, HighlightsVideoUrl, VideoDescription)
VALUES (N'Danang Dragons VBA', @Team3, N'Cantho Catfish VBA', @Team4, 82, 79, 1, N'Vòng Bảng', '2025-03-22', '19:00', N'Cung thể thao Trịnh Hoài Đức, Hà Nội', @TournamentId, 'https://www.youtube.com/watch?v=9bZkp7q19f0', N'Highlights Danang vs Cantho');

INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, Round, GroupName, MatchDate, MatchTime, Location, TournamentId)
VALUES (N'Nha Trang Dolphins VBA', @Team5, N'Thang Long Warriors VBA', @Team6, 1, N'Vòng Bảng', '2025-11-15', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId);

INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, Round, GroupName, MatchDate, MatchTime, Location, TournamentId)
VALUES (N'HCM City Wings VBA', @Team7, N'Vung Tau Waves VBA', @Team8, 1, N'Vòng Bảng', '2025-11-17', '19:00', N'Cung thể thao Trịnh Hoài Đức, Hà Nội', @TournamentId);

INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, Round, GroupName, MatchDate, MatchTime, Location, TournamentId)
VALUES (N'Saigon Heat VBA', @Team1, N'Danang Dragons VBA', @Team3, 2, N'Vòng Bảng', '2025-11-20', '19:00', N'Nhà thi đấu Phú Thọ, TP.HCM', @TournamentId);

INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, Round, GroupName, MatchDate, MatchTime, Location, TournamentId)
VALUES (N'Hanoi Buffaloes VBA', @Team2, N'Nha Trang Dolphins VBA', @Team5, 2, N'Vòng Bảng', '2025-11-22', '19:00', N'Cung thể thao Trịnh Hoài Đức, Hà Nội', @TournamentId);

-- ========================================
-- 7. HOÀN TẤT
-- ========================================
PRINT '';
PRINT '========================================';
PRINT 'THIẾT LẬP DỮ LIỆU VBA HOÀN TẤT!';
PRINT '========================================';
PRINT 'Giải đấu VBA ID: ' + CAST(@TournamentId AS VARCHAR);
PRINT 'Tạo thành công:';
PRINT '- 8 đội bóng VBA';
PRINT '- 65 cầu thủ';
PRINT '- 6 trận đấu mẫu';
PRINT '';
PRINT 'Truy cập: http://localhost:8080/Tournament/Details/' + CAST(@TournamentId AS VARCHAR);
PRINT '========================================';

GO
