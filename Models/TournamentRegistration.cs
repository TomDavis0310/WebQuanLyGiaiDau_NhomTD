﻿using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class TournamentRegistration
    {
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; }
        public ApplicationUser User { get; set; }

        [Required]
        public int TournamentId { get; set; }
        public Tournament Tournament { get; set; }

        [DataType(DataType.Date)]
        public DateTime RegistrationDate { get; set; } = DateTime.Now;

        public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected
        
        public string? Notes { get; set; }
    }
}
