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
        public DateTime StartDate { get; set; } = DateTime.Now;

        [DataType(DataType.Date)]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
        public DateTime EndDate { get; set; } = DateTime.Now.AddMonths(1);

        public string? ImageUrl { get; set; }

        // Trạng thái đăng ký: Open (Mở đăng ký), Closed (Đóng đăng ký), Completed (Đã kết thúc)
        public string RegistrationStatus { get; set; } = "Open";

        // Foreign key to Sports
        public int SportsId { get; set; }
        public Sports? Sports { get; set; }
    }

}
