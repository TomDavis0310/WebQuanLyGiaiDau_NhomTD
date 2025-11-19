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
                // Kiểm tra giải đấu tồn tại
                var tournamentExists = await _context.Tournaments
                    .AnyAsync(t => t.Id == id);

                if (!tournamentExists)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = $"Không tìm thấy giải đấu với ID {id}"
                    });
                }

                // Lấy thông tin matches
                var matches = await _context.Matches
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
                        m.ScoreTeamB,
                        Status = m.MatchDate < DateTime.Now.Date ? "completed" :
                                m.MatchDate == DateTime.Now.Date ? "ongoing" : "upcoming"
                    })
                    .ToListAsync();

                // Đếm matches sau khi đã load (client-side evaluation)
                int completedMatches = matches.Count(m => m.Status == "completed");
                int upcomingMatches = matches.Count(m => m.Status == "upcoming");

                // Lấy thông tin teams đã đăng ký
                var registeredTeams = await _context.TournamentTeams
                    .Where(tt => tt.TournamentId == id && tt.Status == "Approved")
                    .Include(tt => tt.Team)
                    .Select(tt => new
                    {
                        Id = tt.Team.TeamId,
                        Name = tt.Team.Name,
                        Coach = tt.Team.Coach,
                        LogoUrl = tt.Team.LogoUrl
                    })
                    .ToListAsync();

                // Lấy thông tin giải đấu
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .Where(t => t.Id == id)
                    .FirstOrDefaultAsync();

                if (tournament == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy giải đấu"
                    });
                }

                // Tạo response object
                var response = new
                {
                    tournament.Id,
                    tournament.Name,
                    tournament.Description,
                    tournament.StartDate,
                    tournament.EndDate,
                    tournament.Location,
                    tournament.ImageUrl,
                    tournament.RegistrationStatus,
                    tournament.MaxTeams,
                    tournament.TeamsPerGroup,
                    Sports = new
                    {
                        tournament.Sports.Id,
                        tournament.Sports.Name,
                        tournament.Sports.ImageUrl,
                        TournamentCount = await _context.Tournaments.CountAsync(x => x.SportsId == tournament.SportsId)
                    },
                    // Thêm các trường cần thiết
                    RegisteredTeamsCount = registeredTeams.Count,
                    TotalMatches = matches.Count,
                    CompletedMatches = completedMatches,
                    UpcomingMatches = upcomingMatches,
                    AllowChampionVoting = true, // Mặc định cho phép vote
                    UserHasVoted = false, // TODO: Check based on user authentication
                    UserVotedTeamName = (string?)null,
                    Matches = matches,
                    RegisteredTeams = registeredTeams
                };

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin giải đấu thành công",
                    data = response
                });
            }
            catch (Exception ex)
            {
                // Log chi tiết lỗi
                Console.WriteLine($"ERROR in GetTournament({id}): {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");
                
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
