﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class StandingDetail
    {
        public int Id { get; set; }
        
        [Required]
        public int StandingId { get; set; }
        
        [ForeignKey("StandingId")]
        public Standing Standing { get; set; }
        
        [Required]
        public int TeamId { get; set; }
        
        [ForeignKey("TeamId")]
        public Team Team { get; set; }
        
        [Required]
        [Display(Name = "Số Trận Thắng")]
        public int NumberOfWins { get; set; } = 0;
        
        [Required]
        [Display(Name = "Số Trận Thua")]
        public int NumberOfLoses { get; set; } = 0;
        
        [Required]
        [Display(Name = "Số Trận Hòa")]
        public int NumberOfDraws { get; set; } = 0;
        
        [Display(Name = "Điểm Ghi Được")]
        public int? PointsScored { get; set; } = 0;
        
        [Display(Name = "Điểm Bị Thủng Lưới")]
        public int? PointsAgainst { get; set; } = 0;
        
        [Display(Name = "Thứ Hạng")]
        public int? Rank { get; set; }
        
        [Display(Name = "Tổng Điểm")]
        public int? TotalPoints { get; set; } = 0;
        
        [NotMapped]
        [Display(Name = "Hiệu Số")]
        public int? PointDifference => PointsScored - PointsAgainst;
    }
}
