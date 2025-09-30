using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class News
    {
        [Key]
        public int NewsId { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập tiêu đề tin tức")]
        [StringLength(200, ErrorMessage = "Tiêu đề không được vượt quá 200 ký tự")]
        public required string Title { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập nội dung tóm tắt")]
        [StringLength(500, ErrorMessage = "Tóm tắt không được vượt quá 500 ký tự")]
        public required string Summary { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập nội dung tin tức")]
        public required string Content { get; set; }

        [Display(Name = "Hình ảnh")]
        public required string ImageUrl { get; set; }

        [Display(Name = "Ngày đăng")]
        [DataType(DataType.DateTime)]
        public DateTime PublishDate { get; set; } = DateTime.Now;

        [Display(Name = "Tác giả")]
        public string Author { get; set; } = "Admin";

        [Display(Name = "Lượt xem")]
        public int ViewCount { get; set; } = 0;

        [Display(Name = "Thể loại")]
        public string Category { get; set; } = "Thể thao";

        [Display(Name = "Hiển thị")]
        public bool IsVisible { get; set; } = true;

        [Display(Name = "Nổi bật")]
        public bool IsFeatured { get; set; } = false;

        // Thêm mối quan hệ với Sports nếu cần
        public int? SportsId { get; set; }
        
        [ForeignKey("SportsId")]
        public Sports? Sports { get; set; }
    }
}
