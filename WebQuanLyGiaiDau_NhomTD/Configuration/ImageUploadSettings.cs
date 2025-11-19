namespace WebQuanLyGiaiDau_NhomTD.Configuration
{
    /// <summary>
    /// Configuration settings for image uploads
    /// </summary>
    public class ImageUploadSettings
    {
        /// <summary>
        /// Maximum file size in MB (default: 5MB)
        /// </summary>
        public int MaxFileSizeMB { get; set; } = 5;

        /// <summary>
        /// Allowed image file extensions
        /// </summary>
        public string[] AllowedExtensions { get; set; } = { ".jpg", ".jpeg", ".png", ".gif" };

        /// <summary>
        /// Base upload folder path
        /// </summary>
        public string BaseUploadFolder { get; set; } = "wwwroot/images";
    }
}
