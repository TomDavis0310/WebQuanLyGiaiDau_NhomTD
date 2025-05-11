-- Script để cập nhật thời gian bắt đầu cho tất cả các trận đấu
-- Đặt thời gian bắt đầu là 15:00 (3 giờ chiều)

-- Cập nhật tất cả các trận đấu để có thời gian bắt đầu là 15:00
UPDATE Matches
SET MatchDate = DATEADD(HOUR, 15, CAST(CAST(MatchDate AS DATE) AS DATETIME))
WHERE DATEPART(HOUR, MatchDate) <> 15 OR DATEPART(MINUTE, MatchDate) <> 0;

-- Kiểm tra kết quả
SELECT Id, TeamA, TeamB, MatchDate, FORMAT(MatchDate, 'dd/MM/yyyy HH:mm') AS FormattedDate
FROM Matches
ORDER BY MatchDate;
