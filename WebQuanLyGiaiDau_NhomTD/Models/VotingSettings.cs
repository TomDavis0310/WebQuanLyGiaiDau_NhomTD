using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    /// <summary>
    /// Model để cấu hình trạng thái bình chọn
    /// </summary>
    public class VotingSettings
    {
        [Key]
        public int Id { get; set; }

        [Display(Name = "Cho phép bình chọn trận đấu")]
        public bool AllowMatchVoting { get; set; } = true;

        [Display(Name = "Cho phép bình chọn vô địch")]
        public bool AllowTournamentVoting { get; set; } = true;

        [Display(Name = "Thời gian cập nhật")]
        public DateTime LastUpdated { get; set; } = DateTime.Now;

        [Display(Name = "Admin cập nhật")]
        [StringLength(450)]
        public string? UpdatedBy { get; set; }
    }
}