using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    /// <summary>
    /// Service for handling image upload operations with validation and error handling
    /// </summary>
    public class ImageUploadService : IImageUploadService
    {
        private readonly ILogger<ImageUploadService> _logger;
        private const long MaxFileSize = 5 * 1024 * 1024; // 5MB
        private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

        public ImageUploadService(ILogger<ImageUploadService> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Validates image file (size, format)
        /// </summary>
        public string ValidateImage(IFormFile image)
        {
            if (image == null || image.Length == 0)
            {
                return "File không hợp lệ.";
            }

            // Check file size
            if (image.Length > MaxFileSize)
            {
                return "Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 5MB.";
            }

            // Check file extension
            string extension = Path.GetExtension(image.FileName).ToLower();
            if (!AllowedExtensions.Contains(extension))
            {
                return "Chỉ chấp nhận file hình ảnh có định dạng: .jpg, .jpeg, .png, .gif";
            }

            return null; // Valid
        }

        /// <summary>
        /// Saves an uploaded image file to the specified folder
        /// </summary>
        public async Task<string> SaveImageAsync(IFormFile image, string folder)
        {
            try
            {
                // Validate image
                var validationError = ValidateImage(image);
                if (validationError != null)
                {
                    throw new ArgumentException(validationError);
                }

                // Sanitize filename
                string fileName = Path.GetFileNameWithoutExtension(image.FileName);
                fileName = SanitizeFileName(fileName);

                // Create unique filename with timestamp
                string extension = Path.GetExtension(image.FileName).ToLower();
                string uniqueFileName = $"{DateTime.Now.Ticks}_{fileName}{extension}";

                // Create full path
                string uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", folder);

                // Ensure directory exists
                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                    _logger.LogInformation("Created directory: {Directory}", uploadsFolder);
                }

                string filePath = Path.Combine(uploadsFolder, uniqueFileName);

                // Save file
                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await image.CopyToAsync(fileStream);
                }

                _logger.LogInformation("Image saved successfully: {FilePath}", filePath);

                // Return relative URL
                return $"/images/{folder}/{uniqueFileName}";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving image to folder: {Folder}", folder);
                throw new Exception($"Lỗi khi lưu hình ảnh: {ex.Message}");
            }
        }

        /// <summary>
        /// Deletes an image file from the server
        /// </summary>
        public async Task<bool> DeleteImageAsync(string imageUrl)
        {
            try
            {
                if (string.IsNullOrEmpty(imageUrl))
                {
                    return false;
                }

                // Convert URL to physical path
                string filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", imageUrl.TrimStart('/'));

                if (File.Exists(filePath))
                {
                    await Task.Run(() => File.Delete(filePath));
                    _logger.LogInformation("Image deleted successfully: {FilePath}", filePath);
                    return true;
                }

                _logger.LogWarning("Image file not found: {FilePath}", filePath);
                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting image: {ImageUrl}", imageUrl);
                return false;
            }
        }

        /// <summary>
        /// Sanitizes filename by removing special characters
        /// </summary>
        private string SanitizeFileName(string fileName)
        {
            // Remove special characters, keep only alphanumeric and underscores
            var invalidChars = Path.GetInvalidFileNameChars();
            var sanitized = string.Join("_", fileName.Split(invalidChars, StringSplitOptions.RemoveEmptyEntries));
            
            // Limit length
            if (sanitized.Length > 50)
            {
                sanitized = sanitized.Substring(0, 50);
            }

            return sanitized;
        }
    }
}
