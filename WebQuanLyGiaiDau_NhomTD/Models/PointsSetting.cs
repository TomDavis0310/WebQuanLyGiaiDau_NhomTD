using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class PointsSetting
    {
        [Key]
        public int Id { get; set; }

        // Points for reading news
        [Range(0, int.MaxValue)]
        public int ReadNewsPoints { get; set; } = 1;

        // Points for viewing tournament
        [Range(0, int.MaxValue)]
        public int ViewTournamentPoints { get; set; } = 2;

        // Points for voting team
        [Range(0, int.MaxValue)]
        public int VoteTeamPoints { get; set; } = 3;
    }
}
