using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.TempModels;
using System.Security.Claims;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/profile")]
    [ApiController]
    [Authorize]
    public class ProfileApiController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IWebHostEnvironment _webHostEnvironment;
        private readonly ILogger<ProfileApiController> _logger;

        public ProfileApiController(
            UserManager<ApplicationUser> userManager,
            IWebHostEnvironment webHostEnvironment,
            ILogger<ProfileApiController> logger)
        {
            _userManager = userManager;
            _webHostEnvironment = webHostEnvironment;
            _logger = logger;
        }

        // GET: api/profile
        [HttpGet]
        public async Task<ActionResult<ApiResponse<UserProfileDto>>> GetProfile()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var user = await _userManager.FindByIdAsync(userId);

                if (user == null)
                {
                    return NotFound(new ApiResponse<UserProfileDto>
                    {
                        Success = false,
                        Message = "Không tìm thấy người dùng",
                        Data = null
                    });
                }

                var roles = await _userManager.GetRolesAsync(user);

                var profile = new UserProfileDto
                {
                    UserId = user.Id,
                    UserName = user.UserName,
                    Email = user.Email,
                    FullName = user.FullName,
                    PhoneNumber = user.PhoneNumber,
                    Address = user.Address,
                    Age = user.Age != null ? int.TryParse(user.Age, out var age) ? age : null : null,
                    Gender = user.Gender,
                    DateOfBirth = user.DateOfBirth,
                    ProfilePictureUrl = user.ProfilePictureUrl,
                    Role = roles.FirstOrDefault() ?? "User",
                    CreatedAt = null
                };

                return Ok(new ApiResponse<UserProfileDto>
                {
                    Success = true,
                    Message = "Lấy thông tin profile thành công",
                    Data = profile
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting profile");
                return StatusCode(500, new ApiResponse<UserProfileDto>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi lấy thông tin profile",
                    Data = null
                });
            }
        }

        // PUT: api/profile
        [HttpPut]
        public async Task<ActionResult<ApiResponse<UserProfileDto>>> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var user = await _userManager.FindByIdAsync(userId);

                if (user == null)
                {
                    return NotFound(new ApiResponse<UserProfileDto>
                    {
                        Success = false,
                        Message = "Không tìm thấy người dùng",
                        Data = null
                    });
                }

                // Update user information
                user.FullName = request.FullName ?? user.FullName;
                user.PhoneNumber = request.PhoneNumber ?? user.PhoneNumber;
                user.Address = request.Address ?? user.Address;
                user.Age = request.Age?.ToString() ?? user.Age;
                user.Gender = request.Gender ?? user.Gender;
                user.DateOfBirth = request.DateOfBirth ?? user.DateOfBirth;

                var result = await _userManager.UpdateAsync(user);

                if (!result.Succeeded)
                {
                    return BadRequest(new ApiResponse<UserProfileDto>
                    {
                        Success = false,
                        Message = "Cập nhật thông tin thất bại: " + string.Join(", ", result.Errors.Select(e => e.Description)),
                        Data = null
                    });
                }

                var roles = await _userManager.GetRolesAsync(user);

                var profile = new UserProfileDto
                {
                    UserId = user.Id,
                    UserName = user.UserName,
                    Email = user.Email,
                    FullName = user.FullName,
                    PhoneNumber = user.PhoneNumber,
                    Address = user.Address,
                    Age = user.Age != null ? int.TryParse(user.Age, out var age2) ? age2 : null : null,
                    Gender = user.Gender,
                    DateOfBirth = user.DateOfBirth,
                    ProfilePictureUrl = user.ProfilePictureUrl,
                    Role = roles.FirstOrDefault() ?? "User",
                    CreatedAt = null
                };

                return Ok(new ApiResponse<UserProfileDto>
                {
                    Success = true,
                    Message = "Cập nhật thông tin thành công",
                    Data = profile
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating profile");
                return StatusCode(500, new ApiResponse<UserProfileDto>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi cập nhật thông tin",
                    Data = null
                });
            }
        }

        // PUT: api/profile/avatar
        [HttpPut("avatar")]
        public async Task<ActionResult<ApiResponse<string>>> UpdateAvatar([FromForm] IFormFile profilePicture)
        {
            try
            {
                if (profilePicture == null || profilePicture.Length == 0)
                {
                    return BadRequest(new ApiResponse<string>
                    {
                        Success = false,
                        Message = "Vui lòng chọn file ảnh",
                        Data = null
                    });
                }

                // Validate file size (5MB max)
                if (profilePicture.Length > 5 * 1024 * 1024)
                {
                    return BadRequest(new ApiResponse<string>
                    {
                        Success = false,
                        Message = "File quá lớn! Vui lòng chọn file nhỏ hơn 5MB",
                        Data = null
                    });
                }

                // Validate file type
                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
                var fileExtension = Path.GetExtension(profilePicture.FileName).ToLowerInvariant();
                if (!allowedExtensions.Contains(fileExtension))
                {
                    return BadRequest(new ApiResponse<string>
                    {
                        Success = false,
                        Message = "Chỉ chấp nhận file ảnh (JPG, JPEG, PNG, GIF)",
                        Data = null
                    });
                }

                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var user = await _userManager.FindByIdAsync(userId);

                if (user == null)
                {
                    return NotFound(new ApiResponse<string>
                    {
                        Success = false,
                        Message = "Không tìm thấy người dùng",
                        Data = null
                    });
                }

                var uploadsFolder = Path.Combine(_webHostEnvironment.WebRootPath, "images", "profiles");
                Directory.CreateDirectory(uploadsFolder);

                var uniqueFileName = Guid.NewGuid().ToString() + "_" + profilePicture.FileName;
                var filePath = Path.Combine(uploadsFolder, uniqueFileName);

                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await profilePicture.CopyToAsync(fileStream);
                }

                // Delete old profile picture if exists
                if (!string.IsNullOrEmpty(user.ProfilePictureUrl))
                {
                    var oldFilePath = Path.Combine(_webHostEnvironment.WebRootPath, user.ProfilePictureUrl.TrimStart('/'));
                    if (System.IO.File.Exists(oldFilePath))
                    {
                        try
                        {
                            System.IO.File.Delete(oldFilePath);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Could not delete old profile picture");
                        }
                    }
                }

                user.ProfilePictureUrl = "/images/profiles/" + uniqueFileName;
                await _userManager.UpdateAsync(user);

                return Ok(new ApiResponse<string>
                {
                    Success = true,
                    Message = "Cập nhật ảnh đại diện thành công",
                    Data = user.ProfilePictureUrl
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating avatar");
                return StatusCode(500, new ApiResponse<string>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi cập nhật ảnh đại diện",
                    Data = null
                });
            }
        }

        // POST: api/profile/change-password
        [HttpPost("change-password")]
        public async Task<ActionResult<ApiResponse<bool>>> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.OldPassword) || 
                    string.IsNullOrWhiteSpace(request.NewPassword))
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Vui lòng nhập đầy đủ thông tin",
                        Data = false
                    });
                }

                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var user = await _userManager.FindByIdAsync(userId);

                if (user == null)
                {
                    return NotFound(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Không tìm thấy người dùng",
                        Data = false
                    });
                }

                var result = await _userManager.ChangePasswordAsync(user, request.OldPassword, request.NewPassword);

                if (!result.Succeeded)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Đổi mật khẩu thất bại: " + string.Join(", ", result.Errors.Select(e => e.Description)),
                        Data = false
                    });
                }

                _logger.LogInformation("User {UserId} changed their password successfully", userId);

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Đổi mật khẩu thành công",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error changing password");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi đổi mật khẩu",
                    Data = false
                });
            }
        }

        // POST: api/profile/forgot-password
        [HttpPost("forgot-password")]
        [AllowAnonymous]
        public async Task<ActionResult<ApiResponse<bool>>> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Email))
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Vui lòng nhập email",
                        Data = false
                    });
                }

                var user = await _userManager.FindByEmailAsync(request.Email);

                // Always return success to prevent email enumeration
                if (user == null)
                {
                    return Ok(new ApiResponse<bool>
                    {
                        Success = true,
                        Message = "Nếu email tồn tại, mã xác nhận đã được gửi",
                        Data = true
                    });
                }

                var code = await _userManager.GeneratePasswordResetTokenAsync(user);
                
                // TODO: Send email with reset code
                // For now, we'll log it (in production, use email service)
                _logger.LogInformation("Password reset code for {Email}: {Code}", request.Email, code);

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Mã xác nhận đã được gửi đến email của bạn",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in forgot password");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra",
                    Data = false
                });
            }
        }

        // POST: api/profile/reset-password
        [HttpPost("reset-password")]
        [AllowAnonymous]
        public async Task<ActionResult<ApiResponse<bool>>> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.Email) || 
                    string.IsNullOrWhiteSpace(request.Code) ||
                    string.IsNullOrWhiteSpace(request.NewPassword))
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Vui lòng nhập đầy đủ thông tin",
                        Data = false
                    });
                }

                var user = await _userManager.FindByEmailAsync(request.Email);

                if (user == null)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Email không tồn tại",
                        Data = false
                    });
                }

                var result = await _userManager.ResetPasswordAsync(user, request.Code, request.NewPassword);

                if (!result.Succeeded)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Reset mật khẩu thất bại: " + string.Join(", ", result.Errors.Select(e => e.Description)),
                        Data = false
                    });
                }

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Reset mật khẩu thành công",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resetting password");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi reset mật khẩu",
                    Data = false
                });
            }
        }
    }

    // DTOs
    public class UserProfileDto
    {
        public string UserId { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string? FullName { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public int? Age { get; set; }
        public string? Gender { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public string? Role { get; set; }
        public DateTime? CreatedAt { get; set; }
    }

    public class UpdateProfileRequest
    {
        public string? FullName { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public int? Age { get; set; }
        public string? Gender { get; set; }
        public DateTime? DateOfBirth { get; set; }
    }

    public class ChangePasswordRequest
    {
        public string OldPassword { get; set; }
        public string NewPassword { get; set; }
    }

    public class ForgotPasswordRequest
    {
        public string Email { get; set; }
    }

    public class ResetPasswordRequest
    {
        public string Email { get; set; }
        public string Code { get; set; }
        public string NewPassword { get; set; }
    }
}
