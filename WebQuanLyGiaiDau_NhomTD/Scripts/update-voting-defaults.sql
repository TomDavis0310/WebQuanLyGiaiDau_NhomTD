-- Cập nhật dữ liệu existing để enable voting controls
-- Set AllowChampionVoting = true cho tất cả tournaments
UPDATE [Tournaments] SET [AllowChampionVoting] = 1 WHERE [AllowChampionVoting] = 0;

-- Set AllowWinnerVoting = true cho tất cả matches
UPDATE [Matches] SET [AllowWinnerVoting] = 1 WHERE [AllowWinnerVoting] = 0;

-- Kiểm tra kết quả
SELECT 'Tournaments' as TableName, COUNT(*) as TotalCount, 
       SUM(CASE WHEN AllowChampionVoting = 1 THEN 1 ELSE 0 END) as VotingEnabled
FROM [Tournaments]
UNION ALL
SELECT 'Matches' as TableName, COUNT(*) as TotalCount, 
       SUM(CASE WHEN AllowWinnerVoting = 1 THEN 1 ELSE 0 END) as VotingEnabled
FROM [Matches];