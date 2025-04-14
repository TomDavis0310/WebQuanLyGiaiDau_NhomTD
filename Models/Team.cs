using System.Numerics;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    // Models/Team.cs
    public class Team
    {
        public int TeamId { get; set; }
        public string Name { get; set; }
        public string Coach { get; set; }
        public List<Player> Players { get; set; }
    }

}
