﻿using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class TournamentTeam
    {
        public int Id { get; set; }

        [Required]
        public int TournamentId { get; set; }
        public Tournament Tournament { get; set; } = new Tournament();

        [Required]
        public int TeamId { get; set; }
        public Team Team { get; set; } = new Team();

        [DataType(DataType.Date)]
        public DateTime RegistrationDate { get; set; } = DateTime.Now;

        public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected
        
        public string? Notes { get; set; }
    }
}
