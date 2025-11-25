using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    public class ZaloOtpService : IZaloOtpService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<ZaloOtpService> _logger;
        private readonly HttpClient _httpClient;
        private readonly string? _zaloAppId;
        private readonly string? _zaloAppSecret;
        private readonly string? _zaloAccessToken;

        public ZaloOtpService(
            IConfiguration configuration, 
            ILogger<ZaloOtpService> logger,
            IHttpClientFactory httpClientFactory)
        {
            _configuration = configuration;
            _logger = logger;
            _httpClient = httpClientFactory.CreateClient();
            
            _zaloAppId = _configuration["Zalo:AppId"];
            _zaloAppSecret = _configuration["Zalo:AppSecret"];
            _zaloAccessToken = _configuration["Zalo:AccessToken"];
        }

        public async Task<bool> SendZaloOtpAsync(string zaloId, string otpCode)
        {
            try
            {
                if (string.IsNullOrEmpty(_zaloAccessToken))
                {
                    _logger.LogWarning("Zalo access token not configured. OTP will not be sent via Zalo.");
                    return false;
                }

                // Zalo OA API endpoint for sending messages
                var apiUrl = "https://openapi.zalo.me/v2.0/oa/message";

                var messageData = new
                {
                    recipient = new { user_id = zaloId },
                    message = new
                    {
                        text = $"🔐 TDSports - Mã xác thực OTP\n\nMã của bạn: {otpCode}\n\n⏰ Có hiệu lực: 5 phút\n⚠️ Không chia sẻ mã này với ai!"
                    }
                };

                var jsonContent = JsonSerializer.Serialize(messageData);
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                _httpClient.DefaultRequestHeaders.Clear();
                _httpClient.DefaultRequestHeaders.Add("access_token", _zaloAccessToken);

                var response = await _httpClient.PostAsync(apiUrl, content);
                var responseContent = await response.Content.ReadAsStringAsync();

                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation($"Zalo OTP sent successfully to {zaloId}");
                    return true;
                }
                else
                {
                    _logger.LogError($"Failed to send Zalo OTP. Status: {response.StatusCode}, Response: {responseContent}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Exception occurred while sending Zalo OTP to {zaloId}");
                return false;
            }
        }

        public async Task<bool> VerifyZaloIdAsync(string zaloId)
        {
            try
            {
                if (string.IsNullOrEmpty(_zaloAccessToken))
                {
                    _logger.LogWarning("Zalo access token not configured.");
                    return false;
                }

                // Zalo OA API endpoint for getting user info
                var apiUrl = $"https://openapi.zalo.me/v2.0/oa/getuser?data={{\"user_id\":\"{zaloId}\"}}";

                _httpClient.DefaultRequestHeaders.Clear();
                _httpClient.DefaultRequestHeaders.Add("access_token", _zaloAccessToken);

                var response = await _httpClient.GetAsync(apiUrl);
                
                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation($"Zalo ID {zaloId} verified successfully");
                    return true;
                }
                else
                {
                    _logger.LogWarning($"Failed to verify Zalo ID {zaloId}. Status: {response.StatusCode}");
                    return false;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Exception occurred while verifying Zalo ID {zaloId}");
                return false;
            }
        }
    }
}
