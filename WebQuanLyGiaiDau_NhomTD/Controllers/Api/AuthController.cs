using Microsoft.AspNetCore.Mvc;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IConfiguration _configuration;

        public AuthController(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [HttpGet("check-google-oauth")]
        public IActionResult CheckGoogleOAuth()
        {
            var googleClientId = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_ID")
                ?? _configuration["Authentication:Google:ClientId"];
            var googleClientSecret = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_SECRET")
                ?? _configuration["Authentication:Google:ClientSecret"];

            bool isConfigured = !string.IsNullOrEmpty(googleClientId) &&
                               !string.IsNullOrEmpty(googleClientSecret) &&
                               googleClientId != "YOUR_GOOGLE_CLIENT_ID_HERE" &&
                               googleClientSecret != "YOUR_GOOGLE_CLIENT_SECRET_HERE";

            return Ok(new { isConfigured = isConfigured });
        }
    }
}