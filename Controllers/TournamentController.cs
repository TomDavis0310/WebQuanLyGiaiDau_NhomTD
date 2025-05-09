using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Authorize]
    public class TournamentController : Controller
    {
        private readonly ApplicationDbContext _context;

        public TournamentController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Tournament

        public async Task<IActionResult> Index()
        {
            return View(await _context.Tournaments.Include(t => t.Sports).ToListAsync());
        }


        // GET: Tournament/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments
                .Include(t => t.Sports)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (tournament == null)
            {
                return NotFound();
            }

            // Lấy danh sách các trận đấu của giải đấu này, chỉ lấy các cột cần thiết
            // Không bao gồm cột Status vì nó không tồn tại trong database
            var matches = await _context.Matches
                .AsNoTracking()
                .Where(m => m.TournamentId == id)
                .Select(m => new Match
                {
                    Id = m.Id,
                    TeamA = m.TeamA,
                    TeamB = m.TeamB,
                    MatchDate = m.MatchDate,
                    ScoreTeamA = m.ScoreTeamA,
                    ScoreTeamB = m.ScoreTeamB,
                    TournamentId = m.TournamentId
                })
                .ToListAsync();

            // Load related tournament data separately to avoid Status column issue
            foreach (var match in matches)
            {
                match.Tournament = await _context.Tournaments
                    .AsNoTracking()
                    .FirstOrDefaultAsync(t => t.Id == match.TournamentId);
            }

            // Tạo điểm số cho các trận đã hoàn thành nếu chưa có
            var random = new Random();
            foreach (var match in matches)
            {
                // Xác định trạng thái trận đấu dựa trên ngày
                var isCompleted = match.CalculatedStatus == "Completed";

                // Tạo điểm số cho các trận đã hoàn thành
                if (isCompleted && (!match.ScoreTeamA.HasValue || !match.ScoreTeamB.HasValue))
                {
                    match.ScoreTeamA = random.Next(60, 121); // Điểm bóng rổ từ 60-120
                    match.ScoreTeamB = random.Next(60, 121);

                    // Lưu điểm số vào database - chỉ cập nhật các cột cần thiết
                    var matchToUpdate = await _context.Matches.FindAsync(match.Id);
                    if (matchToUpdate != null)
                    {
                        matchToUpdate.ScoreTeamA = match.ScoreTeamA;
                        matchToUpdate.ScoreTeamB = match.ScoreTeamB;
                        _context.Matches.Update(matchToUpdate);
                    }
                }
            }

            // Lưu các thay đổi vào database
            await _context.SaveChangesAsync();

            // Lấy danh sách các đội tham gia dựa trên các trận đấu của giải đấu hiện tại
            var teamNames = new HashSet<string>();
            foreach (var match in matches)
            {
                teamNames.Add(match.TeamA);
                teamNames.Add(match.TeamB);
            }

            // Lấy thông tin chi tiết về các đội từ bảng Teams
            // Chỉ lấy các đội tham gia giải đấu hiện tại
            List<Team> teams = new List<Team>();
            if (teamNames.Count > 0)
            {
                teams = await _context.Teams
                    .Where(t => teamNames.Contains(t.Name))
                    .Include(t => t.Players)
                    .ToListAsync();
            }
            // Nếu không có trận đấu nào, hiển thị danh sách đội rỗng
            // Không lấy tất cả các đội từ database nữa

            // Tính toán bảng xếp hạng dựa trên kết quả trận đấu
            var teamRankings = new List<dynamic>();

            foreach (var team in teams)
            {
                // Tìm tất cả các trận đấu của đội này
                var teamMatches = matches.Where(m => m.TeamA == team.Name || m.TeamB == team.Name).ToList();

                // Chỉ tính các trận đã hoàn thành (dựa vào CalculatedStatus)
                var completedMatches = teamMatches.Where(m => m.CalculatedStatus == "Completed").ToList();

                int played = completedMatches.Count;
                int won = 0;
                int lost = 0;
                int drawn = 0;
                int pointsScored = 0;
                int pointsConceded = 0;

                foreach (var match in completedMatches)
                {
                    if (match.TeamA == team.Name)
                    {
                        // Đội này là TeamA
                        pointsScored += match.ScoreTeamA ?? 0;
                        pointsConceded += match.ScoreTeamB ?? 0;

                        if (match.ScoreTeamA > match.ScoreTeamB)
                            won++;
                        else if (match.ScoreTeamA < match.ScoreTeamB)
                            lost++;
                        else
                            drawn++;
                    }
                    else
                    {
                        // Đội này là TeamB
                        pointsScored += match.ScoreTeamB ?? 0;
                        pointsConceded += match.ScoreTeamA ?? 0;

                        if (match.ScoreTeamB > match.ScoreTeamA)
                            won++;
                        else if (match.ScoreTeamB < match.ScoreTeamA)
                            lost++;
                        else
                            drawn++;
                    }
                }

                // Tính điểm: thắng 2 điểm, hòa 1 điểm (quy tắc bóng rổ)
                int points = won * 2 + drawn;
                int pointDiff = pointsScored - pointsConceded;

                teamRankings.Add(new
                {
                    Team = team,
                    Played = played,
                    Won = won,
                    Drawn = drawn,
                    Lost = lost,
                    PointsScored = pointsScored,
                    PointsConceded = pointsConceded,
                    PointDiff = pointDiff,
                    Points = points
                });
            }

            // Sắp xếp theo điểm (giảm dần) và hiệu số (giảm dần)
            teamRankings = teamRankings.OrderByDescending(t => t.Points)
                                      .ThenByDescending(t => t.PointDiff)
                                      .ToList();

            // Tạo ViewBag.MatchStatus để sử dụng trong view
            var matchStatus = new Dictionary<int, string>();
            foreach (var match in matches)
            {
                matchStatus[match.Id] = match.CalculatedStatus;
            }

            ViewBag.Teams = teams;
            ViewBag.Matches = matches;
            ViewBag.TeamRankings = teamRankings;
            ViewBag.MatchStatus = matchStatus;

            return View(tournament);
        }

        // GET: Tournament/Create
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public IActionResult Create(int? sportsId = null)
        {
            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name", sportsId);

            // Tạo giải đấu mới với ngày bắt đầu và kết thúc mặc định
            var tournament = new Tournament
            {
                StartDate = DateTime.Now,
                EndDate = DateTime.Now.AddMonths(1)
            };

            // If sportsId is provided, pre-select it in the form
            if (sportsId.HasValue)
            {
                tournament.SportsId = sportsId.Value;
            }

            return View(tournament);
        }

        // POST: Tournament/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Create(Tournament tournament, IFormFile imageUrl)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (imageUrl != null)
                    {
                        tournament.ImageUrl = await SaveImage(imageUrl);

                    }
                    _context.Add(tournament);
                    await _context.SaveChangesAsync();

                    // Redirect back to the sports list view if we came from there
                    if (tournament.SportsId > 0)
                    {
                        return RedirectToAction("List", "Sports", new { sportsId = tournament.SportsId });
                    }

                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }
            else
            {
                foreach (var modelState in ViewData.ModelState.Values)
                {
                    foreach (var error in modelState.Errors)
                    {
                        Console.WriteLine(error.ErrorMessage); // Debug
                    }
                }
            }

            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name");
            return View(tournament);
        }
        private async Task<string> SaveImage(IFormFile image)
        {
            var savePath = Path.Combine("wwwroot/images", image.FileName);
            using (var fileStream = new FileStream(savePath, FileMode.Create))
            {
                await image.CopyToAsync(fileStream);
            }
            return "/images/" + image.FileName;
        }


        // GET: Tournament/Edit/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null)
            {
                return NotFound();
            }

            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name", tournament.SportsId);

            return View(tournament);
        }

        // POST: Tournament/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, Tournament tournament, IFormFile imageUrl)
        {
            if (id != tournament.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Get the existing tournament to preserve the image URL if no new image is uploaded
                    var existingTournament = await _context.Tournaments.AsNoTracking().FirstOrDefaultAsync(t => t.Id == id);

                    if (imageUrl != null)
                    {
                        // Upload new image
                        tournament.ImageUrl = await SaveImage(imageUrl);
                    }
                    else if (existingTournament != null)
                    {
                        // Keep existing image URL if no new image is uploaded
                        tournament.ImageUrl = existingTournament.ImageUrl;
                    }

                    _context.Update(tournament);
                    await _context.SaveChangesAsync();

                    // Redirect back to the sports list view if we came from there
                    if (tournament.SportsId > 0)
                    {
                        return RedirectToAction("List", "Sports", new { sportsId = tournament.SportsId });
                    }

                    return RedirectToAction(nameof(Index));
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!TournamentExists(tournament.Id))
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

            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name", tournament.SportsId);
            return View(tournament);
        }

        // GET: Tournament/Delete/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments
                .Include(t => t.Sports)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (tournament == null)
            {
                return NotFound();
            }

            return View(tournament);
        }

        // POST: Tournament/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var tournament = await _context.Tournaments.FindAsync(id);
                if (tournament != null)
                {
                    // Check if there are any registrations for this tournament
                    bool hasRegistrations = false;
                    try
                    {
                        hasRegistrations = await _context.TournamentRegistrations
                            .AnyAsync(r => r.TournamentId == id);
                    }
                    catch (Exception)
                    {
                        // Table might not exist yet, ignore this check
                    }

                    // Check if there are any matches for this tournament
                    bool hasMatches = false;
                    try
                    {
                        hasMatches = await _context.Matches
                            .AnyAsync(m => m.TournamentId == id);
                    }
                    catch (Exception)
                    {
                        // Table might not exist yet, ignore this check
                    }

                    if (hasRegistrations || hasMatches)
                    {
                        // If there are related records, return to the delete view with an error message
                        ViewData["error"] = "Không thể xóa giải đấu này vì có đăng ký hoặc trận đấu liên quan.";
                        tournament = await _context.Tournaments
                            .FirstOrDefaultAsync(m => m.Id == id);
                        return View(tournament);
                    }

                    // Store the sportsId before removing the tournament
                    int? sportsId = tournament.SportsId;

                    _context.Tournaments.Remove(tournament);
                    await _context.SaveChangesAsync();

                    // Redirect back to the sports list view if we have a sportsId
                    if (sportsId.HasValue && sportsId.Value > 0)
                    {
                        return RedirectToAction("List", "Sports", new { sportsId = sportsId.Value });
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                // Handle any other exceptions
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(m => m.Id == id);

                // Format a more user-friendly error message
                string errorMessage = "Lỗi khi xóa giải đấu: ";
                if (ex.Message.Contains("TournamentRegistrations"))
                {
                    errorMessage += "Có đăng ký tham gia giải đấu này. Vui lòng xóa các đăng ký trước.";
                }
                else if (ex.Message.Contains("Matches"))
                {
                    errorMessage += "Có trận đấu liên quan đến giải đấu này. Vui lòng xóa các trận đấu trước.";
                }
                else
                {
                    errorMessage += ex.Message;
                }

                ViewData["error"] = errorMessage;
                return View(tournament);
            }
        }

        private bool TournamentExists(int id)
        {
            return _context.Tournaments.Any(e => e.Id == id);
        }

        // GET: Tournament/Register/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)]
        public async Task<IActionResult> Register(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments
                .Include(t => t.Sports)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (tournament == null)
            {
                return NotFound();
            }

            // Check if user has already registered for this tournament
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var existingRegistration = await _context.TournamentRegistrations
                .FirstOrDefaultAsync(r => r.TournamentId == id && r.UserId == userId);

            if (existingRegistration != null)
            {
                // User has already registered
                ViewBag.AlreadyRegistered = true;
                ViewBag.RegistrationStatus = existingRegistration.Status;
            }
            else
            {
                ViewBag.AlreadyRegistered = false;
            }

            return View(tournament);
        }

        // POST: Tournament/Register/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)]
        public async Task<IActionResult> Register(int id, string notes)
        {
            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null)
            {
                return NotFound();
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Check if user has already registered
            var existingRegistration = await _context.TournamentRegistrations
                .FirstOrDefaultAsync(r => r.TournamentId == id && r.UserId == userId);

            if (existingRegistration != null)
            {
                // User has already registered
                TempData["Message"] = "Bạn đã đăng ký giải đấu này rồi.";
                return RedirectToAction(nameof(Index));
            }

            // Create new registration
            var registration = new TournamentRegistration
            {
                TournamentId = id,
                UserId = userId,
                RegistrationDate = DateTime.Now,
                Status = "Pending",
                Notes = notes
            };

            _context.TournamentRegistrations.Add(registration);
            await _context.SaveChangesAsync();

            TempData["Message"] = "Đăng ký giải đấu thành công. Vui lòng chờ phê duyệt.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Tournament/MyRegistrations
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)]
        public async Task<IActionResult> MyRegistrations()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var registrations = await _context.TournamentRegistrations
                .Include(r => r.Tournament)
                .Where(r => r.UserId == userId)
                .ToListAsync();

            return View(registrations);
        }

        // GET: Tournament/ManageRegistrations
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> ManageRegistrations()
        {
            var registrations = await _context.TournamentRegistrations
                .Include(r => r.Tournament)
                .Include(r => r.User)
                .ToListAsync();

            return View(registrations);
        }

        // POST: Tournament/UpdateRegistrationStatus
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> UpdateRegistrationStatus(int id, string status)
        {
            var registration = await _context.TournamentRegistrations.FindAsync(id);
            if (registration == null)
            {
                return NotFound();
            }

            registration.Status = status;
            _context.Update(registration);
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(ManageRegistrations));
        }
    }
}
