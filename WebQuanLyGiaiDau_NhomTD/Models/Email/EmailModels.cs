namespace WebQuanLyGiaiDau_NhomTD.Models.Email
{
    /// <summary>
    /// Model để cấu hình SMTP email
    /// </summary>
    public class EmailConfiguration
    {
        public string SmtpServer { get; set; } = string.Empty;
        public int SmtpPort { get; set; } = 587;
        public string SmtpUsername { get; set; } = string.Empty;
        public string SmtpPassword { get; set; } = string.Empty;
        public bool EnableSsl { get; set; } = true;
        public string FromEmail { get; set; } = string.Empty;
        public string FromName { get; set; } = string.Empty;
        public string ReplyToEmail { get; set; } = string.Empty;
        public string ReplyToName { get; set; } = string.Empty;
    }

    /// <summary>
    /// Model để gửi email
    /// </summary>
    public class EmailMessage
    {
        public string To { get; set; } = string.Empty;
        public string? ToName { get; set; }
        public string Subject { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public bool IsHtml { get; set; } = true;
        public List<string> Cc { get; set; } = new();
        public List<string> Bcc { get; set; } = new();
        public List<EmailAttachment> Attachments { get; set; } = new();
        public Dictionary<string, string> Tags { get; set; } = new();
        public EmailPriority Priority { get; set; } = EmailPriority.Normal;
    }

    /// <summary>
    /// Model cho file đính kèm
    /// </summary>
    public class EmailAttachment
    {
        public string FileName { get; set; } = string.Empty;
        public byte[] Content { get; set; } = Array.Empty<byte>();
        public string ContentType { get; set; } = "application/octet-stream";
        public bool IsInline { get; set; } = false;
        public string? ContentId { get; set; }
    }

    /// <summary>
    /// Mức độ ưu tiên email
    /// </summary>
    public enum EmailPriority
    {
        Low = 1,
        Normal = 2,
        High = 3,
        Urgent = 4
    }

    /// <summary>
    /// Kết quả gửi email
    /// </summary>
    public class EmailResult
    {
        public bool IsSuccess { get; set; }
        public string? ErrorMessage { get; set; }
        public string? MessageId { get; set; }
        public DateTime SentAt { get; set; }
        public TimeSpan Duration { get; set; }

        public static EmailResult Success(string messageId, TimeSpan duration)
            => new() { IsSuccess = true, MessageId = messageId, SentAt = DateTime.UtcNow, Duration = duration };

        public static EmailResult Failure(string errorMessage)
            => new() { IsSuccess = false, ErrorMessage = errorMessage, SentAt = DateTime.UtcNow };
    }

    /// <summary>
    /// Template email cho các mục đích khác nhau
    /// </summary>
    public class EmailTemplate
    {
        public string Name { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string HtmlBody { get; set; } = string.Empty;
        public string TextBody { get; set; } = string.Empty;
        public List<string> RequiredVariables { get; set; } = new();
        public Dictionary<string, object> DefaultVariables { get; set; } = new();
    }

    /// <summary>
    /// Email templates được định nghĩa sẵn
    /// </summary>
    public static class EmailTemplateNames
    {
        public const string WelcomeUser = "welcome-user";
        public const string ResetPassword = "reset-password";
        public const string EmailVerification = "email-verification";
        public const string TournamentRegistration = "tournament-registration";
        public const string TournamentReminder = "tournament-reminder";
        public const string MatchNotification = "match-notification";
        public const string TeamInvitation = "team-invitation";
        public const string NewsletterDigest = "newsletter-digest";
        public const string SystemNotification = "system-notification";
    }
}