using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class TournamentApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public TournamentApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy danh sách tất cả giải đấu
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<IEnumerable<object>>> GetTournaments()
        {
            try
            {
                var tournaments = await _context.Tournaments
                    .Include(t => t.Sports)
                    .Select(t => new
                    {
                        t.Id,
                        t.Name,
                        t.Description,
                        t.StartDate,
                        t.EndDate,
                        t.Location,
                        t.ImageUrl,
                        t.RegistrationStatus,
                        t.MaxTeams,
                        Sports = new
                        {
                            t.Sports.Id,
                            t.Sports.Name,
                            t.Sports.ImageUrl
                        }
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách giải đấu thành công",
                    data = tournaments,
                    count = tournaments.Count()
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
        /// Lấy thông tin chi tiết một giải đấu
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetTournament(int id)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .Where(t => t.Id == id)
                    .Select(t => new
                    {
                        t.Id,
                        t.Name,
                        t.Description,
                        t.StartDate,
                        t.EndDate,
                        t.Location,
                        t.ImageUrl,
                        t.RegistrationStatus,
                        t.MaxTeams,
                        t.TeamsPerGroup,
                        Sports = new
                        {
                            t.Sports.Id,
                            t.Sports.Name,
                            t.Sports.ImageUrl
                        },
                        // Thêm thông tin matches
                        Matches = _context.Matches
                            .Where(m => m.TournamentId == id)
                            .Select(m => new
                            {
                                m.Id,
                                m.TeamA,
                                m.TeamB,
                                m.MatchDate,
                                m.MatchTime,
                                m.Location,
                                m.ScoreTeamA,
                                m.ScoreTeamB
                            })
                            .ToList(),
                        // Thông tin teams đã đăng ký
                        RegisteredTeams = _context.TournamentTeams
                            .Where(tt => tt.TournamentId == id && tt.Status == "Approved")
                            .Include(tt => tt.Team)
                            .Select(tt => new
                            {
                                tt.Team.TeamId,
                                tt.Team.Name,
                                tt.Team.Coach,
                                tt.Team.LogoUrl
                            })
                            .ToList()
                    })
                    .FirstOrDefaultAsync();

                if (tournament == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy giải đấu"
                    });
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin giải đấu thành công",
                    data = tournament
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
        /// Lấy danh sách giải đấu theo môn thể thao
        /// </summary>
        [HttpGet("by-sport/{sportsId}")]
        public async Task<ActionResult<object>> GetTournamentsBySport(int sportsId)
        {
            try
            {
                var tournaments = await _context.Tournaments
                    .Include(t => t.Sports)
                    .Where(t => t.SportsId == sportsId)
                    .Select(t => new
                    {
                        t.Id,
                        t.Name,
                        t.Description,
                        t.StartDate,
                        t.EndDate,
                        t.Location,
                        t.ImageUrl,
                        t.RegistrationStatus,
                        t.MaxTeams
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách giải đấu theo môn thể thao thành công",
                    data = tournaments,
                    count = tournaments.Count()
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
