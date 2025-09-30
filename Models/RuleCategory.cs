using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class RuleCategory
    {
        public int Id { get; set; }
        
        [Required]
        public required string Name { get; set; }
        
        public required string Description { get; set; }
        
        public List<Rule> Rules { get; set; } = new List<Rule>();
    }
}
