using WebQuanLyGiaiDau_NhomTD.Models.Email;

namespace WebQuanLyGiaiDau_NhomTD.Services.Interfaces
{
    /// <summary>
    /// Interface cho Email Service
    /// </summary>
    public interface IEmailService
    {
        /// <summary>
        /// Gửi email đơn giản
        /// </summary>
        Task<EmailResult> SendEmailAsync(string to, string subject, string body, bool isHtml = true);

        /// <summary>
        /// Gửi email với thông tin chi tiết
        /// </summary>
        Task<EmailResult> SendEmailAsync(EmailMessage message);

        /// <summary>
        /// Gửi email từ template
        /// </summary>
        Task<EmailResult> SendEmailFromTemplateAsync(string to, string templateName, Dictionary<string, object> variables);

        /// <summary>
        /// Gửi email hàng loạt
        /// </summary>
        Task<List<EmailResult>> SendBulkEmailAsync(List<EmailMessage> messages);

        /// <summary>
        /// Kiểm tra cấu hình email
        /// </summary>
        Task<bool> TestConnectionAsync();

        /// <summary>
        /// Lấy template email theo tên
        /// </summary>
        EmailTemplate? GetTemplate(string templateName);

        /// <summary>
        /// Đăng ký template email mới
        /// </summary>
        void RegisterTemplate(string name, EmailTemplate template);
    }

    /// <summary>
    /// Interface cho Template Engine
    /// </summary>
    public interface IEmailTemplateEngine
    {
        /// <summary>
        /// Render template với variables
        /// </summary>
        string RenderTemplate(string template, Dictionary<string, object> variables);

        /// <summary>
        /// Render template file với variables
        /// </summary>
        Task<string> RenderTemplateFromFileAsync(string templatePath, Dictionary<string, object> variables);

        /// <summary>
        /// Validate template syntax
        /// </summary>
        bool ValidateTemplate(string template);

        /// <summary>
        /// Extract variables from template
        /// </summary>
        List<string> ExtractVariables(string template);
    }
}