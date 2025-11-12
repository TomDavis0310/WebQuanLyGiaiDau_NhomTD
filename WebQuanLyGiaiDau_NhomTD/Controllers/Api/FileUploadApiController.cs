using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebQuanLyGiaiDau_NhomTD.Models.FileUpload;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FileUploadApiController : ControllerBase
    {
        private readonly IFileUploadService _fileUploadService;
        private readonly ILogger<FileUploadApiController> _logger;

        public FileUploadApiController(IFileUploadService fileUploadService, ILogger<FileUploadApiController> logger)
        {
            _fileUploadService = fileUploadService;
            _logger = logger;
        }

        /// <summary>
        /// Upload single file
        /// </summary>
        [HttpPost("upload")]
        public async Task<IActionResult> UploadFile(IFormFile file, [FromQuery] string? category = null, [FromQuery] string? subFolder = null)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest(new { error = "No file provided" });

                var options = new FileUploadOptions
                {
                    Category = category ?? FileCategories.Attachments,
                    SubFolder = subFolder
                };

                var result = await _fileUploadService.UploadFileAsync(file, options);
                
                if (result.IsSuccess)
                {
                    return Ok(new
                    {
                        success = true,
                        file = new
                        {
                            id = result.FileInfo!.Id,
                            originalFileName = result.FileInfo.OriginalFileName,
                            fileName = result.FileInfo.FileName,
                            url = result.FileInfo.Url,
                            thumbnailUrl = result.FileInfo.ThumbnailUrl,
                            mimeType = result.FileInfo.MimeType,
                            fileSize = result.FileInfo.FileSize,
                            uploadedAt = result.FileInfo.UploadedAt
                        },
                        warnings = result.Warnings
                    });
                }
                else
                {
                    return BadRequest(new { success = false, error = result.ErrorMessage });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading file");
                return StatusCode(500, new { error = "Failed to upload file", details = ex.Message });
            }
        }

        /// <summary>
        /// Upload multiple files
        /// </summary>
        [HttpPost("upload-multiple")]
        public async Task<IActionResult> UploadFiles(List<IFormFile> files, [FromQuery] string? category = null, [FromQuery] string? subFolder = null)
        {
            try
            {
                if (files == null || !files.Any())
                    return BadRequest(new { error = "No files provided" });

                var options = new FileUploadOptions
                {
                    Category = category ?? FileCategories.Attachments,
                    SubFolder = subFolder
                };

                var results = await _fileUploadService.UploadFilesAsync(files, options);
                
                var successful = results.Where(r => r.IsSuccess).ToList();
                var failed = results.Where(r => !r.IsSuccess).ToList();

                return Ok(new
                {
                    success = true,
                    total = results.Count,
                    successful = successful.Count,
                    failed = failed.Count,
                    files = successful.Select(r => new
                    {
                        id = r.FileInfo!.Id,
                        originalFileName = r.FileInfo.OriginalFileName,
                        fileName = r.FileInfo.FileName,
                        url = r.FileInfo.Url,
                        thumbnailUrl = r.FileInfo.ThumbnailUrl,
                        mimeType = r.FileInfo.MimeType,
                        fileSize = r.FileInfo.FileSize,
                        uploadedAt = r.FileInfo.UploadedAt
                    }),
                    errors = failed.Select(r => r.ErrorMessage)
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading multiple files");
                return StatusCode(500, new { error = "Failed to upload files", details = ex.Message });
            }
        }

        /// <summary>
        /// Get file info
        /// </summary>
        [HttpGet("info/{fileId}")]
        public async Task<IActionResult> GetFileInfo(string fileId)
        {
            try
            {
                var fileInfo = await _fileUploadService.GetFileInfoAsync(fileId);
                if (fileInfo == null)
                    return NotFound(new { error = "File not found" });

                return Ok(new
                {
                    id = fileInfo.Id,
                    originalFileName = fileInfo.OriginalFileName,
                    fileName = fileInfo.FileName,
                    url = fileInfo.Url,
                    thumbnailUrl = fileInfo.ThumbnailUrl,
                    mimeType = fileInfo.MimeType,
                    extension = fileInfo.Extension,
                    fileSize = fileInfo.FileSize,
                    category = fileInfo.Category,
                    uploadedAt = fileInfo.UploadedAt,
                    metadata = fileInfo.Metadata
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting file info: {FileId}", fileId);
                return StatusCode(500, new { error = "Failed to get file info", details = ex.Message });
            }
        }

        /// <summary>
        /// Download file
        /// </summary>
        [HttpGet("download/{fileId}")]
        public async Task<IActionResult> DownloadFile(string fileId)
        {
            try
            {
                var fileInfo = await _fileUploadService.GetFileInfoAsync(fileId);
                if (fileInfo == null)
                    return NotFound(new { error = "File not found" });

                var fileStream = await _fileUploadService.GetFileStreamAsync(fileId);
                if (fileStream == null)
                    return NotFound(new { error = "File content not found" });

                return File(fileStream, fileInfo.MimeType, fileInfo.OriginalFileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error downloading file: {FileId}", fileId);
                return StatusCode(500, new { error = "Failed to download file", details = ex.Message });
            }
        }

        /// <summary>
        /// Delete file
        /// </summary>
        [HttpDelete("{fileId}")]
        [Authorize(Roles = "Admin,Organizer")]
        public async Task<IActionResult> DeleteFile(string fileId)
        {
            try
            {
                var deleted = await _fileUploadService.DeleteFileAsync(fileId);
                if (deleted)
                {
                    return Ok(new { success = true, message = "File deleted successfully" });
                }
                else
                {
                    return NotFound(new { success = false, error = "File not found" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting file: {FileId}", fileId);
                return StatusCode(500, new { error = "Failed to delete file", details = ex.Message });
            }
        }

        /// <summary>
        /// Get files by category
        /// </summary>
        [HttpGet("category/{category}")]
        public async Task<IActionResult> GetFilesByCategory(string category, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var files = await _fileUploadService.GetFilesByCategoryAsync(category);
                var totalFiles = files.Count;
                var pagedFiles = files
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(f => new
                    {
                        id = f.Id,
                        originalFileName = f.OriginalFileName,
                        fileName = f.FileName,
                        url = f.Url,
                        thumbnailUrl = f.ThumbnailUrl,
                        mimeType = f.MimeType,
                        fileSize = f.FileSize,
                        uploadedAt = f.UploadedAt
                    })
                    .ToList();

                return Ok(new
                {
                    files = pagedFiles,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalFiles,
                        totalPages = (int)Math.Ceiling((double)totalFiles / pageSize)
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting files by category: {Category}", category);
                return StatusCode(500, new { error = "Failed to get files", details = ex.Message });
            }
        }

        /// <summary>
        /// Generate thumbnail for existing image
        /// </summary>
        [HttpPost("thumbnail/{fileId}")]
        [Authorize(Roles = "Admin,Organizer")]
        public async Task<IActionResult> GenerateThumbnail(string fileId, [FromQuery] int width = 300, [FromQuery] int height = 300)
        {
            try
            {
                var fileInfo = await _fileUploadService.GetFileInfoAsync(fileId);
                if (fileInfo == null)
                    return NotFound(new { error = "File not found" });

                var thumbnailPath = await _fileUploadService.GenerateThumbnailAsync(fileInfo.FilePath, width, height);
                if (thumbnailPath == null)
                    return BadRequest(new { error = "Failed to generate thumbnail. File may not be an image." });

                return Ok(new
                {
                    success = true,
                    thumbnailPath,
                    message = "Thumbnail generated successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating thumbnail for file: {FileId}", fileId);
                return StatusCode(500, new { error = "Failed to generate thumbnail", details = ex.Message });
            }
        }

        /// <summary>
        /// Copy file
        /// </summary>
        [HttpPost("copy/{fileId}")]
        [Authorize(Roles = "Admin,Organizer")]
        public async Task<IActionResult> CopyFile(string fileId, [FromQuery] string? category = null, [FromQuery] string? subFolder = null)
        {
            try
            {
                var options = new FileUploadOptions
                {
                    Category = category,
                    SubFolder = subFolder
                };

                var result = await _fileUploadService.CopyFileAsync(fileId, options);
                
                if (result.IsSuccess)
                {
                    return Ok(new
                    {
                        success = true,
                        file = new
                        {
                            id = result.FileInfo!.Id,
                            originalFileName = result.FileInfo.OriginalFileName,
                            fileName = result.FileInfo.FileName,
                            url = result.FileInfo.Url,
                            thumbnailUrl = result.FileInfo.ThumbnailUrl,
                            uploadedAt = result.FileInfo.UploadedAt
                        },
                        message = "File copied successfully"
                    });
                }
                else
                {
                    return BadRequest(new { success = false, error = result.ErrorMessage });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error copying file: {FileId}", fileId);
                return StatusCode(500, new { error = "Failed to copy file", details = ex.Message });
            }
        }

        /// <summary>
        /// Move file to different category
        /// </summary>
        [HttpPut("move/{fileId}")]
        [Authorize(Roles = "Admin,Organizer")]
        public async Task<IActionResult> MoveFile(string fileId, [FromQuery] string newCategory)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(newCategory))
                    return BadRequest(new { error = "New category is required" });

                var success = await _fileUploadService.MoveFileAsync(fileId, newCategory);
                if (success)
                {
                    return Ok(new { success = true, message = "File moved successfully" });
                }
                else
                {
                    return NotFound(new { success = false, error = "File not found or failed to move" });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error moving file: {FileId} to category {NewCategory}", fileId, newCategory);
                return StatusCode(500, new { error = "Failed to move file", details = ex.Message });
            }
        }

        /// <summary>
        /// Clean up temp files
        /// </summary>
        [HttpPost("cleanup")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> CleanupTempFiles([FromQuery] int olderThanHours = 24)
        {
            try
            {
                await _fileUploadService.CleanupTempFilesAsync(TimeSpan.FromHours(olderThanHours));
                return Ok(new { success = true, message = $"Cleaned up temp files older than {olderThanHours} hours" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cleaning up temp files");
                return StatusCode(500, new { error = "Failed to cleanup temp files", details = ex.Message });
            }
        }

        /// <summary>
        /// Validate file before upload
        /// </summary>
        [HttpPost("validate")]
        public IActionResult ValidateFile(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest(new { valid = false, errors = new[] { "No file provided" } });

                var isValid = _fileUploadService.ValidateFile(file, out var errors);
                
                return Ok(new
                {
                    valid = isValid,
                    errors = errors,
                    fileInfo = new
                    {
                        fileName = file.FileName,
                        size = file.Length,
                        mimeType = file.ContentType
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating file");
                return StatusCode(500, new { error = "Failed to validate file", details = ex.Message });
            }
        }
    }
}