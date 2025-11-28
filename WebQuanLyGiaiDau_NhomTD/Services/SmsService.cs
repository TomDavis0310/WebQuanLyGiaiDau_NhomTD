using Twilio;
using Twilio.Rest.Api.V2010.Account;
using Twilio.Types;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    public class SmsService : ISmsService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<SmsService> _logger;
        private readonly string? _accountSid;
        private readonly string? _authToken;
        private readonly string? _fromPhoneNumber;

        public SmsService(IConfiguration configuration, ILogger<SmsService> logger)
        {
            _configuration = configuration;
            _logger = logger;
            
            _accountSid = _configuration["Twilio:AccountSid"];
            _authToken = _configuration["Twilio:AuthToken"];
            _fromPhoneNumber = _configuration["Twilio:FromPhoneNumber"];

            if (!string.IsNullOrEmpty(_accountSid) && !string.IsNullOrEmpty(_authToken))
            {
                TwilioClient.Init(_accountSid, _authToken);
            }
        }

        public async Task<bool> SendSmsAsync(string phoneNumber, string message)
        {
            try
            {
                if (string.IsNullOrEmpty(_accountSid) || string.IsNullOrEmpty(_authToken) || string.IsNullOrEmpty(_fromPhoneNumber))
                {
                    _logger.LogWarning("Twilio credentials not configured. SMS will not be sent.");
                    return false;
                }

                // Format phone number to E.164 format if needed
                if (!phoneNumber.StartsWith("+"))
                {
                    // Assume Vietnam phone number if no country code
                    phoneNumber = "+84" + phoneNumber.TrimStart('0');
                }

                var messageResource = await MessageResource.CreateAsync(
                    body: message,
                    from: new PhoneNumber(_fromPhoneNumber),
                    to: new PhoneNumber(phoneNumber)
                );

                _logger.LogInformation($"SMS sent successfully to {phoneNumber}. SID: {messageResource.Sid}");
                return messageResource.Status != MessageResource.StatusEnum.Failed;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send SMS to {phoneNumber}");
                return false;
            }
        }

        public async Task<bool> VerifyPhoneNumberAsync(string phoneNumber, string code)
        {
            // This is a placeholder implementation
            // In a real-world scenario, you would verify the code against a stored verification code
            await Task.CompletedTask;
            return !string.IsNullOrEmpty(phoneNumber) && !string.IsNullOrEmpty(code);
        }
    }
}
