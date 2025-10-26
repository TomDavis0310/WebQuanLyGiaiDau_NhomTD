using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TeamsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public TeamsApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy danh sách tất cả đội bóng
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<object>> GetTeams(string? search = null)
        {
            try
            {
                var query = _context.Teams.AsQueryable();

                // Tìm kiếm nếu có
                if (!string.IsNullOrEmpty(search))
                {
                    query = query.Where(t => 
                        t.Name.Contains(search) || 
                        t.Coach.Contains(search));
                }

                var teams = await query
                    .Include(t => t.Players)
                    .Select(t => new
                    {
                        t.TeamId,
                        t.Name,
                        t.Coach,
                        t.LogoUrl,
                        PlayerCount = t.Players.Count(),
                        Players = t.Players.Select(p => new
                        {
                            p.PlayerId,
                            p.FullName,
                            p.Position,
                            p.Number,
                            p.ImageUrl
                        }).ToList()
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách đội bóng thành công",
                    data = teams,
                    count = teams.Count()
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
        /// Lấy thông tin chi tiết một đội bóng
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetTeam(int id)
        {
            try
            {
                var team = await _context.Teams
                    .Include(t => t.Players)
                    .Where(t => t.TeamId == id)
                    .Select(t => new
                    {
                        t.TeamId,
                        t.Name,
                        t.Coach,
                        t.LogoUrl,
                        t.UserId,
                        Players = t.Players.Select(p => new
                        {
                            p.PlayerId,
                            p.FullName,
                            p.Position,
                            p.Number,
                            p.ImageUrl
                        }).ToList(),
                        // Lấy lịch sử thi đấu
                        MatchHistory = _context.Matches
                            .Where(m => m.TeamA == t.Name || m.TeamB == t.Name)
                            .Include(m => m.Tournament!)
                            .ThenInclude(t => t.Sports!)
                            .Select(m => new
                            {
                                m.Id,
                                m.TeamA,
                                m.TeamB,
                                m.MatchDate,
                                m.ScoreTeamA,
                                m.ScoreTeamB,
                                Tournament = new
                                {
                                    m.Tournament!.Name,
                                    SportsName = m.Tournament.Sports!.Name
                                }
                            })
                            .OrderByDescending(m => m.MatchDate)
                            .Take(10)
                            .ToList()
                    })
                    .FirstOrDefaultAsync();

                if (team == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy đội bóng"
                    });
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin đội bóng thành công",
                    data = team
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
        /// Lấy danh sách cầu thủ của một đội
        /// </summary>
        [HttpGet("{teamId}/players")]
        public async Task<ActionResult<object>> GetTeamPlayers(int teamId)
        {
            try
            {
                var team = await _context.Teams.FindAsync(teamId);
                if (team == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy đội bóng"
                    });
                }

                var players = await _context.Players
                    .Where(p => p.TeamId == teamId)
                    .Select(p => new
                    {
                        p.PlayerId,
                        p.FullName,
                        p.Position,
                        p.Number,
                        p.ImageUrl,
                        Team = new
                        {
                            p.Team.TeamId,
                            p.Team.Name,
                            p.Team.Coach
                        }
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách cầu thủ thành công",
                    data = new
                    {
                        Team = new
                        {
                            team.TeamId,
                            team.Name,
                            team.Coach,
                            team.LogoUrl
                        },
                        Players = players
                    },
                    count = players.Count()
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
