using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class MatchViewModel
    {
        public int Id { get; set; }
        public string TeamA { get; set; }
        public string TeamB { get; set; }
        public int? ScoreTeamA { get; set; }
        public int? ScoreTeamB { get; set; }
        public DateTime MatchDate { get; set; }
        public string Status { get; set; } = "Upcoming"; // "Upcoming", "InProgress", "Completed"
        public int TournamentId { get; set; }
        public Tournament Tournament { get; set; }

        // Convert from Match to MatchViewModel
        public static MatchViewModel FromMatch(Match match)
        {
            return new MatchViewModel
            {
                Id = match.Id,
                TeamA = match.TeamA,
                TeamB = match.TeamB,
                MatchDate = match.MatchDate,
                TournamentId = match.TournamentId,
                Tournament = match.Tournament,
                // Set default values for new properties
                ScoreTeamA = null,
                ScoreTeamB = null,
                Status = match.MatchDate < DateTime.Now ? "Completed" : 
                         (match.MatchDate.Date == DateTime.Now.Date ? "InProgress" : "Upcoming")
            };
        }
    }
}
