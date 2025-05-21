﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class MatchDetail
    {
        public int Id { get; set; }
        
        [Required]
        public int MatchId { get; set; }
        
        [ForeignKey("MatchId")]
        public Match Match { get; set; }
        
        [Required]
        public int Team1Id { get; set; }
        
        [ForeignKey("Team1Id")]
        public Team Team1 { get; set; }
        
        [Required]
        public int Team2Id { get; set; }
        
        [ForeignKey("Team2Id")]
        public Team Team2 { get; set; }
        
        [Display(Name = "Điểm Đội 1")]
        public int? ScoreTeam1 { get; set; }
        
        [Display(Name = "Điểm Đội 2")]
        public int? ScoreTeam2 { get; set; }
        
        [Display(Name = "Ghi Chú")]
        public string? Notes { get; set; }
    }
}
