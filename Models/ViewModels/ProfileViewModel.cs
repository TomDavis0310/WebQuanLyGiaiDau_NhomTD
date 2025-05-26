using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models.ViewModels
{
    public class ProfileViewModel
    {
        public ApplicationUser User { get; set; } = null!;
        public List<Team> Teams { get; set; } = new List<Team>();
        public List<TournamentRegistration> TournamentRegistrations { get; set; } = new List<TournamentRegistration>();
        public List<Player> Players { get; set; } = new List<Player>();
        public List<Statistic> Statistics { get; set; } = new List<Statistic>();
        public List<Tournament> ApprovedTournamentsWithoutTeam { get; set; } = new List<Tournament>();
    }

    public class EditProfileViewModel
    {
        [Required(ErrorMessage = "Họ và tên là bắt buộc")]
        [Display(Name = "Họ và tên")]
        [StringLength(100, ErrorMessage = "Họ và tên không được vượt quá 100 ký tự")]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email là bắt buộc")]
        [EmailAddress(ErrorMessage = "Email không hợp lệ")]
        [Display(Name = "Email")]
        public string Email { get; set; } = string.Empty;

        [Phone(ErrorMessage = "Số điện thoại không hợp lệ")]
        [Display(Name = "Số điện thoại")]
        public string? PhoneNumber { get; set; }

        [Display(Name = "Địa chỉ")]
        [StringLength(200, ErrorMessage = "Địa chỉ không được vượt quá 200 ký tự")]
        public string? Address { get; set; }

        [Display(Name = "Tuổi")]
        [StringLength(10, ErrorMessage = "Tuổi không được vượt quá 10 ký tự")]
        public string? Age { get; set; }

        [Display(Name = "Giới tính")]
        public string? Gender { get; set; }

        [Display(Name = "Ngày sinh")]
        [DataType(DataType.Date)]
        public DateTime? DateOfBirth { get; set; }

        [Display(Name = "Ảnh đại diện hiện tại")]
        public string? CurrentProfilePicture { get; set; }
    }
}
