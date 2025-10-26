using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class FAQ
    {
        public int Id { get; set; }
        
        [Required]
        public required string Question { get; set; }
        
        [Required]
        public required string Answer { get; set; }
    }
}
