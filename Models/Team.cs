using System.ComponentModel.DataAnnotations;
using System.Numerics;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    // Models/Team.cs
    public class Team
    {
        public int TeamId { get; set; }
        public string Name { get; set; }
        public string Coach { get; set; }

        public string? LogoUrl { get; set; } // URL ảnh nếu bạn muốn hiển thị logo

        public ICollection<Player> Players { get; set; }
        public ICollection<Match> Matches { get; set; }
    }

}
