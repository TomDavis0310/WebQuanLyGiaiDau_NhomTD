namespace WebQuanLyGiaiDau_NhomTD.Models
{
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Diagnostics.CodeAnalysis;
    using System.Linq;
    public class Tournament
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Tên giải đấu không được bỏ trống")]
        public required string Name { get; set; }

        public required string Description { get; set; }

        [Display(Name = "Địa điểm")]
        public string? Location { get; set; }

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Display(Name = "Ngày Bắt Đầu Giải")]
        public DateTime StartDate { get; set; } = DateTime.Now;

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Display(Name = "Ngày Kết Thúc Giải")]
        public DateTime EndDate { get; set; } = DateTime.Now.AddMonths(1);

        // These fields are not in the database, so we'll use NotMapped
        [NotMapped]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Display(Name = "Ngày Mở Đăng Ký")]
        public DateTime RegistrationStartDate => StartDate.AddDays(-14);

        [NotMapped]
        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        [Display(Name = "Ngày Kết Thúc Đăng Ký")]
        public DateTime RegistrationEndDate => StartDate.AddDays(-1);

        public string? ImageUrl { get; set; }

        // This property is kept for backward compatibility but should not be used directly
        // Use CalculatedStatus instead
        [Obsolete("Use CalculatedStatus property instead")]
        public string RegistrationStatus { get; set; } = "Open";

        // Foreign key to Sports
        public int SportsId { get; set; }
        public Sports? Sports { get; set; }

        // Foreign key to TournamentFormat
        [Display(Name = "Thể thức thi đấu")]
        public int? TournamentFormatId { get; set; }
        public TournamentFormat? TournamentFormat { get; set; }

        // Số lượng đội tối đa có thể tham gia
        [Display(Name = "Số lượng đội tối đa")]
        public int? MaxTeams { get; set; }

        // Số lượng đội trong mỗi bảng đấu (chỉ áp dụng cho thể thức vòng bảng)
        [Display(Name = "Số đội mỗi bảng")]
        public int? TeamsPerGroup { get; set; }

        [NotMapped]
        public string CalculatedStatus
        {
            get
            {
                var currentTime = DateTime.Now;

                if (currentTime < RegistrationStartDate)
                    return "Chưa mở đăng ký";
                else if (currentTime >= RegistrationStartDate && currentTime <= RegistrationEndDate)
                    return "Mở đăng ký";
                else if (currentTime > RegistrationEndDate && currentTime < StartDate)
                    return "Kết thúc đăng ký";
                else if (currentTime >= StartDate && currentTime <= EndDate)
                    return "Giải đấu đang diễn ra";
                else // currentTime > EndDate
                    return "Giải đấu đã kết thúc";
            }
        }
    }

}
