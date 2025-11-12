using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Text.Json;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    /// <summary>
    /// Health Check API Controller
    /// Cung cấp các endpoint để kiểm tra sức khỏe hệ thống
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class HealthApiController : ControllerBase
    {
        private readonly HealthCheckService _healthCheckService;
        private readonly ILogger<HealthApiController> _logger;

        public HealthApiController(HealthCheckService healthCheckService, ILogger<HealthApiController> logger)
        {
            _healthCheckService = healthCheckService;
            _logger = logger;
        }

        /// <summary>
        /// Kiểm tra sức khỏe tổng thể của hệ thống
        /// </summary>
        /// <returns>Trạng thái sức khỏe chi tiết</returns>
        [HttpGet("status")]
        public async Task<IActionResult> GetHealthStatus()
        {
            try
            {
                var report = await _healthCheckService.CheckHealthAsync();
                
                var response = new
                {
                    status = report.Status.ToString(),
                    totalDuration = report.TotalDuration.TotalMilliseconds,
                    timestamp = DateTime.UtcNow,
                    checks = report.Entries.Select(entry => new
                    {
                        name = entry.Key,
                        status = entry.Value.Status.ToString(),
                        duration = entry.Value.Duration.TotalMilliseconds,
                        description = entry.Value.Description,
                        data = entry.Value.Data,
                        exception = entry.Value.Exception?.Message,
                        tags = entry.Value.Tags
                    })
                };

                var statusCode = report.Status switch
                {
                    HealthStatus.Healthy => 200,
                    HealthStatus.Degraded => 200, // Still OK, but with warnings
                    HealthStatus.Unhealthy => 503,
                    _ => 503
                };

                return StatusCode(statusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get health status");
                return StatusCode(500, new { error = "Failed to get health status", message = ex.Message });
            }
        }

        /// <summary>
        /// Kiểm tra sức khỏe cơ sở dữ liệu
        /// </summary>
        [HttpGet("database")]
        public async Task<IActionResult> GetDatabaseHealth()
        {
            return await GetHealthByTag("database");
        }

        /// <summary>
        /// Kiểm tra sức khỏe các dịch vụ bên ngoài
        /// </summary>
        [HttpGet("external")]
        public async Task<IActionResult> GetExternalServicesHealth()
        {
            return await GetHealthByTag("external");
        }

        /// <summary>
        /// Kiểm tra sức khỏe ứng dụng
        /// </summary>
        [HttpGet("application")]
        public async Task<IActionResult> GetApplicationHealth()
        {
            return await GetHealthByTag("application");
        }

        /// <summary>
        /// Endpoint đơn giản để kiểm tra ứng dụng có chạy không
        /// </summary>
        [HttpGet("ping")]
        public IActionResult Ping()
        {
            return Ok(new 
            { 
                status = "healthy",
                message = "Tournament Management System is running!",
                timestamp = DateTime.UtcNow,
                version = "1.0.0",
                environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown"
            });
        }

        /// <summary>
        /// Lấy thông tin tổng quan hệ thống
        /// </summary>
        [HttpGet("system-info")]
        public IActionResult GetSystemInfo()
        {
            try
            {
                var info = new
                {
                    applicationName = "Tournament Management System",
                    version = "1.0.0",
                    environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown",
                    machineName = Environment.MachineName,
                    processId = Environment.ProcessId,
                    workingSetMB = Environment.WorkingSet / 1024 / 1024,
                    uptime = DateTime.Now - System.Diagnostics.Process.GetCurrentProcess().StartTime,
                    timestamp = DateTime.UtcNow,
                    osVersion = Environment.OSVersion.ToString(),
                    frameworkVersion = Environment.Version.ToString()
                };

                return Ok(info);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get system info");
                return StatusCode(500, new { error = "Failed to get system info", message = ex.Message });
            }
        }

        private async Task<IActionResult> GetHealthByTag(string tag)
        {
            try
            {
                var report = await _healthCheckService.CheckHealthAsync(check => check.Tags.Contains(tag));
                
                var response = new
                {
                    tag,
                    status = report.Status.ToString(),
                    totalDuration = report.TotalDuration.TotalMilliseconds,
                    timestamp = DateTime.UtcNow,
                    checks = report.Entries.Select(entry => new
                    {
                        name = entry.Key,
                        status = entry.Value.Status.ToString(),
                        duration = entry.Value.Duration.TotalMilliseconds,
                        description = entry.Value.Description,
                        data = entry.Value.Data,
                        exception = entry.Value.Exception?.Message
                    })
                };

                var statusCode = report.Status switch
                {
                    HealthStatus.Healthy => 200,
                    HealthStatus.Degraded => 200,
                    HealthStatus.Unhealthy => 503,
                    _ => 503
                };

                return StatusCode(statusCode, response);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get health status for tag {Tag}", tag);
                return StatusCode(500, new { error = $"Failed to get {tag} health status", message = ex.Message });
            }
        }
    }
}