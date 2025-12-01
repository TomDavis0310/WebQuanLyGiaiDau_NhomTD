using Microsoft.AspNetCore.Identity.UI.Services;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;
using WebQuanLyGiaiDau_NhomTD.Models.Email;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    /// <summary>
    /// Mock Email Service for development - doesn't actually send emails
    /// </summary>
    public class MockEmailService : IEmailService, IEmailSender
    {
        private readonly ILogger<MockEmailService> _logger;
        private readonly Dictionary<string, EmailTemplate> _templates = new();

        public MockEmailService(ILogger<MockEmailService> logger)
        {
            _logger = logger;
        }

        // IEmailService implementation
        public Task<EmailResult> SendEmailAsync(string to, string subject, string body, bool isHtml = true)
        {
            _logger.LogInformation("📧 [MOCK EMAIL] Would send to: {To}", to);
            _logger.LogInformation("📧 [MOCK EMAIL] Subject: {Subject}", subject);
            _logger.LogDebug("📧 [MOCK EMAIL] Body: {Body}", body.Substring(0, Math.Min(100, body.Length)));
            
            return Task.FromResult(EmailResult.Success("mock-id", TimeSpan.Zero));
        }

        public Task<EmailResult> SendEmailAsync(EmailMessage message)
        {
             _logger.LogInformation("📧 [MOCK EMAIL] Would send to: {To}", message.To);
            _logger.LogInformation("📧 [MOCK EMAIL] Subject: {Subject}", message.Subject);
            
            return Task.FromResult(EmailResult.Success("mock-id", TimeSpan.Zero));
        }

        public Task<EmailResult> SendEmailFromTemplateAsync(string to, string templateName, Dictionary<string, object> variables)
        {
             _logger.LogInformation("📧 [MOCK EMAIL] Would send template '{Template}' to: {To}", templateName, to);
            return Task.FromResult(EmailResult.Success("mock-id", TimeSpan.Zero));
        }

        public Task<List<EmailResult>> SendBulkEmailAsync(List<EmailMessage> messages)
        {
            _logger.LogInformation("📧 [MOCK EMAIL] Would send {Count} bulk emails", messages.Count);
            var results = messages.Select(m => EmailResult.Success("mock-id", TimeSpan.Zero)).ToList();
            return Task.FromResult(results);
        }

        public Task<bool> TestConnectionAsync()
        {
            _logger.LogInformation("📧 [MOCK EMAIL] Connection test successful");
            return Task.FromResult(true);
        }

        public EmailTemplate? GetTemplate(string templateName)
        {
            return _templates.TryGetValue(templateName, out var template) ? template : null;
        }

        public void RegisterTemplate(string name, EmailTemplate template)
        {
            _templates[name] = template;
        }

        // IEmailSender implementation
        public Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            // Forward to the IEmailService implementation
            return SendEmailAsync(email, subject, htmlMessage, true);
        }
        
        // Legacy methods kept for compatibility if needed, but updated to match signatures if possible or just kept as overloads
        public Task<bool> SendEmailWithAttachmentsAsync(string to, string subject, string body, IEnumerable<string> attachmentPaths, bool isHtml = true)
        {
             _logger.LogInformation("📧 [MOCK EMAIL] Would send email with attachments to: {To}", to);
            return Task.FromResult(true);
        }

        public Task<bool> SendBulkEmailAsync(IEnumerable<string> recipients, string subject, string body, bool isHtml = true)
        {
             _logger.LogInformation("📧 [MOCK EMAIL] Would send bulk email to {Count} recipients", recipients?.Count() ?? 0);
            return Task.FromResult(true);
        }

        public Task<bool> SendTemplatedEmailAsync(string to, string subject, string templateName, Dictionary<string, string> replacements)
        {
             _logger.LogInformation("📧 [MOCK EMAIL] Would send templated email to: {To}", to);
            return Task.FromResult(true);
        }
    }
}
