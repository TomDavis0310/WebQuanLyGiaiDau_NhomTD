-- =============================================
-- Update NBA 2024 Matches với link YouTube
-- Thêm video highlights cho các trận đấu NBA
-- =============================================

USE QLGDDB;
GO

PRINT 'Updating NBA 2024 Matches with YouTube Videos...';
GO

-- Lấy Tournament ID của NBA 2024
DECLARE @TournamentId INT;
SELECT @TournamentId = Id FROM Tournaments WHERE Name = N'NBA 2024 Season';

IF @TournamentId IS NULL
BEGIN
    PRINT 'ERROR: NBA 2024 Tournament not found!';
    RETURN;
END

PRINT 'NBA 2024 Tournament ID: ' + CAST(@TournamentId AS VARCHAR);

-- Update Match 1: Lakers vs Warriors
UPDATE Matches
SET 
    HighlightsVideoUrl = N'https://www.youtube.com/watch?v=T8DBfY-j79c',
    VideoDescription = N'🏀 Highlights đầy kịch tính: LeBron James ghi 28 điểm, Stephen Curry 32 điểm trong trận Lakers thắng Warriors 115-108'
WHERE 
    TournamentId = @TournamentId 
    AND TeamA = N'Los Angeles Lakers' 
    AND TeamB = N'Golden State Warriors'
    AND MatchDate = '2024-10-15';

IF @@ROWCOUNT > 0
    PRINT '✓ Updated Lakers vs Warriors video';

-- Update Match 2: Celtics vs Bucks
UPDATE Matches
SET 
    HighlightsVideoUrl = N'https://www.youtube.com/watch?v=bJ5ppf0po3k',
    VideoDescription = N'🏀 Trận đấu kịch tính: Jayson Tatum 35 điểm, Giannis 38 điểm trong chiến thắng nghẹt thở 122-119 của Celtics'
WHERE 
    TournamentId = @TournamentId 
    AND TeamA = N'Boston Celtics' 
    AND TeamB = N'Milwaukee Bucks'
    AND MatchDate = '2024-10-18';

IF @@ROWCOUNT > 0
    PRINT '✓ Updated Celtics vs Bucks video';

-- Update Match 3: Nuggets vs Suns
UPDATE Matches
SET 
    HighlightsVideoUrl = N'https://www.youtube.com/watch?v=h6VxLsHRYvo',
    VideoDescription = N'🏀 Nikola Jokic triple-double 41 điểm dẫn dắt Nuggets đánh bại Suns 128-125. Kevin Durant 35 điểm'
WHERE 
    TournamentId = @TournamentId 
    AND TeamA = N'Denver Nuggets' 
    AND TeamB = N'Phoenix Suns'
    AND MatchDate = '2024-10-22';

IF @@ROWCOUNT > 0
    PRINT '✓ Updated Nuggets vs Suns video';

-- Update Match 4: Mavericks vs Clippers (Upcoming - add live stream)
UPDATE Matches
SET 
    LiveStreamUrl = N'https://www.youtube.com/watch?v=live_stream_nba',
    VideoDescription = N'🔴 LIVE: Luka Doncic và Dallas Mavericks đối đầu Los Angeles Clippers'
WHERE 
    TournamentId = @TournamentId 
    AND TeamA = N'Dallas Mavericks' 
    AND TeamB = N'Los Angeles Clippers'
    AND MatchDate = '2024-11-15';

IF @@ROWCOUNT > 0
    PRINT '✓ Updated Mavericks vs Clippers live stream';

-- Update Match 5: 76ers vs Heat (Upcoming - add live stream)
UPDATE Matches
SET 
    LiveStreamUrl = N'https://www.youtube.com/watch?v=live_stream_nba2',
    VideoDescription = N'🔴 LIVE: Joel Embiid dẫn dắt 76ers đối đầu Miami Heat'
WHERE 
    TournamentId = @TournamentId 
    AND TeamA = N'Philadelphia 76ers' 
    AND TeamB = N'Miami Heat'
    AND MatchDate = '2024-11-18';

IF @@ROWCOUNT > 0
    PRINT '✓ Updated 76ers vs Heat live stream';

-- Update Match 6: Lakers vs Nuggets (Christmas Game - add both)
UPDATE Matches
SET 
    LiveStreamUrl = N'https://www.youtube.com/watch?v=christmas_game_live',
    HighlightsVideoUrl = N'https://www.youtube.com/watch?v=christmas_highlights',
    VideoDescription = N'🎄 CHRISTMAS GAME: LeBron James vs Nikola Jokic - Trận đấu tâm điểm ngày lễ'
WHERE 
    TournamentId = @TournamentId 
    AND TeamA = N'Los Angeles Lakers' 
    AND TeamB = N'Denver Nuggets'
    AND MatchDate = '2024-12-25';

IF @@ROWCOUNT > 0
    PRINT '✓ Updated Lakers vs Nuggets Christmas Game';

-- Verify updates
PRINT '';
PRINT '================================================';
PRINT 'Verification:';
SELECT 
    TeamA + ' vs ' + TeamB AS [Match],
    CASE 
        WHEN HighlightsVideoUrl IS NOT NULL THEN '✓ Highlights'
        ELSE '✗ No Highlights'
    END AS [Highlights],
    CASE 
        WHEN LiveStreamUrl IS NOT NULL THEN '✓ Live'
        ELSE '✗ No Live'
    END AS [Live Stream],
    LEFT(VideoDescription, 50) + '...' AS [Description]
FROM Matches
WHERE TournamentId = @TournamentId
ORDER BY MatchDate;

PRINT '================================================';
PRINT 'NBA 2024 Videos Updated Successfully!';
GO
