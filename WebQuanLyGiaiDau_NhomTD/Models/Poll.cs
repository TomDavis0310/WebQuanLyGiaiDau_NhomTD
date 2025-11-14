using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Poll
    {
        public int Id { get; set; }

        [Required]
        public int TournamentId { get; set; }

        [Required, StringLength(200)]
        public string Title { get; set; } = null!;

        public string? Description { get; set; }

        [Required, StringLength(50)]
        public string TargetObject { get; set; } = "Player";

        public DateTime StartAt { get; set; }

        public DateTime EndAt { get; set; }

        [Required]
        public string CreatedById { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsPublished { get; set; } = false;

        public virtual ICollection<PollOption>? Options { get; set; }
        public virtual ICollection<PollVote>? Votes { get; set; }
    }
}
