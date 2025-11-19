using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class MatchViewModel
    {
        public int Id { get; set; }
        public string TeamA { get; set; } = string.Empty;
        public string TeamB { get; set; } = string.Empty;
        public int? ScoreTeamA { get; set; }
        public int? ScoreTeamB { get; set; }
        public DateTime MatchDate { get; set; }
        public TimeSpan? MatchTime { get; set; } // Added to match view usage
        public string? Location { get; set; }     // Added to match view usage
        public string Status { get; set; } = "Upcoming"; // "Upcoming", "InProgress", "Completed"
        public int TournamentId { get; set; }
        public Tournament? Tournament { get; set; }
        public List<Statistic> Statistics { get; set; } = new List<Statistic>();
        public List<dynamic> MatchSets { get; set; } = new List<dynamic>();
        public string MatchStatus { get; set; } = string.Empty;
        public DateTime MatchEndTime { get; set; } = DateTime.Now;
        public bool AllowWinnerVoting { get; set; } = true;

        // Convert from Match to MatchViewModel
        public static MatchViewModel FromMatch(Match match)
        {
            var random = new Random();            var matchViewModel = new MatchViewModel
            {
                Id = match.Id,
                TeamA = match.TeamA,
                TeamB = match.TeamB,
                MatchDate = match.MatchDate,
                MatchTime = match.MatchTime,
                Location = match.Location,
                TournamentId = match.TournamentId,
                Tournament = match.Tournament,
                // Set default values for new properties
                ScoreTeamA = match.ScoreTeamA,
                ScoreTeamB = match.ScoreTeamB,
                Status = match.MatchDate < DateTime.Now ? "Completed" :
                         (match.MatchDate.Date == DateTime.Now.Date ? "InProgress" : "Upcoming"),
                Statistics = new List<Statistic>(),
                MatchSets = new List<dynamic>(),
                MatchStatus = match.CalculatedStatus,
                MatchEndTime = match.MatchDate.Add(match.MatchTime ?? TimeSpan.FromHours(1)),
                AllowWinnerVoting = match.AllowWinnerVoting
            };

            // Create virtual match sets (for basketball 5v5 NBA, 4 quarters)
            // For NBA 5v5, we'll simulate 4 quarters
            int totalScoreTeamA = match.ScoreTeamA ?? 0;
            int totalScoreTeamB = match.ScoreTeamB ?? 0;

            // Distribute total score across 4 quarters
            int[] quarterScoresTeamA = new int[4];
            int[] quarterScoresTeamB = new int[4];

            if (totalScoreTeamA > 0 || totalScoreTeamB > 0)
            {
                // Xử lý trường hợp đặc biệt khi tổng điểm nhỏ hơn 15
                if (totalScoreTeamA < 15)
                {
                    // Nếu tổng điểm nhỏ hơn 15, gán tất cả cho quý đầu tiên
                    quarterScoresTeamA[0] = totalScoreTeamA;
                    totalScoreTeamA = 0;
                }

                if (totalScoreTeamB < 15)
                {
                    // Nếu tổng điểm nhỏ hơn 15, gán tất cả cho quý đầu tiên
                    quarterScoresTeamB[0] = totalScoreTeamB;
                    totalScoreTeamB = 0;
                }

                // Distribute scores across quarters
                for (int i = 0; i < 3; i++) // First 3 quarters
                {
                    // Chỉ phân phối điểm nếu còn điểm và chưa được gán ở trên
                    if (i == 0 && quarterScoresTeamA[0] > 0)
                    {
                        // Quý đầu tiên đã được gán ở trên, bỏ qua
                    }
                    else if (totalScoreTeamA >= 15)
                    {
                        quarterScoresTeamA[i] = random.Next(15, Math.Min(35, totalScoreTeamA));
                        totalScoreTeamA -= quarterScoresTeamA[i];
                    }
                    else if (totalScoreTeamA > 0)
                    {
                        // Nếu còn điểm nhưng < 15, gán tất cả cho quý hiện tại
                        quarterScoresTeamA[i] = totalScoreTeamA;
                        totalScoreTeamA = 0;
                    }

                    // Tương tự cho đội B
                    if (i == 0 && quarterScoresTeamB[0] > 0)
                    {
                        // Quý đầu tiên đã được gán ở trên, bỏ qua
                    }
                    else if (totalScoreTeamB >= 15)
                    {
                        quarterScoresTeamB[i] = random.Next(15, Math.Min(35, totalScoreTeamB));
                        totalScoreTeamB -= quarterScoresTeamB[i];
                    }
                    else if (totalScoreTeamB > 0)
                    {
                        // Nếu còn điểm nhưng < 15, gán tất cả cho quý hiện tại
                        quarterScoresTeamB[i] = totalScoreTeamB;
                        totalScoreTeamB = 0;
                    }
                }

                // Last quarter gets the remainder
                quarterScoresTeamA[3] = totalScoreTeamA;
                quarterScoresTeamB[3] = totalScoreTeamB;
            }

            // Find the best players for each quarter
            for (int quarter = 0; quarter < 4; quarter++)
            {
                string bestPlayerName = "Chưa xác định";
                string bestPlayerTeam = "";
                int bestPlayerPoints = 0;

                //if (statistics.Any())
                //{
                //    // For simplicity, we'll pick a random player from the top performers
                //    var topPlayers = statistics.OrderByDescending(s => s.Points).Take(5).ToList();
                //    if (topPlayers.Any())
                //    {
                //        var bestPlayer = topPlayers[random.Next(topPlayers.Count)];
                //        bestPlayerName = bestPlayer.PlayerName;
                //        bestPlayerTeam = bestPlayer.PlayerName.Contains(match.TeamA) ? match.TeamA : match.TeamB;
                //        // Kiểm tra nếu điểm của cầu thủ xuất sắc nhất < 5
                //        if (bestPlayer.Points < 5)
                //        {
                //            bestPlayerPoints = bestPlayer.Points;
                //        }
                //        else
                //        {
                //            bestPlayerPoints = random.Next(5, Math.Min(15, bestPlayer.Points));
                //        }
                //    }
                //}
                if (match.CalculatedStatus != "Upcoming")
                {
                    // If no statistics but match is completed or in progress, generate a random best player
                    bestPlayerName = $"Cầu thủ {random.Next(1, 10)}";
                    bestPlayerTeam = random.Next(2) == 0 ? match.TeamA : match.TeamB;
                    bestPlayerPoints = random.Next(5, 15);
                }

                matchViewModel.MatchSets.Add(new
                {
                    SetNumber = quarter + 1,
                    ScoreTeamA = quarterScoresTeamA[quarter],
                    ScoreTeamB = quarterScoresTeamB[quarter],
                    BestPlayerName = bestPlayerName,
                    BestPlayerTeam = bestPlayerTeam,
                    BestPlayerPoints = bestPlayerPoints
                });
            }
            return matchViewModel;
        }
    }
}
