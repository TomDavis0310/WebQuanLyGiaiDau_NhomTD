using Microsoft.AspNetCore.Identity.UI.Services;
using System.Net;
using System.Net.Mail;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    public interface ITournamentEmailService
    {
        Task SendTeamRegistrationApprovedAsync(string userEmail, string userName, string teamName, string tournamentName);
        Task SendTeamRegistrationRejectedAsync(string userEmail, string userName, string teamName, string tournamentName, string reason);
        Task SendTeamRegistrationNotificationToAdminAsync(string teamName, string tournamentName, string userEmail, List<string> playerNames);
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
                        
                        <div style='background-color: #e7f3ff; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>
                            <h3 style='color: #0066cc; margin-top: 0;'>📋 Thông tin quan trọng:</h3>
                            <ul style='margin: 10px 0; padding-left: 20px;'>
                                <li>Vui lòng theo dõi lịch thi đấu sẽ được cập nhật sớm</li>
                                <li>Đảm bảo đội bóng có đủ cầu thủ cho các trận đấu</li>
                                <li>Kiểm tra thông tin liên lạc của đội thường xuyên</li>
                            </ul>
                        </div>
                        
                        <div style='text-align: center; margin-top: 30px;'>
                            <p style='color: #666; font-size: 14px;'>
                                Chúc đội bóng của bạn thi đấu thành công!<br>
                                <strong>Ban tổ chức giải đấu</strong>
                            </p>
                        </div>
                    </div>";

                await _emailSender.SendEmailAsync(userEmail, subject, htmlMessage);
                _logger.LogInformation($"Sent team approval email to {userEmail} for team {teamName}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send team approval email to {userEmail}");
                throw;
            }
        }

        public async Task SendTeamRegistrationRejectedAsync(string userEmail, string userName, string teamName, string tournamentName, string reason)
        {
            try
            {
                var subject = $"❌ Đội {teamName} không được duyệt tham gia giải đấu {tournamentName}";
                
                var htmlMessage = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                        <div style='text-align: center; margin-bottom: 30px;'>
                            <h1 style='color: #dc3545; margin-bottom: 10px;'>❌ Thông Báo</h1>
                            <h2 style='color: #333; margin-top: 0;'>Đăng ký đội bóng không được duyệt</h2>
                        </div>
                        
                        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
                            <p style='margin: 0; font-size: 16px; line-height: 1.6;'>
                                Xin chào <strong>{userName}</strong>,
                            </p>
                            <p style='margin: 15px 0; font-size: 16px; line-height: 1.6;'>
                                Chúng tôi rất tiếc phải thông báo rằng đội bóng <strong style='color: #007bff;'>{teamName}</strong> 
                                của bạn không được chấp thuận tham gia giải đấu <strong>{tournamentName}</strong>.
                            </p>
                        </div>
                        
                        <div style='background-color: #fff3cd; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #ffc107;'>
                            <h3 style='color: #856404; margin-top: 0;'>📝 Lý do:</h3>
                            <p style='margin: 0; color: #856404;'>{reason}</p>
                        </div>
                        
                        <div style='background-color: #e7f3ff; padding: 15px; border-radius: 8px; margin-bottom: 20px;'>
                            <h3 style='color: #0066cc; margin-top: 0;'>💡 Gợi ý:</h3>
                            <ul style='margin: 10px 0; padding-left: 20px;'>
                                <li>Kiểm tra và cập nhật thông tin đội bóng</li>
                                <li>Đảm bảo đội có đủ số lượng cầu thủ yêu cầu</li>
                                <li>Liên hệ ban tổ chức nếu cần hỗ trợ thêm</li>
                                <li>Có thể đăng ký lại cho các giải đấu khác</li>
                            </ul>
                        </div>
                        
                        <div style='text-align: center; margin-top: 30px;'>
                            <p style='color: #666; font-size: 14px;'>
                                Cảm ơn bạn đã quan tâm đến giải đấu của chúng tôi!<br>
                                <strong>Ban tổ chức giải đấu</strong>
                            </p>
                        </div>
                    </div>";

                await _emailSender.SendEmailAsync(userEmail, subject, htmlMessage);
                _logger.LogInformation($"Sent team rejection email to {userEmail} for team {teamName}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Failed to send team rejection email to {userEmail}");
                throw;
            }
        }

        public async Task SendTeamRegistrationNotificationToAdminAsync(string teamName, string tournamentName, string userEmail, List<string> playerNames)
        {
            try
            {
                var subject = $"🔔 Đăng ký đội mới: {teamName} cho giải đấu {tournamentName}";
                
                var playersHtml = string.Join("", playerNames.Select(name => $"<li>{name}</li>"));
                
                var htmlMessage = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>
                        <div style='text-align: center; margin-bottom: 30px;'>
                            <h1 style='color: #007bff; margin-bottom: 10px;'>🔔 Đăng Ký Đội Mới</h1>
                            <h2 style='color: #333; margin-top: 0;'>Cần phê duyệt</h2>
                        </div>
                        
                        <div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;'>
                            <h3 style='color: #007bff; margin-top: 0;'>📋 Thông tin đội bóng:</h3>
                            <ul style='list-style: none; padding: 0;'>
                                <li style='margin: 10px 0;'><strong>Tên đội:</strong> {teamName}</li>
                                <li style='margin: 10px 0;'><strong>Giải đấu:</strong> {tournamentName}</li>
                                <li style='margin: 10px 0;'><strong>Email người đăng ký:</strong> {userEmail}</li>
                                <li style='margin: 10px 0;'><strong>Số lượng cầu thủ:</strong> {playerNames.Count}</li>
                            </ul>
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
