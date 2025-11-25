namespace WebQuanLyGiaiDau_NhomTD.Services.Interfaces
{
    public interface ITwoFactorService
    {
        /// <summary>
        /// Generate a 6-digit OTP code
        /// </summary>
        string GenerateOtpCode();

        /// <summary>
        /// Verify if the provided OTP code matches and is not expired
        /// </summary>
        bool VerifyOtpCode(string? storedCode, DateTime? expiry, string providedCode);

        /// <summary>
        /// Send OTP code via Email
        /// </summary>
        Task<bool> SendOtpViaEmailAsync(string email, string code, string userName);

        /// <summary>
        /// Send OTP code via SMS
        /// </summary>
        Task<bool> SendOtpViaSmsAsync(string phoneNumber, string code);

        /// <summary>
        /// Send OTP code via Zalo
        /// </summary>
        Task<bool> SendOtpViaZaloAsync(string zaloId, string code);

        /// <summary>
        /// Generate QR code for authenticator app setup
        /// </summary>
        byte[] GenerateQrCodeForAuthenticator(string email, string secretKey);
    }
}
