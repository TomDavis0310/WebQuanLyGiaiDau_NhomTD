using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class FAQ
    {
        public int Id { get; set; }
        
        [Required]
        public string Question { get; set; }
        
        [Required]
        public string Answer { get; set; }
    }
}
