using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class PollsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public PollsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // List polls for a tournament
        public async Task<IActionResult> List(int tournamentId)
        {
            var polls = await _context.Polls
                .Include(p => p.Options)
                .Where(p => p.TournamentId == tournamentId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();

            ViewBag.TournamentId = tournamentId;
            return View(polls);
        }

        // Admin: Create poll (GET)
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Create(int tournamentId)
        {
            var model = new Poll { TournamentId = tournamentId, StartAt = DateTime.UtcNow, EndAt = DateTime.UtcNow.AddDays(7) };

            // load teams participating in tournament and their players
            var teamIds = await _context.TournamentTeams
                .Where(tt => tt.TournamentId == tournamentId)
                .Select(tt => tt.TeamId)
                .ToListAsync();

            var teams = await _context.Teams.Where(t => teamIds.Contains(t.TeamId)).ToListAsync();
            var players = await _context.Players.Where(p => teamIds.Contains(p.TeamId)).ToListAsync();

            ViewBag.Teams = teams;
            ViewBag.Players = players;

            return View(model);
        }

        // Admin: Create poll (POST)
        [HttpPost]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Poll model, string[] optionNames, int[]? optionEntityIds, string? optionEntityType)
        {
            if (!ModelState.IsValid)
            {
                // reload participants for the view
                var teamIds = await _context.TournamentTeams
                    .Where(tt => tt.TournamentId == model.TournamentId)
                    .Select(tt => tt.TeamId)
                    .ToListAsync();

                ViewBag.Teams = await _context.Teams.Where(t => teamIds.Contains(t.TeamId)).ToListAsync();
                ViewBag.Players = await _context.Players.Where(p => teamIds.Contains(p.TeamId)).ToListAsync();
                return View(model);
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? string.Empty;
            model.CreatedById = userId;
            model.CreatedAt = DateTime.UtcNow;
            _context.Polls.Add(model);
            await _context.SaveChangesAsync();
            // Option entities (players/teams) selected
            if (optionEntityIds != null && !string.IsNullOrEmpty(optionEntityType))
            {
                int idx = 0;
                foreach (var entId in optionEntityIds)
                {
                    string name = string.Empty;
                    if (optionEntityType == "Player")
                    {
                        var p = await _context.Players.FindAsync(entId);
                        if (p == null) continue;
                        name = p.FullName;
                    }
                    else if (optionEntityType == "Team")
                    {
                        var t = await _context.Teams.FindAsync(entId);
                        if (t == null) continue;
                        name = t.Name;
                    }

                    if (string.IsNullOrWhiteSpace(name)) continue;
                    _context.PollOptions.Add(new PollOption { PollId = model.Id, Name = name.Trim(), SortOrder = idx, EntityType = optionEntityType, EntityId = entId });
                    idx++;
                }
                await _context.SaveChangesAsync();
            }

            // fallback: raw option names
            else if (optionNames != null)
            {
                foreach (var (name, idx) in optionNames.Select((v, i) => (v, i)))
                {
                    if (string.IsNullOrWhiteSpace(name)) continue;
                    _context.PollOptions.Add(new PollOption { PollId = model.Id, Name = name.Trim(), SortOrder = idx });
                }
                await _context.SaveChangesAsync();
            }

            return RedirectToAction(nameof(List), new { tournamentId = model.TournamentId });
        }

        // Poll details (show options and allow vote)
        public async Task<IActionResult> Details(int id)
        {
            var poll = await _context.Polls.Include(p => p.Options).FirstOrDefaultAsync(p => p.Id == id);
            if (poll == null) return NotFound();
            return View(poll);
        }

        // POST vote
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Vote(int pollId, int optionId)
        {
            var poll = await _context.Polls.FirstOrDefaultAsync(p => p.Id == pollId);
            if (poll == null) return NotFound();

            var now = DateTime.UtcNow;
            if (now < poll.StartAt || now > poll.EndAt)
            {
                TempData["Error"] = "Thời gian bình chọn chưa bắt đầu hoặc đã kết thúc.";
                return RedirectToAction("Details", "Tournament", new { id = poll.TournamentId });
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Challenge();

            var already = await _context.PollVotes.AnyAsync(v => v.PollId == pollId && v.UserId == userId);
            if (already)
            {
                TempData["Error"] = "Bạn đã tham gia bình chọn cho bảng này.";
                return RedirectToAction("Details", "Tournament", new { id = poll.TournamentId });
            }

            var vote = new PollVote { PollId = pollId, OptionId = optionId, UserId = userId, CreatedAt = DateTime.UtcNow };
            _context.PollVotes.Add(vote);
            try
            {
                await _context.SaveChangesAsync();
                TempData["Success"] = "Cảm ơn bạn đã tham gia bình chọn!";
            }
            catch (DbUpdateException)
            {
                // possible race / unique constraint
                TempData["Error"] = "Bạn đã bình chọn cho bảng này (hoặc có lỗi).";
            }

            return RedirectToAction("Details", "Tournament", new { id = poll.TournamentId });
        }

        // Results
        public async Task<IActionResult> Results(int id)
        {
            var poll = await _context.Polls.Include(p => p.Options).FirstOrDefaultAsync(p => p.Id == id);
            if (poll == null) return NotFound();

            var total = await _context.PollVotes.CountAsync(v => v.PollId == id);
            var counts = await _context.PollVotes
                .Where(v => v.PollId == id)
                .GroupBy(v => v.OptionId)
                .Select(g => new { OptionId = g.Key, Count = g.Count() })
                .ToListAsync();

            ViewBag.Total = total;
            ViewBag.Counts = counts.ToDictionary(x => x.OptionId, x => x.Count);
            return View(poll);
        }

        // Admin: list polls created by current admin
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> MyPolls()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var polls = await _context.Polls.Where(p => p.CreatedById == userId).OrderByDescending(p => p.CreatedAt).ToListAsync();
            return View(polls);
        }

        // Admin: publish results
        [HttpPost]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Publish(int id)
        {
            var poll = await _context.Polls.FindAsync(id);
            if (poll == null) return NotFound();
            poll.IsPublished = true;
            _context.Update(poll);
            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Details), new { id });
        }
    }
}
