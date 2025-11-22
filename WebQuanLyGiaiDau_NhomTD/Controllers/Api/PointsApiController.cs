using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PointsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public PointsApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy lịch sử tích điểm và chi tiêu điểm của user
        /// </summary>
        [HttpGet("history")]
        public async Task<ActionResult<object>> GetPointsHistory()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null)
                return Unauthorized(new { message = "Chưa đăng nhập" });

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            // Lấy lịch sử đổi quà (chi tiêu điểm)
            var rewardTransactions = await _context.RewardTransactions
                .Include(t => t.RewardProduct)
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.TransactionDate)
                .Select(t => new
                {
                    type = "spend",
                    date = t.TransactionDate,
                    points = -t.PointsSpent,
                    description = $"Đổi {t.RewardProduct.Name}",
                    details = new
                    {
                        productName = t.RewardProduct.Name,
                        redemptionCode = t.RedemptionCode,
                        status = t.Status.ToString()
                    }
                })
                .ToListAsync();

            // Lấy lịch sử bình chọn (tích điểm)
            var votingHistory = await _context.TournamentVotes
                .Include(v => v.Tournament)
                .Where(v => v.UserId == userId)
                .OrderByDescending(v => v.VoteTime)
                .Select(v => new
                {
                    type = "earn",
                    date = v.VoteTime,
                    points = 10, // Giả sử mỗi lần vote được 10 điểm
                    description = $"Bình chọn giải đấu: {v.Tournament.Name}",
                    details = new
                    {
                        tournamentId = v.TournamentId,
                        tournamentName = v.Tournament.Name,
                        votedTeam = v.VotedTeamName
                    }
                })
                .ToListAsync();

            // Gộp 2 danh sách và sắp xếp theo thời gian
            var allTransactions = rewardTransactions
                .Concat(votingHistory.Cast<object>())
                .OrderByDescending(t =>
                {
                    var type = t.GetType();
                    var dateProperty = type.GetProperty("date");
                    return dateProperty?.GetValue(t) as DateTime? ?? DateTime.MinValue;
                })
                .ToList();

            return Ok(new
            {
                currentPoints = user.Points,
                totalEarned = votingHistory.Sum(v => v.points),
                totalSpent = Math.Abs(rewardTransactions.Sum(t => t.points)),
                history = allTransactions
            });
        }

        /// <summary>
        /// Lấy thống kê điểm của user
        /// </summary>
        [HttpGet("statistics")]
        public async Task<ActionResult<object>> GetPointsStatistics()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null)
                return Unauthorized(new { message = "Chưa đăng nhập" });

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            // Tổng điểm đã chi tiêu
            var totalSpent = await _context.RewardTransactions
                .Where(t => t.UserId == userId)
                .SumAsync(t => t.PointsSpent);

            // Số lượng quà đã đổi
            var totalRewards = await _context.RewardTransactions
                .Where(t => t.UserId == userId)
                .CountAsync();

            // Số lượng lần bình chọn
            var totalVotes = await _context.TournamentVotes
                .Where(v => v.UserId == userId)
                .CountAsync();

            // Tổng điểm tích lũy (giả sử mỗi vote = 10 điểm)
            var totalEarned = totalVotes * 10;

            // Thứ hạng user (dựa trên điểm hiện tại)
            var userRank = await _context.Users
                .Where(u => u.Points > user.Points)
                .CountAsync() + 1;

            return Ok(new
            {
                currentPoints = user.Points,
                totalEarned = totalEarned,
                totalSpent = totalSpent,
                totalRewards = totalRewards,
                totalVotes = totalVotes,
                userRank = userRank
            });
        }

        /// <summary>
        /// Lấy bảng xếp hạng users theo điểm
        /// </summary>
        [HttpGet("leaderboard")]
        public async Task<ActionResult<IEnumerable<object>>> GetLeaderboard([FromQuery] int top = 10)
        {
            var leaderboard = await _context.Users
                .OrderByDescending(u => u.Points)
                .Take(top)
                .Select((u, index) => new
                {
                    rank = index + 1,
                    userName = u.UserName,
                    fullName = u.FullName,
                    points = u.Points,
                    avatarUrl = u.ProfilePictureUrl
                })
                .ToListAsync();

            return Ok(leaderboard);
        }
    }
}
