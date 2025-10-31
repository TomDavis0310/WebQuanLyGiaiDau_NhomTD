using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;
using System.Security.Claims;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DashboardApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public DashboardApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        private string GetUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;
        }

        /// <summary>
        /// Get user dashboard overview
        /// </summary>
        [HttpGet("overview")]
        public async Task<ActionResult<object>> GetDashboardOverview()
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                // Get user's registered tournaments
                var registeredTournaments = await _context.TournamentTeams
                    .Include(tt => tt.Tournament)
                        .ThenInclude(t => t.Sports)
                    .Include(tt => tt.Team)
                    .Where(tt => tt.Team!.UserId == userId)
                    .Select(tt => new
                    {
                        tournamentId = tt.TournamentId,
                        tournamentName = tt.Tournament!.Name,
                        teamId = tt.TeamId,
                        teamName = tt.Team!.Name,
                        sportName = tt.Tournament.Sports != null ? tt.Tournament.Sports.Name : null,
                        status = tt.Status,
                        registrationDate = tt.RegistrationDate,
                        tournamentStatus = tt.Tournament.CalculatedStatus,
                        startDate = tt.Tournament.StartDate,
                        endDate = tt.Tournament.EndDate
                    })
                    .OrderByDescending(tt => tt.registrationDate)
                    .Take(5)
                    .ToListAsync();

                // Get user's teams
                var userTeams = await _context.Teams
                    .Where(t => t.UserId == userId)
                    .Select(t => new
                    {
                        teamId = t.TeamId,
                        name = t.Name,
                        coach = t.Coach,
                        logo = t.LogoUrl,
                        playersCount = t.Players.Count
                    })
                    .ToListAsync();

                // Get upcoming matches for user's teams
                var teamIds = userTeams.Select(t => t.teamId).ToList();
                var upcomingMatches = await _context.Matches
                    .Include(m => m.Tournament)
                    .Where(m => (m.TeamAId.HasValue && teamIds.Contains(m.TeamAId.Value)) ||
                               (m.TeamBId.HasValue && teamIds.Contains(m.TeamBId.Value)))
                    .Where(m => m.MatchDate >= DateTime.Now)
                    .OrderBy(m => m.MatchDate)
                    .Take(5)
                    .Select(m => new
                    {
                        matchId = m.Id,
                        teamA = m.TeamA,
                        teamB = m.TeamB,
                        matchDate = m.MatchDate,
                        matchTime = m.MatchTime,
                        location = m.Location,
                        tournamentName = m.Tournament != null ? m.Tournament.Name : null,
                        status = m.CalculatedStatus
                    })
                    .ToListAsync();

                // Statistics
                var stats = new
                {
                    totalTeams = userTeams.Count,
                    totalTournaments = registeredTournaments.Count,
                    upcomingMatchesCount = upcomingMatches.Count,
                    activeTournaments = registeredTournaments.Count(t => 
                        t.tournamentStatus == "Giải đấu đang diễn ra" || 
                        t.tournamentStatus == "Mở đăng ký")
                };

                return Ok(new
                {
                    stats = stats,
                    myTeams = userTeams,
                    myTournaments = registeredTournaments,
                    upcomingMatches = upcomingMatches
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error loading dashboard", error = ex.Message });
            }
        }

        /// <summary>
        /// Get user's registered tournaments
        /// </summary>
        [HttpGet("my-tournaments")]
        public async Task<ActionResult<object>> GetMyTournaments(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                var query = _context.TournamentTeams
                    .Include(tt => tt.Tournament)
                        .ThenInclude(t => t.Sports)
                    .Include(tt => tt.Team)
                    .Where(tt => tt.Team!.UserId == userId);

                var totalCount = await query.CountAsync();
                var tournaments = await query
                    .OrderByDescending(tt => tt.RegistrationDate)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(tt => new
                    {
                        tournamentId = tt.TournamentId,
                        tournamentName = tt.Tournament!.Name,
                        description = tt.Tournament.Description,
                        location = tt.Tournament.Location,
                        imageUrl = tt.Tournament.ImageUrl,
                        startDate = tt.Tournament.StartDate,
                        endDate = tt.Tournament.EndDate,
                        sportName = tt.Tournament.Sports != null ? tt.Tournament.Sports.Name : null,
                        teamId = tt.TeamId,
                        teamName = tt.Team!.Name,
                        teamLogo = tt.Team.LogoUrl,
                        status = tt.Status,
                        registrationDate = tt.RegistrationDate,
                        tournamentStatus = tt.Tournament.CalculatedStatus
                    })
                    .ToListAsync();

                return Ok(new
                {
                    totalCount = totalCount,
                    page = page,
                    pageSize = pageSize,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize),
                    data = tournaments
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error loading tournaments", error = ex.Message });
            }
        }

        /// <summary>
        /// Get user's teams
        /// </summary>
        [HttpGet("my-teams")]
        public async Task<ActionResult<object>> GetMyTeams()
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                var teams = await _context.Teams
                    .Include(t => t.Players)
                    .Where(t => t.UserId == userId)
                    .Select(t => new
                    {
                        teamId = t.TeamId,
                        name = t.Name,
                        coach = t.Coach,
                        logo = t.LogoUrl,
                        playersCount = t.Players.Count,
                        players = t.Players.Select(p => new
                        {
                            playerId = p.PlayerId,
                            fullName = p.FullName,
                            position = p.Position,
                            number = p.Number,
                            imageUrl = p.ImageUrl
                        }).ToList()
                    })
                    .ToListAsync();

                return Ok(new { data = teams });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error loading teams", error = ex.Message });
            }
        }

        /// <summary>
        /// Get upcoming matches for user's teams
        /// </summary>
        [HttpGet("upcoming-matches")]
        public async Task<ActionResult<object>> GetUpcomingMatches(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                // Get user's team IDs
                var teamIds = await _context.Teams
                    .Where(t => t.UserId == userId)
                    .Select(t => t.TeamId)
                    .ToListAsync();

                if (!teamIds.Any())
                {
                    return Ok(new
                    {
                        totalCount = 0,
                        page = page,
                        pageSize = pageSize,
                        totalPages = 0,
                        data = new List<object>()
                    });
                }

                var query = _context.Matches
                    .Include(m => m.Tournament)
                    .Where(m => (m.TeamAId.HasValue && teamIds.Contains(m.TeamAId.Value)) ||
                               (m.TeamBId.HasValue && teamIds.Contains(m.TeamBId.Value)))
                    .Where(m => m.MatchDate >= DateTime.Now);

                var totalCount = await query.CountAsync();
                var matches = await query
                    .OrderBy(m => m.MatchDate)
                    .ThenBy(m => m.MatchTime)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(m => new
                    {
                        matchId = m.Id,
                        teamA = m.TeamA,
                        teamAId = m.TeamAId,
                        teamB = m.TeamB,
                        teamBId = m.TeamBId,
                        scoreA = m.ScoreTeamA,
                        scoreB = m.ScoreTeamB,
                        matchDate = m.MatchDate,
                        matchTime = m.MatchTime,
                        location = m.Location,
                        tournamentId = m.TournamentId,
                        tournamentName = m.Tournament != null ? m.Tournament.Name : null,
                        status = m.CalculatedStatus,
                        isMyTeamA = m.TeamAId.HasValue && teamIds.Contains(m.TeamAId.Value),
                        isMyTeamB = m.TeamBId.HasValue && teamIds.Contains(m.TeamBId.Value)
                    })
                    .ToListAsync();

                return Ok(new
                {
                    totalCount = totalCount,
                    page = page,
                    pageSize = pageSize,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize),
                    data = matches
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error loading matches", error = ex.Message });
            }
        }

        /// <summary>
        /// Get user's match history
        /// </summary>
        [HttpGet("match-history")]
        public async Task<ActionResult<object>> GetMatchHistory(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                var teamIds = await _context.Teams
                    .Where(t => t.UserId == userId)
                    .Select(t => t.TeamId)
                    .ToListAsync();

                if (!teamIds.Any())
                {
                    return Ok(new
                    {
                        totalCount = 0,
                        page = page,
                        pageSize = pageSize,
                        totalPages = 0,
                        data = new List<object>()
                    });
                }

                var query = _context.Matches
                    .Include(m => m.Tournament)
                    .Where(m => (m.TeamAId.HasValue && teamIds.Contains(m.TeamAId.Value)) ||
                               (m.TeamBId.HasValue && teamIds.Contains(m.TeamBId.Value)))
                    .Where(m => m.MatchDate < DateTime.Now);

                var totalCount = await query.CountAsync();
                var matches = await query
                    .OrderByDescending(m => m.MatchDate)
                    .ThenByDescending(m => m.MatchTime)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(m => new
                    {
                        matchId = m.Id,
                        teamA = m.TeamA,
                        teamAId = m.TeamAId,
                        teamB = m.TeamB,
                        teamBId = m.TeamBId,
                        scoreA = m.ScoreTeamA,
                        scoreB = m.ScoreTeamB,
                        matchDate = m.MatchDate,
                        matchTime = m.MatchTime,
                        location = m.Location,
                        tournamentId = m.TournamentId,
                        tournamentName = m.Tournament != null ? m.Tournament.Name : null,
                        status = m.CalculatedStatus,
                        isMyTeamA = m.TeamAId.HasValue && teamIds.Contains(m.TeamAId.Value),
                        isMyTeamB = m.TeamBId.HasValue && teamIds.Contains(m.TeamBId.Value)
                    })
                    .ToListAsync();

                return Ok(new
                {
                    totalCount = totalCount,
                    page = page,
                    pageSize = pageSize,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize),
                    data = matches
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error loading match history", error = ex.Message });
            }
        }

        /// <summary>
        /// Get user activity timeline
        /// </summary>
        [HttpGet("activity")]
        public async Task<ActionResult<object>> GetActivity(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                var userId = GetUserId();
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "User not authenticated" });
                }

                var activities = new List<object>();

                // Recent tournament registrations
                var recentRegistrations = await _context.TournamentTeams
                    .Include(tt => tt.Tournament)
                    .Include(tt => tt.Team)
                    .Where(tt => tt.Team!.UserId == userId)
                    .OrderByDescending(tt => tt.RegistrationDate)
                    .Take(10)
                    .Select(tt => new
                    {
                        type = "tournament_registration",
                        date = tt.RegistrationDate,
                        title = $"Đăng ký giải {tt.Tournament!.Name}",
                        description = $"Đội {tt.Team!.Name} đã đăng ký tham gia",
                        status = tt.Status,
                        tournamentId = tt.TournamentId,
                        teamId = tt.TeamId
                    })
                    .ToListAsync();

                activities.AddRange(recentRegistrations);

                // Sort by date
                var sortedActivities = activities
                    .OrderByDescending(a => 
                    {
                        var prop = a.GetType().GetProperty("date");
                        return prop?.GetValue(a) as DateTime? ?? DateTime.MinValue;
                    })
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToList();

                return Ok(new
                {
                    page = page,
                    pageSize = pageSize,
                    totalCount = activities.Count,
                    totalPages = (int)Math.Ceiling((double)activities.Count / pageSize),
                    data = sortedActivities
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error loading activity", error = ex.Message });
            }
        }
    }
}
