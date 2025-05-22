﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Standing
    {
        public int StandingId { get; set; }
        
        [Required]
        public int TournamentId { get; set; }
        
        [ForeignKey("TournamentId")]
        public Tournament Tournament { get; set; }
        
        [Required]
        public int SportId { get; set; }
        
        [ForeignKey("SportId")]
        public Sports Sport { get; set; }
        
        [Display(Name = "Tên Bảng")]
        public string? GroupName { get; set; }
        
        [Display(Name = "Mô Tả")]
        public string? Description { get; set; }
        
        [Display(Name = "Ngày Cập Nhật")]
        public DateTime LastUpdated { get; set; } = DateTime.Now;
        
        // Navigation property
        public ICollection<StandingDetail>? StandingDetails { get; set; }
    }
}
