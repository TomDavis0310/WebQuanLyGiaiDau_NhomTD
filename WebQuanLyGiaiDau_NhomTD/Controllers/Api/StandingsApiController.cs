using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class StandingsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public StandingsApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Get standings for a tournament
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        /// <returns>Standings grouped by groups (if applicable)</returns>
        [HttpGet("tournament/{tournamentId}")]
        public async Task<ActionResult<object>> GetTournamentStandings(int tournamentId)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.TournamentFormat)
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return NotFound(new { message = "Tournament not found" });
                }

                // Get all standings for this tournament
                var standings = await _context.Standings
                    .Where(s => s.TournamentId == tournamentId)
                    .Include(s => s.StandingDetails)
                        .ThenInclude(sd => sd.Team)
                    .OrderBy(s => s.GroupName)
                    .ToListAsync();

                // If no standings exist, try to calculate from matches
                if (standings.Count == 0)
                {
                    var calculatedStandings = await CalculateStandingsFromMatches(tournamentId);
                    return Ok(new
                    {
                        tournamentId = tournament.Id,
                        tournamentName = tournament.Name,
                        sportName = tournament.Sports?.Name,
                        hasGroups = false,
                        lastUpdated = DateTime.Now,
                        groups = new[]
                        {
                            new
                            {
                                groupName = "Overall",
                                teams = calculatedStandings
                            }
                        }
                    });
                }

                // Group standings by group name
                var groupedStandings = standings.Select(s => new
                {
                    groupName = s.GroupName ?? "Overall",
                    lastUpdated = s.LastUpdated,
                    teams = s.StandingDetails?
                        .OrderBy(sd => sd.Rank ?? int.MaxValue)
                        .ThenByDescending(sd => sd.TotalPoints)
                        .ThenByDescending(sd => sd.PointDifference)
                        .Select(sd => new
                        {
                            teamId = sd.TeamId,
                            teamName = sd.Team?.Name,
                            teamLogo = sd.Team?.LogoUrl,
                            rank = sd.Rank,
                            played = sd.NumberOfWins + sd.NumberOfLoses + sd.NumberOfDraws,
                            won = sd.NumberOfWins,
                            drawn = sd.NumberOfDraws,
                            lost = sd.NumberOfLoses,
                            goalsFor = sd.PointsScored,
                            goalsAgainst = sd.PointsAgainst,
                            goalDifference = sd.PointDifference,
                            points = sd.TotalPoints
                        })
                        .ToList()
                }).ToList();

                return Ok(new
                {
                    tournamentId = tournament.Id,
                    tournamentName = tournament.Name,
                    sportName = tournament.Sports?.Name,
                    hasGroups = standings.Count > 1 || standings.Any(s => !string.IsNullOrEmpty(s.GroupName)),
                    groups = groupedStandings
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error retrieving standings", error = ex.Message });
            }
        }

        /// <summary>
        /// Get tournament bracket (knockout phase)
        /// </summary>
        /// <param name="tournamentId">Tournament ID</param>
        /// <returns>Bracket structure with matches</returns>
        [HttpGet("tournament/{tournamentId}/bracket")]
        public async Task<ActionResult<object>> GetTournamentBracket(int tournamentId)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.TournamentFormat)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return NotFound(new { message = "Tournament not found" });
                }

                // Get knockout matches (matches without group name or with specific knockout indicators)
                var knockoutMatches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId && 
                               (string.IsNullOrEmpty(m.GroupName) || 
                                m.GroupName.Contains("Final") || 
                                m.GroupName.Contains("Semi") ||
                                m.GroupName.Contains("Quarter")))
                    .OrderBy(m => m.Round)
                    .ThenBy(m => m.MatchDate)
                    .Select(m => new
                    {
                        matchId = m.Id,
                        round = m.Round,
                        roundName = m.GroupName,
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
                        winnerId = m.ScoreTeamA > m.ScoreTeamB ? m.TeamAId : 
                                  m.ScoreTeamB > m.ScoreTeamA ? m.TeamBId : (int?)null
                    })
                    .ToListAsync();

                // Group by round
                var rounds = knockoutMatches
                    .GroupBy(m => m.round ?? 0)
                    .OrderBy(g => g.Key)
                    .Select(g => new
                    {
                        round = g.Key,
                        roundName = DetermineRoundName(g.Key, knockoutMatches.Count),
                        matches = g.ToList()
                    })
                    .ToList();

                return Ok(new
                {
                    tournamentId = tournament.Id,
                    tournamentName = tournament.Name,
                    bracketType = "single-elimination",
                    totalRounds = rounds.Count,
                    rounds = rounds
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error retrieving bracket", error = ex.Message });
            }
        }

        /// <summary>
        /// Get head-to-head record between two teams in a tournament
        /// </summary>
        [HttpGet("tournament/{tournamentId}/head-to-head")]
        public async Task<ActionResult<object>> GetHeadToHead(int tournamentId, [FromQuery] int teamAId, [FromQuery] int teamBId)
        {
            try
            {
                if (teamAId == teamBId)
                {
                    return BadRequest(new { message = "Cannot compare a team with itself" });
                }

                var teamA = await _context.Teams.FindAsync(teamAId);
                var teamB = await _context.Teams.FindAsync(teamBId);

                if (teamA == null || teamB == null)
                {
                    return NotFound(new { message = "One or both teams not found" });
                }

                // Get all matches between these two teams in this tournament
                var matches = await _context.Matches
                    .Where(m => m.TournamentId == tournamentId &&
                               ((m.TeamAId == teamAId && m.TeamBId == teamBId) ||
                                (m.TeamAId == teamBId && m.TeamBId == teamAId)))
                    .OrderBy(m => m.MatchDate)
                    .Select(m => new
                    {
                        matchId = m.Id,
                        matchDate = m.MatchDate,
                        teamA = m.TeamA,
                        teamAId = m.TeamAId,
                        scoreA = m.ScoreTeamA,
                        teamB = m.TeamB,
                        teamBId = m.TeamBId,
                        scoreB = m.ScoreTeamB,
                        location = m.Location,
                        status = m.CalculatedStatus
                    })
                    .ToListAsync();

                // Calculate statistics
                int teamAWins = 0, teamBWins = 0, draws = 0;
                int teamATotalGoals = 0, teamBTotalGoals = 0;

                foreach (var match in matches)
                {
                    if (match.scoreA.HasValue && match.scoreB.HasValue)
                    {
                        bool teamAIsHome = match.teamAId == teamAId;
                        int teamAScore = teamAIsHome ? match.scoreA.Value : match.scoreB.Value;
                        int teamBScore = teamAIsHome ? match.scoreB.Value : match.scoreA.Value;

                        teamATotalGoals += teamAScore;
                        teamBTotalGoals += teamBScore;

                        if (teamAScore > teamBScore)
                            teamAWins++;
                        else if (teamBScore > teamAScore)
                            teamBWins++;
                        else
                            draws++;
                    }
                }

                return Ok(new
                {
                    tournamentId = tournamentId,
                    teamA = new
                    {
                        teamId = teamA.TeamId,
                        name = teamA.Name,
                        logo = teamA.LogoUrl,
                        wins = teamAWins,
                        totalGoals = teamATotalGoals
                    },
                    teamB = new
                    {
                        teamId = teamB.TeamId,
                        name = teamB.Name,
                        logo = teamB.LogoUrl,
                        wins = teamBWins,
                        totalGoals = teamBTotalGoals
                    },
                    draws = draws,
                    totalMatches = matches.Count,
                    matches = matches
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error retrieving head-to-head", error = ex.Message });
            }
        }

        /// <summary>
        /// Calculate standings from match results (when Standing table is empty)
        /// </summary>
        private async Task<List<object>> CalculateStandingsFromMatches(int tournamentId)
        {
            var matches = await _context.Matches
                .Where(m => m.TournamentId == tournamentId && 
                           m.ScoreTeamA.HasValue && 
                           m.ScoreTeamB.HasValue)
                .ToListAsync();

            var teamStats = new Dictionary<int, Dictionary<string, int>>();

            foreach (var match in matches)
            {
                if (!match.TeamAId.HasValue || !match.TeamBId.HasValue)
                    continue;

                // Initialize team stats if not exists
                if (!teamStats.ContainsKey(match.TeamAId.Value))
                {
                    teamStats[match.TeamAId.Value] = new Dictionary<string, int>
                    {
                        ["played"] = 0,
                        ["won"] = 0,
                        ["drawn"] = 0,
                        ["lost"] = 0,
                        ["goalsFor"] = 0,
                        ["goalsAgainst"] = 0,
                        ["points"] = 0
                    };
                }

                if (!teamStats.ContainsKey(match.TeamBId.Value))
                {
                    teamStats[match.TeamBId.Value] = new Dictionary<string, int>
                    {
                        ["played"] = 0,
                        ["won"] = 0,
                        ["drawn"] = 0,
                        ["lost"] = 0,
                        ["goalsFor"] = 0,
                        ["goalsAgainst"] = 0,
                        ["points"] = 0
                    };
                }

                // Update stats
                teamStats[match.TeamAId.Value]["played"]++;
                teamStats[match.TeamBId.Value]["played"]++;
                teamStats[match.TeamAId.Value]["goalsFor"] += match.ScoreTeamA.Value;
                teamStats[match.TeamAId.Value]["goalsAgainst"] += match.ScoreTeamB.Value;
                teamStats[match.TeamBId.Value]["goalsFor"] += match.ScoreTeamB.Value;
                teamStats[match.TeamBId.Value]["goalsAgainst"] += match.ScoreTeamA.Value;

                if (match.ScoreTeamA > match.ScoreTeamB)
                {
                    teamStats[match.TeamAId.Value]["won"]++;
                    teamStats[match.TeamAId.Value]["points"] += 3;
                    teamStats[match.TeamBId.Value]["lost"]++;
                }
                else if (match.ScoreTeamB > match.ScoreTeamA)
                {
                    teamStats[match.TeamBId.Value]["won"]++;
                    teamStats[match.TeamBId.Value]["points"] += 3;
                    teamStats[match.TeamAId.Value]["lost"]++;
                }
                else
                {
                    teamStats[match.TeamAId.Value]["drawn"]++;
                    teamStats[match.TeamBId.Value]["drawn"]++;
                    teamStats[match.TeamAId.Value]["points"]++;
                    teamStats[match.TeamBId.Value]["points"]++;
                }
            }

            // Convert to list with team info
            var result = new List<object>();
            var teams = await _context.Teams
                .Where(t => teamStats.Keys.Contains(t.TeamId))
                .ToListAsync();

            int rank = 1;
            foreach (var teamStat in teamStats.OrderByDescending(t => t.Value["points"])
                                              .ThenByDescending(t => t.Value["goalsFor"] - t.Value["goalsAgainst"])
                                              .ThenByDescending(t => t.Value["goalsFor"]))
            {
                var team = teams.FirstOrDefault(t => t.TeamId == teamStat.Key);
                if (team != null)
                {
                    var stats = teamStat.Value;
                    result.Add(new
                    {
                        teamId = team.TeamId,
                        teamName = team.Name,
                        teamLogo = team.LogoUrl,
                        rank = rank++,
                        played = stats["played"],
                        won = stats["won"],
                        drawn = stats["drawn"],
                        lost = stats["lost"],
                        goalsFor = stats["goalsFor"],
                        goalsAgainst = stats["goalsAgainst"],
                        goalDifference = stats["goalsFor"] - stats["goalsAgainst"],
                        points = stats["points"]
                    });
                }
            }

            return result;
        }

        /// <summary>
        /// Determine round name based on round number and total matches
        /// </summary>
        private string DetermineRoundName(int round, int totalMatches)
        {
            // Simple heuristic based on round number
            return round switch
            {
                1 => totalMatches > 4 ? "Round of 16" : "Quarter-finals",
                2 => totalMatches > 4 ? "Quarter-finals" : "Semi-finals",
                3 => "Semi-finals",
                4 => "Final",
                _ => $"Round {round}"
            };
        }
    }
}
