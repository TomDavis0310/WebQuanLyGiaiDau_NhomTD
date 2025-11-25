using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class ApplicationUser : IdentityUser
    {
        [Required]
        public required string FullName { get; set; }
        public string? Address { get; set; }
        public string? Age { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public string? Gender { get; set; }
        public DateTime? DateOfBirth { get; set; }
        // Điểm tích lũy của người dùng. Không được null, mặc định = 0
        [Required]
        public int Points { get; set; } = 0;

        // Two-Factor Authentication Fields
        public bool IsTwoFactorEnabled { get; set; } = false;
        public string? TwoFactorCode { get; set; }
        public DateTime? TwoFactorExpiry { get; set; }
        public string? PreferredVerificationMethod { get; set; } // "Email", "SMS", "Zalo"
        
        // Phone verification for SMS OTP
        public bool IsPhoneNumberVerified { get; set; } = false;
        
        // Zalo ID for Zalo OTP
        public string? ZaloId { get; set; }
        public bool IsZaloVerified { get; set; } = false;
    }

}
