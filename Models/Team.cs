using System.ComponentModel.DataAnnotations;
using System.Numerics;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    // Models/Team.cs
    public class Team
    {
        public int TeamId { get; set; }
        public required string Name { get; set; }
        public required string Coach { get; set; }

        public string? LogoUrl { get; set; } // URL ảnh nếu bạn muốn hiển thị logo
        public string? UserId { get; set; }

        public ICollection<Player> Players { get; set; } = new List<Player>();
        public ICollection<Match> Matches { get; set; } = new List<Match>();
    }

}
