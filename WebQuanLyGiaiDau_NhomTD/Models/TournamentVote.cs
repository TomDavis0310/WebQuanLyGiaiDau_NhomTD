using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    /// <summary>
    /// Model để lưu bình chọn đội vô địch cho giải đấu
    /// </summary>
    public class TournamentVote
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int TournamentId { get; set; }

        [ForeignKey("TournamentId")]
        public Tournament? Tournament { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [ForeignKey("UserId")]
        public ApplicationUser? User { get; set; }

        [Required]
        [Display(Name = "Đội Được Chọn")]
        [StringLength(100)]
        public string VotedTeamName { get; set; } = string.Empty; // Tên đội được bình chọn

        [Required]
        [Display(Name = "Thời Gian Bình Chọn")]
        public DateTime VoteTime { get; set; } = DateTime.Now;

        [Display(Name = "Ghi Chú")]
        [StringLength(500)]
        public string? Notes { get; set; }
    }
}