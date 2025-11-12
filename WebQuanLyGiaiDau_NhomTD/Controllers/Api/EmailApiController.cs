using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using WebQuanLyGiaiDau_NhomTD.Models.Email;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class EmailApiController : ControllerBase
    {
        private readonly IEmailService _emailService;
        private readonly ILogger<EmailApiController> _logger;

        public EmailApiController(IEmailService emailService, ILogger<EmailApiController> logger)
        {
            _emailService = emailService;
            _logger = logger;
        }

        /// <summary>
        /// Test email connection
        /// </summary>
        [HttpGet("test-connection")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> TestConnection()
        {
            try
            {
                var isConnected = await _emailService.TestConnectionAsync();
                return Ok(new { 
                    isConnected,
                    message = isConnected ? "Email service is working" : "Email service is not configured or not working",
                    timestamp = DateTime.UtcNow 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error testing email connection");
                return StatusCode(500, new { error = "Internal server error", details = ex.Message });
            }
        }

        /// <summary>
        /// Send simple email
        /// </summary>
        [HttpPost("send")]
        [Authorize(Roles = "Admin,Organizer")]
        public async Task<IActionResult> SendEmail([FromBody] SendEmailRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                var result = await _emailService.SendEmailAsync(request.To, request.Subject, request.Body, request.IsHtml);
                
                if (result.IsSuccess)
                {
                    return Ok(new { 
                        success = true,
                        messageId = result.MessageId,
                        sentAt = result.SentAt,
                        duration = result.Duration.TotalMilliseconds 
                    });
                }
                else
                {
                    return BadRequest(new { success = false, error = result.ErrorMessage });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending email");
                return StatusCode(500, new { error = "Failed to send email", details = ex.Message });
            }
        }

        /// <summary>
        /// Send email from template
        /// </summary>
        [HttpPost("send-template")]
        [Authorize(Roles = "Admin,Organizer")]
        public async Task<IActionResult> SendEmailFromTemplate([FromBody] SendTemplateEmailRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                var result = await _emailService.SendEmailFromTemplateAsync(request.To, request.TemplateName, request.Variables);
                
                if (result.IsSuccess)
                {
                    return Ok(new { 
                        success = true,
                        messageId = result.MessageId,
                        sentAt = result.SentAt,
                        duration = result.Duration.TotalMilliseconds 
                    });
                }
                else
                {
                    return BadRequest(new { success = false, error = result.ErrorMessage });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending template email");
                return StatusCode(500, new { error = "Failed to send template email", details = ex.Message });
            }
        }

        /// <summary>
        /// Get available email templates
        /// </summary>
        [HttpGet("templates")]
        [Authorize(Roles = "Admin,Organizer")]
        public IActionResult GetTemplates()
        {
            try
            {
                var templates = new[]
                {
                    new { name = EmailTemplateNames.WelcomeUser, description = "Welcome new user email" },
                    new { name = EmailTemplateNames.TournamentRegistration, description = "Tournament registration confirmation" },
                    new { name = EmailTemplateNames.ResetPassword, description = "Password reset email" },
                    new { name = EmailTemplateNames.TournamentReminder, description = "Tournament reminder email" },
                    new { name = EmailTemplateNames.MatchNotification, description = "Match notification email" },
                    new { name = EmailTemplateNames.TeamInvitation, description = "Team invitation email" },
                    new { name = EmailTemplateNames.NewsletterDigest, description = "Newsletter digest email" },
                    new { name = EmailTemplateNames.SystemNotification, description = "System notification email" }
                };

                return Ok(templates);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting email templates");
                return StatusCode(500, new { error = "Failed to get templates", details = ex.Message });
            }
        }

        /// <summary>
        /// Get template details
        /// </summary>
        [HttpGet("templates/{templateName}")]
        [Authorize(Roles = "Admin,Organizer")]
        public IActionResult GetTemplate(string templateName)
        {
            try
            {
                var template = _emailService.GetTemplate(templateName);
                if (template == null)
                {
                    return NotFound(new { error = $"Template '{templateName}' not found" });
                }

                return Ok(new
                {
                    name = template.Name,
                    subject = template.Subject,
                    htmlBody = template.HtmlBody,
                    textBody = template.TextBody,
                    requiredVariables = template.RequiredVariables,
                    defaultVariables = template.DefaultVariables
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting email template: {TemplateName}", templateName);
                return StatusCode(500, new { error = "Failed to get template", details = ex.Message });
            }
        }

        /// <summary>
        /// Send bulk emails
        /// </summary>
        [HttpPost("send-bulk")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> SendBulkEmails([FromBody] SendBulkEmailRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                    return BadRequest(ModelState);

                var messages = request.Recipients.Select(recipient => new EmailMessage
                {
                    To = recipient.Email,
                    ToName = recipient.Name,
                    Subject = request.Subject,
                    Body = request.Body,
                    IsHtml = request.IsHtml
                }).ToList();

                var results = await _emailService.SendBulkEmailAsync(messages);
                
                var successCount = results.Count(r => r.IsSuccess);
                var failureCount = results.Count(r => !r.IsSuccess);

                return Ok(new 
                { 
                    success = true,
                    total = results.Count,
                    successful = successCount,
                    failed = failureCount,
                    results = results.Select(r => new
                    {
                        success = r.IsSuccess,
                        messageId = r.MessageId,
                        error = r.ErrorMessage,
                        duration = r.Duration.TotalMilliseconds
                    })
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending bulk emails");
                return StatusCode(500, new { error = "Failed to send bulk emails", details = ex.Message });
            }
        }
    }

    public class SendEmailRequest
    {
        public string To { get; set; } = string.Empty;
        public string Subject { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public bool IsHtml { get; set; } = true;
    }

    public class SendTemplateEmailRequest
    {
        public string To { get; set; } = string.Empty;
        public string TemplateName { get; set; } = string.Empty;
        public Dictionary<string, object> Variables { get; set; } = new();
    }

    public class SendBulkEmailRequest
    {
        public string Subject { get; set; } = string.Empty;
        public string Body { get; set; } = string.Empty;
        public bool IsHtml { get; set; } = true;
        public List<EmailRecipient> Recipients { get; set; } = new();
    }

    public class EmailRecipient
    {
        public string Email { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
    }
}