using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class RedeemTransaction
    {
        [Key]
        public int Id { get; set; }

    [Required]
    public string UserId { get; set; } = string.Empty;

        public int ProductId { get; set; }

        [Required]
        public int PointsCost { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Required]
        [StringLength(50)]
        public string Status { get; set; } = "Completed";

        // Navigation properties (optional)
    [ForeignKey("UserId")]
    public ApplicationUser? User { get; set; }

    [ForeignKey("ProductId")]
    public RewardProduct? Product { get; set; }
    }
}
