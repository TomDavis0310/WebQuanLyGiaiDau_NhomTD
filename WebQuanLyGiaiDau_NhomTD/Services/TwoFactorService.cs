using QRCoder;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    public class TwoFactorService : ITwoFactorService
    {
        private readonly IEmailService _emailService;
        private readonly ISmsService _smsService;
        private readonly IZaloOtpService _zaloOtpService;
        private readonly ILogger<TwoFactorService> _logger;

        public TwoFactorService(
            IEmailService emailService,
            ISmsService smsService,
            IZaloOtpService zaloOtpService,
            ILogger<TwoFactorService> logger)
        {
            _emailService = emailService;
            _smsService = smsService;
            _zaloOtpService = zaloOtpService;
            _logger = logger;
        }

        public string GenerateOtpCode()
        {
            var random = new Random();
            return random.Next(100000, 999999).ToString();
        }

        public bool VerifyOtpCode(string? storedCode, DateTime? expiry, string providedCode)
        {
            if (string.IsNullOrEmpty(storedCode) || !expiry.HasValue)
            {
                return false;
            }

            if (DateTime.UtcNow > expiry.Value)
            {
                return false;
            }

            return storedCode == providedCode;
        }

        public async Task<bool> SendOtpViaEmailAsync(string email, string code, string userName)
        {
            try
            {
                var subject = "Mã xác thực TDSports";
                var htmlBody = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                        <h2 style='color: #2c3e50;'>Xác thực đăng nhập</h2>
                        <p>Xin chào <strong>{userName}</strong>,</p>
                        <p>Mã xác thực của bạn là:</p>
                        <div style='background-color: #f8f9fa; padding: 20px; text-align: center; margin: 20px 0;'>
                            <h1 style='color: #007bff; font-size: 36px; margin: 0; letter-spacing: 5px;'>{code}</h1>
                        </div>
                        <p>Mã này sẽ hết hạn sau <strong>5 phút</strong>.</p>
                        <p style='color: #dc3545;'>⚠️ Không chia sẻ mã này với bất kỳ ai!</p>
                        <hr style='margin: 20px 0; border: none; border-top: 1px solid #dee2e6;'>
                        <p style='color: #6c757d; font-size: 14px;'>
                            Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này hoặc liên hệ với chúng tôi ngay lập tức.
                        </p>
                        <p style='color: #6c757d; font-size: 14px;'>
                            <strong>TDSports Team</strong><br>
                            Email: support@tdsports.com
                        </p>
                    </div>
                ";

                var plainTextBody = $@"
                    Xác thực đăng nhập
                    
                    Xin chào {userName},
                    
                    Mã xác thực của bạn là: {code}
                    
                    Mã này sẽ hết hạn sau 5 phút.
                    
                    ⚠️ Không chia sẻ mã này với bất kỳ ai!
                    
                    Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này hoặc liên hệ với chúng tôi ngay lập tức.
                    
                    TDSports Team
                    Email: support@tdsports.com
                ";

                await _emailService.SendEmailAsync(email, subject, htmlBody, true);
                _logger.LogInformation($"OTP sent via email to {email}");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send OTP via email to {email}");
                return false;
            }
        }

        public async Task<bool> SendOtpViaSmsAsync(string phoneNumber, string code)
        {
            try
            {
                var message = $"TDSports - Mã xác thực của bạn là: {code}. Mã có hiệu lực trong 5 phút. Không chia sẻ mã này!";
                var result = await _smsService.SendSmsAsync(phoneNumber, message);
                
                if (result)
                {
                    _logger.LogInformation($"OTP sent via SMS to {phoneNumber}");
                }
                
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send OTP via SMS to {phoneNumber}");
                return false;
            }
        }

        public async Task<bool> SendOtpViaZaloAsync(string zaloId, string code)
        {
            try
            {
                var result = await _zaloOtpService.SendZaloOtpAsync(zaloId, code);
                
                if (result)
                {
                    _logger.LogInformation($"OTP sent via Zalo to {zaloId}");
                }
                
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send OTP via Zalo to {zaloId}");
                return false;
            }
        }

        public byte[] GenerateQrCodeForAuthenticator(string email, string secretKey)
        {
            try
            {
                // Generate QR code for authenticator apps (Google Authenticator, Microsoft Authenticator, etc.)
                var qrCodeText = $"otpauth://totp/TDSports:{email}?secret={secretKey}&issuer=TDSports";
                
                using (var qrGenerator = new QRCodeGenerator())
                {
                    var qrCodeData = qrGenerator.CreateQrCode(qrCodeText, QRCodeGenerator.ECCLevel.Q);
                    var qrCode = new PngByteQRCode(qrCodeData);
                    return qrCode.GetGraphic(20);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to generate QR code for {email}");
                return Array.Empty<byte>();
            }
        }
    }
}
