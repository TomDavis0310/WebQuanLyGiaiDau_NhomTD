﻿using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class StageDetail
    {
        public int Id { get; set; }
        
        [Required]
        public int StageId { get; set; }
        
        [ForeignKey("StageId")]
        public Stage? Stage { get; set; }
        
        [Required]
        public int FormatId { get; set; }
        
        [ForeignKey("FormatId")]
        public Format? Format { get; set; }
        
        [Required]
        public int TournamentId { get; set; }
        
        [ForeignKey("TournamentId")]
        public Tournament? Tournament { get; set; }
        
        [Display(Name = "Thứ Tự")]
        public int? Order { get; set; }
        
        [Display(Name = "Ngày Bắt Đầu")]
        [DataType(DataType.Date)]
        public DateTime? StartDate { get; set; }
        
        [Display(Name = "Ngày Kết Thúc")]
        [DataType(DataType.Date)]
        public DateTime? EndDate { get; set; }
    }
}
