﻿using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class MatchSet
    {
        public int Id { get; set; }

        [Required]
        public int MatchId { get; set; }
        public Match Match { get; set; }

        [Required]
        public int SetNumber { get; set; }

        public int ScoreTeamA { get; set; }
        public int ScoreTeamB { get; set; }

        [Required]
        public string BestPlayerName { get; set; }
        public string BestPlayerTeam { get; set; }
        public int BestPlayerPoints { get; set; }
    }
}
