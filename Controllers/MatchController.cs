namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    using Microsoft.AspNetCore.Authorization;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.EntityFrameworkCore;
    using WebQuanLyGiaiDau_NhomTD.Models;
    using WebQuanLyGiaiDau_NhomTD.Models.UserModel;
    using WebQuanLyGiaiDau_NhomTD.Models.ViewModels;

    [Authorize]
    public class MatchController : Controller
    {
        private readonly ApplicationDbContext _context;

        public MatchController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Match
        public async Task<IActionResult> Index(string searchString, int? pageNumber)
        {
            // Đặt kích thước trang
            int pageSize = 10;

            // Lưu searchString để hiển thị lại trong form
            ViewData["CurrentFilter"] = searchString;

            var matchesQuery = _context.Matches
                .Include(m => m.Tournament)
                .AsQueryable();

            // Áp dụng tìm kiếm nếu có
            if (!string.IsNullOrEmpty(searchString))
            {
                searchString = searchString.ToLower();
                matchesQuery = matchesQuery.Where(m =>
                    (m.TeamA != null && m.TeamA.ToLower().Contains(searchString)) ||
                    (m.TeamB != null && m.TeamB.ToLower().Contains(searchString)) ||
                    (m.Tournament != null && m.Tournament.Name.ToLower().Contains(searchString)));
            }

            // Sắp xếp theo thời gian trận đấu
            matchesQuery = matchesQuery.OrderByDescending(m => m.MatchDate);

            // Thực hiện phân trang
            var matches = await PaginatedList<Match>.CreateAsync(
                matchesQuery, pageNumber ?? 1, pageSize);

            return View(matches);
        }

        // GET: Match/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var match = await _context.Matches
                .Include(m => m.Tournament)
                .Include(m => m.Statistics)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (match == null)
            {
                return NotFound();
            }

            // Get player statistics for this match
            var statistics = await _context.Statistics
                .Where(s => s.MatchId == id)
                .ToListAsync();

            // Create virtual match sets (for basketball 5v5 NBA, 4 quarters)
            var matchSets = new List<dynamic>();
            var random = new Random();

            // For NBA 5v5, we'll simulate 4 quarters
            int totalScoreTeamA = match.ScoreTeamA ?? 0;
            int totalScoreTeamB = match.ScoreTeamB ?? 0;

            // Distribute total score across 4 quarters
            int[] quarterScoresTeamA = new int[4];
            int[] quarterScoresTeamB = new int[4];

            if (totalScoreTeamA > 0 || totalScoreTeamB > 0)
            {
                // Xử lý trường hợp đặc biệt khi tổng điểm nhỏ hơn 15
                if (totalScoreTeamA < 15)
                {
                    // Nếu tổng điểm nhỏ hơn 15, gán tất cả cho quý đầu tiên
                    quarterScoresTeamA[0] = totalScoreTeamA;
                    totalScoreTeamA = 0;
                }

                if (totalScoreTeamB < 15)
                {
                    // Nếu tổng điểm nhỏ hơn 15, gán tất cả cho quý đầu tiên
                    quarterScoresTeamB[0] = totalScoreTeamB;
                    totalScoreTeamB = 0;
                }

                // Distribute scores across quarters
                for (int i = 0; i < 3; i++) // First 3 quarters
                {
                    // Chỉ phân phối điểm nếu còn điểm và chưa được gán ở trên
                    if (i == 0 && quarterScoresTeamA[0] > 0)
                    {
                        // Quý đầu tiên đã được gán ở trên, bỏ qua
                    }
                    else if (totalScoreTeamA >= 15)
                    {
                        quarterScoresTeamA[i] = random.Next(15, Math.Min(35, totalScoreTeamA));
                        totalScoreTeamA -= quarterScoresTeamA[i];
                    }
                    else if (totalScoreTeamA > 0)
                    {
                        // Nếu còn điểm nhưng < 15, gán tất cả cho quý hiện tại
                        quarterScoresTeamA[i] = totalScoreTeamA;
                        totalScoreTeamA = 0;
                    }

                    // Tương tự cho đội B
                    if (i == 0 && quarterScoresTeamB[0] > 0)
                    {
                        // Quý đầu tiên đã được gán ở trên, bỏ qua
                    }
                    else if (totalScoreTeamB >= 15)
                    {
                        quarterScoresTeamB[i] = random.Next(15, Math.Min(35, totalScoreTeamB));
                        totalScoreTeamB -= quarterScoresTeamB[i];
                    }
                    else if (totalScoreTeamB > 0)
                    {
                        // Nếu còn điểm nhưng < 15, gán tất cả cho quý hiện tại
                        quarterScoresTeamB[i] = totalScoreTeamB;
                        totalScoreTeamB = 0;
                    }
                }

                // Last quarter gets the remainder
                quarterScoresTeamA[3] = totalScoreTeamA;
                quarterScoresTeamB[3] = totalScoreTeamB;
            }

            // Find the best players for each quarter
            for (int quarter = 0; quarter < 4; quarter++)
            {
                string bestPlayerName = "Chưa xác định";
                string bestPlayerTeam = "";
                int bestPlayerPoints = 0;

                if (statistics.Any())
                {
                    // For simplicity, we'll pick a random player from the top performers
                    var topPlayers = statistics.OrderByDescending(s => s.Points).Take(5).ToList();
                    if (topPlayers.Any())
                    {
                        var bestPlayer = topPlayers[random.Next(topPlayers.Count)];
                        bestPlayerName = bestPlayer.PlayerName;
                        bestPlayerTeam = bestPlayer.PlayerName.Contains(match.TeamA) ? match.TeamA : match.TeamB;
                        // Kiểm tra nếu điểm của cầu thủ xuất sắc nhất < 5
                        if (bestPlayer.Points < 5)
                        {
                            bestPlayerPoints = bestPlayer.Points;
                        }
                        else
                        {
                            bestPlayerPoints = random.Next(5, Math.Min(15, bestPlayer.Points));
                        }
                    }
                }
                else if (match.CalculatedStatus != "Upcoming")
                {
                    // If no statistics but match is completed or in progress, generate a random best player
                    bestPlayerName = $"Cầu thủ {random.Next(1, 10)}";
                    bestPlayerTeam = random.Next(2) == 0 ? match.TeamA : match.TeamB;
                    bestPlayerPoints = random.Next(5, 15);
                }

                matchSets.Add(new
                {
                    SetNumber = quarter + 1,
                    ScoreTeamA = quarterScoresTeamA[quarter],
                    ScoreTeamB = quarterScoresTeamB[quarter],
                    BestPlayerName = bestPlayerName,
                    BestPlayerTeam = bestPlayerTeam,
                    BestPlayerPoints = bestPlayerPoints
                });
            }

            // Get player scoring records for this match
            var playerScorings = await _context.PlayerScorings
                .Include(ps => ps.Player)
                .ThenInclude(p => p.Team)
                .Where(ps => ps.MatchId == id)
                .OrderByDescending(ps => ps.ScoringTime)
                .ToListAsync();

            ViewBag.PlayerScorings = playerScorings;
            ViewBag.MatchSets = matchSets;
            ViewBag.MatchStatus = match.CalculatedStatus;

            // Tính toán thời gian kết thúc trận đấu dựa trên loại giải đấu
            ViewBag.MatchEndTime = await CalculateMatchEndTime(match.MatchDate, match.TournamentId);

            return View(match);
        }

        // GET: Match/Create
        [Authorize(Roles = SD.Role_Admin)]
        public IActionResult Create()
        {
            ViewData["TournamentId"] = new SelectList(_context.Tournaments, "Id", "Name");
            return View();
        }

        // POST: Match/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Create(Match match)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Đặt ngày thi đấu (chỉ lấy phần ngày)
                    DateTime matchDate = match.MatchDate.Date;

                    // Xử lý thời gian thi đấu
                    if (!match.MatchTime.HasValue)
                    {
                        // Nếu không có thời gian, mặc định là 15:00
                        match.MatchTime = new TimeSpan(15, 0, 0);
                    }

                    // Đảm bảo Location không bị null
                    if (string.IsNullOrEmpty(match.Location))
                    {
                        // Nếu không có địa điểm, lấy địa điểm từ giải đấu nếu có
                        var tournament = await _context.Tournaments.FindAsync(match.TournamentId);
                        if (tournament != null && !string.IsNullOrEmpty(tournament.Location))
                        {
                            match.Location = tournament.Location;
                        }
                    }

                    // Thêm thông tin về thời gian kết thúc vào ViewBag để hiển thị
                    ViewBag.MatchEndTime = await CalculateMatchEndTime(match.MatchDate, match.TournamentId);

                    _context.Matches.Add(match);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }
            ViewData["TournamentId"] = new SelectList(_context.Tournaments, "Id", "Name", match.TournamentId);
            return View(match);
        }

        // GET: Match/Edit/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var match = await _context.Matches.FindAsync(id);
            if (match == null)
            {
                return NotFound();
            }
            ViewData["TournamentId"] = new SelectList(_context.Tournaments, "Id", "Name", match.TournamentId);
            return View(match);
        }

        // POST: Match/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, Match match)
        {
            if (id != match.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Đặt ngày thi đấu (chỉ lấy phần ngày)
                    DateTime matchDate = match.MatchDate.Date;

                    // Xử lý thời gian thi đấu
                    if (!match.MatchTime.HasValue)
                    {
                        // Nếu không có thời gian, mặc định là 15:00
                        match.MatchTime = new TimeSpan(15, 0, 0);
                    }

                    // Đảm bảo Location không bị null
                    if (string.IsNullOrEmpty(match.Location))
                    {
                        // Nếu không có địa điểm, lấy địa điểm từ giải đấu nếu có
                        var tournament = await _context.Tournaments.FindAsync(match.TournamentId);
                        if (tournament != null && !string.IsNullOrEmpty(tournament.Location))
                        {
                            match.Location = tournament.Location;
                        }
                    }

                    // Thêm thông tin về thời gian kết thúc vào ViewBag để hiển thị
                    ViewBag.MatchEndTime = await CalculateMatchEndTime(match.MatchDate, match.TournamentId);

                    _context.Update(match);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!MatchExists(match.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi cập nhật dữ liệu: " + ex.Message);
                }
            }
            ViewData["TournamentId"] = new SelectList(_context.Tournaments, "Id", "Name", match.TournamentId);
            return View(match);
        }

        // GET: Match/Delete/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var match = await _context.Matches
                .Include(m => m.Tournament)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (match == null)
            {
                return NotFound();
            }

            return View(match);
        }

        // POST: Match/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var match = await _context.Matches.FindAsync(id);
                if (match != null)
                {
                    _context.Matches.Remove(match);
                    await _context.SaveChangesAsync();
                }
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                // Handle foreign key constraint violation
                Console.WriteLine($"Lỗi khi xóa trận đấu: {ex.Message}");
                return RedirectToAction(nameof(Delete), new { id = id, error = "Không thể xóa trận đấu này vì có dữ liệu liên quan." });
            }
        }

        // GET: Match/UpdateScore/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> UpdateScore(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var match = await _context.Matches
                .Include(m => m.Tournament)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (match == null)
            {
                return NotFound();
            }

            return View(match);
        }

        // POST: Match/UpdateScore/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> UpdateScore(int id, Match match)
        {
            if (id != match.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Lấy thông tin trận đấu hiện tại từ database
                    var existingMatch = await _context.Matches.FindAsync(id);
                    if (existingMatch == null)
                    {
                        return NotFound();
                    }

                    // Chỉ cập nhật điểm số, giữ nguyên các thông tin khác
                    existingMatch.ScoreTeamA = match.ScoreTeamA;
                    existingMatch.ScoreTeamB = match.ScoreTeamB;

                    _context.Update(existingMatch);
                    await _context.SaveChangesAsync();

                    // Cập nhật bảng xếp hạng nếu cần
                    // Đây là nơi bạn có thể thêm code để cập nhật bảng xếp hạng dựa trên kết quả trận đấu

                    TempData["SuccessMessage"] = "Cập nhật kết quả trận đấu thành công!";
                    return RedirectToAction(nameof(Details), new { id = match.Id });
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!MatchExists(match.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi cập nhật kết quả: " + ex.Message);
                }
            }

            // Nếu có lỗi, load lại thông tin trận đấu và hiển thị form
            var matchToUpdate = await _context.Matches
                .Include(m => m.Tournament)
                .FirstOrDefaultAsync(m => m.Id == id);

            return View(matchToUpdate);
        }

        private bool MatchExists(int id)
        {
            return _context.Matches.Any(e => e.Id == id);
        }

        // GET: Match/ManagePlayerScoring/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> ManagePlayerScoring(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var match = await _context.Matches
                .Include(m => m.Tournament)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (match == null)
            {
                return NotFound();
            }

            // Get teams for this match
            var teamA = await _context.Teams.FirstOrDefaultAsync(t => t.Name == match.TeamA);
            var teamB = await _context.Teams.FirstOrDefaultAsync(t => t.Name == match.TeamB);

            if (teamA == null || teamB == null)
            {
                TempData["ErrorMessage"] = "Không tìm thấy thông tin đội thi đấu.";
                return RedirectToAction(nameof(Details), new { id });
            }

            // Get players for both teams
            var teamAPlayers = await _context.Players
                .Where(p => p.TeamId == teamA.TeamId)
                .OrderBy(p => p.FullName)
                .ToListAsync();

            var teamBPlayers = await _context.Players
                .Where(p => p.TeamId == teamB.TeamId)
                .OrderBy(p => p.FullName)
                .ToListAsync();

            // Get existing player scoring records
            var playerScorings = await _context.PlayerScorings
                .Include(ps => ps.Player)
                .ThenInclude(p => p.Team)
                .Where(ps => ps.MatchId == id)
                .OrderByDescending(ps => ps.ScoringTime)
                .ToListAsync();

            // Create view model
            var viewModel = new PlayerScoringViewModel
            {
                MatchId = match.Id,
                Match = match,
                TeamAPlayers = teamAPlayers,
                TeamBPlayers = teamBPlayers,
                PlayerScorings = playerScorings
            };

            return View(viewModel);
        }

        // POST: Match/AddPlayerScoring
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> AddPlayerScoring(PlayerScoringViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Validate that the player exists and belongs to one of the teams in the match
                    var player = await _context.Players
                        .Include(p => p.Team)
                        .FirstOrDefaultAsync(p => p.PlayerId == model.SelectedPlayerId);

                    if (player == null)
                    {
                        ModelState.AddModelError("SelectedPlayerId", "Cầu thủ không tồn tại.");
                        return RedirectToAction(nameof(ManagePlayerScoring), new { id = model.MatchId });
                    }

                    var match = await _context.Matches.FindAsync(model.MatchId);
                    if (match == null)
                    {
                        return NotFound();
                    }

                    // Validate that the player belongs to one of the teams in the match
                    if (player.Team.Name != match.TeamA && player.Team.Name != match.TeamB)
                    {
                        ModelState.AddModelError("SelectedPlayerId", "Cầu thủ không thuộc đội tham gia trận đấu này.");
                        return RedirectToAction(nameof(ManagePlayerScoring), new { id = model.MatchId });
                    }

                    // Create new player scoring record
                    var playerScoring = new PlayerScoring
                    {
                        MatchId = model.MatchId,
                        PlayerId = model.SelectedPlayerId,
                        Points = model.Points,
                        ScoringTime = DateTime.Now,
                        Notes = model.Notes
                    };

                    _context.PlayerScorings.Add(playerScoring);
                    await _context.SaveChangesAsync();

                    // Update match score
                    await UpdateMatchScore(model.MatchId);

                    // Update player statistics
                    await UpdatePlayerStatistics(player.PlayerId, model.Points);

                    TempData["SuccessMessage"] = "Thêm điểm số thành công!";
                    return RedirectToAction(nameof(ManagePlayerScoring), new { id = model.MatchId });
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi thêm điểm số: " + ex.Message);
                }
            }

            return RedirectToAction(nameof(ManagePlayerScoring), new { id = model.MatchId });
        }

        // POST: Match/DeletePlayerScoring/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> DeletePlayerScoring(int id, int matchId)
        {
            var playerScoring = await _context.PlayerScorings
                .Include(ps => ps.Player)
                .FirstOrDefaultAsync(ps => ps.Id == id);

            if (playerScoring == null)
            {
                return NotFound();
            }

            try
            {
                // Store player ID and points for updating statistics
                int playerId = playerScoring.PlayerId;
                int points = playerScoring.Points;

                _context.PlayerScorings.Remove(playerScoring);
                await _context.SaveChangesAsync();

                // Update match score
                await UpdateMatchScore(matchId);

                // Update player statistics (subtract points)
                await UpdatePlayerStatistics(playerId, -points);

                TempData["SuccessMessage"] = "Xóa điểm số thành công!";
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Lỗi khi xóa điểm số: " + ex.Message;
            }

            return RedirectToAction(nameof(ManagePlayerScoring), new { id = matchId });
        }

        // Helper method to update match score based on player scoring records
        private async Task UpdateMatchScore(int matchId)
        {
            var match = await _context.Matches.FindAsync(matchId);
            if (match == null)
            {
                return;
            }

            // Get all player scoring records for this match
            var playerScorings = await _context.PlayerScorings
                .Include(ps => ps.Player)
                .ThenInclude(p => p.Team)
                .Where(ps => ps.MatchId == matchId)
                .ToListAsync();

            // Calculate total score for each team
            int scoreTeamA = 0;
            int scoreTeamB = 0;

            foreach (var scoring in playerScorings)
            {
                if (scoring.Player.Team.Name == match.TeamA)
                {
                    scoreTeamA += scoring.Points;
                }
                else if (scoring.Player.Team.Name == match.TeamB)
                {
                    scoreTeamB += scoring.Points;
                }
            }

            // Update match score
            match.ScoreTeamA = scoreTeamA;
            match.ScoreTeamB = scoreTeamB;

            _context.Update(match);
            await _context.SaveChangesAsync();
        }

        // Helper method to update player statistics
        private async Task UpdatePlayerStatistics(int playerId, int points)
        {
            // Find player detail record
            var playerDetail = await _context.PlayerDetails
                .FirstOrDefaultAsync(pd => pd.PlayerId == playerId);

            if (playerDetail == null)
            {
                // Create new player detail record if it doesn't exist
                var player = await _context.Players.FindAsync(playerId);
                if (player != null)
                {
                    playerDetail = new PlayerDetail
                    {
                        PlayerId = playerId,
                        TeamId = player.TeamId,
                        TotalPoints = points > 0 ? points : 0
                    };
                    _context.PlayerDetails.Add(playerDetail);
                }
            }
            else
            {
                // Update existing player detail record
                playerDetail.TotalPoints = (playerDetail.TotalPoints ?? 0) + points;
                if (playerDetail.TotalPoints < 0)
                {
                    playerDetail.TotalPoints = 0;
                }
                _context.Update(playerDetail);
            }

            await _context.SaveChangesAsync();
        }

        // Helper method to calculate match end time based on tournament type
        private async Task<DateTime> CalculateMatchEndTime(DateTime matchDate, int? tournamentId = null)
        {
            // Default duration for 3v3 basketball (15 minutes)
            TimeSpan duration = TimeSpan.FromMinutes(15);

            if (tournamentId.HasValue)
            {
                // Get tournament information
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId.Value);

                if (tournament != null)
                {
                    // Check tournament name to determine type (3v3 or 5v5)
                    bool is5v5 = tournament.Name.Contains("5v5") || tournament.Name.Contains("5 vs 5");

                    if (is5v5)
                    {
                        // NBA 5v5 match duration calculation:
                        // 4 quarters x 12 minutes = 48 minutes of play time
                        // 3 x 2 minutes break between quarters = 6 minutes
                        // 1 x 15 minutes halftime break = 15 minutes
                        // Total: 48 + 6 + 15 = 69 minutes
                        duration = TimeSpan.FromMinutes(69);
                    }
                    else
                    {
                        // 3v3 basketball: match lasts 15 minutes or until a team reaches 21 points
                        duration = TimeSpan.FromMinutes(15);
                    }
                }
            }

            // Calculate end time by adding duration to start time
            // Use the date part from matchDate and time part from MatchTime
            DateTime endTime = matchDate.Add(duration);

            return endTime;
        }
    }
}
