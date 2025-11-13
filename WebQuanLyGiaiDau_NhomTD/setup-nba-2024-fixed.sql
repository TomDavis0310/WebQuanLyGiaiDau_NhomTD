-- =============================================
-- NBA 2024 Tournament Setup Script (FIXED)
-- Tạo giải đấu NBA 2024 với các đội và cầu thủ thực tế
-- Database: QLGDDB
-- =============================================

USE QLGDDB;
GO

PRINT 'Starting NBA 2024 Setup...';
GO

-- =============================================
-- 1. TẠO GIẢI ĐẤU NBA 2024
-- =============================================
DECLARE @TournamentId INT;
DECLARE @SportsId INT;

-- Lấy hoặc tạo Sport Basketball
SELECT @SportsId = Id FROM Sports WHERE Name = N'Bóng rổ';
IF @SportsId IS NULL
BEGIN
    INSERT INTO Sports (Name, ImageUrl) 
    VALUES (N'Bóng rổ', N'/images/sports/basketball.jpg');
    SET @SportsId = SCOPE_IDENTITY();
    PRINT 'Created Basketball sport with ID: ' + CAST(@SportsId AS VARCHAR);
END
ELSE
    PRINT 'Basketball sport already exists with ID: ' + CAST(@SportsId AS VARCHAR);

-- Tạo giải đấu NBA 2024
IF NOT EXISTS (SELECT 1 FROM Tournaments WHERE Name = N'NBA 2024 Season')
BEGIN
    INSERT INTO Tournaments (
        Name, 
        Description, 
        Location, 
        StartDate, 
        EndDate, 
        ImageUrl,
        RegistrationStatus,
        SportsId,
        MaxTeams, 
        TeamsPerGroup,
        TournamentFormatId
    )
    VALUES (
        N'NBA 2024 Season',
        N'Giải bóng rổ nhà nghề Mỹ - NBA mùa giải 2024. Cuộc đua gay cấn giữa các đội bóng hàng đầu thế giới với những ngôi sao xuất sắc nhất.',
        N'United States',
        '2024-10-01',
        '2025-06-20',
        N'https://upload.wikimedia.org/wikipedia/en/thumb/0/03/National_Basketball_Association_logo.svg/200px-National_Basketball_Association_logo.svg.png',
        N'InProgress',
        @SportsId,
        30,
        15,
        NULL
    );
    
    SET @TournamentId = SCOPE_IDENTITY();
    PRINT 'Created NBA 2024 Tournament with ID: ' + CAST(@TournamentId AS VARCHAR);
END
ELSE
BEGIN
    SELECT @TournamentId = Id FROM Tournaments WHERE Name = N'NBA 2024 Season';
    PRINT 'NBA 2024 Tournament already exists with ID: ' + CAST(@TournamentId AS VARCHAR);
END

-- =============================================
-- 2. TẠO CÁC ĐỘI BÓNG NBA (Top 16 teams)
-- =============================================
PRINT 'Creating NBA Teams...';

DECLARE @Teams TABLE (TeamId INT, TeamName NVARCHAR(100));

-- Boston Celtics
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Boston Celtics')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Boston Celtics', N'Joe Mazzulla', N'https://upload.wikimedia.org/wikipedia/en/thumb/8/8f/Boston_Celtics.svg/200px-Boston_Celtics.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Boston Celtics');
END

-- Milwaukee Bucks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Milwaukee Bucks')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Milwaukee Bucks', N'Doc Rivers', N'https://upload.wikimedia.org/wikipedia/en/thumb/4/4a/Milwaukee_Bucks_logo.svg/200px-Milwaukee_Bucks_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Milwaukee Bucks');
END

-- Philadelphia 76ers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Philadelphia 76ers')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Philadelphia 76ers', N'Nick Nurse', N'https://upload.wikimedia.org/wikipedia/en/thumb/0/0e/Philadelphia_76ers_logo.svg/200px-Philadelphia_76ers_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Philadelphia 76ers');
END

-- Miami Heat
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Miami Heat')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Miami Heat', N'Erik Spoelstra', N'https://upload.wikimedia.org/wikipedia/en/thumb/f/fb/Miami_Heat_logo.svg/200px-Miami_Heat_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Miami Heat');
END

-- New York Knicks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'New York Knicks')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'New York Knicks', N'Tom Thibodeau', N'https://upload.wikimedia.org/wikipedia/en/thumb/2/25/New_York_Knicks_logo.svg/200px-New_York_Knicks_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'New York Knicks');
END

-- Cleveland Cavaliers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Cleveland Cavaliers')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Cleveland Cavaliers', N'J.B. Bickerstaff', N'https://upload.wikimedia.org/wikipedia/en/thumb/4/4b/Cleveland_Cavaliers_logo.svg/200px-Cleveland_Cavaliers_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Cleveland Cavaliers');
END

-- Brooklyn Nets
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Brooklyn Nets')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Brooklyn Nets', N'Jacque Vaughn', N'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Brooklyn_Nets_newlogo.svg/200px-Brooklyn_Nets_newlogo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Brooklyn Nets');
END

-- Atlanta Hawks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Atlanta Hawks')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Atlanta Hawks', N'Quin Snyder', N'https://upload.wikimedia.org/wikipedia/en/thumb/2/24/Atlanta_Hawks_logo.svg/200px-Atlanta_Hawks_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Atlanta Hawks');
END

-- Denver Nuggets
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Denver Nuggets')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Denver Nuggets', N'Michael Malone', N'https://upload.wikimedia.org/wikipedia/en/thumb/7/76/Denver_Nuggets.svg/200px-Denver_Nuggets.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Denver Nuggets');
END

-- Los Angeles Lakers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Los Angeles Lakers')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Los Angeles Lakers', N'Darvin Ham', N'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Los_Angeles_Lakers_logo.svg/200px-Los_Angeles_Lakers_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Los Angeles Lakers');
END

-- Golden State Warriors
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Golden State Warriors')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Golden State Warriors', N'Steve Kerr', N'https://upload.wikimedia.org/wikipedia/en/thumb/0/01/Golden_State_Warriors_logo.svg/200px-Golden_State_Warriors_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Golden State Warriors');
END

-- Phoenix Suns
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Phoenix Suns')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Phoenix Suns', N'Frank Vogel', N'https://upload.wikimedia.org/wikipedia/en/thumb/d/dc/Phoenix_Suns_logo.svg/200px-Phoenix_Suns_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Phoenix Suns');
END

-- Dallas Mavericks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Dallas Mavericks')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Dallas Mavericks', N'Jason Kidd', N'https://upload.wikimedia.org/wikipedia/en/thumb/9/97/Dallas_Mavericks_logo.svg/200px-Dallas_Mavericks_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Dallas Mavericks');
END

-- Los Angeles Clippers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Los Angeles Clippers')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Los Angeles Clippers', N'Tyronn Lue', N'https://upload.wikimedia.org/wikipedia/en/thumb/b/bb/Los_Angeles_Clippers_%282015%29.svg/200px-Los_Angeles_Clippers_%282015%29.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Los Angeles Clippers');
END

-- Sacramento Kings
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Sacramento Kings')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Sacramento Kings', N'Mike Brown', N'https://upload.wikimedia.org/wikipedia/en/thumb/c/c7/SacramentoKings.svg/200px-SacramentoKings.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Sacramento Kings');
END

-- Minnesota Timberwolves
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Minnesota Timberwolves')
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId)
    VALUES (N'Minnesota Timberwolves', N'Chris Finch', N'https://upload.wikimedia.org/wikipedia/en/thumb/c/c2/Minnesota_Timberwolves_logo.svg/200px-Minnesota_Timberwolves_logo.svg.png', NULL);
    INSERT INTO @Teams VALUES (SCOPE_IDENTITY(), N'Minnesota Timberwolves');
END

PRINT 'Created 16 NBA Teams';

-- =============================================
-- 3. TẠO CẦU THỦ CHO CÁC ĐỘI (Top players)
-- =============================================
PRINT 'Creating NBA Players...';

-- Boston Celtics Players
DECLARE @CelticsId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Boston Celtics');
IF @CelticsId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'Jayson Tatum' AND TeamId = @CelticsId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Jayson Tatum', N'Forward', N'0', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1628369.png', @CelticsId),
        (N'Jaylen Brown', N'Guard', N'7', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1627759.png', @CelticsId),
        (N'Kristaps Porzingis', N'Center', N'8', N'https://cdn.nba.com/headshots/nba/latest/1040x760/204001.png', @CelticsId),
        (N'Derrick White', N'Guard', N'9', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1628401.png', @CelticsId),
        (N'Jrue Holiday', N'Guard', N'4', N'https://cdn.nba.com/headshots/nba/latest/1040x760/201950.png', @CelticsId);
END

-- Los Angeles Lakers Players
DECLARE @LakersId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Los Angeles Lakers');
IF @LakersId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'LeBron James' AND TeamId = @LakersId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'LeBron James', N'Forward', N'23', N'https://cdn.nba.com/headshots/nba/latest/1040x760/2544.png', @LakersId),
        (N'Anthony Davis', N'Forward', N'3', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203076.png', @LakersId),
        (N'D''Angelo Russell', N'Guard', N'1', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1626156.png', @LakersId),
        (N'Austin Reaves', N'Guard', N'15', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1630559.png', @LakersId),
        (N'Rui Hachimura', N'Forward', N'28', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1629060.png', @LakersId);
END

-- Golden State Warriors Players
DECLARE @WarriorsId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Golden State Warriors');
IF @WarriorsId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'Stephen Curry' AND TeamId = @WarriorsId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Stephen Curry', N'Guard', N'30', N'https://cdn.nba.com/headshots/nba/latest/1040x760/201939.png', @WarriorsId),
        (N'Klay Thompson', N'Guard', N'11', N'https://cdn.nba.com/headshots/nba/latest/1040x760/202691.png', @WarriorsId),
        (N'Andrew Wiggins', N'Forward', N'22', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203952.png', @WarriorsId),
        (N'Draymond Green', N'Forward', N'23', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203110.png', @WarriorsId),
        (N'Chris Paul', N'Guard', N'3', N'https://cdn.nba.com/headshots/nba/latest/1040x760/101108.png', @WarriorsId);
END

-- Milwaukee Bucks Players
DECLARE @BucksId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Milwaukee Bucks');
IF @BucksId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'Giannis Antetokounmpo' AND TeamId = @BucksId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Giannis Antetokounmpo', N'Forward', N'34', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203507.png', @BucksId),
        (N'Damian Lillard', N'Guard', N'0', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203081.png', @BucksId),
        (N'Khris Middleton', N'Forward', N'22', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203114.png', @BucksId),
        (N'Brook Lopez', N'Center', N'11', N'https://cdn.nba.com/headshots/nba/latest/1040x760/201572.png', @BucksId),
        (N'Bobby Portis', N'Forward', N'9', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1626171.png', @BucksId);
END

-- Denver Nuggets Players
DECLARE @NuggetsId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Denver Nuggets');
IF @NuggetsId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'Nikola Jokic' AND TeamId = @NuggetsId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Nikola Jokic', N'Center', N'15', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203999.png', @NuggetsId),
        (N'Jamal Murray', N'Guard', N'27', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1627750.png', @NuggetsId),
        (N'Michael Porter Jr.', N'Forward', N'1', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1629008.png', @NuggetsId),
        (N'Aaron Gordon', N'Forward', N'50', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203932.png', @NuggetsId),
        (N'Kentavious Caldwell-Pope', N'Guard', N'5', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203484.png', @NuggetsId);
END

-- Phoenix Suns Players
DECLARE @SunsId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Phoenix Suns');
IF @SunsId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'Kevin Durant' AND TeamId = @SunsId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Kevin Durant', N'Forward', N'35', N'https://cdn.nba.com/headshots/nba/latest/1040x760/201142.png', @SunsId),
        (N'Devin Booker', N'Guard', N'1', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1626164.png', @SunsId),
        (N'Bradley Beal', N'Guard', N'3', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203078.png', @SunsId),
        (N'Jusuf Nurkic', N'Center', N'20', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203994.png', @SunsId),
        (N'Grayson Allen', N'Guard', N'8', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1628960.png', @SunsId);
END

-- Dallas Mavericks Players
DECLARE @MavericksId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Dallas Mavericks');
IF @MavericksId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'Luka Doncic' AND TeamId = @MavericksId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Luka Doncic', N'Guard', N'77', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1629029.png', @MavericksId),
        (N'Kyrie Irving', N'Guard', N'11', N'https://cdn.nba.com/headshots/nba/latest/1040x760/202681.png', @MavericksId),
        (N'Dereck Lively II', N'Center', N'2', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1641705.png', @MavericksId),
        (N'Josh Green', N'Guard', N'8', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1630182.png', @MavericksId),
        (N'Daniel Gafford', N'Center', N'21', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1629655.png', @MavericksId);
END

-- Philadelphia 76ers Players
DECLARE @SixersId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Philadelphia 76ers');
IF @SixersId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Players WHERE FullName = N'Joel Embiid' AND TeamId = @SixersId)
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Joel Embiid', N'Center', N'21', N'https://cdn.nba.com/headshots/nba/latest/1040x760/203954.png', @SixersId),
        (N'Tyrese Maxey', N'Guard', N'0', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1630178.png', @SixersId),
        (N'Tobias Harris', N'Forward', N'12', N'https://cdn.nba.com/headshots/nba/latest/1040x760/202699.png', @SixersId),
        (N'De''Anthony Melton', N'Guard', N'8', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1629001.png', @SixersId),
        (N'Kelly Oubre Jr.', N'Forward', N'9', N'https://cdn.nba.com/headshots/nba/latest/1040x760/1626162.png', @SixersId);
END

PRINT 'Created NBA Players for all teams';

-- =============================================
-- 4. TẠO CÁC TRẬN ĐẤU (Sample matches)
-- =============================================
PRINT 'Creating NBA Matches...';

-- Match 1: Lakers vs Warriors (Completed)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @LakersId AND TeamBId = @WarriorsId AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (N'Los Angeles Lakers', @LakersId, N'Golden State Warriors', @WarriorsId, '2024-10-15', '19:30:00', N'Crypto.com Arena', 115, 108, @TournamentId, N'Regular Season', 1);
    PRINT 'Created Match 1: Lakers vs Warriors';
END

-- Match 2: Celtics vs Bucks (Completed)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @CelticsId AND TeamBId = @BucksId AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (N'Boston Celtics', @CelticsId, N'Milwaukee Bucks', @BucksId, '2024-10-18', '20:00:00', N'TD Garden', 122, 119, @TournamentId, N'Regular Season', 1);
    PRINT 'Created Match 2: Celtics vs Bucks';
END

-- Match 3: Nuggets vs Suns (Completed)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @NuggetsId AND TeamBId = @SunsId AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (N'Denver Nuggets', @NuggetsId, N'Phoenix Suns', @SunsId, '2024-10-22', '21:00:00', N'Ball Arena', 128, 125, @TournamentId, N'Regular Season', 2);
    PRINT 'Created Match 3: Nuggets vs Suns';
END

-- Match 4: Mavericks vs Clippers (Upcoming)
DECLARE @ClippersId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Los Angeles Clippers');
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @MavericksId AND TeamBId = @ClippersId AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (N'Dallas Mavericks', @MavericksId, N'Los Angeles Clippers', @ClippersId, '2024-11-15', '19:30:00', N'American Airlines Center', NULL, NULL, @TournamentId, N'Regular Season', 3);
    PRINT 'Created Match 4: Mavericks vs Clippers';
END

-- Match 5: 76ers vs Heat (Upcoming)
DECLARE @HeatId INT = (SELECT TOP 1 TeamId FROM Teams WHERE Name = N'Miami Heat');
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @SixersId AND TeamBId = @HeatId AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (N'Philadelphia 76ers', @SixersId, N'Miami Heat', @HeatId, '2024-11-18', '20:00:00', N'Wells Fargo Center', NULL, NULL, @TournamentId, N'Regular Season', 3);
    PRINT 'Created Match 5: 76ers vs Heat';
END

-- Match 6: Lakers vs Nuggets (Upcoming - Christmas Game)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @LakersId AND TeamBId = @NuggetsId AND TournamentId = @TournamentId AND MatchDate = '2024-12-25')
BEGIN
    INSERT INTO Matches (TeamA, TeamAId, TeamB, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (N'Los Angeles Lakers', @LakersId, N'Denver Nuggets', @NuggetsId, '2024-12-25', '15:00:00', N'Crypto.com Arena', NULL, NULL, @TournamentId, N'Christmas Games', 4);
    PRINT 'Created Match 6: Lakers vs Nuggets (Christmas Game)';
END

PRINT 'Created NBA Matches';

-- =============================================
-- 5. TẠO TIN TỨC VỀ NBA 2024
-- =============================================
PRINT 'Creating NBA News...';

IF NOT EXISTS (SELECT 1 FROM News WHERE Title LIKE N'%NBA 2024%')
BEGIN
    INSERT INTO News (Title, Summary, Content, ImageUrl, PublishDate, Author, ViewCount, Category, IsVisible, IsFeatured, SportsId)
    VALUES 
        (N'NBA 2024: Mùa giải hấp dẫn với nhiều ngôi sao sáng giá',
         N'Mùa giải NBA 2024 bắt đầu với nhiều trận đấu kịch tính',
         N'Mùa giải NBA 2024 đã bắt đầu với những trận đấu kịch tính. Boston Celtics và Denver Nuggets được đánh giá cao là ứng cử viên vô địch. LeBron James tiếp tục thi đấu ấn tượng ở tuổi 39, trong khi Nikola Jokic duy trì phong độ MVP xuất sắc.',
         N'https://upload.wikimedia.org/wikipedia/en/thumb/0/03/National_Basketball_Association_logo.svg/200px-National_Basketball_Association_logo.svg.png',
         GETDATE(),
         N'TD Sports',
         0,
         N'Basketball',
         1,
         1,
         @SportsId),
        (N'Stephen Curry phá kỷ lục ba điểm trong trận đấu với Lakers',
         N'Curry ghi 8 quả ba điểm xuất sắc',
         N'Ngôi sao Golden State Warriors Stephen Curry đã có màn trình diễn xuất sắc với 8 quả ba điểm trong trận thua Lakers 108-115. Curry hiện dẫn đầu về số ba điểm ghi được trong lịch sử NBA.',
         N'https://cdn.nba.com/headshots/nba/latest/1040x760/201939.png',
         GETDATE(),
         N'TD Sports',
         0,
         N'Basketball',
         1,
         1,
         @SportsId),
        (N'Giannis Antetokounmpo: "Chúng tôi sẽ chiến đấu vì chức vô địch"',
         N'Giannis quyết tâm cùng Bucks vô địch',
         N'Sau trận thua sát nút trước Celtics, Giannis Antetokounmpo khẳng định Milwaukee Bucks sẽ quay trở lại mạnh mẽ hơn. Với sự bổ sung của Damian Lillard, Bucks được kỳ vọng sẽ đi sâu trong playoffs.',
         N'https://cdn.nba.com/headshots/nba/latest/1040x760/203507.png',
         DATEADD(day, -2, GETDATE()),
         N'TD Sports',
         0,
         N'Basketball',
         1,
         0,
         @SportsId),
        (N'NBA Christmas Games: Lakers vs Nuggets sẽ là trận đấu tâm điểm',
         N'Trận đấu Giáng sinh đáng chờ đợi',
         N'Trận đấu giữa Los Angeles Lakers và Denver Nuggets vào ngày Giáng sinh hứa hẹn sẽ là cuộc đối đầu đáng xem nhất. LeBron James và Nikola Jokic, hai siêu sao hàng đầu, sẽ đối đầu trực tiếp.',
         N'https://cdn.nba.com/headshots/nba/latest/1040x760/2544.png',
         DATEADD(day, -1, GETDATE()),
         N'TD Sports',
         0,
         N'Basketball',
         1,
         1,
         @SportsId);
    
    PRINT 'Created 4 NBA News articles';
END

-- =============================================
-- HOÀN THÀNH
-- =============================================
PRINT '================================================';
PRINT 'NBA 2024 Setup Completed Successfully!';
PRINT 'Tournament ID: ' + CAST(@TournamentId AS VARCHAR);
PRINT '================================================';
PRINT 'Created:';
PRINT '- 1 NBA 2024 Tournament';
PRINT '- 16 NBA Teams';
PRINT '- 40+ NBA Players';
PRINT '- 6 Matches (3 completed, 3 upcoming)';
PRINT '- 4 News articles';
PRINT '================================================';

GO
