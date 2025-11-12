using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Formats.Jpeg;
using System.Text.Json;
using WebQuanLyGiaiDau_NhomTD.Models.FileUpload;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    /// <summary>
    /// Local File Storage Provider
    /// </summary>
    public class LocalFileStorageProvider : IFileStorageProvider
    {
        private readonly FileUploadConfiguration _config;
        private readonly ILogger<LocalFileStorageProvider> _logger;

        public LocalFileStorageProvider(FileUploadConfiguration config, ILogger<LocalFileStorageProvider> logger)
        {
            _config = config;
            _logger = logger;
            EnsureDirectoriesExist();
        }

        public async Task<string> SaveFileAsync(Stream fileStream, string fileName, string category)
        {
            try
            {
                var categoryPath = Path.Combine(_config.UploadPath, category);
                Directory.CreateDirectory(categoryPath);

                var filePath = Path.Combine(categoryPath, fileName);
                
                using var fileStreamWriter = new FileStream(filePath, FileMode.Create);
                await fileStream.CopyToAsync(fileStreamWriter);
                
                _logger.LogInformation("File saved: {FilePath}", filePath);
                return filePath;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving file: {FileName}", fileName);
                throw;
            }
        }

        public async Task<bool> DeleteFileAsync(string filePath)
        {
            try
            {
                if (await FileExistsAsync(filePath))
                {
                    File.Delete(filePath);
                    _logger.LogInformation("File deleted: {FilePath}", filePath);
                    return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting file: {FilePath}", filePath);
                return false;
            }
        }

        public async Task<Stream?> GetFileStreamAsync(string filePath)
        {
            try
            {
                if (await FileExistsAsync(filePath))
                {
                    return new FileStream(filePath, FileMode.Open, FileAccess.Read);
                }
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting file stream: {FilePath}", filePath);
                return null;
            }
        }

        public async Task<bool> FileExistsAsync(string filePath)
        {
            return await Task.FromResult(File.Exists(filePath));
        }

        public async Task<FileInfo?> GetFileInfoAsync(string filePath)
        {
            try
            {
                if (await FileExistsAsync(filePath))
                {
                    return new FileInfo(filePath);
                }
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting file info: {FilePath}", filePath);
                return null;
            }
        }

        public async Task<bool> CopyFileAsync(string sourcePath, string destinationPath)
        {
            try
            {
                if (!await FileExistsAsync(sourcePath))
                    return false;

                var destDir = Path.GetDirectoryName(destinationPath);
                if (!string.IsNullOrEmpty(destDir))
                    Directory.CreateDirectory(destDir);

                File.Copy(sourcePath, destinationPath, true);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error copying file from {Source} to {Destination}", sourcePath, destinationPath);
                return false;
            }
        }

        public async Task<bool> MoveFileAsync(string sourcePath, string destinationPath)
        {
            try
            {
                if (!await FileExistsAsync(sourcePath))
                    return false;

                var destDir = Path.GetDirectoryName(destinationPath);
                if (!string.IsNullOrEmpty(destDir))
                    Directory.CreateDirectory(destDir);

                File.Move(sourcePath, destinationPath, true);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error moving file from {Source} to {Destination}", sourcePath, destinationPath);
                return false;
            }
        }

        private void EnsureDirectoriesExist()
        {
            Directory.CreateDirectory(_config.UploadPath);
            Directory.CreateDirectory(_config.TempPath);
        }
    }

    /// <summary>
    /// File Upload Service implementation
    /// </summary>
    public class FileUploadService : IFileUploadService
    {
        private readonly FileUploadConfiguration _config;
        private readonly IFileStorageProvider _storageProvider;
        private readonly ILogger<FileUploadService> _logger;
        private readonly Dictionary<string, UploadedFileInfo> _fileIndex;
        private readonly string _indexFilePath;

        public FileUploadService(
            IConfiguration configuration,
            IFileStorageProvider storageProvider,
            ILogger<FileUploadService> logger)
        {
            _config = configuration.GetSection("FileUpload").Get<FileUploadConfiguration>() ?? new FileUploadConfiguration();
            _storageProvider = storageProvider;
            _logger = logger;
            _fileIndex = new Dictionary<string, UploadedFileInfo>();
            _indexFilePath = Path.Combine(_config.UploadPath, "file-index.json");
            LoadFileIndex();
        }

        public async Task<FileUploadResult> UploadFileAsync(IFormFile file, FileUploadOptions? options = null)
        {
            try
            {
                if (!ValidateFile(file, out var errors))
                {
                    return FileUploadResult.Failure(string.Join("; ", errors));
                }

                options ??= new FileUploadOptions();
                var warnings = new List<string>();

                // Generate unique file name
                var fileExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
                var fileName = options.PreserveName 
                    ? SanitizeFileName(file.FileName)
                    : $"{Guid.NewGuid()}{fileExtension}";

                // Determine category and subfolder
                var category = options.Category ?? FileCategories.Attachments;
                var fullCategory = string.IsNullOrEmpty(options.SubFolder) 
                    ? category 
                    : Path.Combine(category, options.SubFolder);

                // Save original file
                string filePath;
                using (var stream = file.OpenReadStream())
                {
                    filePath = await _storageProvider.SaveFileAsync(stream, fileName, fullCategory);
                }

                // Create file info
                var fileInfo = new UploadedFileInfo
                {
                    Id = Guid.NewGuid().ToString(),
                    OriginalFileName = file.FileName,
                    FileName = fileName,
                    FilePath = filePath,
                    MimeType = file.ContentType,
                    Extension = fileExtension,
                    FileSize = file.Length,
                    Category = category,
                    Metadata = new Dictionary<string, object>(options.Metadata),
                    Url = GetFileUrl(fullCategory, fileName)
                };

                // Process image if applicable
                if (IsImageFile(fileExtension))
                {
                    await ProcessImageAsync(fileInfo, options, warnings);
                }

                // Save to index
                _fileIndex[fileInfo.Id] = fileInfo;
                await SaveFileIndex();

                _logger.LogInformation("File uploaded successfully: {FileName} -> {FilePath}", file.FileName, filePath);
                
                return warnings.Any() 
                    ? FileUploadResult.Success(fileInfo, warnings)
                    : FileUploadResult.Success(fileInfo);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading file: {FileName}", file.FileName);
                return FileUploadResult.Failure($"Upload failed: {ex.Message}");
            }
        }

        public async Task<List<FileUploadResult>> UploadFilesAsync(IEnumerable<IFormFile> files, FileUploadOptions? options = null)
        {
            var results = new List<FileUploadResult>();
            
            foreach (var file in files)
            {
                var result = await UploadFileAsync(file, options);
                results.Add(result);
            }

            return results;
        }

        public async Task<FileUploadResult> UploadFileAsync(byte[] fileBytes, string fileName, string mimeType, FileUploadOptions? options = null)
        {
            using var stream = new MemoryStream(fileBytes);
            return await UploadFileAsync(stream, fileName, mimeType, options);
        }

        public async Task<FileUploadResult> UploadFileAsync(Stream fileStream, string fileName, string mimeType, FileUploadOptions? options = null)
        {
            try
            {
                options ??= new FileUploadOptions();

                // Validate file size
                if (fileStream.Length > _config.MaxFileSize)
                {
                    return FileUploadResult.Failure($"File size ({fileStream.Length} bytes) exceeds maximum allowed size ({_config.MaxFileSize} bytes)");
                }

                // Validate file type
                if (!IsValidFile(fileName, mimeType))
                {
                    return FileUploadResult.Failure($"File type not allowed: {mimeType}");
                }

                var fileExtension = Path.GetExtension(fileName).ToLowerInvariant();
                var generatedFileName = options.PreserveName 
                    ? SanitizeFileName(fileName)
                    : $"{Guid.NewGuid()}{fileExtension}";

                var category = options.Category ?? FileCategories.Attachments;
                var fullCategory = string.IsNullOrEmpty(options.SubFolder) 
                    ? category 
                    : Path.Combine(category, options.SubFolder);

                var filePath = await _storageProvider.SaveFileAsync(fileStream, generatedFileName, fullCategory);

                var fileInfo = new UploadedFileInfo
                {
                    Id = Guid.NewGuid().ToString(),
                    OriginalFileName = fileName,
                    FileName = generatedFileName,
                    FilePath = filePath,
                    MimeType = mimeType,
                    Extension = fileExtension,
                    FileSize = fileStream.Length,
                    Category = category,
                    Metadata = new Dictionary<string, object>(options.Metadata),
                    Url = GetFileUrl(fullCategory, generatedFileName)
                };

                // Save to index
                _fileIndex[fileInfo.Id] = fileInfo;
                await SaveFileIndex();

                return FileUploadResult.Success(fileInfo);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading file from stream: {FileName}", fileName);
                return FileUploadResult.Failure($"Upload failed: {ex.Message}");
            }
        }

        public async Task<bool> DeleteFileAsync(string fileId)
        {
            try
            {
                if (!_fileIndex.TryGetValue(fileId, out var fileInfo))
                {
                    _logger.LogWarning("File not found in index: {FileId}", fileId);
                    return false;
                }

                // Delete main file
                var deleted = await _storageProvider.DeleteFileAsync(fileInfo.FilePath);
                
                // Delete thumbnail if exists
                if (!string.IsNullOrEmpty(fileInfo.ThumbnailPath))
                {
                    await _storageProvider.DeleteFileAsync(fileInfo.ThumbnailPath);
                }

                // Remove from index
                _fileIndex.Remove(fileId);
                await SaveFileIndex();

                _logger.LogInformation("File deleted: {FileId} -> {FilePath}", fileId, fileInfo.FilePath);
                return deleted;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting file: {FileId}", fileId);
                return false;
            }
        }

        public async Task<bool> DeleteFileByPathAsync(string filePath)
        {
            try
            {
                // Find file in index by path
                var fileInfo = _fileIndex.Values.FirstOrDefault(f => f.FilePath == filePath);
                if (fileInfo != null)
                {
                    return await DeleteFileAsync(fileInfo.Id);
                }

                // If not in index, delete directly
                return await _storageProvider.DeleteFileAsync(filePath);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting file by path: {FilePath}", filePath);
                return false;
            }
        }

        public async Task<UploadedFileInfo?> GetFileInfoAsync(string fileId)
        {
            return await Task.FromResult(_fileIndex.TryGetValue(fileId, out var fileInfo) ? fileInfo : null);
        }

        public async Task<byte[]?> GetFileContentAsync(string fileId)
        {
            try
            {
                var fileInfo = await GetFileInfoAsync(fileId);
                if (fileInfo == null) return null;

                using var stream = await _storageProvider.GetFileStreamAsync(fileInfo.FilePath);
                if (stream == null) return null;

                using var memoryStream = new MemoryStream();
                await stream.CopyToAsync(memoryStream);
                return memoryStream.ToArray();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting file content: {FileId}", fileId);
                return null;
            }
        }

        public async Task<Stream?> GetFileStreamAsync(string fileId)
        {
            try
            {
                var fileInfo = await GetFileInfoAsync(fileId);
                if (fileInfo == null) return null;

                return await _storageProvider.GetFileStreamAsync(fileInfo.FilePath);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting file stream: {FileId}", fileId);
                return null;
            }
        }

        public bool ValidateFile(IFormFile file, out List<string> errors)
        {
            errors = new List<string>();

            if (file == null || file.Length == 0)
            {
                errors.Add("File is empty or null");
                return false;
            }

            if (file.Length > _config.MaxFileSize)
            {
                errors.Add($"File size ({file.Length} bytes) exceeds maximum allowed size ({_config.MaxFileSize} bytes)");
            }

            if (!IsValidFile(file.FileName, file.ContentType))
            {
                errors.Add($"File type not allowed: {file.ContentType}");
            }

            return !errors.Any();
        }

        public bool IsValidFile(string fileName, string mimeType)
        {
            var extension = Path.GetExtension(fileName).ToLowerInvariant();
            
            var isValidExtension = _config.AllowedExtensions.Any() 
                ? _config.AllowedExtensions.Contains(extension)
                : true;

            var isValidMimeType = _config.AllowedMimeTypes.Any()
                ? _config.AllowedMimeTypes.Contains(mimeType)
                : true;

            return isValidExtension && isValidMimeType;
        }

        public async Task<string?> GenerateThumbnailAsync(string imagePath, int width = 300, int height = 300)
        {
            try
            {
                if (!await _storageProvider.FileExistsAsync(imagePath))
                    return null;

                var thumbnailFileName = $"thumb_{width}x{height}_{Path.GetFileName(imagePath)}";
                var thumbnailPath = Path.Combine(Path.GetDirectoryName(imagePath) ?? "", "thumbnails", thumbnailFileName);
                
                var thumbnailDir = Path.GetDirectoryName(thumbnailPath);
                if (!string.IsNullOrEmpty(thumbnailDir))
                    Directory.CreateDirectory(thumbnailDir);

                using var inputStream = await _storageProvider.GetFileStreamAsync(imagePath);
                if (inputStream == null) return null;

                using var image = await Image.LoadAsync(inputStream);
                image.Mutate(x => x.Resize(width, height, KnownResamplers.Lanczos3));

                await image.SaveAsJpegAsync(thumbnailPath, new JpegEncoder { Quality = 85 });

                _logger.LogDebug("Thumbnail generated: {ThumbnailPath}", thumbnailPath);
                return thumbnailPath;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating thumbnail: {ImagePath}", imagePath);
                return null;
            }
        }

        public async Task<string?> ResizeImageAsync(string imagePath, int maxWidth, int maxHeight)
        {
            try
            {
                if (!await _storageProvider.FileExistsAsync(imagePath))
                    return null;

                using var inputStream = await _storageProvider.GetFileStreamAsync(imagePath);
                if (inputStream == null) return null;

                using var image = await Image.LoadAsync(inputStream);
                
                var originalWidth = image.Width;
                var originalHeight = image.Height;

                // Calculate new dimensions while maintaining aspect ratio
                var ratio = Math.Min((double)maxWidth / originalWidth, (double)maxHeight / originalHeight);
                if (ratio >= 1) return imagePath; // No need to resize

                var newWidth = (int)(originalWidth * ratio);
                var newHeight = (int)(originalHeight * ratio);

                image.Mutate(x => x.Resize(newWidth, newHeight, KnownResamplers.Lanczos3));

                // Save resized image
                var resizedPath = Path.ChangeExtension(imagePath, null) + "_resized" + Path.GetExtension(imagePath);
                await image.SaveAsJpegAsync(resizedPath, new JpegEncoder { Quality = 90 });

                // Replace original if configured
                if (_config.EnableCompression)
                {
                    File.Delete(imagePath);
                    File.Move(resizedPath, imagePath);
                    return imagePath;
                }

                return resizedPath;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error resizing image: {ImagePath}", imagePath);
                return null;
            }
        }

        public async Task CleanupTempFilesAsync(TimeSpan olderThan)
        {
            try
            {
                var tempFiles = Directory.GetFiles(_config.TempPath, "*", SearchOption.AllDirectories);
                var cutoffTime = DateTime.UtcNow - olderThan;
                var deletedCount = 0;

                foreach (var file in tempFiles)
                {
                    var fileInfo = new FileInfo(file);
                    if (fileInfo.CreationTimeUtc < cutoffTime)
                    {
                        try
                        {
                            File.Delete(file);
                            deletedCount++;
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Failed to delete temp file: {FilePath}", file);
                        }
                    }
                }

                _logger.LogInformation("Cleaned up {DeletedCount} temp files older than {OlderThan}", deletedCount, olderThan);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cleaning up temp files");
            }
        }

        public async Task<List<UploadedFileInfo>> GetFilesByCategoryAsync(string category)
        {
            return await Task.FromResult(_fileIndex.Values
                .Where(f => f.Category?.Equals(category, StringComparison.OrdinalIgnoreCase) == true)
                .OrderByDescending(f => f.UploadedAt)
                .ToList());
        }

        public async Task<FileUploadResult> CopyFileAsync(string sourceFileId, FileUploadOptions? options = null)
        {
            try
            {
                var sourceFileInfo = await GetFileInfoAsync(sourceFileId);
                if (sourceFileInfo == null)
                    return FileUploadResult.Failure("Source file not found");

                var sourceBytes = await GetFileContentAsync(sourceFileId);
                if (sourceBytes == null)
                    return FileUploadResult.Failure("Could not read source file");

                return await UploadFileAsync(sourceBytes, sourceFileInfo.OriginalFileName, sourceFileInfo.MimeType, options);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error copying file: {SourceFileId}", sourceFileId);
                return FileUploadResult.Failure($"Copy failed: {ex.Message}");
            }
        }

        public async Task<bool> MoveFileAsync(string fileId, string newCategory)
        {
            try
            {
                var fileInfo = await GetFileInfoAsync(fileId);
                if (fileInfo == null) return false;

                var newFileName = Path.GetFileName(fileInfo.FilePath);
                var newFilePath = Path.Combine(_config.UploadPath, newCategory, newFileName);
                
                var success = await _storageProvider.MoveFileAsync(fileInfo.FilePath, newFilePath);
                if (success)
                {
                    fileInfo.FilePath = newFilePath;
                    fileInfo.Category = newCategory;
                    fileInfo.Url = GetFileUrl(newCategory, newFileName);
                    await SaveFileIndex();
                }

                return success;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error moving file: {FileId} to category {NewCategory}", fileId, newCategory);
                return false;
            }
        }

        private async Task ProcessImageAsync(UploadedFileInfo fileInfo, FileUploadOptions options, List<string> warnings)
        {
            try
            {
                // Resize image if needed
                var maxWidth = options.MaxWidth ?? _config.ImageMaxWidth;
                var maxHeight = options.MaxHeight ?? _config.ImageMaxHeight;
                
                if (_config.EnableCompression && (maxWidth > 0 || maxHeight > 0))
                {
                    var resizedPath = await ResizeImageAsync(fileInfo.FilePath, maxWidth, maxHeight);
                    if (resizedPath != null && resizedPath != fileInfo.FilePath)
                    {
                        warnings.Add($"Image was resized to fit within {maxWidth}x{maxHeight} pixels");
                    }
                }

                // Generate thumbnail
                if (_config.GenerateThumbnails && options.GenerateThumbnail)
                {
                    var thumbWidth = options.ThumbnailWidth ?? _config.ThumbnailWidth;
                    var thumbHeight = options.ThumbnailHeight ?? _config.ThumbnailHeight;
                    
                    var thumbnailPath = await GenerateThumbnailAsync(fileInfo.FilePath, thumbWidth, thumbHeight);
                    if (!string.IsNullOrEmpty(thumbnailPath))
                    {
                        fileInfo.ThumbnailPath = thumbnailPath;
                        fileInfo.ThumbnailUrl = GetFileUrl(Path.GetDirectoryName(thumbnailPath)?.Replace(_config.UploadPath, "").Trim('\\', '/') ?? "", Path.GetFileName(thumbnailPath));
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Error processing image: {FilePath}", fileInfo.FilePath);
                warnings.Add("Image processing failed but file was uploaded successfully");
            }
        }

        private bool IsImageFile(string extension)
        {
            return FileTypes.Images.All.Contains(extension);
        }

        private string SanitizeFileName(string fileName)
        {
            var invalidChars = Path.GetInvalidFileNameChars();
            var sanitized = string.Join("_", fileName.Split(invalidChars, StringSplitOptions.RemoveEmptyEntries));
            return sanitized.Length > 100 ? sanitized[..100] + Path.GetExtension(fileName) : sanitized;
        }

        private string GetFileUrl(string category, string fileName)
        {
            return $"{_config.BaseUrl.TrimEnd('/')}/{category.Replace('\\', '/')}/{fileName}";
        }

        private void LoadFileIndex()
        {
            try
            {
                if (File.Exists(_indexFilePath))
                {
                    var json = File.ReadAllText(_indexFilePath);
                    var files = JsonSerializer.Deserialize<Dictionary<string, UploadedFileInfo>>(json);
                    if (files != null)
                    {
                        foreach (var kvp in files)
                        {
                            _fileIndex[kvp.Key] = kvp.Value;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading file index");
            }
        }

        private async Task SaveFileIndex()
        {
            try
            {
                var json = JsonSerializer.Serialize(_fileIndex, new JsonSerializerOptions { WriteIndented = true });
                await File.WriteAllTextAsync(_indexFilePath, json);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error saving file index");
            }
        }
    }
}