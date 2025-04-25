using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Match
    {
        public int Id { get; set; }

        [Required]
        public string TeamA { get; set; }

        [Required]
        public string TeamB { get; set; }

        [DataType(DataType.Date)]
        public DateTime MatchDate { get; set; }

        // Foreign Key
        public int TournamentId { get; set; }

        // Navigation
        public Tournament Tournament { get; set; }
        public ICollection<Statistic>? Statistics { get; set; }
    }
}