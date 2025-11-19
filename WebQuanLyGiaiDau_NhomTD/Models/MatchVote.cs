using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    /// <summary>
    /// Model để lưu bình chọn đội thắng cho từng trận đấu
    /// </summary>
    public class MatchVote
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int MatchId { get; set; }

        [ForeignKey("MatchId")]
        public Match? Match { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [ForeignKey("UserId")]
        public ApplicationUser? User { get; set; }

        [Required]
        [Display(Name = "Đội Được Chọn")]
        [StringLength(100)]
        public string VotedTeam { get; set; } = string.Empty; // "TeamA" hoặc "TeamB"

        [Required]
        [Display(Name = "Thời Gian Bình Chọn")]
        public DateTime VoteTime { get; set; } = DateTime.Now;

        [Display(Name = "Ghi Chú")]
        [StringLength(500)]
        public string? Notes { get; set; }
    }
}