namespace WebQuanLyGiaiDau_NhomTD.Services.Interfaces
{
    public interface IZaloOtpService
    {
        /// <summary>
        /// Send OTP via Zalo message
        /// </summary>
        Task<bool> SendZaloOtpAsync(string zaloId, string otpCode);

        /// <summary>
        /// Verify Zalo ID
        /// </summary>
        Task<bool> VerifyZaloIdAsync(string zaloId);
    }
}
