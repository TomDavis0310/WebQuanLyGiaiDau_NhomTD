using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class RuleDifference
    {
        public int Id { get; set; }
        
        [Required]
        public string Category { get; set; }
        
        [Required]
        public string Rule5v5 { get; set; }
        
        [Required]
        public string Rule3x3 { get; set; }
    }
}
