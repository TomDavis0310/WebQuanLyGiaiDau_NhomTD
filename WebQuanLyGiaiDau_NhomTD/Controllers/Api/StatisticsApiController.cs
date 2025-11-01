using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    /// <summary>
    /// API Controller for Tournament Statistics
    /// Provides endpoints for top scorers, team statistics, and tournament analytics
    /// </summary>
    [Route("api/[controller]")]
    [ApiController]
    public class StatisticsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public StatisticsApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Get top scorers for a specific tournament
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        /// <param name="limit">Number of top scorers to return (default: 10)</param>
        [HttpGet("tournament/{tournamentId}/top-scorers")]
        public async Task<ActionResult<object>> GetTopScorers(int tournamentId, [FromQuery] int limit = 10)
        {
            try
            {
                // Verify tournament exists
                var tournament = await _context.Tournaments.FindAsync(tournamentId);
                if (tournament == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Không tìm thấy giải đấu"
                    });
                }

                // Get all matches in tournament
                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId)
                    .Select(m => m.Id)
                    .ToListAsync();

                if (!matches.Any())
                {
                    return Ok(new
                    {
                        success = true,
                        message = "Giải đấu chưa có trận đấu nào",
                        data = new List<object>(),
                        count = 0
                    });
                }

                // Get top scorers from PlayerScorings
                var topScorers = await _context.PlayerScorings
                    .Include(ps => ps.Player)
                        .ThenInclude(p => p.Team)
                    .Where(ps => matches.Contains(ps.MatchId))
                    .GroupBy(ps => new { ps.PlayerId, ps.Player })
                    .Select(g => new
                    {
                        playerId = g.Key.PlayerId,
                        playerName = g.Key.Player!.FullName,
                        playerImage = g.Key.Player.ImageUrl,
                        teamId = g.Key.Player.TeamId,
                        teamName = g.Key.Player.Team != null ? g.Key.Player.Team.Name : "N/A",
                        teamLogo = g.Key.Player.Team != null ? g.Key.Player.Team.LogoUrl : null,
                        totalPoints = g.Sum(ps => ps.Points),
                        matchesPlayed = g.Select(ps => ps.MatchId).Distinct().Count(),
                        averagePoints = Math.Round((double)g.Sum(ps => ps.Points) / g.Select(ps => ps.MatchId).Distinct().Count(), 2)
                    })
                    .OrderByDescending(x => x.totalPoints)
                    .Take(limit)
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách vua phá lưới thành công",
                    data = topScorers,
                    count = topScorers.Count
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

        /// <summary>
        /// Get team statistics for a specific tournament
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        [HttpGet("tournament/{tournamentId}/team-stats")]
        public async Task<ActionResult<object>> GetTeamStatistics(int tournamentId)
        {
            try
            {
                // Verify tournament exists
                var tournament = await _context.Tournaments.FindAsync(tournamentId);
                if (tournament == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Không tìm thấy giải đấu"
                    });
                }

                // Get all matches in tournament
                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId && m.Status == "Đã kết thúc")
                    .ToListAsync();

                if (!matches.Any())
                {
                    return Ok(new
                    {
                        success = true,
                        message = "Giải đấu chưa có trận đấu nào kết thúc",
                        data = new List<object>(),
                        count = 0
                    });
                }

                // Get all unique teams in tournament
                var teamNames = matches
                    .SelectMany(m => new[] { m.TeamA, m.TeamB })
                    .Distinct()
                    .ToList();

                var teamStats = new List<object>();

                foreach (var teamName in teamNames)
                {
                    var teamMatches = matches.Where(m => m.TeamA == teamName || m.TeamB == teamName).ToList();
                    
                    var wins = teamMatches.Count(m =>
                        (m.TeamA == teamName && m.ScoreTeamA > m.ScoreTeamB) ||
                        (m.TeamB == teamName && m.ScoreTeamB > m.ScoreTeamA));

                    var draws = teamMatches.Count(m => m.ScoreTeamA == m.ScoreTeamB);
                    var losses = teamMatches.Count - wins - draws;

                    var totalGoalsScored = teamMatches.Sum(m => m.TeamA == teamName ? m.ScoreTeamA : m.ScoreTeamB);
                    var totalGoalsConceded = teamMatches.Sum(m => m.TeamA == teamName ? m.ScoreTeamB : m.ScoreTeamA);

                    // Get team info
                    var team = await _context.Teams.FirstOrDefaultAsync(t => t.Name == teamName);

                    teamStats.Add(new
                    {
                        teamId = team?.TeamId,
                        teamName = teamName,
                        teamLogo = team?.LogoUrl,
                        matchesPlayed = teamMatches.Count,
                        wins = wins,
                        draws = draws,
                        losses = losses,
                        goalsScored = totalGoalsScored,
                        goalsConceded = totalGoalsConceded,
                        goalDifference = totalGoalsScored - totalGoalsConceded,
                        points = (wins * 3) + draws, // Standard football point system
                        winRate = teamMatches.Count > 0 ? Math.Round((double)wins / teamMatches.Count * 100, 2) : 0
                    });
                }

                // Sort by points descending, then goal difference
                teamStats = teamStats
                    .OrderByDescending(t => ((dynamic)t).points)
                    .ThenByDescending(t => ((dynamic)t).goalDifference)
                    .ToList();

                return Ok(new
                {
                    success = true,
                    message = "Lấy thống kê đội bóng thành công",
                    data = teamStats,
                    count = teamStats.Count
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

        /// <summary>
        /// Get match statistics for a specific tournament
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        [HttpGet("tournament/{tournamentId}/match-stats")]
        public async Task<ActionResult<object>> GetMatchStatistics(int tournamentId)
        {
            try
            {
                // Verify tournament exists
                var tournament = await _context.Tournaments.FindAsync(tournamentId);
                if (tournament == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Không tìm thấy giải đấu"
                    });
                }

                // Get all matches in tournament
                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId)
                    .ToListAsync();

                if (!matches.Any())
                {
                    return Ok(new
                    {
                        success = true,
                        message = "Giải đấu chưa có trận đấu nào",
                        data = new { },
                        count = 0
                    });
                }

                var completedMatches = matches.Where(m => m.Status == "Đã kết thúc").ToList();
                var totalGoals = completedMatches.Sum(m => m.ScoreTeamA + m.ScoreTeamB);
                var averageGoals = completedMatches.Any() ? Math.Round((double)totalGoals / completedMatches.Count, 2) : 0;

                // Highest scoring match
                var highestScoringMatch = completedMatches
                    .OrderByDescending(m => m.ScoreTeamA + m.ScoreTeamB)
                    .FirstOrDefault();

                var matchStats = new
                {
                    totalMatches = matches.Count,
                    completedMatches = completedMatches.Count,
                    upcomingMatches = matches.Count(m => m.Status == "Sắp diễn ra"),
                    ongoingMatches = matches.Count(m => m.Status == "Đang diễn ra"),
                    totalGoals = totalGoals,
                    averageGoalsPerMatch = averageGoals,
                    highestScoringMatch = highestScoringMatch != null ? new
                    {
                        matchId = highestScoringMatch.Id,
                        teamA = highestScoringMatch.TeamA,
                        teamB = highestScoringMatch.TeamB,
                        scoreTeamA = highestScoringMatch.ScoreTeamA,
                        scoreTeamB = highestScoringMatch.ScoreTeamB,
                        totalGoals = highestScoringMatch.ScoreTeamA + highestScoringMatch.ScoreTeamB,
                        matchDate = highestScoringMatch.MatchDate
                    } : null
                };

                return Ok(new
                {
                    success = true,
                    message = "Lấy thống kê trận đấu thành công",
                    data = matchStats
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

        /// <summary>
        /// Get overview statistics for a tournament
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        [HttpGet("tournament/{tournamentId}/overview")]
        public async Task<ActionResult<object>> GetTournamentOverview(int tournamentId)
        {
            try
            {
                // Verify tournament exists
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Không tìm thấy giải đấu"
                    });
                }

                // Get matches
                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId)
                    .ToListAsync();

                // Get unique teams
                var uniqueTeams = matches
                    .SelectMany(m => new[] { m.TeamA, m.TeamB })
                    .Distinct()
                    .Count();

                // Get total players
                var matchIds = matches.Select(m => m.Id).ToList();
                var totalPlayers = await _context.PlayerScorings
                    .Where(ps => matchIds.Contains(ps.MatchId))
                    .Select(ps => ps.PlayerId)
                    .Distinct()
                    .CountAsync();

                // Get total goals
                var completedMatches = matches.Where(m => m.Status == "Đã kết thúc").ToList();
                var totalGoals = completedMatches.Sum(m => m.ScoreTeamA + m.ScoreTeamB);

                // Get top scorer
                var topScorer = await _context.PlayerScorings
                    .Include(ps => ps.Player)
                    .Where(ps => matchIds.Contains(ps.MatchId))
                    .GroupBy(ps => new { ps.PlayerId, ps.Player })
                    .Select(g => new
                    {
                        playerId = g.Key.PlayerId,
                        playerName = g.Key.Player!.FullName,
                        totalPoints = g.Sum(ps => ps.Points)
                    })
                    .OrderByDescending(x => x.totalPoints)
                    .FirstOrDefaultAsync();

                var overview = new
                {
                    tournamentId = tournament.Id,
                    tournamentName = tournament.Name,
                    sportName = tournament.Sports?.Name,
                    status = tournament.CalculatedStatus,
                    startDate = tournament.StartDate,
                    endDate = tournament.EndDate,
                    totalTeams = uniqueTeams,
                    totalPlayers = totalPlayers,
                    totalMatches = matches.Count,
                    completedMatches = completedMatches.Count,
                    totalGoals = totalGoals,
                    topScorer = topScorer
                };

                return Ok(new
                {
                    success = true,
                    message = "Lấy tổng quan giải đấu thành công",
                    data = overview
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
