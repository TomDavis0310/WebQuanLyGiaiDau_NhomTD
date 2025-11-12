using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class RewardProduct
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Range(0, int.MaxValue)]
        public int PointsCost { get; set; }

        public string? Description { get; set; }
    }
}
