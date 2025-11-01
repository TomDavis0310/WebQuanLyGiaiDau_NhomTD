using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;
using Microsoft.AspNetCore.SignalR;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Route("api/notifications")]
    [ApiController]
    public class NotificationsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly IHubContext<MatchHub> _hubContext;

        public NotificationsApiController(ApplicationDbContext context, IHubContext<MatchHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        // GET: api/notifications
        [HttpGet]
        public async Task<ActionResult<object>> GetNotifications(
            [FromQuery] string? type = null,
            [FromQuery] bool? isRead = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                var query = _context.Notifications
                    .Where(n => !n.IsDeleted)
                    .AsQueryable();

                // Filter by type
                if (!string.IsNullOrEmpty(type))
                {
                    query = query.Where(n => n.Type == type);
                }

                // Filter by read status
                if (isRead.HasValue)
                {
                    query = query.Where(n => n.IsRead == isRead.Value);
                }

                // Count total
                var total = await query.CountAsync();

                // Get unread count
                var unreadCount = await _context.Notifications
                    .Where(n => !n.IsDeleted && !n.IsRead)
                    .CountAsync();

                // Paginate
                var notifications = await query
                    .OrderByDescending(n => n.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(n => new
                    {
                        n.Id,
                        n.Title,
                        n.Message,
                        n.Type,
                        n.RelatedId,
                        n.RelatedType,
                        n.IsRead,
                        n.CreatedAt,
                        n.ReadAt,
                        n.ImageUrl,
                        n.ActionUrl,
                        n.Priority
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    data = notifications,
                    total = total,
                    unreadCount = unreadCount,
                    page = page,
                    pageSize = pageSize,
                    totalPages = (int)Math.Ceiling(total / (double)pageSize)
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi tải thông báo",
                    error = ex.Message
                });
            }
        }

        // GET: api/notifications/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetNotification(int id)
        {
            try
            {
                var notification = await _context.Notifications
                    .Where(n => n.Id == id && !n.IsDeleted)
                    .Select(n => new
                    {
                        n.Id,
                        n.Title,
                        n.Message,
                        n.Type,
                        n.RelatedId,
                        n.RelatedType,
                        n.IsRead,
                        n.CreatedAt,
                        n.ReadAt,
                        n.ImageUrl,
                        n.ActionUrl,
                        n.Priority
                    })
                    .FirstOrDefaultAsync();

                if (notification == null)
                {
                    return NotFound(new { message = "Không tìm thấy thông báo" });
                }

                return Ok(new
                {
                    success = true,
                    data = notification
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi tải thông báo",
                    error = ex.Message
                });
            }
        }

        // POST: api/notifications
        [HttpPost]
        public async Task<ActionResult<object>> CreateNotification([FromBody] NotificationCreateDto dto)
        {
            try
            {
                var notification = new Notification
                {
                    Title = dto.Title,
                    Message = dto.Message,
                    Type = dto.Type ?? "info",
                    RelatedId = dto.RelatedId,
                    RelatedType = dto.RelatedType,
                    ImageUrl = dto.ImageUrl,
                    ActionUrl = dto.ActionUrl,
                    Priority = dto.Priority ?? 0,
                    CreatedAt = DateTime.Now
                };

                _context.Notifications.Add(notification);
                await _context.SaveChangesAsync();

                // Send real-time notification via SignalR
                await _hubContext.Clients.All.SendAsync("ReceiveNotification", new
                {
                    notification.Id,
                    notification.Title,
                    notification.Message,
                    notification.Type,
                    notification.RelatedId,
                    notification.RelatedType,
                    notification.IsRead,
                    notification.CreatedAt,
                    notification.ImageUrl,
                    notification.ActionUrl,
                    notification.Priority
                });

                return Ok(new
                {
                    success = true,
                    message = "Tạo thông báo thành công",
                    data = new
                    {
                        notification.Id,
                        notification.Title,
                        notification.Message,
                        notification.Type,
                        notification.CreatedAt
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi tạo thông báo",
                    error = ex.Message
                });
            }
        }

        // PUT: api/notifications/{id}/read
        [HttpPut("{id}/read")]
        public async Task<ActionResult<object>> MarkAsRead(int id)
        {
            try
            {
                var notification = await _context.Notifications.FindAsync(id);

                if (notification == null || notification.IsDeleted)
                {
                    return NotFound(new { message = "Không tìm thấy thông báo" });
                }

                notification.IsRead = true;
                notification.ReadAt = DateTime.Now;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    success = true,
                    message = "Đã đánh dấu đã đọc"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi cập nhật thông báo",
                    error = ex.Message
                });
            }
        }

        // PUT: api/notifications/{id}/unread
        [HttpPut("{id}/unread")]
        public async Task<ActionResult<object>> MarkAsUnread(int id)
        {
            try
            {
                var notification = await _context.Notifications.FindAsync(id);

                if (notification == null || notification.IsDeleted)
                {
                    return NotFound(new { message = "Không tìm thấy thông báo" });
                }

                notification.IsRead = false;
                notification.ReadAt = null;

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    success = true,
                    message = "Đã đánh dấu chưa đọc"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi cập nhật thông báo",
                    error = ex.Message
                });
            }
        }

        // PUT: api/notifications/read-all
        [HttpPut("read-all")]
        public async Task<ActionResult<object>> MarkAllAsRead()
        {
            try
            {
                var unreadNotifications = await _context.Notifications
                    .Where(n => !n.IsRead && !n.IsDeleted)
                    .ToListAsync();

                foreach (var notification in unreadNotifications)
                {
                    notification.IsRead = true;
                    notification.ReadAt = DateTime.Now;
                }

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    success = true,
                    message = $"Đã đánh dấu {unreadNotifications.Count} thông báo là đã đọc",
                    count = unreadNotifications.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi cập nhật thông báo",
                    error = ex.Message
                });
            }
        }

        // DELETE: api/notifications/{id}
        [HttpDelete("{id}")]
        public async Task<ActionResult<object>> DeleteNotification(int id)
        {
            try
            {
                var notification = await _context.Notifications.FindAsync(id);

                if (notification == null)
                {
                    return NotFound(new { message = "Không tìm thấy thông báo" });
                }

                // Soft delete
                notification.IsDeleted = true;
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    success = true,
                    message = "Đã xóa thông báo"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi xóa thông báo",
                    error = ex.Message
                });
            }
        }

        // DELETE: api/notifications/delete-all
        [HttpDelete("delete-all")]
        public async Task<ActionResult<object>> DeleteAllNotifications()
        {
            try
            {
                var notifications = await _context.Notifications
                    .Where(n => !n.IsDeleted)
                    .ToListAsync();

                foreach (var notification in notifications)
                {
                    notification.IsDeleted = true;
                }

                await _context.SaveChangesAsync();

                return Ok(new
                {
                    success = true,
                    message = $"Đã xóa {notifications.Count} thông báo",
                    count = notifications.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi xóa thông báo",
                    error = ex.Message
                });
            }
        }

        // GET: api/notifications/unread-count
        [HttpGet("unread-count")]
        public async Task<ActionResult<object>> GetUnreadCount()
        {
            try
            {
                var count = await _context.Notifications
                    .Where(n => !n.IsRead && !n.IsDeleted)
                    .CountAsync();

                return Ok(new
                {
                    success = true,
                    data = new { unreadCount = count }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi đếm thông báo",
                    error = ex.Message
                });
            }
        }

        // GET: api/notifications/types
        [HttpGet("types")]
        public ActionResult<object> GetNotificationTypes()
        {
            var types = new[]
            {
                new { value = "match", label = "Trận đấu", icon = "sports_soccer", color = "#4CAF50" },
                new { value = "tournament", label = "Giải đấu", icon = "emoji_events", color = "#FF9800" },
                new { value = "team", label = "Đội bóng", icon = "group", color = "#2196F3" },
                new { value = "player", label = "Cầu thủ", icon = "person", color = "#9C27B0" },
                new { value = "system", label = "Hệ thống", icon = "settings", color = "#607D8B" },
                new { value = "info", label = "Thông tin", icon = "info", color = "#00BCD4" }
            };

            return Ok(new
            {
                success = true,
                data = types
            });
        }
    }

    // DTO for creating notification
    public class NotificationCreateDto
    {
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? Type { get; set; }
        public int? RelatedId { get; set; }
        public string? RelatedType { get; set; }
        public string? ImageUrl { get; set; }
        public string? ActionUrl { get; set; }
        public int? Priority { get; set; }
    }
}
