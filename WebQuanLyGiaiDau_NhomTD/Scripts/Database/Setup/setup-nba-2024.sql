-- =============================================
-- NBA 2024 Tournament Setup Script
-- Tạo giải đấu NBA 2024 với các đội và cầu thủ thực tế
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
DECLARE @FormatId INT;
DECLARE @UserId NVARCHAR(450);

-- Lấy SportsId cho Basketball
SELECT @SportsId = Id FROM Sports WHERE Name = N'Bóng rổ';
IF @SportsId IS NULL
BEGIN
    INSERT INTO Sports (Name, ImageUrl, Description) 
    VALUES (N'Bóng rổ', N'/images/sports/basketball.jpg', N'Basketball - NBA');
    SET @SportsId = SCOPE_IDENTITY();
    PRINT 'Created Basketball sport';
END

-- Lấy FormatId cho League format
SELECT @FormatId = Id FROM TournamentFormats WHERE Name = N'League';
IF @FormatId IS NULL
BEGIN
    INSERT INTO TournamentFormats (Name, Description) 
    VALUES (N'League', N'League format with regular season');
    SET @FormatId = SCOPE_IDENTITY();
    PRINT 'Created League format';
END

-- Lấy UserId đầu tiên (admin)
SELECT TOP 1 @UserId = Id FROM AspNetUsers;

-- Tạo giải đấu NBA 2024
IF NOT EXISTS (SELECT 1 FROM Tournaments WHERE Name = N'NBA 2024 Season')
BEGIN
    INSERT INTO Tournaments (
        Name, 
        Description, 
        ImageUrl,
        Location, 
        StartDate, 
        EndDate, 
        MaxTeams, 
        TeamsPerGroup,
        RegistrationStatus,
        SportsId,
        TournamentFormatId,
        UserId,
        CreateAt
    )
    VALUES (
        N'NBA 2024 Season',
        N'Giải bóng rổ nhà nghề Mỹ - NBA mùa giải 2024. Cuộc đua gay cấn giữa các đội bóng hàng đầu thế giới với những ngôi sao xuất sắc nhất.',
        N'/images/tournaments/nba-2024.jpg',
        N'United States',
        '2024-10-01',
        '2025-06-20',
        30,
        15,
        N'InProgress',
        @SportsId,
        @FormatId,
        @UserId,
        GETDATE()
    );
    
    SET @TournamentId = SCOPE_IDENTITY();
    PRINT 'Created NBA 2024 Tournament with ID: ' + CAST(@TournamentId AS NVARCHAR(10));
END
ELSE
BEGIN
    SELECT @TournamentId = Id FROM Tournaments WHERE Name = N'NBA 2024 Season';
    PRINT 'NBA 2024 Tournament already exists with ID: ' + CAST(@TournamentId AS NVARCHAR(10));
END

-- =============================================
-- 2. TẠO CÁC ĐỘI BÓNG NBA (Top 16 teams)
-- =============================================
PRINT 'Creating NBA Teams...';

-- Eastern Conference Teams
DECLARE @TeamIds TABLE (TeamName NVARCHAR(100), TeamId INT);

-- Boston Celtics
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Boston Celtics' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Boston Celtics', N'Joe Mazzulla', N'/images/teams/celtics.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Boston Celtics', SCOPE_IDENTITY());
END

-- Milwaukee Bucks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Milwaukee Bucks' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Milwaukee Bucks', N'Doc Rivers', N'/images/teams/bucks.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Milwaukee Bucks', SCOPE_IDENTITY());
END

-- Philadelphia 76ers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Philadelphia 76ers' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Philadelphia 76ers', N'Nick Nurse', N'/images/teams/76ers.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Philadelphia 76ers', SCOPE_IDENTITY());
END

-- Miami Heat
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Miami Heat' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Miami Heat', N'Erik Spoelstra', N'/images/teams/heat.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Miami Heat', SCOPE_IDENTITY());
END

-- New York Knicks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'New York Knicks' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'New York Knicks', N'Tom Thibodeau', N'/images/teams/knicks.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'New York Knicks', SCOPE_IDENTITY());
END

-- Cleveland Cavaliers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Cleveland Cavaliers' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Cleveland Cavaliers', N'J.B. Bickerstaff', N'/images/teams/cavaliers.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Cleveland Cavaliers', SCOPE_IDENTITY());
END

-- Brooklyn Nets
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Brooklyn Nets' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Brooklyn Nets', N'Jacque Vaughn', N'/images/teams/nets.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Brooklyn Nets', SCOPE_IDENTITY());
END

-- Atlanta Hawks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Atlanta Hawks' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Atlanta Hawks', N'Quin Snyder', N'/images/teams/hawks.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Atlanta Hawks', SCOPE_IDENTITY());
END

-- Western Conference Teams

-- Denver Nuggets
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Denver Nuggets' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Denver Nuggets', N'Michael Malone', N'/images/teams/nuggets.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Denver Nuggets', SCOPE_IDENTITY());
END

-- Los Angeles Lakers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Los Angeles Lakers' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Los Angeles Lakers', N'Darvin Ham', N'/images/teams/lakers.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Los Angeles Lakers', SCOPE_IDENTITY());
END

-- Golden State Warriors
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Golden State Warriors' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Golden State Warriors', N'Steve Kerr', N'/images/teams/warriors.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Golden State Warriors', SCOPE_IDENTITY());
END

-- Phoenix Suns
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Phoenix Suns' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Phoenix Suns', N'Frank Vogel', N'/images/teams/suns.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Phoenix Suns', SCOPE_IDENTITY());
END

-- Dallas Mavericks
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Dallas Mavericks' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Dallas Mavericks', N'Jason Kidd', N'/images/teams/mavericks.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Dallas Mavericks', SCOPE_IDENTITY());
END

-- Los Angeles Clippers
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Los Angeles Clippers' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Los Angeles Clippers', N'Tyronn Lue', N'/images/teams/clippers.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Los Angeles Clippers', SCOPE_IDENTITY());
END

-- Sacramento Kings
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Sacramento Kings' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Sacramento Kings', N'Mike Brown', N'/images/teams/kings.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Sacramento Kings', SCOPE_IDENTITY());
END

-- Minnesota Timberwolves
IF NOT EXISTS (SELECT 1 FROM Teams WHERE Name = N'Minnesota Timberwolves' AND TournamentId = @TournamentId)
BEGIN
    INSERT INTO Teams (Name, Coach, LogoUrl, UserId, TournamentId, SportsId)
    VALUES (N'Minnesota Timberwolves', N'Chris Finch', N'/images/teams/timberwolves.png', @UserId, @TournamentId, @SportsId);
    INSERT INTO @TeamIds VALUES (N'Minnesota Timberwolves', SCOPE_IDENTITY());
END

PRINT 'Created 16 NBA Teams';

-- =============================================
-- 3. TẠO CẦU THỦ CHO CÁC ĐỘI (Top players)
-- =============================================
PRINT 'Creating NBA Players...';

-- Boston Celtics Players
DECLARE @CelticsId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Boston Celtics' AND TournamentId = @TournamentId);
IF @CelticsId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Jayson Tatum', N'Forward', N'0', N'/images/players/tatum.jpg', @CelticsId),
        (N'Jaylen Brown', N'Guard', N'7', N'/images/players/brown.jpg', @CelticsId),
        (N'Kristaps Porzingis', N'Center', N'8', N'/images/players/porzingis.jpg', @CelticsId),
        (N'Derrick White', N'Guard', N'9', N'/images/players/white.jpg', @CelticsId),
        (N'Jrue Holiday', N'Guard', N'4', N'/images/players/holiday.jpg', @CelticsId);
END

-- Los Angeles Lakers Players
DECLARE @LakersId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Los Angeles Lakers' AND TournamentId = @TournamentId);
IF @LakersId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'LeBron James', N'Forward', N'23', N'/images/players/lebron.jpg', @LakersId),
        (N'Anthony Davis', N'Forward', N'3', N'/images/players/davis.jpg', @LakersId),
        (N'D''Angelo Russell', N'Guard', N'1', N'/images/players/russell.jpg', @LakersId),
        (N'Austin Reaves', N'Guard', N'15', N'/images/players/reaves.jpg', @LakersId),
        (N'Rui Hachimura', N'Forward', N'28', N'/images/players/hachimura.jpg', @LakersId);
END

-- Golden State Warriors Players
DECLARE @WarriorsId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Golden State Warriors' AND TournamentId = @TournamentId);
IF @WarriorsId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Stephen Curry', N'Guard', N'30', N'/images/players/curry.jpg', @WarriorsId),
        (N'Klay Thompson', N'Guard', N'11', N'/images/players/thompson.jpg', @WarriorsId),
        (N'Andrew Wiggins', N'Forward', N'22', N'/images/players/wiggins.jpg', @WarriorsId),
        (N'Draymond Green', N'Forward', N'23', N'/images/players/green.jpg', @WarriorsId),
        (N'Chris Paul', N'Guard', N'3', N'/images/players/paul.jpg', @WarriorsId);
END

-- Milwaukee Bucks Players
DECLARE @BucksId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Milwaukee Bucks' AND TournamentId = @TournamentId);
IF @BucksId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Giannis Antetokounmpo', N'Forward', N'34', N'/images/players/giannis.jpg', @BucksId),
        (N'Damian Lillard', N'Guard', N'0', N'/images/players/lillard.jpg', @BucksId),
        (N'Khris Middleton', N'Forward', N'22', N'/images/players/middleton.jpg', @BucksId),
        (N'Brook Lopez', N'Center', N'11', N'/images/players/lopez.jpg', @BucksId),
        (N'Bobby Portis', N'Forward', N'9', N'/images/players/portis.jpg', @BucksId);
END

-- Denver Nuggets Players
DECLARE @NuggetsId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Denver Nuggets' AND TournamentId = @TournamentId);
IF @NuggetsId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Nikola Jokic', N'Center', N'15', N'/images/players/jokic.jpg', @NuggetsId),
        (N'Jamal Murray', N'Guard', N'27', N'/images/players/murray.jpg', @NuggetsId),
        (N'Michael Porter Jr.', N'Forward', N'1', N'/images/players/porter.jpg', @NuggetsId),
        (N'Aaron Gordon', N'Forward', N'50', N'/images/players/gordon.jpg', @NuggetsId),
        (N'Kentavious Caldwell-Pope', N'Guard', N'5', N'/images/players/kcp.jpg', @NuggetsId);
END

-- Phoenix Suns Players
DECLARE @SunsId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Phoenix Suns' AND TournamentId = @TournamentId);
IF @SunsId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Kevin Durant', N'Forward', N'35', N'/images/players/durant.jpg', @SunsId),
        (N'Devin Booker', N'Guard', N'1', N'/images/players/booker.jpg', @SunsId),
        (N'Bradley Beal', N'Guard', N'3', N'/images/players/beal.jpg', @SunsId),
        (N'Jusuf Nurkic', N'Center', N'20', N'/images/players/nurkic.jpg', @SunsId),
        (N'Grayson Allen', N'Guard', N'8', N'/images/players/allen.jpg', @SunsId);
END

-- Dallas Mavericks Players
DECLARE @MavericksId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Dallas Mavericks' AND TournamentId = @TournamentId);
IF @MavericksId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Luka Doncic', N'Guard', N'77', N'/images/players/doncic.jpg', @MavericksId),
        (N'Kyrie Irving', N'Guard', N'11', N'/images/players/irving.jpg', @MavericksId),
        (N'Dereck Lively II', N'Center', N'2', N'/images/players/lively.jpg', @MavericksId),
        (N'Josh Green', N'Guard', N'8', N'/images/players/green-j.jpg', @MavericksId),
        (N'Daniel Gafford', N'Center', N'21', N'/images/players/gafford.jpg', @MavericksId);
END

-- Philadelphia 76ers Players
DECLARE @SixersId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Philadelphia 76ers' AND TournamentId = @TournamentId);
IF @SixersId IS NOT NULL
BEGIN
    INSERT INTO Players (FullName, Position, Number, ImageUrl, TeamId)
    VALUES 
        (N'Joel Embiid', N'Center', N'21', N'/images/players/embiid.jpg', @SixersId),
        (N'Tyrese Maxey', N'Guard', N'0', N'/images/players/maxey.jpg', @SixersId),
        (N'Tobias Harris', N'Forward', N'12', N'/images/players/harris.jpg', @SixersId),
        (N'De''Anthony Melton', N'Guard', N'8', N'/images/players/melton.jpg', @SixersId),
        (N'Kelly Oubre Jr.', N'Forward', N'9', N'/images/players/oubre.jpg', @SixersId);
END

PRINT 'Created NBA Players for all teams';

-- =============================================
-- 4. TẠO CÁC TRẬN ĐẤU (Sample matches)
-- =============================================
PRINT 'Creating NBA Matches...';

-- Match 1: Lakers vs Warriors (Completed)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @LakersId AND TeamBId = @WarriorsId)
BEGIN
    INSERT INTO Matches (TeamAId, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (@LakersId, @WarriorsId, '2024-10-15', '19:30:00', N'Crypto.com Arena', 115, 108, @TournamentId, NULL, 1);
    
    -- Thêm ghi điểm cho trận này
    DECLARE @MatchId INT = SCOPE_IDENTITY();
    DECLARE @LeBronId INT = (SELECT TOP 1 PlayerId FROM Players WHERE FullName = N'LeBron James' AND TeamId = @LakersId);
    DECLARE @CurryId INT = (SELECT TOP 1 PlayerId FROM Players WHERE FullName = N'Stephen Curry' AND TeamId = @WarriorsId);
    
    IF @LeBronId IS NOT NULL
        INSERT INTO PlayerScorings (PlayerId, MatchId, Points, ScoringTime) VALUES (@LeBronId, @MatchId, 28, '23:45');
    IF @CurryId IS NOT NULL
        INSERT INTO PlayerScorings (PlayerId, MatchId, Points, ScoringTime) VALUES (@CurryId, @MatchId, 32, '22:30');
END

-- Match 2: Celtics vs Bucks (Completed)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @CelticsId AND TeamBId = @BucksId)
BEGIN
    INSERT INTO Matches (TeamAId, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (@CelticsId, @BucksId, '2024-10-18', '20:00:00', N'TD Garden', 122, 119, @TournamentId, NULL, 1);
    
    DECLARE @MatchId2 INT = SCOPE_IDENTITY();
    DECLARE @TatumId INT = (SELECT TOP 1 PlayerId FROM Players WHERE FullName = N'Jayson Tatum' AND TeamId = @CelticsId);
    DECLARE @GiannisId INT = (SELECT TOP 1 PlayerId FROM Players WHERE FullName = N'Giannis Antetokounmpo' AND TeamId = @BucksId);
    
    IF @TatumId IS NOT NULL
        INSERT INTO PlayerScorings (PlayerId, MatchId, Points, ScoringTime) VALUES (@TatumId, @MatchId2, 35, '24:15');
    IF @GiannisId IS NOT NULL
        INSERT INTO PlayerScorings (PlayerId, MatchId, Points, ScoringTime) VALUES (@GiannisId, @MatchId2, 38, '25:30');
END

-- Match 3: Nuggets vs Suns (Completed)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @NuggetsId AND TeamBId = @SunsId)
BEGIN
    INSERT INTO Matches (TeamAId, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (@NuggetsId, @SunsId, '2024-10-22', '21:00:00', N'Ball Arena', 128, 125, @TournamentId, NULL, 2);
    
    DECLARE @MatchId3 INT = SCOPE_IDENTITY();
    DECLARE @JokicId INT = (SELECT TOP 1 PlayerId FROM Players WHERE FullName = N'Nikola Jokic' AND TeamId = @NuggetsId);
    DECLARE @DurantId INT = (SELECT TOP 1 PlayerId FROM Players WHERE FullName = N'Kevin Durant' AND TeamId = @SunsId);
    
    IF @JokicId IS NOT NULL
        INSERT INTO PlayerScorings (PlayerId, MatchId, Points, ScoringTime) VALUES (@JokicId, @MatchId3, 41, '26:45');
    IF @DurantId IS NOT NULL
        INSERT INTO PlayerScorings (PlayerId, MatchId, Points, ScoringTime) VALUES (@DurantId, @MatchId3, 35, '25:00');
END

-- Match 4: Mavericks vs Clippers (Upcoming)
DECLARE @ClippersId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Los Angeles Clippers' AND TournamentId = @TournamentId);
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @MavericksId AND TeamBId = @ClippersId)
BEGIN
    INSERT INTO Matches (TeamAId, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (@MavericksId, @ClippersId, '2024-11-15', '19:30:00', N'American Airlines Center', NULL, NULL, @TournamentId, NULL, 3);
END

-- Match 5: 76ers vs Heat (Upcoming)
DECLARE @HeatId INT = (SELECT TOP 1 Id FROM Teams WHERE Name = N'Miami Heat' AND TournamentId = @TournamentId);
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @SixersId AND TeamBId = @HeatId)
BEGIN
    INSERT INTO Matches (TeamAId, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (@SixersId, @HeatId, '2024-11-18', '20:00:00', N'Wells Fargo Center', NULL, NULL, @TournamentId, NULL, 3);
END

-- Match 6: Lakers vs Nuggets (Upcoming - Christmas Game)
IF NOT EXISTS (SELECT 1 FROM Matches WHERE TeamAId = @LakersId AND TeamBId = @NuggetsId)
BEGIN
    INSERT INTO Matches (TeamAId, TeamBId, MatchDate, MatchTime, Location, ScoreTeamA, ScoreTeamB, TournamentId, GroupName, Round)
    VALUES (@LakersId, @NuggetsId, '2024-12-25', '15:00:00', N'Crypto.com Arena', NULL, NULL, @TournamentId, NULL, 4);
END

PRINT 'Created NBA Matches';

-- =============================================
-- 5. TẠO TIN TỨC VỀ NBA 2024
-- =============================================
PRINT 'Creating NBA News...';

IF NOT EXISTS (SELECT 1 FROM News WHERE Title LIKE N'%NBA 2024%')
BEGIN
    INSERT INTO News (Title, Content, ImageUrl, UserId, CreateAt, IsHighlight)
    VALUES 
        (N'NBA 2024: Mùa giải hấp dẫn với nhiều ngôi sao sáng giá',
         N'Mùa giải NBA 2024 đã bắt đầu với những trận đấu kịch tính. Boston Celtics và Denver Nuggets được đánh giá cao là ứng cử viên vô địch. LeBron James tiếp tục thi đấu ấn tượng ở tuổi 39, trong khi Nikola Jokic duy trì phong độ MVP xuất sắc.',
         N'/images/news/nba-2024-season.jpg',
         @UserId,
         GETDATE(),
         1),
        (N'Stephen Curry phá kỷ lục ba điểm trong trận đấu với Lakers',
         N'Ngôi sao Golden State Warriors Stephen Curry đã có màn trình diễn xuất sắc với 8 quả ba điểm trong trận thua Lakers 108-115. Curry hiện dẫn đầu về số ba điểm ghi được trong lịch sử NBA.',
         N'/images/news/curry-record.jpg',
         @UserId,
         GETDATE(),
         1),
        (N'Giannis Antetokounmpo: "Chúng tôi sẽ chiến đấu vì chức vô địch"',
         N'Sau trận thua sát nút trước Celtics, Giannis Antetokounmpo khẳng định Milwaukee Bucks sẽ quay trở lại mạnh mẽ hơn. Với sự bổ sung của Damian Lillard, Bucks được kỳ vọng sẽ đi sâu trong playoffs.',
         N'/images/news/giannis-interview.jpg',
         @UserId,
         DATEADD(day, -2, GETDATE()),
         0),
        (N'NBA Christmas Games: Lakers vs Nuggets sẽ là trận đấu tâm điểm',
         N'Trận đấu giữa Los Angeles Lakers và Denver Nuggets vào ngày Giáng sinh hứa hẹn sẽ là cuộc đối đầu đáng xem nhất. LeBron James và Nikola Jokic, hai siêu sao hàng đầu, sẽ đối đầu trực tiếp.',
         N'/images/news/christmas-games.jpg',
         @UserId,
         DATEADD(day, -1, GETDATE()),
         1);
END

PRINT 'Created NBA News';

-- =============================================
-- HOÀN THÀNH
-- =============================================
PRINT '================================================';
PRINT 'NBA 2024 Setup Completed Successfully!';
PRINT 'Tournament ID: ' + CAST(@TournamentId AS NVARCHAR(10));
PRINT '================================================';
PRINT 'Created:';
PRINT '- 1 NBA 2024 Tournament';
PRINT '- 16 NBA Teams';
PRINT '- 40+ NBA Players';
PRINT '- 6 Matches (3 completed, 3 upcoming)';
PRINT '- 4 News articles';
PRINT '================================================';

GO
