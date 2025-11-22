-- ========================================
-- SCRIPT THIẾT LẬP DỮ LIỆU VBA VÀO DATABASE
-- ========================================
-- Database: QLGDDB
-- Run this script in SQL Server Management Studio or sqlcmd
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
    N'Giải bóng rổ chuyên nghiệp hàng đầu Việt Nam mùa giải 2025. VBA là giải đấu bóng rổ cao cấp nhất tại Việt Nam, quy tụ các đội bóng mạnh nhất từ các tỉnh thành trên cả nước.',
    N'Nhà thi đấu Phú Thọ, TP.HCM & Cung thể thao Trịnh Hoài Đức, Hà Nội',
    '2025-03-15',
    '2025-08-30',
    'https://vba.vn/wp-content/uploads/2024/01/vba-2024-logo.jpg',
    'Open',
    1, -- Basketball Sport ID
    8,
    4
);

-- Get the Tournament ID
DECLARE @TournamentId INT = SCOPE_IDENTITY();
PRINT 'VBA Tournament created with ID: ' + CAST(@TournamentId AS VARCHAR);

-- ========================================
-- 2. TẠO 8 ĐỘI BÓNG VBA
-- ========================================
PRINT 'Creating VBA Teams...';

-- Create Teams table variable to store IDs
DECLARE @Teams TABLE (TeamId INT, TeamName NVARCHAR(100));

-- Saigon Heat
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'Saigon Heat', N'HLV Nguyễn Minh Chiến', 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Saigon_Heat_logo.svg/200px-Saigon_Heat_logo.svg.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Saigon Heat');

-- Hanoi Buffaloes
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'Hanoi Buffaloes', N'HLV Phạm Đức Thuận', 'https://vba.vn/wp-content/uploads/2023/01/hanoi-buffaloes-logo.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Hanoi Buffaloes');

-- Danang Dragons
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'Danang Dragons', N'HLV Trần Quốc Tuấn', 'https://vba.vn/wp-content/uploads/2023/01/danang-dragons-logo.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Danang Dragons');

-- Cantho Catfish
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'Cantho Catfish', N'HLV Lê Văn Hùng', 'https://vba.vn/wp-content/uploads/2023/01/cantho-catfish-logo.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Cantho Catfish');

-- Nha Trang Dolphins
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'Nha Trang Dolphins', N'HLV Trương Minh Đức', 'https://vba.vn/wp-content/uploads/2023/01/nhatrang-dolphins-logo.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Nha Trang Dolphins');

-- Thang Long Warriors
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'Thang Long Warriors', N'HLV Nguyễn Hải Đăng', 'https://vba.vn/wp-content/uploads/2023/01/thanglong-warriors-logo.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Thang Long Warriors');

-- HCM City Wings
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'HCM City Wings', N'HLV Lê Hoàng Anh', 'https://vba.vn/wp-content/uploads/2023/01/hcmc-wings-logo.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'HCM City Wings');

-- Vung Tau Waves
INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
VALUES (N'Vung Tau Waves', N'HLV Phạm Văn Tùng', 'https://vba.vn/wp-content/uploads/2023/01/vungtau-waves-logo.png', NULL);
INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Vung Tau Waves');

PRINT 'Created ' + CAST((SELECT COUNT(*) FROM @Teams) AS VARCHAR) + ' teams';

-- ========================================
-- 3. TẠO CẦU THỦ CHO MỖI ĐỘI
-- ========================================
PRINT 'Creating Players for each team...';

-- Cursor to iterate through teams
DECLARE @CurrentTeamId INT;
DECLARE @CurrentTeamName NVARCHAR(100);
DECLARE @PlayerCount INT = 0;

DECLARE team_cursor CURSOR FOR
SELECT TeamId, TeamName FROM @Teams;

OPEN team_cursor;
FETCH NEXT FROM team_cursor INTO @CurrentTeamId, @CurrentTeamName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Creating players for team: ' + @CurrentTeamName;
    
    -- Create 15 players per team (3 per position)
    -- Point Guards (1-3)
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl, UserId)
    VALUES 
        (N'Nguyễn Văn Hùng', N'Point Guard', 1, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=1', NULL),
        (N'Trần Minh Long', N'Point Guard', 6, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=6', NULL),
        (N'Lê Quốc Nam', N'Point Guard', 11, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=11', NULL);
    
    -- Shooting Guards (2-4)
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl, UserId)
    VALUES 
        (N'Phạm Đức Khoa', N'Shooting Guard', 2, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=2', NULL),
        (N'Hoàng Tấn Dũng', N'Shooting Guard', 7, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=7', NULL),
        (N'Huỳnh Anh Thắng', N'Shooting Guard', 12, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=12', NULL);
    
    -- Small Forwards (3-5)
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl, UserId)
    VALUES 
        (N'Võ Hải Phong', N'Small Forward', 3, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=3', NULL),
        (N'Đặng Tuấn Tài', N'Small Forward', 8, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=8', NULL),
        (N'Bùi Minh Kiên', N'Small Forward', 13, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=13', NULL);
    
    -- Power Forwards (4-6)
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl, UserId)
    VALUES 
        (N'Đỗ Hoàng Đạt', N'Power Forward', 4, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=4', NULL),
        (N'Nguyễn Văn Thắng', N'Power Forward', 9, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=9', NULL),
        (N'Trần Quốc Tuấn', N'Power Forward', 14, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=14', NULL);
    
    -- Centers (5-7)
    INSERT INTO Players (FullName, Position, Number, TeamId, ImageUrl, UserId)
    VALUES 
        (N'Lê Văn Dũng', N'Center', 5, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=5', NULL),
        (N'Phạm Minh Phong', N'Center', 10, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=10', NULL),
        (N'Hoàng Đức Long', N'Center', 15, @CurrentTeamId, 'https://via.placeholder.com/200x200?text=15', NULL);
    
    SET @PlayerCount = @PlayerCount + 15;
    
    FETCH NEXT FROM team_cursor INTO @CurrentTeamId, @CurrentTeamName;
END;

CLOSE team_cursor;
DEALLOCATE team_cursor;

SELECT @PlayerCount = COUNT(*) FROM Players WHERE TeamId IN (SELECT TeamId FROM @Teams);
PRINT 'Created ' + CAST(@PlayerCount AS VARCHAR) + ' players';

-- ========================================
-- 4. TẠO LỊCH THI ĐẤU (VÒNG BẢNG)
-- ========================================
PRINT 'Creating Match Schedule...';

DECLARE @MatchCount INT = 0;
DECLARE @TeamA_Id INT, @TeamA_Name NVARCHAR(100);
DECLARE @TeamB_Id INT, @TeamB_Name NVARCHAR(100);
DECLARE @MatchDate DATE = '2025-03-20';
DECLARE @ScoreA INT, @ScoreB INT;
DECLARE @VideoUrl NVARCHAR(500);

-- Create matches between all teams (round-robin)
DECLARE team_a_cursor CURSOR FOR
SELECT TeamId, TeamName FROM @Teams;

OPEN team_a_cursor;
FETCH NEXT FROM team_a_cursor INTO @TeamA_Id, @TeamA_Name;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE team_b_cursor CURSOR FOR
    SELECT TeamId, TeamName FROM @Teams WHERE TeamId > @TeamA_Id;
    
    OPEN team_b_cursor;
    FETCH NEXT FROM team_b_cursor INTO @TeamB_Id, @TeamB_Name;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if match is in the past
        IF @MatchDate < GETDATE()
        BEGIN
            SET @ScoreA = FLOOR(RAND() * 40) + 70; -- Random score 70-110
            SET @ScoreB = FLOOR(RAND() * 40) + 70;
            SET @VideoUrl = CASE FLOOR(RAND() * 2)
                WHEN 0 THEN 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
                ELSE 'https://www.youtube.com/watch?v=9bZkp7q19f0'
            END;
        END
        ELSE
        BEGIN
            SET @ScoreA = NULL;
            SET @ScoreB = NULL;
            SET @VideoUrl = NULL;
        END;
        
        -- Create match
        INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, ScoreTeamA, ScoreTeamB, Round, GroupName, MatchDate, MatchTime, Location, TournamentId, HighlightsVideoUrl, VideoDescription)
        VALUES (
            @TeamA_Name,
            @TeamA_Id,
            @TeamB_Name,
            @TeamB_Id,
            @ScoreA,
            @ScoreB,
            (@MatchCount / 4) + 1, -- Round number
            N'Vòng Bảng',
            @MatchDate,
            '19:00:00',
            CASE @MatchCount % 2
                WHEN 0 THEN N'Nhà thi đấu Phú Thọ, TP.HCM'
                ELSE N'Cung thể thao Trịnh Hoài Đức, Hà Nội'
            END,
            @TournamentId,
            @VideoUrl,
            CASE 
                WHEN @VideoUrl IS NOT NULL THEN N'Highlights trận ' + @TeamA_Name + ' vs ' + @TeamB_Name + ' - VBA 2025'
                ELSE NULL
            END
        );
        
        SET @MatchCount = @MatchCount + 1;
        SET @MatchDate = DATEADD(DAY, 2, @MatchDate); -- Match every 2 days
        
        FETCH NEXT FROM team_b_cursor INTO @TeamB_Id, @TeamB_Name;
    END;
    
    CLOSE team_b_cursor;
    DEALLOCATE team_b_cursor;
    
    FETCH NEXT FROM team_a_cursor INTO @TeamA_Id, @TeamA_Name;
END;

CLOSE team_a_cursor;
DEALLOCATE team_a_cursor;

PRINT 'Created ' + CAST(@MatchCount AS VARCHAR) + ' matches';

-- ========================================
-- 5. TẠO TIN TỨC VBA
-- ========================================
PRINT 'Creating News Articles...';

INSERT INTO News (Title, Content, ImageUrl, PublishDate)
VALUES 
    (N'Khai mạc VBA 2025: Mùa giải đầy hứa hẹn',
     N'Giải bóng rổ chuyên nghiệp VBA 2025 chính thức khai mạc với sự tham gia của 8 đội bóng mạnh nhất cả nước. Đây hứa hẹn sẽ là một mùa giải đầy kịch tính và hấp dẫn với nhiều cầu thủ tài năng.',
     'https://vba.vn/wp-content/uploads/2024/01/vba-2024-opening.jpg',
     DATEADD(DAY, -30, GETDATE())),
    
    (N'Saigon Heat: Ứng cử viên nặng ký cho chức vô địch',
     N'Với đội hình mạnh và kinh nghiệm dày dặn, Saigon Heat được đánh giá cao là ứng cử viên sáng giá nhất cho chức vô địch VBA 2025.',
     'https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Saigon_Heat_logo.svg/200px-Saigon_Heat_logo.svg.png',
     DATEADD(DAY, -25, GETDATE())),
    
    (N'Hanoi Buffaloes tuyển thêm ngoại binh chất lượng',
     N'Hanoi Buffaloes vừa hoàn tất việc ký hợp đồng với ngoại binh người Mỹ Marcus Johnson, hứa hẹn sẽ là sự bổ sung quan trọng cho đội.',
     'https://vba.vn/wp-content/uploads/2023/01/hanoi-buffaloes-logo.png',
     DATEADD(DAY, -20, GETDATE())),
    
    (N'Lịch thi đấu VBA 2025 chính thức được công bố',
     N'Ban tổ chức VBA đã công bố lịch thi đấu chính thức cho mùa giải 2025 với 28 trận đấu trong giai đoạn vòng bảng.',
     'https://vba.vn/wp-content/uploads/2024/01/vba-schedule.jpg',
     DATEADD(DAY, -15, GETDATE()));

PRINT 'Created 4 news articles';

-- ========================================
-- SUMMARY
-- ========================================
DECLARE @TeamCount INT;
SELECT @TeamCount = COUNT(*) FROM @Teams;

PRINT '';
PRINT '========================================';
PRINT 'THIẾT LẬP DỮ LIỆU VBA HOÀN TẤT!';
PRINT '========================================';
PRINT 'Giải đấu VBA ID: ' + CAST(@TournamentId AS VARCHAR);
PRINT 'Số đội: ' + CAST(@TeamCount AS VARCHAR);
PRINT 'Số cầu thủ: ' + CAST(@PlayerCount AS VARCHAR);
PRINT 'Số trận đấu: ' + CAST(@MatchCount AS VARCHAR);
PRINT '';
PRINT 'Truy cập web tại: http://localhost:8080/';
PRINT 'Chi tiết giải đấu: http://localhost:8080/Tournament/Details/' + CAST(@TournamentId AS VARCHAR);
PRINT '========================================';

GO
