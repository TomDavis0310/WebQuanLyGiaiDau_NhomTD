using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebQuanLyGiaiDau_NhomTD.Services;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.Annotations;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] // Requires JWT authentication
    public class ImageUploadController : ControllerBase
    {
        private readonly IImageUploadService _imageUploadService;
        private readonly ILogger<ImageUploadController> _logger;

        public ImageUploadController(
            IImageUploadService imageUploadService,
            ILogger<ImageUploadController> logger)
        {
            _imageUploadService = imageUploadService;
            _logger = logger;
        }

        /// <summary>
        /// Upload image file for mobile app
        /// </summary>
        /// <param name="file">Image file</param>
        /// <param name="uploadType">Type: ProfileImage, TeamLogo, PlayerPhoto, TournamentImage</param>
        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        [ApiExplorerSettings(IgnoreApi = true)] // Hide from Swagger due to IFormFile issue
        public async Task<IActionResult> UploadImage([FromForm] IFormFile file, [FromForm] string uploadType)
        {
            try
            {
                if (file == null || file.Length == 0)
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = "Vui lòng chọn file để upload"
                    });
                }

                // Validate file type
                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
                var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
                
                if (!allowedExtensions.Contains(extension))
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = "Chỉ cho phép upload file ảnh (.jpg, .jpeg, .png, .gif)"
                    });
                }

                // Validate file size (max 5MB)
                if (file.Length > 5 * 1024 * 1024)
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = "Kích thước file không được vượt quá 5MB"
                    });
                }

                // Determine folder based on upload type
                string folder = uploadType?.ToLower() switch
                {
                    "profileimage" => "profiles",
                    "teamlogo" => "teams",
                    "playerphoto" => "players",
                    "tournamentimage" => "tournaments",
                    _ => "misc"
                };

                // Save image using ImageUploadService
                var imageUrl = await _imageUploadService.SaveImageAsync(file, folder);

                _logger.LogInformation($"Image uploaded successfully: {imageUrl} by user {User.Identity?.Name}");

                return Ok(new
                {
                    success = true,
                    message = "Upload ảnh thành công",
                    data = new
                    {
                        imageUrl = imageUrl,
                        uploadType = uploadType,
                        fileName = file.FileName,
                        fileSize = file.Length
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error uploading image: {ex.Message}");
                
                return StatusCode(500, new
                {
                    success = false,
                    message = $"Lỗi server: {ex.Message}"
                });
            }
        }

        /// <summary>
        /// Delete image by URL
        /// </summary>
        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteImage([FromQuery] string imageUrl)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(imageUrl))
                {
                    return BadRequest(new
                    {
                        success = false,
                        message = "URL ảnh không hợp lệ"
                    });
                }

                await _imageUploadService.DeleteImageAsync(imageUrl);

                _logger.LogInformation($"Image deleted successfully: {imageUrl} by user {User.Identity?.Name}");

                return Ok(new
                {
                    success = true,
                    message = "Xóa ảnh thành công"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error deleting image: {ex.Message}");
                
                return StatusCode(500, new
                {
                    success = false,
                    message = $"Lỗi server: {ex.Message}"
                });
            }
        }
    }
}
