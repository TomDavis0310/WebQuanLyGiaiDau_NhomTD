﻿using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Format
    {
        public int FormatId { get; set; }
        
        [Required(ErrorMessage = "Vui lòng nhập tên thể thức")]
        [Display(Name = "Tên Thể Thức")]
        [StringLength(255, ErrorMessage = "Tên thể thức không được vượt quá 255 ký tự")]
        public required string FormatName { get; set; }
        
        [Display(Name = "Mô Tả")]
        public string? Description { get; set; }
        
        // Navigation property
        public ICollection<StageDetail>? StageDetails { get; set; }
    }
}
