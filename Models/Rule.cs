using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class Rule
    {
        public int Id { get; set; }

        [Required]
        public required string Title { get; set; }

        [Required]
        public required string Content { get; set; }
    }
}
