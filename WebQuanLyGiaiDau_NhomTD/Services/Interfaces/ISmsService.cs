namespace WebQuanLyGiaiDau_NhomTD.Services.Interfaces
{
    public interface ISmsService
    {
        /// <summary>
        /// Send SMS message to phone number
        /// </summary>
        Task<bool> SendSmsAsync(string phoneNumber, string message);

        /// <summary>
        /// Verify phone number with code
        /// </summary>
        Task<bool> VerifyPhoneNumberAsync(string phoneNumber, string code);
    }
}
