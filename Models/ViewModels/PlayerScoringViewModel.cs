using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models.ViewModels
{
    public class PlayerScoringViewModel
    {
        public int MatchId { get; set; }
        public Match Match { get; set; }
        
        public List<PlayerScoring> PlayerScorings { get; set; } = new List<PlayerScoring>();
        
        public List<Player> TeamAPlayers { get; set; } = new List<Player>();
        public List<Player> TeamBPlayers { get; set; } = new List<Player>();
        
        // Properties for adding a new scoring record
        [Required(ErrorMessage = "Vui lòng chọn cầu thủ")]
        [Display(Name = "Cầu Thủ")]
        public int SelectedPlayerId { get; set; }
        
        [Required(ErrorMessage = "Vui lòng nhập điểm số")]
        [Range(0, 100, ErrorMessage = "Điểm số phải từ 0 đến 100")]
        [Display(Name = "Điểm Số")]
        public int Points { get; set; }
        
        [Display(Name = "Ghi Chú")]
        public string? Notes { get; set; }
        
        // Summary statistics
        public int TotalPointsTeamA => PlayerScorings
            .Where(ps => ps.TeamIdentifier == "A")
            .Sum(ps => ps.Points);
            
        public int TotalPointsTeamB => PlayerScorings
            .Where(ps => ps.TeamIdentifier == "B")
            .Sum(ps => ps.Points);
    }
}
