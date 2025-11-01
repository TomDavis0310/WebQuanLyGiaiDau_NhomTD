using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.TempModels;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/tournament-management")]
    [ApiController]
    [Authorize]
    public class TournamentManagementApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<TournamentManagementApiController> _logger;

        public TournamentManagementApiController(
            ApplicationDbContext context,
            ILogger<TournamentManagementApiController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // ==================== MY TEAMS APIs ====================

        /// <summary>
        /// Get list of teams that belong to the current user
        /// </summary>
        [HttpGet("my-teams")]
        public async Task<ActionResult<ApiResponse<List<TeamDto>>>> GetMyTeams()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                
                var teams = await _context.Teams
                    .Where(t => t.UserId == userId)
                    .Include(t => t.Players)
                    .Select(t => new TeamDto
                    {
                        TeamId = t.TeamId,
                        Name = t.Name,
                        Coach = t.Coach,
                        LogoUrl = t.LogoUrl,
                        UserId = t.UserId,
                        PlayerCount = t.Players.Count()
                    })
                    .ToListAsync();

                return Ok(new ApiResponse<List<TeamDto>>
                {
                    Success = true,
                    Message = "Lấy danh sách đội thành công",
                    Data = teams,
                    Count = teams.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting my teams");
                return StatusCode(500, new ApiResponse<List<TeamDto>>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi lấy danh sách đội",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Create a new team
        /// </summary>
        [HttpPost("teams")]
        public async Task<ActionResult<ApiResponse<TeamDto>>> CreateTeam([FromBody] CreateTeamRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                // Check if team name already exists for this user
                var existingTeam = await _context.Teams
                    .FirstOrDefaultAsync(t => t.Name == request.Name && t.UserId == userId);

                if (existingTeam != null)
                {
                    return BadRequest(new ApiResponse<TeamDto>
                    {
                        Success = false,
                        Message = "Tên đội đã tồn tại"
                    });
                }

                var team = new Team
                {
                    Name = request.Name,
                    Coach = request.Coach,
                    LogoUrl = request.LogoUrl,
                    UserId = userId
                };

                _context.Teams.Add(team);
                await _context.SaveChangesAsync();

                var teamDto = new TeamDto
                {
                    TeamId = team.TeamId,
                    Name = team.Name,
                    Coach = team.Coach,
                    LogoUrl = team.LogoUrl,
                    UserId = team.UserId,
                    PlayerCount = 0
                };

                return Ok(new ApiResponse<TeamDto>
                {
                    Success = true,
                    Message = "Tạo đội thành công",
                    Data = teamDto
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating team");
                return StatusCode(500, new ApiResponse<TeamDto>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi tạo đội",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Update team information
        /// </summary>
        [HttpPut("teams/{teamId}")]
        public async Task<ActionResult<ApiResponse<TeamDto>>> UpdateTeam(int teamId, [FromBody] UpdateTeamRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var team = await _context.Teams.FindAsync(teamId);

                if (team == null)
                {
                    return NotFound(new ApiResponse<TeamDto>
                    {
                        Success = false,
                        Message = "Không tìm thấy đội"
                    });
                }

                // Check if user owns this team
                if (team.UserId != userId)
                {
                    return Forbid();
                }

                // Check if new name conflicts with another team
                if (request.Name != team.Name)
                {
                    var existingTeam = await _context.Teams
                        .FirstOrDefaultAsync(t => t.Name == request.Name && t.UserId == userId && t.TeamId != teamId);

                    if (existingTeam != null)
                    {
                        return BadRequest(new ApiResponse<TeamDto>
                        {
                            Success = false,
                            Message = "Tên đội đã tồn tại"
                        });
                    }
                }

                team.Name = request.Name;
                team.Coach = request.Coach;
                team.LogoUrl = request.LogoUrl;

                await _context.SaveChangesAsync();

                var playerCount = await _context.Players.CountAsync(p => p.TeamId == teamId);

                var teamDto = new TeamDto
                {
                    TeamId = team.TeamId,
                    Name = team.Name,
                    Coach = team.Coach,
                    LogoUrl = team.LogoUrl,
                    UserId = team.UserId,
                    PlayerCount = playerCount
                };

                return Ok(new ApiResponse<TeamDto>
                {
                    Success = true,
                    Message = "Cập nhật đội thành công",
                    Data = teamDto
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating team");
                return StatusCode(500, new ApiResponse<TeamDto>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi cập nhật đội",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Delete a team
        /// </summary>
        [HttpDelete("teams/{teamId}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteTeam(int teamId)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var team = await _context.Teams.FindAsync(teamId);

                if (team == null)
                {
                    return NotFound(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Không tìm thấy đội"
                    });
                }

                // Check if user owns this team
                if (team.UserId != userId)
                {
                    return Forbid();
                }

                // Check if team is registered in any tournament
                var hasRegistrations = await _context.TournamentTeams
                    .AnyAsync(tt => tt.TeamId == teamId);

                if (hasRegistrations)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Không thể xóa đội đã đăng ký giải đấu"
                    });
                }

                // Delete all players in the team first
                var players = await _context.Players.Where(p => p.TeamId == teamId).ToListAsync();
                _context.Players.RemoveRange(players);

                _context.Teams.Remove(team);
                await _context.SaveChangesAsync();

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Xóa đội thành công",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting team");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi xóa đội",
                    Error = ex.Message
                });
            }
        }

        // ==================== PLAYERS APIs ====================

        /// <summary>
        /// Get players of a team
        /// </summary>
        [HttpGet("teams/{teamId}/players")]
        public async Task<ActionResult<ApiResponse<List<PlayerDto>>>> GetTeamPlayers(int teamId)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var team = await _context.Teams.FindAsync(teamId);

                if (team == null)
                {
                    return NotFound(new ApiResponse<List<PlayerDto>>
                    {
                        Success = false,
                        Message = "Không tìm thấy đội"
                    });
                }

                // Check if user owns this team
                if (team.UserId != userId)
                {
                    return Forbid();
                }

                var players = await _context.Players
                    .Where(p => p.TeamId == teamId)
                    .Select(p => new PlayerDto
                    {
                        PlayerId = p.PlayerId,
                        FullName = p.FullName,
                        Position = p.Position,
                        Number = p.Number,
                        ImageUrl = p.ImageUrl,
                        TeamId = p.TeamId,
                        UserId = p.UserId
                    })
                    .ToListAsync();

                return Ok(new ApiResponse<List<PlayerDto>>
                {
                    Success = true,
                    Message = "Lấy danh sách cầu thủ thành công",
                    Data = players,
                    Count = players.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting team players");
                return StatusCode(500, new ApiResponse<List<PlayerDto>>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi lấy danh sách cầu thủ",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Add a player to a team
        /// </summary>
        [HttpPost("teams/{teamId}/players")]
        public async Task<ActionResult<ApiResponse<PlayerDto>>> AddPlayer(int teamId, [FromBody] CreatePlayerRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var team = await _context.Teams.FindAsync(teamId);

                if (team == null)
                {
                    return NotFound(new ApiResponse<PlayerDto>
                    {
                        Success = false,
                        Message = "Không tìm thấy đội"
                    });
                }

                // Check if user owns this team
                if (team.UserId != userId)
                {
                    return Forbid();
                }

                // Check if jersey number is already taken
                var existingPlayer = await _context.Players
                    .FirstOrDefaultAsync(p => p.TeamId == teamId && p.Number == request.Number);

                if (existingPlayer != null)
                {
                    return BadRequest(new ApiResponse<PlayerDto>
                    {
                        Success = false,
                        Message = "Số áo đã được sử dụng"
                    });
                }

                var player = new Player
                {
                    FullName = request.FullName,
                    Position = request.Position,
                    Number = request.Number,
                    ImageUrl = request.ImageUrl,
                    TeamId = teamId,
                    UserId = userId
                };

                _context.Players.Add(player);
                await _context.SaveChangesAsync();

                var playerDto = new PlayerDto
                {
                    PlayerId = player.PlayerId,
                    FullName = player.FullName,
                    Position = player.Position,
                    Number = player.Number,
                    ImageUrl = player.ImageUrl,
                    TeamId = player.TeamId,
                    UserId = player.UserId
                };

                return Ok(new ApiResponse<PlayerDto>
                {
                    Success = true,
                    Message = "Thêm cầu thủ thành công",
                    Data = playerDto
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error adding player");
                return StatusCode(500, new ApiResponse<PlayerDto>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi thêm cầu thủ",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Update player information
        /// </summary>
        [HttpPut("players/{playerId}")]
        public async Task<ActionResult<ApiResponse<PlayerDto>>> UpdatePlayer(int playerId, [FromBody] UpdatePlayerRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var player = await _context.Players
                    .Include(p => p.Team)
                    .FirstOrDefaultAsync(p => p.PlayerId == playerId);

                if (player == null)
                {
                    return NotFound(new ApiResponse<PlayerDto>
                    {
                        Success = false,
                        Message = "Không tìm thấy cầu thủ"
                    });
                }

                // Check if user owns the team
                if (player.Team.UserId != userId)
                {
                    return Forbid();
                }

                // Check if new jersey number conflicts
                if (request.Number != player.Number)
                {
                    var existingPlayer = await _context.Players
                        .FirstOrDefaultAsync(p => p.TeamId == player.TeamId && p.Number == request.Number && p.PlayerId != playerId);

                    if (existingPlayer != null)
                    {
                        return BadRequest(new ApiResponse<PlayerDto>
                        {
                            Success = false,
                            Message = "Số áo đã được sử dụng"
                        });
                    }
                }

                player.FullName = request.FullName;
                player.Position = request.Position;
                player.Number = request.Number;
                player.ImageUrl = request.ImageUrl;

                await _context.SaveChangesAsync();

                var playerDto = new PlayerDto
                {
                    PlayerId = player.PlayerId,
                    FullName = player.FullName,
                    Position = player.Position,
                    Number = player.Number,
                    ImageUrl = player.ImageUrl,
                    TeamId = player.TeamId,
                    UserId = player.UserId
                };

                return Ok(new ApiResponse<PlayerDto>
                {
                    Success = true,
                    Message = "Cập nhật cầu thủ thành công",
                    Data = playerDto
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating player");
                return StatusCode(500, new ApiResponse<PlayerDto>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi cập nhật cầu thủ",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Delete a player
        /// </summary>
        [HttpDelete("players/{playerId}")]
        public async Task<ActionResult<ApiResponse<bool>>> DeletePlayer(int playerId)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var player = await _context.Players
                    .Include(p => p.Team)
                    .FirstOrDefaultAsync(p => p.PlayerId == playerId);

                if (player == null)
                {
                    return NotFound(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Không tìm thấy cầu thủ"
                    });
                }

                // Check if user owns the team
                if (player.Team.UserId != userId)
                {
                    return Forbid();
                }

                _context.Players.Remove(player);
                await _context.SaveChangesAsync();

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Xóa cầu thủ thành công",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting player");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi xóa cầu thủ",
                    Error = ex.Message
                });
            }
        }

        // ==================== TOURNAMENT REGISTRATION APIs ====================

        /// <summary>
        /// Get available tournaments for registration
        /// </summary>
        [HttpGet("available-tournaments")]
        public async Task<ActionResult<ApiResponse<List<TournamentForRegistrationDto>>>> GetAvailableTournaments()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var now = DateTime.Now;

                // Get tournaments that are open for registration
                var tournaments = await _context.Tournaments
                    .Include(t => t.Sports)
                    .Include(t => t.TournamentFormat)
                    .Where(t => t.StartDate > now) // Future tournaments only
                    .Select(t => new TournamentForRegistrationDto
                    {
                        Id = t.Id,
                        Name = t.Name,
                        Description = t.Description,
                        SportsName = t.Sports != null ? t.Sports.Name : "",
                        SportsId = t.SportsId,
                        StartDate = t.StartDate,
                        EndDate = t.EndDate,
                        Location = t.Location,
                        MaxTeams = t.MaxTeams,
                        Format = t.TournamentFormat != null ? t.TournamentFormat.Name : null,
                        Status = t.CalculatedStatus,
                        ImageUrl = t.ImageUrl,
                        // Check if user already registered
                        IsRegistered = _context.TournamentTeams.Any(tt => 
                            tt.TournamentId == t.Id && 
                            _context.Teams.Any(team => team.TeamId == tt.TeamId && team.UserId == userId))
                    })
                    .OrderBy(t => t.StartDate)
                    .ToListAsync();

                return Ok(new ApiResponse<List<TournamentForRegistrationDto>>
                {
                    Success = true,
                    Message = "Lấy danh sách giải đấu thành công",
                    Data = tournaments,
                    Count = tournaments.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting available tournaments");
                return StatusCode(500, new ApiResponse<List<TournamentForRegistrationDto>>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi lấy danh sách giải đấu",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Register team for a tournament
        /// </summary>
        [HttpPost("tournaments/{tournamentId}/register")]
        public async Task<ActionResult<ApiResponse<bool>>> RegisterTournament(int tournamentId, [FromBody] TournamentRegistrationRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                // Validate tournament
                var tournament = await _context.Tournaments.FindAsync(tournamentId);
                if (tournament == null)
                {
                    return NotFound(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Không tìm thấy giải đấu"
                    });
                }

                // Check if tournament is still open
                if (tournament.StartDate <= DateTime.Now)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Giải đấu đã bắt đầu hoặc kết thúc"
                    });
                }

                // Validate team ownership
                var team = await _context.Teams.FindAsync(request.TeamId);
                if (team == null)
                {
                    return NotFound(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Không tìm thấy đội"
                    });
                }

                if (team.UserId != userId)
                {
                    return Forbid();
                }

                // Check if already registered
                var existingRegistration = await _context.TournamentTeams
                    .FirstOrDefaultAsync(tt => tt.TournamentId == tournamentId && tt.TeamId == request.TeamId);

                if (existingRegistration != null)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Đội đã đăng ký giải đấu này"
                    });
                }

                // Check team limit
                var currentTeamsCount = await _context.TournamentTeams
                    .CountAsync(tt => tt.TournamentId == tournamentId);

                if (tournament.MaxTeams.HasValue && currentTeamsCount >= tournament.MaxTeams.Value)
                {
                    return BadRequest(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Giải đấu đã đủ số lượng đội"
                    });
                }

                // Create registration
                var tournamentTeam = new TournamentTeam
                {
                    TournamentId = tournamentId,
                    TeamId = request.TeamId
                };

                _context.TournamentTeams.Add(tournamentTeam);
                await _context.SaveChangesAsync();

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Đăng ký giải đấu thành công",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error registering tournament");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi đăng ký giải đấu",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Unregister team from a tournament
        /// </summary>
        [HttpDelete("tournaments/{tournamentId}/register")]
        public async Task<ActionResult<ApiResponse<bool>>> UnregisterTournament(int tournamentId, [FromQuery] int teamId)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                // Validate team ownership
                var team = await _context.Teams.FindAsync(teamId);
                if (team == null || team.UserId != userId)
                {
                    return Forbid();
                }

                var registration = await _context.TournamentTeams
                    .FirstOrDefaultAsync(tt => tt.TournamentId == tournamentId && tt.TeamId == teamId);

                if (registration == null)
                {
                    return NotFound(new ApiResponse<bool>
                    {
                        Success = false,
                        Message = "Không tìm thấy đăng ký"
                    });
                }

                _context.TournamentTeams.Remove(registration);
                await _context.SaveChangesAsync();

                return Ok(new ApiResponse<bool>
                {
                    Success = true,
                    Message = "Hủy đăng ký thành công",
                    Data = true
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error unregistering tournament");
                return StatusCode(500, new ApiResponse<bool>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi hủy đăng ký",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Get user's tournament registrations
        /// </summary>
        [HttpGet("my-registrations")]
        public async Task<ActionResult<ApiResponse<List<MyRegistrationDto>>>> GetMyRegistrations()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                var registrations = await _context.TournamentTeams
                    .Include(tt => tt.Tournament)
                        .ThenInclude(t => t.Sports)
                    .Include(tt => tt.Team)
                    .Where(tt => tt.Team.UserId == userId)
                    .Select(tt => new MyRegistrationDto
                    {
                        TournamentId = tt.TournamentId,
                        TournamentName = tt.Tournament.Name,
                        SportsName = tt.Tournament.Sports != null ? tt.Tournament.Sports.Name : "",
                        StartDate = tt.Tournament.StartDate,
                        EndDate = tt.Tournament.EndDate,
                        Location = tt.Tournament.Location,
                        Status = tt.Tournament.CalculatedStatus,
                        TeamId = tt.TeamId,
                        TeamName = tt.Team.Name,
                        ImageUrl = tt.Tournament.ImageUrl
                    })
                    .OrderByDescending(r => r.StartDate)
                    .ToListAsync();

                return Ok(new ApiResponse<List<MyRegistrationDto>>
                {
                    Success = true,
                    Message = "Lấy danh sách đăng ký thành công",
                    Data = registrations,
                    Count = registrations.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting my registrations");
                return StatusCode(500, new ApiResponse<List<MyRegistrationDto>>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi lấy danh sách đăng ký",
                    Error = ex.Message
                });
            }
        }

        // ==================== TOURNAMENT SCHEDULE APIs ====================

        /// <summary>
        /// Generate schedule for a tournament (Admin only)
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        /// <returns>Generated match schedule</returns>
        [HttpPost("{tournamentId}/generate-schedule")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<ApiResponse<object>>> GenerateSchedule(int tournamentId)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .Include(t => t.TournamentFormat)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return NotFound(new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Không tìm thấy giải đấu"
                    });
                }

                // Get all registered teams for this tournament
                var registeredTeams = await _context.TournamentTeams
                    .Include(tt => tt.Team)
                    .Where(tt => tt.TournamentId == tournamentId && tt.Status == "Approved")
                    .Select(tt => tt.Team!)
                    .ToListAsync();

                if (registeredTeams.Count < 2)
                {
                    return BadRequest(new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Giải đấu cần ít nhất 2 đội để tạo lịch thi đấu"
                    });
                }

                // Delete existing matches for this tournament
                var existingMatches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId)
                    .ToListAsync();

                if (existingMatches.Any())
                {
                    _context.Matches.RemoveRange(existingMatches);
                    await _context.SaveChangesAsync();
                }

                // Generate matches based on tournament format
                var matches = new List<WebQuanLyGiaiDau_NhomTD.Models.Match>();
                var startDate = tournament.StartDate;

                // Round Robin - Each team plays every other team once
                for (int i = 0; i < registeredTeams.Count; i++)
                {
                    for (int j = i + 1; j < registeredTeams.Count; j++)
                    {
                        var matchDate = startDate.AddDays(matches.Count / 2); // 2 matches per day
                        var matchTime = matches.Count % 2 == 0 
                            ? new TimeSpan(15, 0, 0)  // 3:00 PM
                            : new TimeSpan(17, 0, 0); // 5:00 PM

                        var match = new WebQuanLyGiaiDau_NhomTD.Models.Match
                        {
                            TeamA = registeredTeams[i].Name,
                            TeamAId = registeredTeams[i].TeamId,
                            TeamB = registeredTeams[j].Name,
                            TeamBId = registeredTeams[j].TeamId,
                            MatchDate = matchDate,
                            MatchTime = matchTime,
                            Location = tournament.Location ?? "Sân chưa xác định",
                            TournamentId = tournamentId
                        };

                        matches.Add(match);
                    }
                }

                foreach (var match in matches)
                {
                    _context.Matches.Add(match);
                }
                await _context.SaveChangesAsync();

                var scheduleInfo = new
                {
                    tournamentId = tournament.Id,
                    tournamentName = tournament.Name,
                    totalTeams = registeredTeams.Count,
                    totalMatches = matches.Count,
                    startDate = tournament.StartDate,
                    endDate = matches.Max(m => m.MatchDate),
                    matches = matches.Select(m => new
                    {
                        matchId = m.Id,
                        teamA = m.TeamA,
                        teamB = m.TeamB,
                        matchDate = m.MatchDate,
                        matchTime = m.MatchTime,
                        location = m.Location
                    }).OrderBy(m => m.matchDate).ThenBy(m => m.matchTime).ToList()
                };

                return Ok(new ApiResponse<object>
                {
                    Success = true,
                    Message = $"Đã tạo {matches.Count} trận đấu thành công",
                    Data = scheduleInfo,
                    Count = matches.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating tournament schedule");
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi tạo lịch thi đấu",
                    Error = ex.Message
                });
            }
        }

        /// <summary>
        /// Get tournament schedule with match details
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        /// <returns>Tournament schedule</returns>
        [HttpGet("{tournamentId}/schedule")]
        public async Task<ActionResult<ApiResponse<object>>> GetTournamentSchedule(int tournamentId)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return NotFound(new ApiResponse<object>
                    {
                        Success = false,
                        Message = "Không tìm thấy giải đấu"
                    });
                }

                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId)
                    .OrderBy(m => m.MatchDate)
                    .ThenBy(m => m.MatchTime)
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
                        status = m.CalculatedStatus,
                        highlightsUrl = m.HighlightsVideoUrl,
                        liveStreamUrl = m.LiveStreamUrl
                    })
                    .ToListAsync();

                var scheduleInfo = new
                {
                    tournamentId = tournament.Id,
                    tournamentName = tournament.Name,
                    sportName = tournament.Sports?.Name,
                    location = tournament.Location,
                    startDate = tournament.StartDate,
                    endDate = tournament.EndDate,
                    totalMatches = matches.Count,
                    completedMatches = matches.Count(m => m.status == "Đã kết thúc"),
                    upcomingMatches = matches.Count(m => m.status == "Sắp diễn ra"),
                    matches = matches
                };

                return Ok(new ApiResponse<object>
                {
                    Success = true,
                    Message = "Lấy lịch thi đấu thành công",
                    Data = scheduleInfo,
                    Count = matches.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting tournament schedule");
                return StatusCode(500, new ApiResponse<object>
                {
                    Success = false,
                    Message = "Có lỗi xảy ra khi lấy lịch thi đấu",
                    Error = ex.Message
                });
            }
        }
    }

    // ==================== DTOs ====================

    public class TeamDto
    {
        public int TeamId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Coach { get; set; } = string.Empty;
        public string? LogoUrl { get; set; }
        public string? UserId { get; set; }
        public int PlayerCount { get; set; }
    }

    public class CreateTeamRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Coach { get; set; } = string.Empty;
        public string? LogoUrl { get; set; }
    }

    public class UpdateTeamRequest
    {
        public string Name { get; set; } = string.Empty;
        public string Coach { get; set; } = string.Empty;
        public string? LogoUrl { get; set; }
    }

    public class PlayerDto
    {
        public int PlayerId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string? Position { get; set; }
        public int? Number { get; set; }
        public string? ImageUrl { get; set; }
        public int TeamId { get; set; }
        public string? UserId { get; set; }
    }

    public class CreatePlayerRequest
    {
        public string FullName { get; set; } = string.Empty;
        public string? Position { get; set; }
        public int Number { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class UpdatePlayerRequest
    {
        public string FullName { get; set; } = string.Empty;
        public string? Position { get; set; }
        public int Number { get; set; }
        public string? ImageUrl { get; set; }
    }

    public class TournamentForRegistrationDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string SportsName { get; set; } = string.Empty;
        public int SportsId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? Location { get; set; }
        public int? MaxTeams { get; set; }
        public string? Format { get; set; }
        public string? Status { get; set; }
        public string? ImageUrl { get; set; }
        public bool IsRegistered { get; set; }
    }

    public class TournamentRegistrationRequest
    {
        public int TeamId { get; set; }
    }

    public class MyRegistrationDto
    {
        public int TournamentId { get; set; }
        public string TournamentName { get; set; } = string.Empty;
        public string SportsName { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string? Location { get; set; }
        public string? Status { get; set; }
        public int TeamId { get; set; }
        public string TeamName { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
    }
}
