using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Notification
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(1000)]
        public string Message { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string Type { get; set; } = "info"; // match, tournament, team, player, system, info

        public int? RelatedId { get; set; } // ID của tournament, match, team, etc.

        [MaxLength(100)]
        public string? RelatedType { get; set; } // "tournament", "match", "team", "player"

        public bool IsRead { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? ReadAt { get; set; }

        [MaxLength(100)]
        public string? UserId { get; set; } // Null = broadcast to all

        [MaxLength(500)]
        public string? ImageUrl { get; set; }

        [MaxLength(500)]
        public string? ActionUrl { get; set; } // Deep link for navigation

        public int Priority { get; set; } = 0; // 0=normal, 1=high, 2=urgent

        public bool IsDeleted { get; set; } = false;
    }
}
