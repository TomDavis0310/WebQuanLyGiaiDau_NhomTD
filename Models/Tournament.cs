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
        public string Name { get; set; }

        public string Description { get; set; }

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

        // Trạng thái đăng ký: Open (Mở đăng ký), Closed (Đóng đăng ký), Completed (Đã kết thúc)
        public string RegistrationStatus { get; set; } = "Open";

        // Foreign key to Sports
        public int SportsId { get; set; }
        public Sports? Sports { get; set; }

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
