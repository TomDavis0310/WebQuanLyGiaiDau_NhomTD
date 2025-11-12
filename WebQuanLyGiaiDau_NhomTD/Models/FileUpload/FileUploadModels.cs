namespace WebQuanLyGiaiDau_NhomTD.Models.FileUpload
{
    /// <summary>
    /// Cấu hình cho File Upload
    /// </summary>
    public class FileUploadConfiguration
    {
        public string UploadPath { get; set; } = "wwwroot/uploads";
        public string TempPath { get; set; } = "wwwroot/temp";
        public long MaxFileSize { get; set; } = 10 * 1024 * 1024; // 10MB
        public List<string> AllowedExtensions { get; set; } = new();
        public List<string> AllowedMimeTypes { get; set; } = new();
        public bool EnableVirusScan { get; set; } = false;
        public bool GenerateThumbnails { get; set; } = true;
        public bool EnableCompression { get; set; } = true;
        public int ThumbnailWidth { get; set; } = 300;
        public int ThumbnailHeight { get; set; } = 300;
        public int ImageMaxWidth { get; set; } = 1920;
        public int ImageMaxHeight { get; set; } = 1080;
        public string BaseUrl { get; set; } = "/uploads";
    }

    /// <summary>
    /// Thông tin file được upload
    /// </summary>
    public class UploadedFileInfo
    {
        public string Id { get; set; } = Guid.NewGuid().ToString();
        public string OriginalFileName { get; set; } = string.Empty;
        public string FileName { get; set; } = string.Empty;
        public string FilePath { get; set; } = string.Empty;
        public string MimeType { get; set; } = string.Empty;
        public string Extension { get; set; } = string.Empty;
        public long FileSize { get; set; }
        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
        public string? ThumbnailPath { get; set; }
        public string? Category { get; set; }
        public string? Description { get; set; }
        public Dictionary<string, object> Metadata { get; set; } = new();
        public string Url { get; set; } = string.Empty;
        public string? ThumbnailUrl { get; set; }
    }

    /// <summary>
    /// Kết quả upload file
    /// </summary>
    public class FileUploadResult
    {
        public bool IsSuccess { get; set; }
        public string? ErrorMessage { get; set; }
        public UploadedFileInfo? FileInfo { get; set; }
        public List<string> Warnings { get; set; } = new();

        public static FileUploadResult Success(UploadedFileInfo fileInfo)
            => new() { IsSuccess = true, FileInfo = fileInfo };

        public static FileUploadResult Success(UploadedFileInfo fileInfo, List<string> warnings)
            => new() { IsSuccess = true, FileInfo = fileInfo, Warnings = warnings };

        public static FileUploadResult Failure(string errorMessage)
            => new() { IsSuccess = false, ErrorMessage = errorMessage };
    }

    /// <summary>
    /// Options cho upload file
    /// </summary>
    public class FileUploadOptions
    {
        public string? Category { get; set; }
        public string? SubFolder { get; set; }
        public bool GenerateThumbnail { get; set; } = true;
        public bool CompressImage { get; set; } = true;
        public bool PreserveName { get; set; } = false;
        public Dictionary<string, object> Metadata { get; set; } = new();
        public int? MaxWidth { get; set; }
        public int? MaxHeight { get; set; }
        public int? ThumbnailWidth { get; set; }
        public int? ThumbnailHeight { get; set; }
    }

    /// <summary>
    /// File types được hỗ trợ
    /// </summary>
    public static class FileTypes
    {
        public static class Images
        {
            public const string JPEG = ".jpg";
            public const string JPG = ".jpeg"; 
            public const string PNG = ".png";
            public const string GIF = ".gif";
            public const string WEBP = ".webp";
            public const string BMP = ".bmp";
            public const string SVG = ".svg";

            public static readonly List<string> All = new() 
            { JPEG, JPG, PNG, GIF, WEBP, BMP, SVG };

            public static readonly List<string> MimeTypes = new()
            {
                "image/jpeg", "image/jpg", "image/png", "image/gif",
                "image/webp", "image/bmp", "image/svg+xml"
            };
        }

        public static class Documents
        {
            public const string PDF = ".pdf";
            public const string DOC = ".doc";
            public const string DOCX = ".docx";
            public const string XLS = ".xls";
            public const string XLSX = ".xlsx";
            public const string PPT = ".ppt";
            public const string PPTX = ".pptx";
            public const string TXT = ".txt";

            public static readonly List<string> All = new() 
            { PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, TXT };

            public static readonly List<string> MimeTypes = new()
            {
                "application/pdf",
                "application/msword",
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                "application/vnd.ms-excel",
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "application/vnd.ms-powerpoint",
                "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                "text/plain"
            };
        }

        public static class Videos
        {
            public const string MP4 = ".mp4";
            public const string AVI = ".avi";
            public const string MOV = ".mov";
            public const string WMV = ".wmv";
            public const string FLV = ".flv";
            public const string WEBM = ".webm";

            public static readonly List<string> All = new() 
            { MP4, AVI, MOV, WMV, FLV, WEBM };

            public static readonly List<string> MimeTypes = new()
            {
                "video/mp4", "video/avi", "video/quicktime",
                "video/x-ms-wmv", "video/x-flv", "video/webm"
            };
        }

        public static class Audio
        {
            public const string MP3 = ".mp3";
            public const string WAV = ".wav";
            public const string OGG = ".ogg";
            public const string M4A = ".m4a";

            public static readonly List<string> All = new() 
            { MP3, WAV, OGG, M4A };

            public static readonly List<string> MimeTypes = new()
            {
                "audio/mpeg", "audio/wav", "audio/ogg", "audio/mp4"
            };
        }
    }

    /// <summary>
    /// File categories
    /// </summary>
    public static class FileCategories
    {
        public const string ProfileImages = "profile-images";
        public const string TournamentImages = "tournament-images";
        public const string TeamLogos = "team-logos";
        public const string NewsImages = "news-images";
        public const string Documents = "documents";
        public const string Attachments = "attachments";
        public const string Temp = "temp";
    }
}