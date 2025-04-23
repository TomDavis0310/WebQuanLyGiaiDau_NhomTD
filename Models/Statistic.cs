using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Statistic
    {
        public int Id { get; set; }

        [Required]
        public string PlayerName { get; set; }

        public int Points { get; set; }
        public int Assists { get; set; }
        public int Rebounds { get; set; }

        // Foreign Key
        public int MatchId { get; set; }

        // Navigation
        public Match Match { get; set; }
    }
}