using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class PollOption
    {
        public int Id { get; set; }

        [Required]
        public int PollId { get; set; }

        [Required, StringLength(200)]
        public string Name { get; set; } = null!;

        public string? Description { get; set; }

        public int SortOrder { get; set; } = 0;

        // If this option references an entity (Player/Team), store its type and id
        public string? EntityType { get; set; }
        public int? EntityId { get; set; }

        public virtual Poll? Poll { get; set; }
        public virtual ICollection<PollVote>? Votes { get; set; }
    }
}
