using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    /// <summary>
    /// API Controller for Voting System
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class VotingApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<VotingApiController> _logger;

        public VotingApiController(ApplicationDbContext context, ILogger<VotingApiController> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// Vote for tournament champion
        /// </summary>
        /// <param name="request">Vote request with tournament ID and team name</param>
        [HttpPost("tournament")]
        public async Task<ActionResult<object>> VoteTournamentChampion([FromBody] TournamentVoteRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Ok(new { success = false, message = "Bạn cần đăng nhập để bình chọn" });
                }

                // Check tournament exists and voting is allowed
                var tournament = await _context.Tournaments.FindAsync(request.TournamentId);
                if (tournament == null)
                {
                    return Ok(new { success = false, message = "Không tìm thấy giải đấu" });
                }

                if (!tournament.AllowChampionVoting)
                {
                    return Ok(new { success = false, message = "Bình chọn vô địch đã bị tắt cho giải đấu này" });
                }

                // Check if user already voted
                var existingVote = await _context.TournamentVotes
                    .FirstOrDefaultAsync(v => v.TournamentId == request.TournamentId && v.UserId == userId);

                if (existingVote != null)
                {
                    // Update existing vote
                    existingVote.VotedTeamName = request.VotedTeamName;
                    existingVote.VoteTime = DateTime.Now;
                    existingVote.Notes = request.Notes;
                    _context.Update(existingVote);
                    await _context.SaveChangesAsync();

                    return Ok(new
                    {
                        success = true,
                        message = "Đã cập nhật bình chọn thành công!",
                        data = new
                        {
                            voteId = existingVote.Id,
                            isUpdate = true
                        }
                    });
                }
                else
                {
                    // Create new vote
                    var newVote = new TournamentVote
                    {
                        TournamentId = request.TournamentId,
                        UserId = userId,
                        VotedTeamName = request.VotedTeamName,
                        VoteTime = DateTime.Now,
                        Notes = request.Notes
                    };
                    _context.TournamentVotes.Add(newVote);

                    // Award points to user
                    var pointsSetting = await _context.PointsSettings.FirstOrDefaultAsync();
                    var user = await _context.Users.FindAsync(userId);
                    if (user != null)
                    {
                        var points = pointsSetting?.VoteTournamentPoints ?? 5;
                        user.Points += points;
                        _context.Update(user);
                    }

                    await _context.SaveChangesAsync();

                    return Ok(new
                    {
                        success = true,
                        message = $"Bình chọn thành công! Bạn được +{pointsSetting?.VoteTournamentPoints ?? 5} điểm",
                        data = new
                        {
                            voteId = newVote.Id,
                            isUpdate = false,
                            pointsEarned = pointsSetting?.VoteTournamentPoints ?? 5
                        }
                    });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error voting for tournament champion");
                return Ok(new { success = false, message = "Lỗi: " + ex.Message });
            }
        }

        /// <summary>
        /// Vote for match winner
        /// </summary>
        /// <param name="request">Vote request with match ID and team name</param>
        [HttpPost("match")]
        public async Task<ActionResult<object>> VoteMatchWinner([FromBody] MatchVoteRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Ok(new { success = false, message = "Bạn cần đăng nhập để bình chọn" });
                }

                // Check match exists and voting is allowed
                var match = await _context.Matches.FindAsync(request.MatchId);
                if (match == null)
                {
                    return Ok(new { success = false, message = "Không tìm thấy trận đấu" });
                }

                if (!match.AllowWinnerVoting)
                {
                    return Ok(new { success = false, message = "Bình chọn đội thắng đã bị tắt cho trận đấu này" });
                }

                // Check if match is already completed
                if (match.Status?.ToLower() == "completed")
                {
                    return Ok(new { success = false, message = "Trận đấu đã kết thúc, không thể bình chọn" });
                }

                // Check if user already voted
                var existingVote = await _context.MatchVotes
                    .FirstOrDefaultAsync(v => v.MatchId == request.MatchId && v.UserId == userId);

                if (existingVote != null)
                {
                    // Update existing vote
                    existingVote.VotedTeam = request.VotedTeam;
                    existingVote.VoteTime = DateTime.Now;
                    existingVote.Notes = request.Notes;
                    _context.Update(existingVote);
                    await _context.SaveChangesAsync();

                    return Ok(new
                    {
                        success = true,
                        message = "Đã cập nhật bình chọn thành công!",
                        data = new
                        {
                            voteId = existingVote.Id,
                            isUpdate = true
                        }
                    });
                }
                else
                {
                    // Create new vote
                    var newVote = new MatchVote
                    {
                        MatchId = request.MatchId,
                        UserId = userId,
                        VotedTeam = request.VotedTeam,
                        VoteTime = DateTime.Now,
                        Notes = request.Notes
                    };
                    _context.MatchVotes.Add(newVote);

                    // Award points to user
                    var pointsSetting = await _context.PointsSettings.FirstOrDefaultAsync();
                    var user = await _context.Users.FindAsync(userId);
                    if (user != null)
                    {
                        var points = pointsSetting?.VoteTeamPoints ?? 3;
                        user.Points += points;
                        _context.Update(user);
                    }

                    await _context.SaveChangesAsync();

                    return Ok(new
                    {
                        success = true,
                        message = $"Bình chọn thành công! Bạn được +{pointsSetting?.VoteTeamPoints ?? 3} điểm",
                        data = new
                        {
                            voteId = newVote.Id,
                            isUpdate = false,
                            pointsEarned = pointsSetting?.VoteTeamPoints ?? 3
                        }
                    });
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error voting for match winner");
                return Ok(new { success = false, message = "Lỗi: " + ex.Message });
            }
        }

        /// <summary>
        /// Get user's vote for a tournament
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        [HttpGet("tournament/{tournamentId}")]
        public async Task<ActionResult<object>> GetTournamentVote(int tournamentId)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Ok(new { success = false, message = "Bạn cần đăng nhập" });
                }

                var vote = await _context.TournamentVotes
                    .FirstOrDefaultAsync(v => v.TournamentId == tournamentId && v.UserId == userId);

                if (vote == null)
                {
                    return Ok(new
                    {
                        success = true,
                        message = "Chưa bình chọn",
                        data = new { hasVoted = false }
                    });
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin bình chọn thành công",
                    data = new
                    {
                        hasVoted = true,
                        voteId = vote.Id,
                        votedTeamName = vote.VotedTeamName,
                        voteTime = vote.VoteTime,
                        notes = vote.Notes
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting tournament vote");
                return Ok(new { success = false, message = "Lỗi: " + ex.Message });
            }
        }

        /// <summary>
        /// Get user's vote for a match
        /// </summary>
        /// <param name="matchId">Match ID</param>
        [HttpGet("match/{matchId}")]
        public async Task<ActionResult<object>> GetMatchVote(int matchId)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId))
                {
                    return Ok(new { success = false, message = "Bạn cần đăng nhập" });
                }

                var vote = await _context.MatchVotes
                    .FirstOrDefaultAsync(v => v.MatchId == matchId && v.UserId == userId);

                if (vote == null)
                {
                    return Ok(new
                    {
                        success = true,
                        message = "Chưa bình chọn",
                        data = new { hasVoted = false }
                    });
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin bình chọn thành công",
                    data = new
                    {
                        hasVoted = true,
                        voteId = vote.Id,
                        votedTeam = vote.VotedTeam,
                        voteTime = vote.VoteTime,
                        notes = vote.Notes
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting match vote");
                return Ok(new { success = false, message = "Lỗi: " + ex.Message });
            }
        }

        /// <summary>
        /// Get voting statistics for a tournament
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        [HttpGet("tournament/{tournamentId}/statistics")]
        [AllowAnonymous]
        public async Task<ActionResult<object>> GetTournamentVoteStatistics(int tournamentId)
        {
            try
            {
                var votes = await _context.TournamentVotes
                    .Where(v => v.TournamentId == tournamentId)
                    .GroupBy(v => v.VotedTeamName)
                    .Select(g => new
                    {
                        teamName = g.Key,
                        voteCount = g.Count(),
                        percentage = 0.0 // Will calculate below
                    })
                    .ToListAsync();

                var totalVotes = votes.Sum(v => v.voteCount);
                var statistics = votes.Select(v => new
                {
                    v.teamName,
                    v.voteCount,
                    percentage = totalVotes > 0 ? Math.Round((double)v.voteCount / totalVotes * 100, 2) : 0
                }).OrderByDescending(v => v.voteCount).ToList();

                return Ok(new
                {
                    success = true,
                    message = "Lấy thống kê bình chọn thành công",
                    data = new
                    {
                        totalVotes,
                        votes = statistics
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting tournament vote statistics");
                return Ok(new { success = false, message = "Lỗi: " + ex.Message });
            }
        }

        /// <summary>
        /// Get voting statistics for a match
        /// </summary>
        /// <param name="matchId">Match ID</param>
        [HttpGet("match/{matchId}/statistics")]
        [AllowAnonymous]
        public async Task<ActionResult<object>> GetMatchVoteStatistics(int matchId)
        {
            try
            {
                var votes = await _context.MatchVotes
                    .Where(v => v.MatchId == matchId)
                    .GroupBy(v => v.VotedTeam)
                    .Select(g => new
                    {
                        teamName = g.Key,
                        voteCount = g.Count(),
                        percentage = 0.0
                    })
                    .ToListAsync();

                var totalVotes = votes.Sum(v => v.voteCount);
                var statistics = votes.Select(v => new
                {
                    v.teamName,
                    v.voteCount,
                    percentage = totalVotes > 0 ? Math.Round((double)v.voteCount / totalVotes * 100, 2) : 0
                }).OrderByDescending(v => v.voteCount).ToList();

                return Ok(new
                {
                    success = true,
                    message = "Lấy thống kê bình chọn thành công",
                    data = new
                    {
                        totalVotes,
                        votes = statistics
                    }
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting match vote statistics");
                return Ok(new { success = false, message = "Lỗi: " + ex.Message });
            }
        }
    }

    // Request DTOs
    public class TournamentVoteRequest
    {
        public int TournamentId { get; set; }
        public string VotedTeamName { get; set; } = string.Empty;
        public string? Notes { get; set; }
    }

    public class MatchVoteRequest
    {
        public int MatchId { get; set; }
        public string VotedTeam { get; set; } = string.Empty;
        public string? Notes { get; set; }
    }
}
