using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class MatchesApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public MatchesApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy danh sách tất cả trận đấu
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<object>> GetMatches(string? search = null, int page = 1, int pageSize = 10)
        {
            try
            {
                var query = _context.Matches
                    .Include(m => m.Tournament)
                    .ThenInclude(t => t.Sports)
                    .AsQueryable();

                // Tìm kiếm nếu có
                if (!string.IsNullOrEmpty(search))
                {
                    query = query.Where(m => 
                        m.TeamA.Contains(search) || 
                        m.TeamB.Contains(search) ||
                        m.Tournament.Name.Contains(search));
                }

                // Tính tổng số record
                var totalRecords = await query.CountAsync();

                // Phân trang
                var matches = await query
                    .OrderByDescending(m => m.MatchDate)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(m => new
                    {
                        m.Id,
                        m.TeamA,
                        m.TeamB,
                        m.MatchDate,
                        m.MatchTime,
                        m.Location,
                        m.ScoreTeamA,
                        m.ScoreTeamB,
                        Status = m.CalculatedStatus,
                        Tournament = new
                        {
                            m.Tournament.Id,
                            m.Tournament.Name,
                            Sports = new
                            {
                                m.Tournament.Sports.Id,
                                m.Tournament.Sports.Name,
                                m.Tournament.Sports.ImageUrl
                            }
                        }
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách trận đấu thành công",
                    data = matches,
                    pagination = new
                    {
                        currentPage = page,
                        pageSize = pageSize,
                        totalRecords = totalRecords,
                        totalPages = (int)Math.Ceiling((double)totalRecords / pageSize)
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy thông tin chi tiết một trận đấu
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetMatch(int id)
        {
            try
            {
                var match = await _context.Matches
                    .Include(m => m.Tournament)
                    .ThenInclude(t => t.Sports)
                    .Where(m => m.Id == id)
                    .Select(m => new
                    {
                        m.Id,
                        m.TeamA,
                        m.TeamB,
                        m.MatchDate,
                        m.MatchTime,
                        m.Location,
                        m.ScoreTeamA,
                        m.ScoreTeamB,
                        m.GroupName,
                        m.Round,
                        Status = m.CalculatedStatus,
                        m.HighlightsVideoUrl,
                        m.LiveStreamUrl,
                        m.VideoDescription,
                        Tournament = new
                        {
                            m.Tournament.Id,
                            m.Tournament.Name,
                            m.Tournament.Description,
                            Sports = new
                            {
                                m.Tournament.Sports.Id,
                                m.Tournament.Sports.Name,
                                m.Tournament.Sports.ImageUrl
                            }
                        },
                        // Lấy thông tin chi tiết đội A
                        TeamAInfo = _context.Teams
                            .Where(t => t.Name == m.TeamA)
                            .Select(t => new
                            {
                                t.TeamId,
                                t.Name,
                                t.Coach,
                                t.LogoUrl
                            })
                            .FirstOrDefault(),
                        // Lấy thông tin chi tiết đội B
                        TeamBInfo = _context.Teams
                            .Where(t => t.Name == m.TeamB)
                            .Select(t => new
                            {
                                t.TeamId,
                                t.Name,
                                t.Coach,
                                t.LogoUrl
                            })
                            .FirstOrDefault(),
                        // Lấy thống kê ghi bàn
                        PlayerScorings = _context.PlayerScorings
                            .Where(ps => ps.MatchId == id)
                            .Include(ps => ps.Player)
                            .Select(ps => new
                            {
                                ps.Id,
                                ps.Points,
                                ps.ScoringTime,
                                ps.Notes,
                                Player = new
                                {
                                    ps.Player.PlayerId,
                                    ps.Player.FullName,
                                    ps.Player.Position,
                                    ps.Player.Number
                                }
                            })
                            .ToList()
                    })
                    .FirstOrDefaultAsync();

                if (match == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy trận đấu"
                    });
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin trận đấu thành công",
                    data = match
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy trận đấu theo giải đấu
        /// </summary>
        [HttpGet("tournament/{tournamentId}")]
        public async Task<ActionResult<object>> GetMatchesByTournament(int tournamentId)
        {
            try
            {
                var tournament = await _context.Tournaments.FindAsync(tournamentId);
                if (tournament == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy giải đấu"
                    });
                }

                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId)
                    .OrderBy(m => m.MatchDate)
                    .ThenBy(m => m.MatchTime)
                    .Select(m => new
                    {
                        m.Id,
                        m.TeamA,
                        m.TeamB,
                        m.MatchDate,
                        m.MatchTime,
                        m.Location,
                        m.ScoreTeamA,
                        m.ScoreTeamB,
                        m.GroupName,
                        m.Round,
                        Status = m.CalculatedStatus
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách trận đấu theo giải đấu thành công",
                    data = new
                    {
                        Tournament = new
                        {
                            tournament.Id,
                            tournament.Name
                        },
                        Matches = matches
                    },
                    count = matches.Count()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy trận đấu đang diễn ra (Live)
        /// </summary>
        [HttpGet("live")]
        public async Task<ActionResult<object>> GetLiveMatches()
        {
            try
            {
                var today = DateTime.Today;
                var liveMatches = await _context.Matches
                    .Include(m => m.Tournament)
                    .ThenInclude(t => t.Sports)
                    .Where(m => m.MatchDate.Date == today && 
                               (m.ScoreTeamA == null || m.ScoreTeamB == null)) // Chưa có kết quả
                    .Select(m => new
                    {
                        m.Id,
                        m.TeamA,
                        m.TeamB,
                        m.MatchDate,
                        m.MatchTime,
                        m.Location,
                        m.ScoreTeamA,
                        m.ScoreTeamB,
                        Tournament = new
                        {
                            m.Tournament.Name,
                            Sports = m.Tournament.Sports.Name
                        }
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách trận đấu đang diễn ra thành công",
                    data = liveMatches,
                    count = liveMatches.Count()
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy danh sách trận đấu có video trong giải đấu
        /// </summary>
        [HttpGet("tournament/{tournamentId}/videos")]
        public async Task<ActionResult<object>> GetTournamentMatchesWithVideos(int tournamentId)
        {
            try
            {
                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId && 
                               (m.HighlightsVideoUrl != null || m.LiveStreamUrl != null))
                    .OrderByDescending(m => m.MatchDate)
                    .Select(m => new
                    {
                        id = m.Id,
                        teamA = m.TeamA ?? "",
                        teamB = m.TeamB ?? "",
                        matchDate = m.MatchDate,
                        scoreTeamA = m.ScoreTeamA,
                        scoreTeamB = m.ScoreTeamB,
                        highlightsVideoUrl = m.HighlightsVideoUrl,
                        liveStreamUrl = m.LiveStreamUrl,
                        status = m.CalculatedStatus
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách trận đấu có video thành công",
                    data = matches,
                    count = matches.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }
    }
}
