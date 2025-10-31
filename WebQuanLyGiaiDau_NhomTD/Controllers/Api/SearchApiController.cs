using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class SearchApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SearchApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Global search across all content types
        /// </summary>
        /// <param name="query">Search query string</param>
        /// <param name="types">Content types to search (teams, players, matches, news, tournaments)</param>
        /// <param name="limit">Maximum results per type</param>
        [HttpGet]
        public async Task<ActionResult<object>> GlobalSearch(
            [FromQuery] string query,
            [FromQuery] string? types = null,
            [FromQuery] int limit = 10)
        {
            if (string.IsNullOrWhiteSpace(query))
            {
                return BadRequest(new { message = "Query parameter is required" });
            }

            try
            {
                var searchTypes = string.IsNullOrEmpty(types) 
                    ? new[] { "teams", "players", "matches", "news", "tournaments" }
                    : types.Split(',').Select(t => t.Trim().ToLower()).ToArray();

                var results = new Dictionary<string, object>();

                // Search Teams
                if (searchTypes.Contains("teams"))
                {
                    var teams = await _context.Teams
                        .Where(t => t.Name.Contains(query) || t.Coach.Contains(query))
                        .Take(limit)
                        .Select(t => new
                        {
                            id = t.TeamId,
                            name = t.Name,
                            coach = t.Coach,
                            logo = t.LogoUrl,
                            type = "team"
                        })
                        .ToListAsync();
                    results["teams"] = teams;
                }

                // Search Players
                if (searchTypes.Contains("players"))
                {
                    var players = await _context.Players
                        .Include(p => p.Team)
                        .Where(p => p.FullName.Contains(query) || 
                                   p.Position.Contains(query) ||
                                   (p.Team != null && p.Team.Name.Contains(query)))
                        .Take(limit)
                        .Select(p => new
                        {
                            id = p.PlayerId,
                            fullName = p.FullName,
                            position = p.Position,
                            number = p.Number,
                            teamName = p.Team != null ? p.Team.Name : null,
                            imageUrl = p.ImageUrl,
                            type = "player"
                        })
                        .ToListAsync();
                    results["players"] = players;
                }

                // Search Matches
                if (searchTypes.Contains("matches"))
                {
                    var matches = await _context.Matches
                        .Include(m => m.Tournament)
                        .Where(m => m.TeamA.Contains(query) || 
                                   m.TeamB.Contains(query) ||
                                   (m.Location != null && m.Location.Contains(query)) ||
                                   (m.Tournament != null && m.Tournament.Name.Contains(query)))
                        .Take(limit)
                        .Select(m => new
                        {
                            id = m.Id,
                            teamA = m.TeamA,
                            teamB = m.TeamB,
                            scoreA = m.ScoreTeamA,
                            scoreB = m.ScoreTeamB,
                            matchDate = m.MatchDate,
                            location = m.Location,
                            tournamentName = m.Tournament != null ? m.Tournament.Name : null,
                            status = m.CalculatedStatus,
                            type = "match"
                        })
                        .ToListAsync();
                    results["matches"] = matches;
                }

                // Search News
                if (searchTypes.Contains("news"))
                {
                    var news = await _context.News
                        .Where(n => n.Title.Contains(query) || 
                                   (n.Summary != null && n.Summary.Contains(query)) ||
                                   (n.Category != null && n.Category.Contains(query)))
                        .Take(limit)
                        .Select(n => new
                        {
                            id = n.NewsId,
                            title = n.Title,
                            summary = n.Summary,
                            category = n.Category,
                            imageUrl = n.ImageUrl,
                            publishedDate = n.PublishDate,
                            isFeatured = n.IsFeatured,
                            type = "news"
                        })
                        .ToListAsync();
                    results["news"] = news;
                }

                // Search Tournaments
                if (searchTypes.Contains("tournaments"))
                {
                    var tournaments = await _context.Tournaments
                        .Include(t => t.Sports)
                        .Where(t => t.Name.Contains(query) || 
                                   (t.Description != null && t.Description.Contains(query)) ||
                                   (t.Location != null && t.Location.Contains(query)) ||
                                   (t.Sports != null && t.Sports.Name.Contains(query)))
                        .Take(limit)
                        .Select(t => new
                        {
                            id = t.Id,
                            name = t.Name,
                            description = t.Description,
                            location = t.Location,
                            startDate = t.StartDate,
                            endDate = t.EndDate,
                            imageUrl = t.ImageUrl,
                            sportName = t.Sports != null ? t.Sports.Name : null,
                            status = t.CalculatedStatus,
                            type = "tournament"
                        })
                        .ToListAsync();
                    results["tournaments"] = tournaments;
                }

                // Calculate total results
                var totalResults = results.Values.Sum(v => 
                {
                    if (v is System.Collections.ICollection collection)
                        return collection.Count;
                    return 0;
                });

                return Ok(new
                {
                    query = query,
                    totalResults = totalResults,
                    results = results
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error performing search", error = ex.Message });
            }
        }

        /// <summary>
        /// Search teams with filters
        /// </summary>
        [HttpGet("teams")]
        public async Task<ActionResult<object>> SearchTeams(
            [FromQuery] string? query = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                var teamsQuery = _context.Teams.AsQueryable();

                if (!string.IsNullOrWhiteSpace(query))
                {
                    teamsQuery = teamsQuery.Where(t => 
                        t.Name.Contains(query) || 
                        t.Coach.Contains(query));
                }

                var totalCount = await teamsQuery.CountAsync();
                var teams = await teamsQuery
                    .OrderBy(t => t.Name)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(t => new
                    {
                        teamId = t.TeamId,
                        name = t.Name,
                        coach = t.Coach,
                        logo = t.LogoUrl
                    })
                    .ToListAsync();

                return Ok(new
                {
                    query = query,
                    totalCount = totalCount,
                    page = page,
                    pageSize = pageSize,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize),
                    data = teams
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error searching teams", error = ex.Message });
            }
        }

        /// <summary>
        /// Search players with filters
        /// </summary>
        [HttpGet("players")]
        public async Task<ActionResult<object>> SearchPlayers(
            [FromQuery] string? query = null,
            [FromQuery] string? position = null,
            [FromQuery] int? teamId = null,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            try
            {
                var playersQuery = _context.Players
                    .Include(p => p.Team)
                    .AsQueryable();

                if (!string.IsNullOrWhiteSpace(query))
                {
                    playersQuery = playersQuery.Where(p => 
                        p.FullName.Contains(query) ||
                        (p.Team != null && p.Team.Name.Contains(query)));
                }

                if (!string.IsNullOrWhiteSpace(position))
                {
                    playersQuery = playersQuery.Where(p => p.Position.Contains(position));
                }

                if (teamId.HasValue)
                {
                    playersQuery = playersQuery.Where(p => p.TeamId == teamId.Value);
                }

                var totalCount = await playersQuery.CountAsync();
                var players = await playersQuery
                    .OrderBy(p => p.FullName)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(p => new
                    {
                        playerId = p.PlayerId,
                        fullName = p.FullName,
                        position = p.Position,
                        number = p.Number,
                        teamId = p.TeamId,
                        teamName = p.Team != null ? p.Team.Name : null,
                        imageUrl = p.ImageUrl
                    })
                    .ToListAsync();

                return Ok(new
                {
                    query = query,
                    filters = new { position, teamId },
                    totalCount = totalCount,
                    page = page,
                    pageSize = pageSize,
                    totalPages = (int)Math.Ceiling((double)totalCount / pageSize),
                    data = players
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error searching players", error = ex.Message });
            }
        }

        /// <summary>
        /// Get search suggestions (autocomplete)
        /// </summary>
        [HttpGet("suggestions")]
        public async Task<ActionResult<object>> GetSuggestions(
            [FromQuery] string query,
            [FromQuery] int limit = 5)
        {
            if (string.IsNullOrWhiteSpace(query) || query.Length < 2)
            {
                return Ok(new { suggestions = new List<object>() });
            }

            try
            {
                var suggestions = new List<object>();

                // Team suggestions
                var teamSuggestions = await _context.Teams
                    .Where(t => t.Name.Contains(query))
                    .Take(limit)
                    .Select(t => new
                    {
                        text = t.Name,
                        type = "team",
                        id = t.TeamId,
                        subtitle = "Đội bóng"
                    })
                    .ToListAsync();
                suggestions.AddRange(teamSuggestions);

                // Player suggestions
                var playerSuggestions = await _context.Players
                    .Include(p => p.Team)
                    .Where(p => p.FullName.Contains(query))
                    .Take(limit)
                    .Select(p => new
                    {
                        text = p.FullName,
                        type = "player",
                        id = p.PlayerId,
                        subtitle = p.Team != null ? p.Team.Name : "Cầu thủ"
                    })
                    .ToListAsync();
                suggestions.AddRange(playerSuggestions);

                // Tournament suggestions
                var tournamentSuggestions = await _context.Tournaments
                    .Where(t => t.Name.Contains(query))
                    .Take(limit)
                    .Select(t => new
                    {
                        text = t.Name,
                        type = "tournament",
                        id = t.Id,
                        subtitle = "Giải đấu"
                    })
                    .ToListAsync();
                suggestions.AddRange(tournamentSuggestions);

                return Ok(new
                {
                    query = query,
                    suggestions = suggestions.Take(limit * 3)
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error getting suggestions", error = ex.Message });
            }
        }

        /// <summary>
        /// Get popular search terms
        /// </summary>
        [HttpGet("popular")]
        public async Task<ActionResult<object>> GetPopularSearches()
        {
            try
            {
                // Get top teams by name (placeholder for actual popularity tracking)
                var popularTeams = await _context.Teams
                    .OrderBy(t => t.Name)
                    .Take(5)
                    .Select(t => new
                    {
                        text = t.Name,
                        type = "team",
                        id = t.TeamId
                    })
                    .ToListAsync();

                // Get featured tournaments
                var popularTournaments = await _context.Tournaments
                    .Where(t => t.StartDate <= DateTime.Now && t.EndDate >= DateTime.Now)
                    .OrderByDescending(t => t.StartDate)
                    .Take(3)
                    .Select(t => new
                    {
                        text = t.Name,
                        type = "tournament",
                        id = t.Id
                    })
                    .ToListAsync();

                var popularSearches = new List<object>();
                popularSearches.AddRange(popularTournaments);
                popularSearches.AddRange(popularTeams.Take(3));

                return Ok(new
                {
                    popularSearches = popularSearches
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error getting popular searches", error = ex.Message });
            }
        }
    }
}
