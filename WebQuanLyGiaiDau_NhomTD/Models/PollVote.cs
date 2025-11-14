using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class PollVote
    {
        public int Id { get; set; }

        [Required]
        public int PollId { get; set; }

        [Required]
        public int OptionId { get; set; }

        [Required]
        public string UserId { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public virtual Poll? Poll { get; set; }
        public virtual PollOption? Option { get; set; }
    }
}
