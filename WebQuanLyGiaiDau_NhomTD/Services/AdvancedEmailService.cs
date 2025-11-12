using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using System.Diagnostics;
using System.Text.RegularExpressions;
using WebQuanLyGiaiDau_NhomTD.Models.Email;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.Extensions.Options;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    // Keep existing interfaces and services for backward compatibility
    public interface ITournamentEmailService
    {
        Task SendTeamRegistrationApprovedAsync(string userEmail, string userName, string teamName, string tournamentName);
        Task SendTeamRegistrationRejectedAsync(string userEmail, string userName, string teamName, string tournamentName, string reason);
        Task SendTeamRegistrationNotificationToAdminAsync(string teamName, string tournamentName, string userEmail, List<string> playerNames);
    }

    /// <summary>
    /// Email Template Engine để xử lý template variables
    /// </summary>
    public class EmailTemplateEngine : IEmailTemplateEngine
    {
        private readonly ILogger<EmailTemplateEngine> _logger;
        private static readonly Regex VariableRegex = new(@"\{\{(\w+)\}\}", RegexOptions.Compiled);

        public EmailTemplateEngine(ILogger<EmailTemplateEngine> logger)
        {
            _logger = logger;
        }

        public string RenderTemplate(string template, Dictionary<string, object> variables)
        {
            if (string.IsNullOrEmpty(template))
                return string.Empty;

            var result = template;

            foreach (var variable in variables)
            {
                var placeholder = $"{{{{{variable.Key}}}}}";
                var value = variable.Value?.ToString() ?? string.Empty;
                result = result.Replace(placeholder, value, StringComparison.OrdinalIgnoreCase);
            }

            // Log any unmatched variables
            var unmatchedVariables = VariableRegex.Matches(result)
                .Cast<Match>()
                .Select(m => m.Groups[1].Value)
                .Distinct()
                .ToList();

            if (unmatchedVariables.Any())
            {
                _logger.LogWarning("Unmatched template variables found: {Variables}", string.Join(", ", unmatchedVariables));
            }

            return result;
        }

        public async Task<string> RenderTemplateFromFileAsync(string templatePath, Dictionary<string, object> variables)
        {
            try
            {
                if (!File.Exists(templatePath))
                    throw new FileNotFoundException($"Template file not found: {templatePath}");

                var template = await File.ReadAllTextAsync(templatePath);
                return RenderTemplate(template, variables);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to render template from file: {TemplatePath}", templatePath);
                throw;
            }
        }

        public bool ValidateTemplate(string template)
        {
            return !string.IsNullOrEmpty(template);
        }

        public List<string> ExtractVariables(string template)
        {
            if (string.IsNullOrEmpty(template))
                return new List<string>();

            return VariableRegex.Matches(template)
                .Cast<Match>()
                .Select(m => m.Groups[1].Value)
                .Distinct()
                .ToList();
        }
    }

    /// <summary>
    /// Advanced Email Service with MailKit SMTP support and template engine
    /// </summary>
    public class AdvancedEmailService : IEmailService, IEmailSender
    {
        private readonly EmailConfiguration _configuration;
        private readonly IEmailTemplateEngine _templateEngine;
        private readonly ILogger<AdvancedEmailService> _logger;
        private readonly Dictionary<string, EmailTemplate> _templates;

        public AdvancedEmailService(
            IOptions<EmailConfiguration> configuration,
            IEmailTemplateEngine templateEngine,
            ILogger<AdvancedEmailService> logger)
        {
            _configuration = configuration.Value;
            _templateEngine = templateEngine;
            _logger = logger;
            _templates = new Dictionary<string, EmailTemplate>();

            InitializeDefaultTemplates();
        }

        public async Task<EmailResult> SendEmailAsync(string to, string subject, string body, bool isHtml = true)
        {
            var stopwatch = Stopwatch.StartNew();
            try
            {
                using var client = new SmtpClient();
                
                // Connect to SMTP server
                await client.ConnectAsync(_configuration.SmtpServer, _configuration.SmtpPort, SecureSocketOptions.StartTls);
                
                // Authenticate if credentials are provided
                if (!string.IsNullOrEmpty(_configuration.SmtpUsername) && !string.IsNullOrEmpty(_configuration.SmtpPassword))
                {
                    await client.AuthenticateAsync(_configuration.SmtpUsername, _configuration.SmtpPassword);
                }

                // Create message
                var mimeMessage = CreateMimeMessage(to, subject, body, isHtml);
                
                // Send message
                await client.SendAsync(mimeMessage);
                await client.DisconnectAsync(true);

                stopwatch.Stop();
                _logger.LogInformation("Email sent successfully to {ToEmail} in {ElapsedMs}ms", to, stopwatch.ElapsedMilliseconds);

                return EmailResult.Success("email-sent", stopwatch.Elapsed);
            }
            catch (Exception ex)
            {
                stopwatch.Stop();
                _logger.LogError(ex, "Failed to send email to {ToEmail}", to);
                
                return EmailResult.Failure($"Failed to send email: {ex.Message}");
            }
        }

        public async Task<EmailResult> SendEmailAsync(EmailMessage message)
        {
            return await SendEmailAsync(message.To, message.Subject, message.Body, message.IsHtml);
        }

        public async Task<EmailResult> SendEmailFromTemplateAsync(string to, string templateName, Dictionary<string, object> variables)
        {
            try
            {
                if (!_templates.TryGetValue(templateName, out var template))
                {
                    return EmailResult.Failure($"Template '{templateName}' not found");
                }

                // Validate required variables
                foreach (var requiredVar in template.RequiredVariables)
                {
                    if (!variables.ContainsKey(requiredVar))
                    {
                        return EmailResult.Failure($"Required variable '{requiredVar}' is missing");
                    }
                }

                var renderedSubject = _templateEngine.RenderTemplate(template.Subject, variables);
                var renderedBody = _templateEngine.RenderTemplate(template.HtmlBody, variables);

                return await SendEmailAsync(to, renderedSubject, renderedBody, true);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send email from template {TemplateName} to {ToEmail}", templateName, to);
                return EmailResult.Failure($"Failed to send email from template: {ex.Message}");
            }
        }

        public async Task<List<EmailResult>> SendBulkEmailAsync(List<EmailMessage> messages)
        {
            var results = new List<EmailResult>();
            var semaphore = new SemaphoreSlim(5, 5); // Max 5 concurrent emails
            var tasks = new List<Task<EmailResult>>();

            foreach (var message in messages)
            {
                tasks.Add(SendEmailWithSemaphoreAsync(message, semaphore));
            }

            results.AddRange(await Task.WhenAll(tasks));
            return results;
        }

        private async Task<EmailResult> SendEmailWithSemaphoreAsync(EmailMessage message, SemaphoreSlim semaphore)
        {
            await semaphore.WaitAsync();
            try
            {
                return await SendEmailAsync(message);
            }
            finally
            {
                semaphore.Release();
            }
        }

        public async Task<bool> TestConnectionAsync()
        {
            try
            {
                using var client = new SmtpClient();
                await client.ConnectAsync(_configuration.SmtpServer, _configuration.SmtpPort, SecureSocketOptions.StartTls);
                
                if (!string.IsNullOrEmpty(_configuration.SmtpUsername) && !string.IsNullOrEmpty(_configuration.SmtpPassword))
                {
                    await client.AuthenticateAsync(_configuration.SmtpUsername, _configuration.SmtpPassword);
                }
                
                await client.DisconnectAsync(true);
                
                _logger.LogInformation("SMTP connection test successful");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SMTP connection test failed");
                return false;
            }
        }

        public EmailTemplate? GetTemplate(string templateName)
        {
            _templates.TryGetValue(templateName, out var template);
            return template;
        }

        public void RegisterTemplate(string name, EmailTemplate template)
        {
            _templates[name] = template;
        }

        private MimeMessage CreateMimeMessage(string toEmail, string subject, string body, bool isHtml)
        {
            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(_configuration.FromName, _configuration.FromEmail));
            message.To.Add(MailboxAddress.Parse(toEmail));
            message.Subject = subject;

            var bodyBuilder = new BodyBuilder();
            
            if (isHtml)
            {
                bodyBuilder.HtmlBody = body;
            }
            else
            {
                bodyBuilder.TextBody = body;
            }

            message.Body = bodyBuilder.ToMessageBody();
            return message;
        }

        // IEmailSender implementation for ASP.NET Core Identity
        public async Task SendEmailAsync(string email, string subject, string htmlMessage)
        {
            await SendEmailAsync(email, subject, htmlMessage, true);
        }

        private void InitializeDefaultTemplates()
        {
            // Welcome email template
            RegisterTemplate(EmailTemplateNames.WelcomeUser, new EmailTemplate
            {
                Name = EmailTemplateNames.WelcomeUser,
                Subject = "Chào mừng đến với TD Sports - {{UserName}}!",
                HtmlBody = @"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2>Chào mừng đến với TD Sports!</h2>
                    <p>Xin chào {{UserName}},</p>
                    <p>Cảm ơn bạn đã đăng ký tài khoản TD Sports. Chúng tôi rất vui mừng chào đón bạn!</p>
                    <p>Bạn có thể bắt đầu khám phá các giải đấu thể thao hấp dẫn và tham gia cộng đồng của chúng tôi.</p>
                    <p>Trân trọng,<br>Đội ngũ TD Sports</p>
                </body>
                </html>",
                RequiredVariables = new List<string> { "UserName" }
            });

            // Password reset template
            RegisterTemplate(EmailTemplateNames.ResetPassword, new EmailTemplate
            {
                Name = EmailTemplateNames.ResetPassword,
                Subject = "Đặt lại mật khẩu TD Sports",
                HtmlBody = @"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <h2>Đặt lại mật khẩu</h2>
                    <p>Xin chào {{UserName}},</p>
                    <p>Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản TD Sports của mình.</p>
                    <p>Nhấp vào liên kết dưới đây để đặt lại mật khẩu:</p>
                    <p><a href='{{ResetUrl}}' style='background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;'>Đặt lại mật khẩu</a></p>
                    <p>Liên kết này sẽ hết hạn sau {{ExpirationHours}} giờ.</p>
                    <p>Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này.</p>
                    <p>Trân trọng,<br>Đội ngũ TD Sports</p>
                </body>
                </html>",
                RequiredVariables = new List<string> { "UserName", "ResetUrl", "ExpirationHours" }
            });

            _logger.LogInformation("Default email templates initialized");
        }
    }

    public class TournamentEmailService : ITournamentEmailService
    {
        private readonly IEmailSender _emailSender;
        private readonly ILogger<TournamentEmailService> _logger;

        public TournamentEmailService(IEmailSender emailSender, ILogger<TournamentEmailService> logger)
        {
            _emailSender = emailSender;
            _logger = logger;
        }

        public async Task SendTeamRegistrationApprovedAsync(string userEmail, string userName, string teamName, string tournamentName)
        {
            try
            {
                var subject = $"🎉 Đội {teamName} đã được duyệt tham gia giải đấu {tournamentName}";
                
                var htmlMessage = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                        <div style='text-align: center; margin-bottom: 30px;'>
                            <h1 style='color: #28a745; margin-bottom: 10px;'>🎉 Chúc Mừng!</h1>
                            <h2 style='color: #333; margin-top: 0;'>Đội bóng của bạn đã được duyệt</h2>
                        </div>
                        
                        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
                            <p style='margin: 0; font-size: 16px; line-height: 1.6;'>
                                Xin chào <strong>{userName}</strong>,
                            </p>
                            <p style='margin: 15px 0; font-size: 16px; line-height: 1.6;'>
                                Chúng tôi vui mừng thông báo rằng đội bóng <strong style='color: #007bff;'>{teamName}</strong> 
                                của bạn đã được chấp thuận tham gia giải đấu <strong style='color: #28a745;'>{tournamentName}</strong>.
                            </p>
                        </div>
                        
                        <div style='text-align: center; margin-top: 30px; padding: 20px; background-color: #d4edda; border-radius: 8px;'>
                            <p style='margin: 0; color: #155724; font-weight: bold;'>
                                🏆 Chúc đội bạn thi đấu thành công!
                            </p>
                        </div>
                    </div>";

                await _emailSender.SendEmailAsync(userEmail, subject, htmlMessage);
                _logger.LogInformation($"Sent team registration approval email to {userEmail} for team {teamName}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send team registration approval email to {userEmail} for team {teamName}");
                throw;
            }
        }

        public async Task SendTeamRegistrationRejectedAsync(string userEmail, string userName, string teamName, string tournamentName, string reason)
        {
            try
            {
                var subject = $"❌ Đăng ký đội {teamName} cho giải đấu {tournamentName} bị từ chối";
                
                var htmlMessage = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                        <div style='text-align: center; margin-bottom: 30px;'>
                            <h1 style='color: #dc3545; margin-bottom: 10px;'>❌ Thông Báo</h1>
                            <h2 style='color: #333; margin-top: 0;'>Đăng ký đội bóng bị từ chối</h2>
                        </div>
                        
                        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
                            <p style='margin: 0; font-size: 16px; line-height: 1.6;'>
                                Xin chào <strong>{userName}</strong>,
                            </p>
                            <p style='margin: 15px 0; font-size: 16px; line-height: 1.6;'>
                                Chúng tôi rất tiếc phải thông báo rằng đăng ký đội bóng <strong style='color: #007bff;'>{teamName}</strong> 
                                của bạn cho giải đấu <strong style='color: #dc3545;'>{tournamentName}</strong> đã bị từ chối.
                            </p>
                            <p style='margin: 15px 0; font-size: 16px; line-height: 1.6;'>
                                <strong>Lý do:</strong> {reason}
                            </p>
                        </div>
                        
                        <div style='text-align: center; margin-top: 30px; padding: 20px; background-color: #fff3cd; border-radius: 8px;'>
                            <p style='margin: 0; color: #856404; font-weight: bold;'>
                                💡 Bạn có thể chỉnh sửa và đăng ký lại sau khi khắc phục các vấn đề
                            </p>
                        </div>
                    </div>";

                await _emailSender.SendEmailAsync(userEmail, subject, htmlMessage);
                _logger.LogInformation($"Sent team registration rejection email to {userEmail} for team {teamName}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send team registration rejection email to {userEmail} for team {teamName}");
                throw;
            }
        }

        public async Task SendTeamRegistrationNotificationToAdminAsync(string teamName, string tournamentName, string userEmail, List<string> playerNames)
        {
            try
            {
                var subject = $"📋 Đăng ký đội mới: {teamName} - {tournamentName}";
                
                var playersHtml = string.Join("", playerNames.Select(player => $"<li>{player}</li>"));
                
                var htmlMessage = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                        <div style='text-align: center; margin-bottom: 30px;'>
                            <h1 style='color: #17a2b8; margin-bottom: 10px;'>📋 Thông Báo</h1>
                            <h2 style='color: #333; margin-top: 0;'>Đăng ký đội mới cần phê duyệt</h2>
                        </div>
                        
                        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
                            <h3 style='color: #007bff; margin-top: 0;'>🏆 Thông tin đội:</h3>
                            <p style='margin: 10px 0; font-size: 16px;'><strong>Tên đội:</strong> {teamName}</p>
                            <p style='margin: 10px 0; font-size: 16px;'><strong>Giải đấu:</strong> {tournamentName}</p>
                            <p style='margin: 10px 0; font-size: 16px;'><strong>Email người đăng ký:</strong> {userEmail}</p>
                        </div>
                        
                        <div style='background-color: #e7f3ff; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>
                            <h3 style='color: #0066cc; margin-top: 0;'>👥 Danh sách cầu thủ:</h3>
                            <ol style='margin: 10px 0; padding-left: 20px;'>
                                {playersHtml}
                            </ol>
                        </div>
                        
                        <div style='text-align: center; margin-top: 30px; padding: 20px; background-color: #fff3cd; border-radius: 8px;'>
                            <p style='margin: 0; color: #856404; font-weight: bold;'>
                                ⏰ Vui lòng vào hệ thống để phê duyệt đăng ký này
                            </p>
                        </div>
                    </div>";

                // Gửi email cho admin (có thể lấy email admin từ configuration)
                var adminEmail = "admin@example.com"; // Hoặc lấy từ configuration
                await _emailSender.SendEmailAsync(adminEmail, subject, htmlMessage);
                _logger.LogInformation($"Sent team registration notification to admin for team {teamName}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send team registration notification to admin for team {teamName}");
                throw;
            }
        }
    }
}