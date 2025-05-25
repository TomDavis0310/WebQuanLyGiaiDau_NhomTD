using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Match
    {
        public int Id { get; set; }

        [Required]
        public string TeamA { get; set; }

        // ID của đội A (tùy chọn)
        public int? TeamAId { get; set; }

        [Required]
        public string TeamB { get; set; }

        // ID của đội B (tùy chọn)
        public int? TeamBId { get; set; }

        // Add score properties
        public int? ScoreTeamA { get; set; }
        public int? ScoreTeamB { get; set; }

        // Vòng đấu (ví dụ: 1, 2, 3, ...)
        public int? Round { get; set; }

        // Tên bảng đấu (ví dụ: "Bảng A", "Bảng B", ...)
        public string? GroupName { get; set; }

        [DataType(DataType.Date)]
        [Display(Name = "Ngày Thi Đấu")]
        public DateTime MatchDate { get; set; }

        // Thời gian thi đấu
        [Display(Name = "Thời Gian Thi Đấu")]
        [DataType(DataType.Time)]
        public TimeSpan? MatchTime { get; set; } = new TimeSpan(15, 0, 0); // Default to 15:00 (3 PM)

        // Địa điểm thi đấu
        [Display(Name = "Địa Điểm Thi Đấu")]
        public string? Location { get; set; }

        // YouTube video URLs for highlights and live stream
        [Display(Name = "Video Highlights")]
        public string? HighlightsVideoUrl { get; set; }

        [Display(Name = "Live Stream URL")]
        public string? LiveStreamUrl { get; set; }

        [Display(Name = "Mô tả Video")]
        public string? VideoDescription { get; set; }

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