using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    /// <summary>
    /// Model lưu lịch sử đổi quà tặng của user
    /// </summary>
    public class RewardTransaction
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string UserId { get; set; } = string.Empty;

        [ForeignKey("UserId")]
        public ApplicationUser? User { get; set; }

        [Required]
        public int RewardProductId { get; set; }

        [ForeignKey("RewardProductId")]
        public RewardProduct? RewardProduct { get; set; }

        /// <summary>
        /// Số điểm đã sử dụng để đổi quà
        /// </summary>
        [Required]
        public int PointsSpent { get; set; }

        /// <summary>
        /// Mã quà tặng duy nhất để xuất trình khi nhận quà
        /// Format: RWD-{YYYYMMDD}-{Random5Digits}
        /// Ví dụ: RWD-20251122-AB123
        /// </summary>
        [Required]
        [MaxLength(50)]
        public string RedemptionCode { get; set; } = string.Empty;

        /// <summary>
        /// Trạng thái giao dịch
        /// </summary>
        [Required]
        [MaxLength(20)]
        public string Status { get; set; } = "Pending"; // Pending, Redeemed, Cancelled

        /// <summary>
        /// Ngày đổi quà
        /// </summary>
        [Required]
        public DateTime TransactionDate { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// Ngày nhận quà (khi xuất trình mã)
        /// </summary>
        public DateTime? RedeemedDate { get; set; }

        /// <summary>
        /// Ghi chú (lý do hủy, v.v.)
        /// </summary>
        [MaxLength(500)]
        public string? Notes { get; set; }
    }

    /// <summary>
    /// Trạng thái giao dịch đổi quà
    /// </summary>
    public static class RewardTransactionStatus
    {
        public const string Pending = "Pending";       // Chờ nhận
        public const string Redeemed = "Redeemed";     // Đã nhận
        public const string Cancelled = "Cancelled";   // Đã hủy
    }
}
