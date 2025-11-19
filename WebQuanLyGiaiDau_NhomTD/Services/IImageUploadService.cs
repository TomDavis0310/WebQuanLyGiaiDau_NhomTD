using Microsoft.AspNetCore.Http;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    /// <summary>
    /// Service interface for handling image upload operations
    /// </summary>
    public interface IImageUploadService
    {
        /// <summary>
        /// Saves an uploaded image file to the specified folder
        /// </summary>
        /// <param name="image">The image file to upload</param>
        /// <param name="folder">The target folder (e.g., "sports", "teams", "players", "news", "tournaments")</param>
        /// <returns>The relative URL path to the saved image</returns>
        Task<string> SaveImageAsync(IFormFile image, string folder);

        /// <summary>
        /// Deletes an image file from the server
        /// </summary>
        /// <param name="imageUrl">The relative URL of the image to delete</param>
        /// <returns>True if deletion was successful, false otherwise</returns>
        Task<bool> DeleteImageAsync(string imageUrl);

        /// <summary>
        /// Validates image file (size, format)
        /// </summary>
        /// <param name="image">The image file to validate</param>
        /// <returns>Validation error message or null if valid</returns>
        string ValidateImage(IFormFile image);
    }
}
