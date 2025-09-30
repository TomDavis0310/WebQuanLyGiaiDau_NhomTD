﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class CoachDetail
    {
        public int Id { get; set; }
        
        [Required]
        public int TeamId { get; set; }
        
        [ForeignKey("TeamId")]
        public Team? Team { get; set; }
        
        [Required]
        public required string UserId { get; set; }
        
        [ForeignKey("UserId")]
        public ApplicationUser? User { get; set; }
        
        [Required(ErrorMessage = "Vui lòng nhập tên huấn luyện viên")]
        [Display(Name = "Tên Huấn Luyện Viên")]
        [StringLength(255, ErrorMessage = "Tên huấn luyện viên không được vượt quá 255 ký tự")]
        public required string CoachName { get; set; }
        
        [Display(Name = "Số Điện Thoại")]
        [Phone(ErrorMessage = "Số điện thoại không hợp lệ")]
        public string? PhoneNumber { get; set; }
        
        [Display(Name = "Email")]
        [EmailAddress(ErrorMessage = "Email không hợp lệ")]
        public string? Email { get; set; }
        
        [Display(Name = "Kinh Nghiệm")]
        public string? Experience { get; set; }
        
        [Display(Name = "Ảnh")]
        public string? ImageUrl { get; set; }
    }
}
