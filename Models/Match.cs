using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Match
    {
        public int Id { get; set; }

        [Required]
        public string TeamA { get; set; }

        [Required]
        public string TeamB { get; set; }

        // Add score properties
        public int? ScoreTeamA { get; set; }
        public int? ScoreTeamB { get; set; }

        [DataType(DataType.Date)]
        public DateTime MatchDate { get; set; }

        // Match status: "Upcoming", "InProgress", "Completed"
        // This property doesn't exist in the database
        [NotMapped]
        public string? Status { get; set; }

        // Calculate status based on match date
        [NotMapped] // This property is not stored in the database
        public string CalculatedStatus
        {
            get
            {
                if (MatchDate < DateTime.Now)
                    return "Completed";
                else if (MatchDate.Date == DateTime.Now.Date)
                    return "InProgress";
                else
                    return "Upcoming";
            }
        }

        // Foreign Key
        public int TournamentId { get; set; }

        // Navigation
        public Tournament Tournament { get; set; }
        public ICollection<Statistic>? Statistics { get; set; }
        public ICollection<MatchSet>? MatchSets { get; set; }
    }
}