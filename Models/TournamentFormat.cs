using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class TournamentFormat
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Tên thể thức không được bỏ trống")]
        [Display(Name = "Tên thể thức")]
        public string Name { get; set; }

        [Display(Name = "Mô tả")]
        public string Description { get; set; }

        [Display(Name = "Quy tắc tính điểm")]
        public string ScoringRules { get; set; }

        [Display(Name = "Cách xác định đội chiến thắng")]
        public string WinnerDetermination { get; set; }

        // Các thể thức thi đấu
        public const string Knockout = "Knockout";
        public const string RoundRobin = "RoundRobin";
        public const string GroupStageSwiss = "GroupStageSwiss";
        public const string GroupStageOnly = "GroupStageOnly";

        // Danh sách các giải đấu sử dụng thể thức này
        public ICollection<Tournament> Tournaments { get; set; }
    }
}
