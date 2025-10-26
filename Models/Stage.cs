﻿using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Stage
    {
        public int StageId { get; set; }
        
        [Required(ErrorMessage = "Vui lòng nhập tên giai đoạn")]
        [Display(Name = "Tên Giai Đoạn")]
        [StringLength(225, ErrorMessage = "Tên giai đoạn không được vượt quá 225 ký tự")]
        public required string StageName { get; set; }
        
        [Display(Name = "Mô Tả")]
        public string? Description { get; set; }
        
        // Navigation property
        public ICollection<StageDetail>? StageDetails { get; set; }
    }
}
