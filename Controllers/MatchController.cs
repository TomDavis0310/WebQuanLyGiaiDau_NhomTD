namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    using Microsoft.AspNetCore.Authorization;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.EntityFrameworkCore;
    using WebQuanLyGiaiDau_NhomTD.Models;
    using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

    [Authorize]
    public class MatchController : Controller
    {
        private readonly ApplicationDbContext _context;

        public MatchController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Match
        public async Task<IActionResult> Index(string searchString)
        {
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

            var matches = await matchesQuery.ToListAsync();

            // Lưu searchString để hiển thị lại trong form
            ViewData["CurrentFilter"] = searchString;

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
                // Distribute scores across quarters
                for (int i = 0; i < 3; i++) // First 3 quarters
                {
                    quarterScoresTeamA[i] = totalScoreTeamA > 0 ? random.Next(15, Math.Min(35, totalScoreTeamA)) : 0;
                    totalScoreTeamA -= quarterScoresTeamA[i];

                    quarterScoresTeamB[i] = totalScoreTeamB > 0 ? random.Next(15, Math.Min(35, totalScoreTeamB)) : 0;
                    totalScoreTeamB -= quarterScoresTeamB[i];
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
                        bestPlayerPoints = random.Next(5, Math.Min(15, bestPlayer.Points));
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

            ViewBag.MatchSets = matchSets;
            ViewBag.MatchStatus = match.CalculatedStatus;

            // Tính toán thời gian kết thúc trận đấu dựa trên luật NBA
            ViewBag.MatchEndTime = CalculateMatchEndTime(match.MatchDate);

            return View(match);
        }

        // GET: Match/Create
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Create()
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
                    // Đặt thời gian bắt đầu là 15:00 (3 giờ chiều)
                    DateTime matchDate = match.MatchDate.Date;
                    match.MatchDate = matchDate.AddHours(15); // 15:00

                    // Thêm thông tin về thời gian kết thúc vào ViewBag để hiển thị
                    ViewBag.MatchEndTime = CalculateMatchEndTime(match.MatchDate);

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
                    // Đảm bảo thời gian bắt đầu là 15:00 (3 giờ chiều)
                    DateTime matchDate = match.MatchDate.Date;
                    match.MatchDate = matchDate.AddHours(15); // 15:00

                    // Thêm thông tin về thời gian kết thúc vào ViewBag để hiển thị
                    ViewBag.MatchEndTime = CalculateMatchEndTime(match.MatchDate);

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
                return RedirectToAction(nameof(Delete), new { id = id, error = "Không thể xóa trận đấu này vì có dữ liệu liên quan." });
            }
        }

        private bool MatchExists(int id)
        {
            return _context.Matches.Any(e => e.Id == id);
        }

        // Helper method to calculate match end time based on NBA rules
        private DateTime CalculateMatchEndTime(DateTime startTime)
        {
            // NBA 5v5 match duration:
            // 4 quarters x 12 minutes = 48 minutes of play time
            // 2 x 2.5 minutes break between quarters 1-2 and 3-4 = 5 minutes
            // 1 x 15 minutes halftime break between quarters 2-3 = 15 minutes
            // Total: 48 + 5 + 15 = 68 minutes = 1 hour and 8 minutes

            return startTime.AddHours(1).AddMinutes(8);
        }
    }
}
