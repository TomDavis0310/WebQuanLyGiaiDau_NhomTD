using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class VotingController : Controller
    {
        private readonly ApplicationDbContext _context;

        public VotingController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Bình chọn đội thắng trong trận đấu
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> VoteMatch(int matchId, string votedTeam)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Json(new { success = false, message = "Bạn cần đăng nhập để bình chọn" });
            }

            // Kiểm tra cài đặt bình chọn
            var settings = await _context.VotingSettings.FirstOrDefaultAsync();
            if (settings != null && !settings.AllowMatchVoting)
            {
                return Json(new { success = false, message = "Bình chọn trận đấu đã bị tắt" });
            }

            // Kiểm tra trận đấu có tồn tại
            var match = await _context.Matches.FindAsync(matchId);
            if (match == null)
            {
                return Json(new { success = false, message = "Không tìm thấy trận đấu" });
            }

            // Kiểm tra user đã vote chưa
            var existingVote = await _context.MatchVotes
                .FirstOrDefaultAsync(v => v.MatchId == matchId && v.UserId == userId);

            if (existingVote != null)
            {
                // Cập nhật vote cũ
                existingVote.VotedTeam = votedTeam;
                existingVote.VoteTime = DateTime.Now;
                _context.Update(existingVote);
            }
            else
            {
                // Tạo vote mới và tặng điểm
                var newVote = new MatchVote
                {
                    MatchId = matchId,
                    UserId = userId,
                    VotedTeam = votedTeam,
                    VoteTime = DateTime.Now
                };
                _context.MatchVotes.Add(newVote);

                // Tặng điểm cho user
                var user = await _context.Users.FindAsync(userId);
                if (user != null)
                {
                    var pointsSetting = await _context.PointsSettings.FirstOrDefaultAsync();
                    var points = pointsSetting?.VoteTeamPoints ?? 3;
                    user.Points += points;
                    _context.Update(user);
                }
            }

            await _context.SaveChangesAsync();
            return Json(new { success = true, message = "Bình chọn thành công!" });
        }

        // Bình chọn đội vô địch giải đấu
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> VoteTournament(int tournamentId, string votedTeamName)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
            {
                return Json(new { success = false, message = "Bạn cần đăng nhập để bình chọn" });
            }

            // Kiểm tra cài đặt bình chọn
            var settings = await _context.VotingSettings.FirstOrDefaultAsync();
            if (settings != null && !settings.AllowTournamentVoting)
            {
                return Json(new { success = false, message = "Bình chọn vô địch đã bị tắt" });
            }

            // Kiểm tra giải đấu có tồn tại
            var tournament = await _context.Tournaments.FindAsync(tournamentId);
            if (tournament == null)
            {
                return Json(new { success = false, message = "Không tìm thấy giải đấu" });
            }

            // Kiểm tra user đã vote chưa
            var existingVote = await _context.TournamentVotes
                .FirstOrDefaultAsync(v => v.TournamentId == tournamentId && v.UserId == userId);

            if (existingVote != null)
            {
                // Cập nhật vote cũ
                existingVote.VotedTeamName = votedTeamName;
                existingVote.VoteTime = DateTime.Now;
                _context.Update(existingVote);
            }
            else
            {
                // Tạo vote mới và tặng điểm
                var newVote = new TournamentVote
                {
                    TournamentId = tournamentId,
                    UserId = userId,
                    VotedTeamName = votedTeamName,
                    VoteTime = DateTime.Now
                };
                _context.TournamentVotes.Add(newVote);

                // Tặng điểm cho user
                var user = await _context.Users.FindAsync(userId);
                if (user != null)
                {
                    var pointsSetting = await _context.PointsSettings.FirstOrDefaultAsync();
                    var points = pointsSetting?.VoteTournamentPoints ?? 5;
                    user.Points += points;
                    _context.Update(user);
                }
            }

            await _context.SaveChangesAsync();
            return Json(new { success = true, message = "Bình chọn vô địch thành công!" });
        }

        // Admin: Quản lý cài đặt bình chọn
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Settings()
        {
            var settings = await _context.VotingSettings.FirstOrDefaultAsync();
            if (settings == null)
            {
                settings = new VotingSettings();
                _context.VotingSettings.Add(settings);
                await _context.SaveChangesAsync();
            }
            return View(settings);
        }

        [HttpPost]
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Settings(VotingSettings model)
        {
            if (ModelState.IsValid)
            {
                var settings = await _context.VotingSettings.FirstOrDefaultAsync();
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                
                if (settings == null)
                {
                    model.UpdatedBy = userId;
                    model.LastUpdated = DateTime.Now;
                    _context.VotingSettings.Add(model);
                }
                else
                {
                    settings.AllowMatchVoting = model.AllowMatchVoting;
                    settings.AllowTournamentVoting = model.AllowTournamentVoting;
                    settings.UpdatedBy = userId;
                    settings.LastUpdated = DateTime.Now;
                    _context.Update(settings);
                }
                
                await _context.SaveChangesAsync();
                TempData["Success"] = "Cập nhật cài đặt bình chọn thành công!";
                return RedirectToAction(nameof(Settings));
            }
            return View(model);
        }

        // Xem thống kê bình chọn
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Statistics(int? matchId, int? tournamentId)
        {
            ViewData["Matches"] = await _context.Matches
                .OrderByDescending(m => m.MatchDate)
                .Take(20)
                .ToListAsync();

            ViewData["Tournaments"] = await _context.Tournaments
                .OrderByDescending(t => t.StartDate)
                .Take(10)
                .ToListAsync();

            if (matchId.HasValue)
            {
                var matchVotes = await _context.MatchVotes
                    .Include(v => v.User)
                    .Include(v => v.Match)
                    .Where(v => v.MatchId == matchId.Value)
                    .OrderByDescending(v => v.VoteTime)
                    .ToListAsync();
                ViewData["MatchVotes"] = matchVotes;
                ViewData["SelectedMatchId"] = matchId.Value;
            }

            if (tournamentId.HasValue)
            {
                var tournamentVotes = await _context.TournamentVotes
                    .Include(v => v.User)
                    .Include(v => v.Tournament)
                    .Where(v => v.TournamentId == tournamentId.Value)
                    .OrderByDescending(v => v.VoteTime)
                    .ToListAsync();
                ViewData["TournamentVotes"] = tournamentVotes;
                ViewData["SelectedTournamentId"] = tournamentId.Value;
            }

            return View();
        }
    }
}