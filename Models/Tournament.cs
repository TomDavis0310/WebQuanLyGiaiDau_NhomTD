namespace WebQuanLyGiaiDau_NhomTD.Models
{
    using System.ComponentModel.DataAnnotations;
    using System.ComponentModel.DataAnnotations.Schema;
    using System.Diagnostics.CodeAnalysis;
    using System.Linq;
    public class Tournament
    {
        public int Id { get; set; }

        [Required(ErrorMessage = "Tên giải đấu không được bỏ trống")]
        public string Name { get; set; }

        public string Description { get; set; }

        [DataType(DataType.Date)]
        public DateTime StartDate { get; set; }

        [DataType(DataType.Date)]
        public DateTime EndDate { get; set; }

        public string? ImageUrl { get; set; }

        // Foreign key to Sports
        public int SportsId { get; set; }
        public Sports? Sports { get; set; }
    }

}
