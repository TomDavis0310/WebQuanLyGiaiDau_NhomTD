using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class PlayersApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public PlayersApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/PlayersApi/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetPlayerDetail(int id)
        {
            try
            {
                var player = await _context.Players
                    .Include(p => p.Team)
                    .FirstOrDefaultAsync(p => p.PlayerId == id);

                if (player == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Không tìm thấy cầu thủ"
                    });
                }

                // Get player statistics from PlayerScorings
                var playerScorings = await _context.PlayerScorings
                    .Include(ps => ps.Match)
                    .Where(ps => ps.PlayerId == id)
                    .OrderByDescending(ps => ps.ScoringTime)
                    .ToListAsync();

                // Calculate statistics
                var totalPoints = playerScorings.Sum(ps => ps.Points);
                var totalMatches = playerScorings.Select(ps => ps.MatchId).Distinct().Count();
                var averagePoints = totalMatches > 0 ? (double)totalPoints / totalMatches : 0;
                
                // Get recent matches
                var recentMatches = playerScorings
                    .GroupBy(ps => ps.MatchId)
                    .Select(g => new
                    {
                        matchId = g.Key,
                        match = g.First().Match,
                        points = g.Sum(ps => ps.Points),
                        scoringCount = g.Count()
                    })
                    .OrderByDescending(m => m.match.MatchDate)
                    .Take(10)
                    .Select(m => new
                    {
                        matchId = m.matchId,
                        teamA = m.match.TeamA,
                        teamB = m.match.TeamB,
                        scoreA = m.match.ScoreTeamA,
                        scoreB = m.match.ScoreTeamB,
                        matchDate = m.match.MatchDate,
                        location = m.match.Location,
                        status = m.match.Status,
                        points = m.points,
                        scoringCount = m.scoringCount
                    })
                    .ToList();

                // Get performance by match (for chart data)
                var performanceData = playerScorings
                    .GroupBy(ps => ps.MatchId)
                    .Select(g => new
                    {
                        matchId = g.Key,
                        matchDate = g.First().Match.MatchDate,
                        points = g.Sum(ps => ps.Points)
                    })
                    .OrderBy(p => p.matchDate)
                    .Take(20) // Last 20 matches
                    .ToList();

                var result = new
                {
                    playerId = player.PlayerId,
                    fullName = player.FullName,
                    position = player.Position,
                    number = player.Number,
                    imageUrl = player.ImageUrl,
                    team = player.Team != null ? new
                    {
                        teamId = player.Team.TeamId,
                        name = player.Team.Name,
                        logo = player.Team.LogoUrl
                    } : null,
                    statistics = new
                    {
                        totalMatches = totalMatches,
                        totalPoints = totalPoints,
                        averagePoints = Math.Round(averagePoints, 2),
                        highestScore = playerScorings.Any() ? 
                            playerScorings.GroupBy(ps => ps.MatchId)
                                .Max(g => g.Sum(ps => ps.Points)) : 0
                    },
                    recentMatches = recentMatches,
                    performanceData = performanceData
                };

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin cầu thủ thành công",
                    data = result
                });
            }
            catch (Exception ex)
            {
                return Ok(new
                {
                    success = false,
                    message = $"Lỗi: {ex.Message}"
                });
            }
        }

        // GET: api/PlayersApi/{id}/matches
        [HttpGet("{id}/matches")]
        public async Task<ActionResult<object>> GetPlayerMatches(int id, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            try
            {
                var player = await _context.Players.FindAsync(id);
                if (player == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Không tìm thấy cầu thủ"
                    });
                }

                // Get all match IDs where player has scored
                var matchIdsQuery = _context.PlayerScorings
                    .Where(ps => ps.PlayerId == id)
                    .Select(ps => ps.MatchId)
                    .Distinct();

                var totalCount = await matchIdsQuery.CountAsync();
                var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

                var matchIds = await matchIdsQuery
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                var matches = await _context.Matches
                    .Where(m => matchIds.Contains(m.Id))
                    .OrderByDescending(m => m.MatchDate)
                    .Select(m => new
                    {
                        matchId = m.Id,
                        teamA = m.TeamA,
                        teamB = m.TeamB,
                        scoreA = m.ScoreTeamA,
                        scoreB = m.ScoreTeamB,
                        matchDate = m.MatchDate,
                        location = m.Location,
                        status = m.Status,
                        playerPoints = _context.PlayerScorings
                            .Where(ps => ps.MatchId == m.Id && ps.PlayerId == id)
                            .Sum(ps => ps.Points)
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách trận đấu thành công",
                    data = matches,
                    pagination = new
                    {
                        page = page,
                        pageSize = pageSize,
                        totalCount = totalCount,
                        totalPages = totalPages,
                        hasNextPage = page < totalPages,
                        hasPreviousPage = page > 1
                    }
                });
            }
            catch (Exception ex)
            {
                return Ok(new
                {
                    success = false,
                    message = $"Lỗi: {ex.Message}"
                });
            }
        }

        // GET: api/PlayersApi/{id}/statistics/summary
        [HttpGet("{id}/statistics/summary")]
        public async Task<ActionResult<object>> GetPlayerStatisticsSummary(int id)
        {
            try
            {
                var player = await _context.Players.FindAsync(id);
                if (player == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Không tìm thấy cầu thủ"
                    });
                }

                var scorings = await _context.PlayerScorings
                    .Include(ps => ps.Match)
                    .Where(ps => ps.PlayerId == id)
                    .ToListAsync();

                if (!scorings.Any())
                {
                    return Ok(new
                    {
                        success = true,
                        message = "Cầu thủ chưa có thống kê",
                        data = new
                        {
                            totalMatches = 0,
                            totalPoints = 0,
                            averagePoints = 0.0,
                            highestScore = 0,
                            winRate = 0.0,
                            currentStreak = 0
                        }
                    });
                }

                var totalMatches = scorings.Select(ps => ps.MatchId).Distinct().Count();
                var totalPoints = scorings.Sum(ps => ps.Points);
                var averagePoints = (double)totalPoints / totalMatches;

                var matchScores = scorings
                    .GroupBy(ps => ps.MatchId)
                    .Select(g => new
                    {
                        matchId = g.Key,
                        points = g.Sum(ps => ps.Points),
                        match = g.First().Match
                    })
                    .OrderByDescending(m => m.match.MatchDate)
                    .ToList();

                var highestScore = matchScores.Max(m => m.points);

                // Calculate win rate (assuming completed matches with valid scores)
                var completedMatches = matchScores
                    .Where(m => m.match.Status == "Đã kết thúc" && 
                               m.match.ScoreTeamA.HasValue && 
                               m.match.ScoreTeamB.HasValue)
                    .ToList();

                var wins = completedMatches.Count(m => 
                    (m.match.TeamA == player.Team?.Name && m.match.ScoreTeamA > m.match.ScoreTeamB) ||
                    (m.match.TeamB == player.Team?.Name && m.match.ScoreTeamB > m.match.ScoreTeamA)
                );

                var winRate = completedMatches.Any() ? (double)wins / completedMatches.Count * 100 : 0;

                // Current streak (consecutive matches with points)
                var currentStreak = 0;
                foreach (var match in matchScores)
                {
                    if (match.points > 0)
                        currentStreak++;
                    else
                        break;
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy thống kê tổng quan thành công",
                    data = new
                    {
                        totalMatches = totalMatches,
                        totalPoints = totalPoints,
                        averagePoints = Math.Round(averagePoints, 2),
                        highestScore = highestScore,
                        winRate = Math.Round(winRate, 2),
                        currentStreak = currentStreak,
                        recentForm = matchScores.Take(5).Select(m => m.points).ToList()
                    }
                });
            }
            catch (Exception ex)
            {
                return Ok(new
                {
                    success = false,
                    message = $"Lỗi: {ex.Message}"
                });
            }
        }
    }
}
