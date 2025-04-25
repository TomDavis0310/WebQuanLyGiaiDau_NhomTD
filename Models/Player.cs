using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    // Models/Player.cs
    public class Player
    {
        public int PlayerId { get; set; }
        public string FullName { get; set; }
        public string Position { get; set; }
        public int Number { get; set; }
        public string? ImageUrl { get; set; } // URL ảnh nếu bạn muốn hiển thị

        // Foreign key
        public int TeamId { get; set; }
        public Team Team { get; set; }
    }

}
