using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class PlayerScoring
    {
        public int Id { get; set; }

        [Required]
        public int MatchId { get; set; }

        [ForeignKey("MatchId")]
        public Match? Match { get; set; }

        [Required]
        public int PlayerId { get; set; }

        [ForeignKey("PlayerId")]
        public Player? Player { get; set; }

        [Required]
        [Display(Name = "Điểm Số")]
        [Range(0, 100, ErrorMessage = "Điểm số phải từ 0 đến 100")]
        public int Points { get; set; }

        [Display(Name = "Thời Điểm Ghi Điểm")]
        public DateTime ScoringTime { get; set; } = DateTime.Now;

        [Display(Name = "Ghi Chú")]
        public string? Notes { get; set; }

        // Calculated property to determine which team the player belongs to
        [NotMapped]
        public string? TeamName => Player?.Team?.Name;

        // Helper property to identify if player is from Team A or Team B in a match
        [NotMapped]
        public string TeamIdentifier
        {
            get
            {
                if (Match == null || Player == null || Player.Team == null)
                    return string.Empty;

                return Match.TeamA == Player.Team.Name ? "A" : (Match.TeamB == Player.Team.Name ? "B" : "Unknown");
            }
        }
    }
}
