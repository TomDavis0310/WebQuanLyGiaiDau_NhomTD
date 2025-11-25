using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthController> _logger;

        public AuthController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration,
            ILogger<AuthController> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _logger = logger;
        }

        // POST: api/Auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                _logger.LogInformation($"Login attempt for email: {request.Email}");

                if (!ModelState.IsValid)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Dữ liệu không hợp lệ"
                    });
                }

                var user = await _userManager.FindByEmailAsync(request.Email);
                if (user == null)
                {
                    _logger.LogWarning($"User not found: {request.Email}");
                    return Ok(new
                    {
                        success = false,
                        message = "Email hoặc mật khẩu không đúng"
                    });
                }

                // Enable account lockout on failed login attempts
                var result = await _signInManager.CheckPasswordSignInAsync(
                    user, request.Password, lockoutOnFailure: true);

                if (result.IsLockedOut)
                {
                    _logger.LogWarning($"Account locked out: {request.Email}");
                    return Ok(new
                    {
                        success = false,
                        message = "Tài khoản đã bị khóa do đăng nhập sai quá nhiều lần. Vui lòng thử lại sau 15 phút."
                    });
                }

                if (!result.Succeeded)
                {
                    _logger.LogWarning($"Invalid password for user: {request.Email}");
                    return Ok(new
                    {
                        success = false,
                        message = "Email hoặc mật khẩu không đúng"
                    });
                }

                // Generate JWT token
                var token = await GenerateJwtToken(user);
                var roles = await _userManager.GetRolesAsync(user);

                _logger.LogInformation($"Login successful for user: {request.Email}");

                return Ok(new
                {
                    success = true,
                    message = "Đăng nhập thành công",
                    token = token,
                    user = new
                    {
                        id = user.Id,
                        email = user.Email,
                        userName = user.UserName,
                        fullName = user.FullName,
                        phoneNumber = user.PhoneNumber,
                        avatarUrl = user.ProfilePictureUrl,
                        role = roles.FirstOrDefault() ?? "User"
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error during login for email: {request.Email}");
                return Ok(new
                {
                    success = false,
                    message = $"Lỗi: {ex.Message}"
                });
            }
        }

        // POST: api/Auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            try
            {
                _logger.LogInformation($"Registration attempt for email: {request.Email}");

                if (!ModelState.IsValid)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Dữ liệu không hợp lệ"
                    });
                }

                if (request.Password != request.ConfirmPassword)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Mật khẩu xác nhận không khớp"
                    });
                }

                // Check if email exists
                var existingUser = await _userManager.FindByEmailAsync(request.Email);
                if (existingUser != null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Email đã được sử dụng"
                    });
                }

                // Check if username exists
                var existingUsername = await _userManager.FindByNameAsync(request.UserName);
                if (existingUsername != null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Tên đăng nhập đã được sử dụng"
                    });
                }

                // Create new user
                var user = new ApplicationUser
                {
                    Email = request.Email,
                    UserName = request.UserName,
                    FullName = request.FullName ?? request.UserName,
                    PhoneNumber = request.PhoneNumber,
                    EmailConfirmed = true // Auto-confirm for now
                };

                var result = await _userManager.CreateAsync(user, request.Password);

                if (!result.Succeeded)
                {
                    var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                    _logger.LogWarning($"Registration failed for {request.Email}: {errors}");
                    return Ok(new
                    {
                        success = false,
                        message = $"Đăng ký thất bại: {errors}"
                    });
                }

                // Assign default role
                await _userManager.AddToRoleAsync(user, "User");

                // Generate JWT token
                var token = await GenerateJwtToken(user);

                _logger.LogInformation($"Registration successful for user: {request.Email}");

                return Ok(new
                {
                    success = true,
                    message = "Đăng ký thành công",
                    token = token,
                    user = new
                    {
                        id = user.Id,
                        email = user.Email,
                        userName = user.UserName,
                        fullName = user.FullName,
                        phoneNumber = user.PhoneNumber,
                        role = "User"
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error during registration for email: {request.Email}");
                return Ok(new
                {
                    success = false,
                    message = $"Lỗi: {ex.Message}"
                });
            }
        }

        // GET: api/Auth/validate
        [HttpGet("validate")]
        [Authorize(AuthenticationSchemes = "Bearer")]
        public IActionResult ValidateToken()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return Ok(new
            {
                success = true,
                message = "Token hợp lệ",
                userId = userId
            });
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

        // Helper: Generate JWT Token
        private async Task<string> GenerateJwtToken(ApplicationUser user)
        {
            var roles = await _userManager.GetRolesAsync(user);
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Email, user.Email ?? ""),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Name, user.UserName ?? ""),
                new Claim(ClaimTypes.NameIdentifier, user.Id)
            };

            // Add role claims
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:Key"] ?? "YourSuperSecretKeyThatIsAtLeast32CharactersLongForTDSports!"));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"] ?? "WebQuanLyGiaiDau",
                audience: _configuration["Jwt:Audience"] ?? "TDSportsApp",
                claims: claims,
                expires: DateTime.Now.AddDays(7),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    // Request Models
    public class LoginRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public bool RememberMe { get; set; }
    }

    public class RegisterRequest
    {
        public string Email { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string ConfirmPassword { get; set; } = string.Empty;
        public string? FullName { get; set; }
        public string? PhoneNumber { get; set; }
    }
}