using WebQuanLyGiaiDau_NhomTD.Models.FileUpload;

namespace WebQuanLyGiaiDau_NhomTD.Services.Interfaces
{
    /// <summary>
    /// Interface cho File Upload Service
    /// </summary>
    public interface IFileUploadService
    {
        /// <summary>
        /// Upload single file
        /// </summary>
        Task<FileUploadResult> UploadFileAsync(IFormFile file, FileUploadOptions? options = null);

        /// <summary>
        /// Upload multiple files
        /// </summary>
        Task<List<FileUploadResult>> UploadFilesAsync(IEnumerable<IFormFile> files, FileUploadOptions? options = null);

        /// <summary>
        /// Upload file từ byte array
        /// </summary>
        Task<FileUploadResult> UploadFileAsync(byte[] fileBytes, string fileName, string mimeType, FileUploadOptions? options = null);

        /// <summary>
        /// Upload file từ stream
        /// </summary>
        Task<FileUploadResult> UploadFileAsync(Stream fileStream, string fileName, string mimeType, FileUploadOptions? options = null);

        /// <summary>
        /// Xóa file
        /// </summary>
        Task<bool> DeleteFileAsync(string fileId);

        /// <summary>
        /// Xóa file theo path
        /// </summary>
        Task<bool> DeleteFileByPathAsync(string filePath);

        /// <summary>
        /// Lấy thông tin file
        /// </summary>
        Task<UploadedFileInfo?> GetFileInfoAsync(string fileId);

        /// <summary>
        /// Lấy file content
        /// </summary>
        Task<byte[]?> GetFileContentAsync(string fileId);

        /// <summary>
        /// Lấy file stream
        /// </summary>
        Task<Stream?> GetFileStreamAsync(string fileId);

        /// <summary>
        /// Validate file
        /// </summary>
        bool ValidateFile(IFormFile file, out List<string> errors);

        /// <summary>
        /// Validate file extension và MIME type
        /// </summary>
        bool IsValidFile(string fileName, string mimeType);

        /// <summary>
        /// Tạo thumbnail
        /// </summary>
        Task<string?> GenerateThumbnailAsync(string imagePath, int width = 300, int height = 300);

        /// <summary>
        /// Resize image
        /// </summary>
        Task<string?> ResizeImageAsync(string imagePath, int maxWidth, int maxHeight);

        /// <summary>
        /// Clean up temp files
        /// </summary>
        Task CleanupTempFilesAsync(TimeSpan olderThan);

        /// <summary>
        /// Get files by category
        /// </summary>
        Task<List<UploadedFileInfo>> GetFilesByCategoryAsync(string category);

        /// <summary>
        /// Copy file
        /// </summary>
        Task<FileUploadResult> CopyFileAsync(string sourceFileId, FileUploadOptions? options = null);

        /// <summary>
        /// Move file
        /// </summary>
        Task<bool> MoveFileAsync(string fileId, string newCategory);
    }

    /// <summary>
    /// Interface cho File Storage Provider
    /// </summary>
    public interface IFileStorageProvider
    {
        /// <summary>
        /// Save file
        /// </summary>
        Task<string> SaveFileAsync(Stream fileStream, string fileName, string category);

        /// <summary>
        /// Delete file
        /// </summary>
        Task<bool> DeleteFileAsync(string filePath);

        /// <summary>
        /// Get file stream
        /// </summary>
        Task<Stream?> GetFileStreamAsync(string filePath);

        /// <summary>
        /// File exists
        /// </summary>
        Task<bool> FileExistsAsync(string filePath);

        /// <summary>
        /// Get file info
        /// </summary>
        Task<FileInfo?> GetFileInfoAsync(string filePath);

        /// <summary>
        /// Copy file
        /// </summary>
        Task<bool> CopyFileAsync(string sourcePath, string destinationPath);

        /// <summary>
        /// Move file
        /// </summary>
        Task<bool> MoveFileAsync(string sourcePath, string destinationPath);
    }
}