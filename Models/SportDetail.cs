﻿﻿﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class SportDetail
    {
        public int Id { get; set; }
        
        [Required]
        public int TournamentId { get; set; }
        
        [ForeignKey("TournamentId")]
        [DeleteBehavior(DeleteBehavior.NoAction)]
        public Tournament Tournament { get; set; }
        
        [Required]
        public int SportId { get; set; }
        
        [ForeignKey("SportId")]
        [DeleteBehavior(DeleteBehavior.NoAction)]
        public Sports Sport { get; set; }
        
        [Display(Name = "Quy Định")]
        public string? Rules { get; set; }
        
        [Display(Name = "Số Đội Tối Đa")]
        public int? MaxTeams { get; set; }
        
        [Display(Name = "Số Cầu Thủ Mỗi Đội")]
        public int? PlayersPerTeam { get; set; }
    }
}
