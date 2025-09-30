using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    // Models/Player.cs
    public class Player
    {
        public int PlayerId { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập họ tên cầu thủ")]
        [Display(Name = "Họ Tên")]
        [StringLength(100, ErrorMessage = "Họ tên không được vượt quá 100 ký tự")]
        public required string FullName { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập vị trí thi đấu")]
        [Display(Name = "Vị Trí")]
        [StringLength(50, ErrorMessage = "Vị trí không được vượt quá 50 ký tự")]
        public required string Position { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập số áo")]
        [Display(Name = "Số Áo")]
        [Range(0, 99, ErrorMessage = "Số áo phải từ 0 đến 99")]
        public int Number { get; set; }

        [Display(Name = "Ảnh Cầu Thủ")]
        public string? ImageUrl { get; set; } // URL ảnh nếu bạn muốn hiển thị

        // Foreign key
        [Required(ErrorMessage = "Vui lòng chọn đội bóng")]
        [Display(Name = "Đội Bóng")]
        public int TeamId { get; set; }

        public Team? Team { get; set; }

        // ID của người dùng sở hữu cầu thủ này (nếu có)
        public string? UserId { get; set; }
    }

}
