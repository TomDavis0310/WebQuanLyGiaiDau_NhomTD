﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class PlayerDetail
    {
        public int Id { get; set; }
        
        [Required]
        public int PlayerId { get; set; }
        
        [ForeignKey("PlayerId")]
        public Player? Player { get; set; }
        
        public int? TeamId { get; set; }
        
        [ForeignKey("TeamId")]
        public Team? Team { get; set; }
        
        [Display(Name = "Số Áo")]
        public int? JerseyNumber { get; set; }
        
        [Display(Name = "Ngày Sinh")]
        [DataType(DataType.Date)]
        public DateTime? DateOfBirth { get; set; }
        
        [Display(Name = "Thành Tích")]
        public string? Achievements { get; set; }
        
        [Display(Name = "Tổng Số Điểm")]
        public int? TotalPoints { get; set; } = 0;
        
        [Display(Name = "Tổng Số Kiến Tạo")]
        public int? TotalAssists { get; set; } = 0;
        
        [Display(Name = "Tổng Số Rebounds")]
        public int? TotalRebounds { get; set; } = 0;
        
        [Display(Name = "Số Trận Đã Tham Gia")]
        public int? GamesPlayed { get; set; } = 0;
    }
}
