using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.EntityFrameworkCore;
using System.Threading;
using System.Threading.Tasks;
using System.Diagnostics;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Services.HealthChecks
{
    /// <summary>
    /// Custom Health Check for Application Database
    /// </summary>
    public class DatabaseHealthCheck : IHealthCheck
    {
        private readonly ApplicationDbContext _context;

        public DatabaseHealthCheck(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            try
            {
                // Kiểm tra kết nối database bằng cách thực hiện một query đơn giản
                await _context.Database.CanConnectAsync(cancellationToken);
                
                // Kiểm tra một số bảng quan trọng
                var tournamentCount = await _context.Tournaments.CountAsync(cancellationToken);
                var userCount = await _context.Users.CountAsync(cancellationToken);
                
                var data = new Dictionary<string, object>
                {
                    {"tournaments", tournamentCount},
                    {"users", userCount},
                    {"database", _context.Database.GetDbConnection().Database},
                    {"connectionState", _context.Database.GetDbConnection().State.ToString()}
                };

                return HealthCheckResult.Healthy("Database is healthy", data);
            }
            catch (Exception ex)
            {
                return HealthCheckResult.Unhealthy("Database is unhealthy", ex);
            }
        }
    }

    /// <summary>
    /// Custom Health Check for External Services (YouTube API, etc.)
    /// </summary>
    public class ExternalServicesHealthCheck : IHealthCheck
    {
        private readonly IConfiguration _configuration;
        private readonly HttpClient _httpClient;
        private readonly ILogger<ExternalServicesHealthCheck> _logger;

        public ExternalServicesHealthCheck(IConfiguration configuration, HttpClient httpClient, ILogger<ExternalServicesHealthCheck> logger)
        {
            _configuration = configuration;
            _httpClient = httpClient;
            _logger = logger;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            var results = new Dictionary<string, object>();
            var isHealthy = true;
            var errors = new List<string>();

            try
            {
                // Kiểm tra YouTube API key configuration
                var youtubeApiKey = _configuration["YouTube:ApiKey"];
                results["youtubeApiConfigured"] = !string.IsNullOrEmpty(youtubeApiKey) && youtubeApiKey != "YOUR_YOUTUBE_API_KEY_HERE";

                // Kiểm tra Google OAuth configuration
                var googleClientId = _configuration["Authentication:Google:ClientId"];
                var googleClientSecret = _configuration["Authentication:Google:ClientSecret"];
                results["googleOAuthConfigured"] = !string.IsNullOrEmpty(googleClientId) && 
                                                  !string.IsNullOrEmpty(googleClientSecret) &&
                                                  googleClientId != "YOUR_GOOGLE_CLIENT_ID_HERE" &&
                                                  googleClientSecret != "YOUR_GOOGLE_CLIENT_SECRET_HERE";

                // Kiểm tra JWT configuration
                var jwtKey = _configuration["Jwt:Key"];
                results["jwtConfigured"] = !string.IsNullOrEmpty(jwtKey) && jwtKey.Length >= 32;

                // Kiểm tra kết nối internet (optional)
                try
                {
                    var response = await _httpClient.GetAsync("https://www.google.com", cancellationToken);
                    results["internetConnection"] = response.IsSuccessStatusCode;
                }
                catch
                {
                    results["internetConnection"] = false;
                    errors.Add("No internet connection");
                }

            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking external services health");
                errors.Add(ex.Message);
                isHealthy = false;
            }

            results["errors"] = errors;

            if (isHealthy && errors.Count == 0)
            {
                return HealthCheckResult.Healthy("External services are healthy", results);
            }
            else
            {
                return HealthCheckResult.Degraded("Some external services have issues", null, results);
            }
        }
    }

    /// <summary>
    /// Application Health Check - kiểm tra các thành phần cốt lõi của ứng dụng
    /// </summary>
    public class ApplicationHealthCheck : IHealthCheck
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<ApplicationHealthCheck> _logger;

        public ApplicationHealthCheck(ApplicationDbContext context, ILogger<ApplicationHealthCheck> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            try
            {
                var data = new Dictionary<string, object>();
                
                // Kiểm tra dữ liệu cơ bản có tồn tại
                data["sportsCount"] = await _context.Sports.CountAsync(cancellationToken);
                data["tournamentsCount"] = await _context.Tournaments.CountAsync(cancellationToken);
                data["teamsCount"] = await _context.Teams.CountAsync(cancellationToken);
                data["playersCount"] = await _context.Players.CountAsync(cancellationToken);
                data["matchesCount"] = await _context.Matches.CountAsync(cancellationToken);
                data["usersCount"] = await _context.Users.CountAsync(cancellationToken);

                // Kiểm tra có tournament format data
                var formatCount = await _context.TournamentFormats.CountAsync(cancellationToken);
                data["tournamentFormatsCount"] = formatCount;

                // Kiểm tra có news data
                var newsCount = await _context.News.CountAsync(cancellationToken);
                data["newsCount"] = newsCount;

                // Memory usage
                var workingSet = Environment.WorkingSet;
                data["memoryUsageMB"] = workingSet / 1024 / 1024;

                // Uptime
                var uptime = DateTime.Now - Process.GetCurrentProcess().StartTime;
                data["uptimeMinutes"] = uptime.TotalMinutes;

                return HealthCheckResult.Healthy("Application is healthy", data);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Application health check failed");
                return HealthCheckResult.Unhealthy("Application health check failed", ex);
            }
        }
    }
}