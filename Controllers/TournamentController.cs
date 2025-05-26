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
using WebQuanLyGiaiDau_NhomTD.Services;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;
using Microsoft.AspNetCore.Http;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class TournamentController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly TournamentScheduleService _scheduleService;
        private readonly ITournamentEmailService _emailService;

        public TournamentController(ApplicationDbContext context, WebQuanLyGiaiDau_NhomTD.Services.TournamentScheduleService scheduleService, ITournamentEmailService emailService)
        {
            _context = context;
            _scheduleService = scheduleService;
            _emailService = emailService;
        }

        // GET: Tournament/GenerateSchedule
        [Authorize]
        public async Task<IActionResult> Index(string searchString)
        {
            var tournamentsQuery = _context.Tournaments
                .Include(t => t.Sports)
                .AsQueryable();

            // Áp dụng tìm kiếm nếu có
            if (!string.IsNullOrEmpty(searchString))
            {
                searchString = searchString.ToLower();
                tournamentsQuery = tournamentsQuery.Where(t =>
                    t.Name.ToLower().Contains(searchString) ||
                    (t.Description != null && t.Description.ToLower().Contains(searchString)) ||
                    (t.Sports != null && t.Sports.Name.ToLower().Contains(searchString)));
            }

            var tournaments = await tournamentsQuery.ToListAsync();

            // Lưu searchString để hiển thị lại trong form
            ViewData["CurrentFilter"] = searchString;

            return View(tournaments);
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
                .Include(t => t.TournamentFormat)
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

            // Đảm bảo tất cả các trận đấu đều có thời gian bắt đầu là 15:00 (3 giờ chiều)
            foreach (var match in matches)
            {
                // Chỉ cập nhật hiển thị, không cập nhật database
                DateTime matchDate = match.MatchDate.Date;
                match.MatchDate = matchDate.AddHours(15); // 15:00
            }

            // Load related tournament data separately to avoid Status column issue
            foreach (var match in matches)
            {
                var tournamentData = await _context.Tournaments
                    .AsNoTracking()
                    .FirstOrDefaultAsync(t => t.Id == match.TournamentId);

                if (tournamentData != null)
                {
                    match.Tournament = tournamentData;
                }
            }

            // Tạo điểm số cho các trận đã hoàn thành và đang diễn ra nếu chưa có
            var random = new Random();
            foreach (var match in matches)
            {
                // Xác định trạng thái trận đấu dựa trên ngày
                var status = match.CalculatedStatus;

                // Tạo điểm số cho các trận đã hoàn thành
                if (status == "Completed" && (!match.ScoreTeamA.HasValue || !match.ScoreTeamB.HasValue))
                {
                    // Trong bóng rổ 3v3, điểm thường thấp hơn, thường từ 15-21 điểm
                    match.ScoreTeamA = random.Next(15, 22); // Điểm bóng rổ 3v3 từ 15-21
                    match.ScoreTeamB = random.Next(15, 22);

                    // Đảm bảo không có trận hòa trong bóng rổ 3v3
                    if (match.ScoreTeamA == match.ScoreTeamB)
                    {
                        // Một đội phải thắng, không có hòa
                        if (random.Next(2) == 0)
                            match.ScoreTeamA += 1;
                        else
                            match.ScoreTeamB += 1;
                    }

                    // Lưu điểm số vào database - chỉ cập nhật các cột cần thiết
                    var matchToUpdate = await _context.Matches.FindAsync(match.Id);
                    if (matchToUpdate != null)
                    {
                        matchToUpdate.ScoreTeamA = match.ScoreTeamA;
                        matchToUpdate.ScoreTeamB = match.ScoreTeamB;
                        _context.Matches.Update(matchToUpdate);
                    }
                }
                // Tạo điểm số cho các trận đang diễn ra - Bóng rổ 3v3
                else if (status == "InProgress" && (!match.ScoreTeamA.HasValue || !match.ScoreTeamB.HasValue))
                {
                    match.ScoreTeamA = random.Next(5, 16); // Điểm bóng rổ 3v3 đang diễn ra từ 5-15
                    match.ScoreTeamB = random.Next(5, 16);

                    // Đảm bảo điểm số hợp lý cho trận đang diễn ra
                    // Trong bóng rổ 3v3, trận đấu kết thúc khi một đội đạt 21 điểm
                    if (match.ScoreTeamA >= 21 || match.ScoreTeamB >= 21)
                    {
                        // Nếu một đội đạt 21 điểm, trận đấu đã kết thúc, không phải đang diễn ra
                        match.ScoreTeamA = Math.Min(match.ScoreTeamA.Value, 20);
                        match.ScoreTeamB = Math.Min(match.ScoreTeamB.Value, 20);
                    }

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

            // Lấy danh sách các đội đã đăng ký tham gia giải đấu từ bảng TournamentTeams
            var registeredTeamIds = await _context.TournamentTeams
                .Where(tt => tt.TournamentId == id && tt.Status == "Approved")
                .Select(tt => tt.TeamId)
                .ToListAsync();

            // Lấy thông tin chi tiết về các đội từ bảng Teams
            List<Team> teams = new List<Team>();

            // Lấy đội từ các trận đấu
            if (teamNames.Count > 0)
            {
                teams = await _context.Teams
                    .Where(t => teamNames.Contains(t.Name))
                    .Include(t => t.Players)
                    .ToListAsync();
            }

            // Lấy thêm các đội đã đăng ký nhưng chưa có trận đấu
            if (registeredTeamIds.Count > 0)
            {
                // Get the IDs of teams we already have
                var existingTeamIds = teams.Select(t => t.TeamId).ToList();

                // Get teams that are registered but not already in our list
                var registeredTeams = await _context.Teams
                    .Where(t => registeredTeamIds.Contains(t.TeamId) && !existingTeamIds.Contains(t.TeamId))
                    .Include(t => t.Players)
                    .ToListAsync();

                teams.AddRange(registeredTeams);
            }

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

                // Tính điểm: thắng 1 điểm, không có hòa (quy tắc bóng rổ 3v3)
                // Trong bóng rổ 3v3, không có trận hòa vì trận đấu kết thúc khi một đội đạt 21 điểm
                // hoặc khi hết thời gian, đội nào có điểm cao hơn sẽ thắng
                int points = won;
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

            // Get player statistics for this tournament
            var playerStats = await GetPlayerStatistics(id.Value, teams, matches);

            // Kiểm tra xem user hiện tại đã được duyệt tham gia giải đấu này chưa
            bool isUserApproved = false;
            bool hasTeamForTournament = false;

            if (User.Identity.IsAuthenticated && !User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                // Kiểm tra xem user đã được duyệt chưa
                isUserApproved = await _context.TournamentRegistrations
                    .AnyAsync(r => r.TournamentId == id && r.UserId == userId && r.Status == "Approved");

                // Kiểm tra xem user đã có đội cho giải đấu này chưa
                if (isUserApproved)
                {
                    hasTeamForTournament = await _context.Teams
                        .Where(t => t.Coach == userId)
                        .Join(_context.TournamentTeams.Where(tt => tt.TournamentId == id),
                              team => team.TeamId,
                              tt => tt.TeamId,
                              (team, tt) => team)
                        .AnyAsync();
                }

                // Kiểm tra xem user có đội bóng nào không
                var userHasTeams = await _context.Teams
                    .AnyAsync(t => t.Coach == userId);

                ViewBag.UserHasTeams = userHasTeams;
            }

            ViewBag.Teams = teams;
            ViewBag.Matches = matches;
            ViewBag.TeamRankings = teamRankings;
            ViewBag.MatchStatus = matchStatus;
            ViewBag.PlayerStats = playerStats;
            ViewBag.IsUserApproved = isUserApproved;
            ViewBag.HasTeamForTournament = hasTeamForTournament;

            return View(tournament);
        }

        // GET: Tournament/GenerateSchedule
        [Authorize]
        public IActionResult GenerateSchedule(int id)
        {
            try
            {
                var matches = _scheduleService.GenerateSchedule(id);
                TempData["SuccessMessage"] = "Lịch thi đấu đã được tạo thành công!";
                return RedirectToAction(nameof(Details), new { id });
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = $"Lỗi khi tạo lịch thi đấu: {ex.Message}";
                return RedirectToAction(nameof(Details), new { id });
            }
        }

        // GET: Tournament/Create
        [Authorize]
        public async Task<IActionResult> GenerateSchedule(int id)
        {
            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name", sportsId);

            // Lấy danh sách các thể thức thi đấu
            var tournamentFormats = _context.TournamentFormats.ToList();
            if (tournamentFormats == null || !tournamentFormats.Any())
            {
                // Nếu chưa có dữ liệu thể thức thi đấu, khởi tạo
                SeedTournamentFormatData.SeedTournamentFormats(HttpContext.RequestServices).Wait();
                tournamentFormats = _context.TournamentFormats.ToList();
            }
            ViewBag.TournamentFormats = new SelectList(tournamentFormats, "Id", "Name");

            // Truyền thông tin chi tiết về các thể thức thi đấu để hiển thị mô tả
            ViewBag.FormatDetails = tournamentFormats;

            // Tạo giải đấu mới với ngày bắt đầu và kết thúc mặc định
            var tournament = new Tournament
            {
                StartDate = DateTime.Now,
                EndDate = DateTime.Now.AddMonths(1),
                MaxTeams = 8, // Mặc định 8 đội
                TeamsPerGroup = 4 // Mặc định 4 đội mỗi bảng
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
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Create(Tournament tournament, IFormFile imageUrl, int? TournamentFormatId, int? MaxTeams, int? TeamsPerGroup)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (imageUrl != null)
                    {
                        tournament.ImageUrl = await SaveImage(imageUrl);
                    }

                    // Cập nhật thông tin thể thức thi đấu
                    tournament.TournamentFormatId = TournamentFormatId;
                    tournament.MaxTeams = MaxTeams;
                    tournament.TeamsPerGroup = TeamsPerGroup;

                    _context.Add(tournament);
                    await _context.SaveChangesAsync();

                    // Nếu người dùng không phải Admin, đánh dấu họ là người tạo giải đấu
                    if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
                    {
                        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                        // Tạo đăng ký với trạng thái "Creator"
                        var registration = new TournamentRegistration
                        {
                            TournamentId = tournament.Id,
                            UserId = userId ?? string.Empty, // Ensure userId is not null
                            RegistrationDate = DateTime.Now,
                            Status = "Creator",
                            Notes = "Người tạo giải đấu"
                        };

                        _context.TournamentRegistrations.Add(registration);
                        await _context.SaveChangesAsync();
                    }

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
            try
            {
                if (image == null || image.Length == 0)
                {
                    return string.Empty; // Return empty string instead of null
                }

                // Kiểm tra kích thước file (giới hạn 5MB)
                if (image.Length > 5 * 1024 * 1024)
                {
                    throw new Exception("Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 5MB.");
                }

                // Kiểm tra loại file
                string extension = Path.GetExtension(image.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                if (!allowedExtensions.Contains(extension))
                {
                    throw new Exception("Chỉ chấp nhận file hình ảnh có định dạng: .jpg, .jpeg, .png, .gif");
                }

                // Đảm bảo tên file không chứa ký tự đặc biệt
                string fileName = Path.GetFileNameWithoutExtension(image.FileName);
                // Thêm timestamp để tránh trùng tên file
                string uniqueFileName = DateTime.Now.Ticks + "_" + fileName + extension;

                // Tạo đường dẫn đầy đủ
                string uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "tournaments");

                // Đảm bảo thư mục tồn tại
                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                }

                string filePath = Path.Combine(uploadsFolder, uniqueFileName);

                // Lưu file
                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await image.CopyToAsync(fileStream);
                }

                // Trả về đường dẫn tương đối để lưu vào database
                return "/images/tournaments/" + uniqueFileName;
            }
            catch (Exception ex)
            {
                throw new Exception("Lỗi khi lưu hình ảnh: " + ex.Message);
            }
        }


        // GET: Tournament/Edit/5
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments
                .Include(t => t.TournamentFormat)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tournament == null)
            {
                return NotFound();
            }

            // Kiểm tra quyền: Admin có thể sửa tất cả, người dùng thường chỉ có thể sửa giải đấu do họ tạo
            if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                // Kiểm tra xem giải đấu này có thuộc về người dùng hiện tại không
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var isTournamentCreator = await _context.TournamentRegistrations
                    .AnyAsync(tr => tr.TournamentId == id && tr.UserId == userId && tr.Status == "Creator");

                if (!isTournamentCreator)
                {
                    TempData["ErrorMessage"] = "Bạn không có quyền chỉnh sửa giải đấu này.";
                    return RedirectToAction(nameof(Index));
                }
            }

            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name", tournament.SportsId);

            // Lấy danh sách các thể thức thi đấu
            var tournamentFormats = _context.TournamentFormats.ToList();
            if (tournamentFormats == null || !tournamentFormats.Any())
            {
                // Nếu chưa có dữ liệu thể thức thi đấu, khởi tạo
                SeedTournamentFormatData.SeedTournamentFormats(HttpContext.RequestServices).Wait();
                tournamentFormats = _context.TournamentFormats.ToList();
            }
            ViewBag.TournamentFormats = new SelectList(tournamentFormats, "Id", "Name", tournament.TournamentFormatId);

            // Truyền thông tin chi tiết về các thể thức thi đấu để hiển thị mô tả
            ViewBag.FormatDetails = tournamentFormats;

            return View(tournament);
        }

        // POST: Tournament/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Edit(int id, Tournament tournament, IFormFile imageUrl, int? TournamentFormatId, int? MaxTeams, int? TeamsPerGroup)
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

                    // Cập nhật thông tin thể thức thi đấu
                    tournament.TournamentFormatId = TournamentFormatId;
                    tournament.MaxTeams = MaxTeams;
                    tournament.TeamsPerGroup = TeamsPerGroup;

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

        private bool SubmissionExists(int id)
        {
            return _context.TournamentSubmissions.Any(e => e.Id == id);
        }

        // Method to get player statistics for a tournament
        private async Task<List<dynamic>> GetPlayerStatistics(int tournamentId, List<Team> teams, List<Match> matches)
        {
            // Get all completed matches for this tournament
            var completedMatches = matches.Where(m => m.CalculatedStatus == "Completed").ToList();
            var matchIds = completedMatches.Select(m => m.Id).ToList();

            // Get existing statistics for these matches
            var existingStats = await _context.Statistics
                .Where(s => matchIds.Contains(s.MatchId))
                .ToListAsync();

            // If no statistics exist for completed matches, generate them
            if (existingStats.Count == 0 && completedMatches.Count > 0)
            {
                var newStats = new List<Statistic>();
                var random = new Random();

                foreach (var match in completedMatches)
                {
                    // Get players from both teams
                    var teamAPlayers = teams
                        .FirstOrDefault(t => t.Name == match.TeamA)?.Players
                        .ToList() ?? new List<Player>();

                    var teamBPlayers = teams
                        .FirstOrDefault(t => t.Name == match.TeamB)?.Players
                        .ToList() ?? new List<Player>();

                    int totalTeamAPoints = 0;
                    int totalTeamBPoints = 0;

                    // For 3v3 basketball, we need 5 players per team (3 chính thức + 2 dự bị)
                    // Limit to 5 players per team or use all available if less than 5
                    var teamAPlayersFor3v3 = teamAPlayers.Take(5).ToList();
                    var teamBPlayersFor3v3 = teamBPlayers.Take(5).ToList();

                    // Add stats for each player in Team A (3v3 format)
                    // Trong bóng rổ 3v3, mỗi đội có 5 cầu thủ (3 chính thức + 2 dự bị)
                    foreach (var player in teamAPlayersFor3v3)
                    {
                        // For 3v3 basketball, points are typically lower
                        // Trận đấu kéo dài 15 phút hoặc đến khi một đội đạt 21 điểm
                        // Trong bóng rổ 3v3, điểm cá nhân thường thấp hơn nhiều
                        int playerPoints = random.Next(2, 8); // Individual player scores for 3v3
                        totalTeamAPoints += playerPoints;

                        newStats.Add(new Statistic
                        {
                            PlayerName = player.FullName,
                            Points = playerPoints,
                            Assists = random.Next(0, 4),  // Fewer assists in 3v3
                            Rebounds = random.Next(0, 6), // Fewer rebounds in 3v3
                            MatchId = match.Id
                        });
                    }

                    // Add stats for each player in Team B (3v3 format)
                    // Trong bóng rổ 3v3, mỗi đội có 5 cầu thủ (3 chính thức + 2 dự bị)
                    foreach (var player in teamBPlayersFor3v3)
                    {
                        // Trận đấu kéo dài 15 phút hoặc đến khi một đội đạt 21 điểm
                        // Trong bóng rổ 3v3, điểm cá nhân thường thấp hơn nhiều
                        int playerPoints = random.Next(2, 8); // Individual player scores for 3v3
                        totalTeamBPoints += playerPoints;

                        newStats.Add(new Statistic
                        {
                            PlayerName = player.FullName,
                            Points = playerPoints,
                            Assists = random.Next(0, 4),  // Fewer assists in 3v3
                            Rebounds = random.Next(0, 6), // Fewer rebounds in 3v3
                            MatchId = match.Id
                        });
                    }

                    // Adjust the last player's points to match the team score for 3v3 format
                    if (teamAPlayersFor3v3.Any() && match.ScoreTeamA.HasValue)
                    {
                        var lastPlayerA = newStats.Last(s => s.MatchId == match.Id && teamAPlayersFor3v3.Any(p => p.FullName == s.PlayerName));
                        int adjustment = match.ScoreTeamA.Value - totalTeamAPoints;

                        // Make sure the adjustment is reasonable for 3v3 basketball
                        if (adjustment > 5)
                            adjustment = random.Next(1, 6); // Limit large adjustments
                        else if (adjustment < -5)
                            adjustment = random.Next(-5, 0); // Limit large negative adjustments

                        lastPlayerA.Points += adjustment;

                        // Ensure points are not negative
                        if (lastPlayerA.Points < 0)
                            lastPlayerA.Points = 0;
                    }

                    if (teamBPlayersFor3v3.Any() && match.ScoreTeamB.HasValue)
                    {
                        var lastPlayerB = newStats.Last(s => s.MatchId == match.Id && teamBPlayersFor3v3.Any(p => p.FullName == s.PlayerName));
                        int adjustment = match.ScoreTeamB.Value - totalTeamBPoints;

                        // Make sure the adjustment is reasonable for 3v3 basketball
                        if (adjustment > 5)
                            adjustment = random.Next(1, 6); // Limit large adjustments
                        else if (adjustment < -5)
                            adjustment = random.Next(-5, 0); // Limit large negative adjustments

                        lastPlayerB.Points += adjustment;

                        // Ensure points are not negative
                        if (lastPlayerB.Points < 0)
                            lastPlayerB.Points = 0;
                    }
                }

                // Save the new statistics to the database
                _context.Statistics.AddRange(newStats);
                await _context.SaveChangesAsync();

                // Update the existingStats list with the newly created stats
                existingStats = newStats;
            }

            // Aggregate player statistics across all matches
            var playerStatistics = existingStats
                .GroupBy(s => s.PlayerName)
                .Select(g => new
                {
                    PlayerName = g.Key,
                    TotalPoints = g.Sum(s => s.Points),
                    TotalAssists = g.Sum(s => s.Assists),
                    TotalRebounds = g.Sum(s => s.Rebounds),
                    GamesPlayed = g.Select(s => s.MatchId).Distinct().Count(),
                    PointsPerGame = Math.Round((double)g.Sum(s => s.Points) / g.Select(s => s.MatchId).Distinct().Count(), 1),
                    Team = GetPlayerTeam(g.Key, teams)
                })
                .OrderByDescending(p => p.TotalPoints)
                .ThenByDescending(p => p.PointsPerGame)
                .ThenByDescending(p => p.TotalAssists)
                .ToList<dynamic>();

            return playerStatistics;
        }

        // Helper method to get a player's team
        private string GetPlayerTeam(string playerName, List<Team> teams)
        {
            foreach (var team in teams)
            {
                if (team.Players != null && team.Players.Any(p => p.FullName == playerName))
                {
                    return team.Name;
                }
            }
            return "Unknown";
        }

        // Helper method to get a player's ID by name
        private int? GetPlayerIdByName(string playerName, List<Team> teams)
        {
            foreach (var team in teams)
            {
                if (team.Players != null)
                {
                    var player = team.Players.FirstOrDefault(p => p.FullName == playerName);
                    if (player != null)
                    {
                        return player.PlayerId;
                    }
                }
            }
            return null;
        }

        // Action to find player by name and redirect to player details
        public async Task<IActionResult> FindPlayerByName(string playerName, int tournamentId)
        {
            if (string.IsNullOrEmpty(playerName))
            {
                return RedirectToAction(nameof(Details), new { id = tournamentId });
            }

            // Get all teams in the tournament
            var tournament = await _context.Tournaments.FindAsync(tournamentId);
            if (tournament == null)
            {
                return NotFound();
            }

            // Get team names from matches
            var matches = await _context.Matches
                .Where(m => m.TournamentId == tournamentId)
                .ToListAsync();

            var teamNames = matches
                .SelectMany(m => new[] { m.TeamA, m.TeamB })
                .Where(name => !string.IsNullOrEmpty(name))
                .Distinct()
                .ToList();

            // Get registered teams
            var registeredTeamIds = await _context.TournamentTeams
                .Where(tt => tt.TournamentId == tournamentId && tt.Status == "Approved")
                .Select(tt => tt.TeamId)
                .ToListAsync();

            // Get teams with players
            var teams = new List<Team>();

            if (teamNames.Count > 0)
            {
                teams.AddRange(await _context.Teams
                    .Where(t => teamNames.Contains(t.Name))
                    .Include(t => t.Players)
                    .ToListAsync());
            }

            if (registeredTeamIds.Count > 0)
            {
                var existingTeamIds = teams.Select(t => t.TeamId).ToList();

                teams.AddRange(await _context.Teams
                    .Where(t => registeredTeamIds.Contains(t.TeamId) && !existingTeamIds.Contains(t.TeamId))
                    .Include(t => t.Players)
                    .ToListAsync());
            }

            // Find player by name
            foreach (var team in teams)
            {
                var player = team.Players?.FirstOrDefault(p => p.FullName == playerName);
                if (player != null)
                {
                    return RedirectToAction("Details", "Players", new { id = player.PlayerId });
                }
            }

            // If player not found, try to find by direct query
            var playerFromDb = await _context.Players
                .FirstOrDefaultAsync(p => p.FullName == playerName);

            if (playerFromDb != null)
            {
                return RedirectToAction("Details", "Players", new { id = playerFromDb.PlayerId });
            }

            // If player still not found, redirect back to tournament details
            TempData["ErrorMessage"] = $"Không tìm thấy thông tin cầu thủ: {playerName}";
            return RedirectToAction(nameof(Details), new { id = tournamentId });
        }

        // GET: Tournament/Register/5
        [Authorize] // Allow all authenticated users
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

            // Kiểm tra trạng thái đăng ký của giải đấu
            if (tournament.CalculatedStatus != "Mở đăng ký")
            {
                TempData["ErrorMessage"] = "Giải đấu này hiện không mở đăng ký.";
                return RedirectToAction(nameof(Details), new { id = tournament.Id });
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

            // Lấy danh sách đội của người dùng hiện tại
            var userTeams = await _context.Teams
                .Where(t => t.Coach != null && userId != null && t.Coach.Contains(userId)) // Kiểm tra null trước khi sử dụng Contains
                .ToListAsync();
            ViewBag.UserTeams = userTeams;

            return View(tournament);
        }

        // POST: Tournament/Register/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Register(int id, string notes, string teamOption, int? teamId, string newTeamName, IFormFile logoFile)
        {
            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null)
            {
                return NotFound();
            }

            // Kiểm tra trạng thái đăng ký của giải đấu
            if (tournament.CalculatedStatus != "Mở đăng ký")
            {
                TempData["ErrorMessage"] = "Giải đấu này hiện không mở đăng ký.";
                return RedirectToAction(nameof(Details), new { id = tournament.Id });
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Check if user has already registered
            var existingRegistration = await _context.TournamentRegistrations
                .FirstOrDefaultAsync(r => r.TournamentId == id && r.UserId == userId);

            if (existingRegistration != null)
            {
                // User has already registered
                TempData["ErrorMessage"] = "Bạn đã đăng ký giải đấu này rồi.";
                return RedirectToAction(nameof(Index));
            }

            // VALIDATION: Kiểm tra user phải có ít nhất một đội bóng
            var userTeams = await _context.Teams
                .Where(t => t.Coach == userId)
                .Include(t => t.Players)
                .ToListAsync();

            if (!userTeams.Any())
            {
                TempData["ErrorMessage"] = "Bạn phải tạo đội bóng trước khi đăng ký giải đấu. Vui lòng tạo đội bóng trước.";
                return RedirectToAction("Create", "Teams", new { returnUrl = Url.Action("Details", "Tournament", new { id = id }) });
            }

            // VALIDATION: Nếu chọn đội có sẵn, kiểm tra đội có đủ cầu thủ không
            if (teamOption == "existing" && teamId.HasValue)
            {
                var selectedTeam = userTeams.FirstOrDefault(t => t.TeamId == teamId.Value);
                if (selectedTeam == null)
                {
                    TempData["ErrorMessage"] = "Đội bóng được chọn không hợp lệ.";
                    return RedirectToAction(nameof(Details), new { id = tournament.Id });
                }

                // Kiểm tra số lượng cầu thủ tối thiểu (ví dụ: 5 cầu thủ cho 5v5, 3 cầu thủ cho 3v3)
                int minPlayers = tournament.Name.Contains("3v3") ? 3 : 5;
                if (selectedTeam.Players.Count < minPlayers)
                {
                    TempData["ErrorMessage"] = $"Đội '{selectedTeam.Name}' cần có ít nhất {minPlayers} cầu thủ để tham gia giải đấu này.";
                    return RedirectToAction("Details", "Teams", new { id = selectedTeam.TeamId });
                }
            }

            // Create new registration
            var registration = new TournamentRegistration
            {
                TournamentId = id,
                UserId = userId ?? string.Empty, // Ensure userId is not null
                RegistrationDate = DateTime.Now,
                Status = "Pending",
                Notes = notes
            };

            _context.TournamentRegistrations.Add(registration);
            await _context.SaveChangesAsync();

            // Handle team registration based on user's choice
            if (teamOption == "existing" && teamId.HasValue)
            {
                // Register existing team
                var team = await _context.Teams.FindAsync(teamId.Value);
                if (team != null)
                {
                    // Kiểm tra xem đội đã đăng ký giải đấu này chưa
                    var existingTeamRegistration = await _context.TournamentTeams
                        .FirstOrDefaultAsync(tt => tt.TournamentId == id && tt.TeamId == teamId.Value);

                    if (existingTeamRegistration == null)
                    {
                        // Tạo đăng ký mới cho đội
                        var teamRegistration = new TournamentTeam
                        {
                            TournamentId = id,
                            TeamId = teamId.Value,
                            RegistrationDate = DateTime.Now,
                            Status = "Pending",
                            Notes = notes
                        };

                        _context.TournamentTeams.Add(teamRegistration);
                        await _context.SaveChangesAsync();
                        TempData["Message"] = "Đăng ký giải đấu và đội thành công. Vui lòng chờ phê duyệt.";
                    }
                    else
                    {
                        TempData["Message"] = "Đăng ký giải đấu thành công. Đội đã được đăng ký trước đó.";
                    }
                }
                else
                {
                    TempData["Message"] = "Đăng ký giải đấu thành công. Không tìm thấy đội đã chọn.";
                }
            }
            else if (teamOption == "new" && !string.IsNullOrEmpty(newTeamName))
            {
                // Create and register new team
                string logoUrl = string.Empty;

                // Process logo file if provided
                if (logoFile != null && logoFile.Length > 0)
                {
                    logoUrl = await SaveTeamLogo(logoFile);
                }

                // Create new team
                var newTeam = new Team
                {
                    Name = newTeamName,
                    Coach = userId ?? string.Empty, // Ensure userId is not null
                    LogoUrl = logoUrl,
                    Players = new List<Player>()
                };

                _context.Teams.Add(newTeam);
                await _context.SaveChangesAsync();

                // Register the new team for the tournament
                var teamRegistration = new TournamentTeam
                {
                    TournamentId = id,
                    TeamId = newTeam.TeamId,
                    RegistrationDate = DateTime.Now,
                    Status = "Pending",
                    Notes = notes
                };

                _context.TournamentTeams.Add(teamRegistration);
                await _context.SaveChangesAsync();

                TempData["Message"] = "Đăng ký giải đấu thành công. Đội mới đã được tạo và đăng ký. Vui lòng chờ phê duyệt.";
            }
            else
            {
                TempData["Message"] = "Đăng ký giải đấu thành công. Không có đội nào được đăng ký.";
            }

            return RedirectToAction(nameof(Index));
        }

        // Helper method to save team logo
        private async Task<string> SaveTeamLogo(IFormFile logoFile)
        {
            try
            {
                if (logoFile == null || logoFile.Length == 0)
                {
                    return string.Empty;
                }

                // Kiểm tra kích thước file (giới hạn 5MB)
                if (logoFile.Length > 5 * 1024 * 1024)
                {
                    throw new Exception("Kích thước file quá lớn. Vui lòng chọn file nhỏ hơn 5MB.");
                }

                // Kiểm tra loại file
                string extension = Path.GetExtension(logoFile.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                if (!allowedExtensions.Contains(extension))
                {
                    throw new Exception("Chỉ chấp nhận file hình ảnh có định dạng: .jpg, .jpeg, .png, .gif");
                }

                // Đảm bảo tên file không chứa ký tự đặc biệt
                string fileName = Path.GetFileNameWithoutExtension(logoFile.FileName);
                // Thêm timestamp để tránh trùng tên file
                string uniqueFileName = DateTime.Now.Ticks + "_" + fileName + extension;

                // Tạo đường dẫn đầy đủ
                string uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "teams");

                // Đảm bảo thư mục tồn tại
                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                }

                string filePath = Path.Combine(uploadsFolder, uniqueFileName);

                // Lưu file
                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await logoFile.CopyToAsync(fileStream);
                }

                // Trả về đường dẫn tương đối
                return "/images/teams/" + uniqueFileName;
            }
            catch (Exception ex)
            {
                // Log the error
                Console.WriteLine($"Error saving team logo: {ex.Message}");
                return string.Empty;
            }
        }

        // GET: Tournament/MyRegistrations
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> MyRegistrations()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Lấy danh sách đăng ký giải đấu của người dùng
            var registrations = await _context.TournamentRegistrations
                .Include(r => r.Tournament)
                .Where(r => r.UserId == userId)
                .ToListAsync();

            return View(registrations);
        }

        // POST: Tournament/SubmitDocument
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> SubmitDocument(int tournamentId, string title, string content, IFormFile documentFile)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var tournament = await _context.Tournaments.FindAsync(tournamentId);

            if (tournament == null)
            {
                TempData["ErrorMessage"] = "Không tìm thấy giải đấu.";
                return RedirectToAction(nameof(MyRegistrations));
            }

            // Kiểm tra trạng thái đăng ký của giải đấu
            if (tournament.CalculatedStatus != "Mở đăng ký")
            {
                TempData["ErrorMessage"] = "Giải đấu này hiện không mở đăng ký.";
                return RedirectToAction(nameof(MyRegistrations));
            }

            // Tạo bài nộp mới
            var submission = new TournamentSubmission
            {
                TournamentId = tournamentId,
                UserId = userId ?? string.Empty, // Ensure userId is not null
                Title = title,
                Content = content,
                SubmissionDate = DateTime.Now,
                Status = "Pending"
            };

            // Xử lý file đính kèm nếu có
            if (documentFile != null)
            {
                // Lưu file vào thư mục uploads
                var fileName = Path.GetFileName(documentFile.FileName);
                var uniqueFileName = Guid.NewGuid().ToString() + "_" + fileName;
                var filePath = Path.Combine("wwwroot/uploads", uniqueFileName);

                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await documentFile.CopyToAsync(fileStream);
                }

                submission.FileUrl = "/uploads/" + uniqueFileName;
                submission.FileName = fileName;
            }

            _context.TournamentSubmissions.Add(submission);
            await _context.SaveChangesAsync();

            TempData["Message"] = "Bài viết đã được nộp thành công. Vui lòng chờ phê duyệt.";
            return RedirectToAction(nameof(MyRegistrations));
        }

        // GET: Tournament/ManageSubmissions
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> ManageSubmissions()
        {
            var submissions = await _context.TournamentSubmissions
                .Include(s => s.Tournament)
                .Include(s => s.User)
                .ToListAsync();

            return View(submissions);
        }

        // POST: Tournament/ApproveSubmission/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> ApproveSubmission(int id, string adminNotes)
        {
            var submission = await _context.TournamentSubmissions.FindAsync(id);
            if (submission == null)
            {
                return NotFound();
            }

            submission.Status = "Approved";
            submission.AdminNotes = adminNotes;

            _context.Update(submission);
            await _context.SaveChangesAsync();

            TempData["Message"] = "Bài viết đã được phê duyệt.";
            return RedirectToAction(nameof(ManageSubmissions));
        }

        // POST: Tournament/RejectSubmission/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> RejectSubmission(int id, string adminNotes)
        {
            var submission = await _context.TournamentSubmissions.FindAsync(id);
            if (submission == null)
            {
                return NotFound();
            }

            submission.Status = "Rejected";
            submission.AdminNotes = adminNotes;

            _context.Update(submission);
            await _context.SaveChangesAsync();

            TempData["Message"] = "Bài viết đã bị từ chối.";
            return RedirectToAction(nameof(ManageSubmissions));
        }

        // GET: Tournament/EditSubmission/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> EditSubmission(int id)
        {
            var submission = await _context.TournamentSubmissions
                .Include(s => s.Tournament)
                .Include(s => s.User)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (submission == null)
            {
                return NotFound();
            }

            return View(submission);
        }

        // POST: Tournament/EditSubmission/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> EditSubmission(int id, TournamentSubmission submission, IFormFile documentFile)
        {
            if (id != submission.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Lấy thông tin bài nộp hiện tại
                    var existingSubmission = await _context.TournamentSubmissions.AsNoTracking()
                        .FirstOrDefaultAsync(s => s.Id == id);

                    if (existingSubmission == null)
                    {
                        return NotFound();
                    }

                    // Giữ nguyên thông tin người dùng, giải đấu và ngày nộp
                    submission.UserId = existingSubmission.UserId;
                    submission.TournamentId = existingSubmission.TournamentId;
                    submission.SubmissionDate = existingSubmission.SubmissionDate;

                    // Xử lý file đính kèm mới nếu có
                    if (documentFile != null)
                    {
                        // Lưu file mới
                        var fileName = Path.GetFileName(documentFile.FileName);
                        var uniqueFileName = Guid.NewGuid().ToString() + "_" + fileName;
                        var filePath = Path.Combine("wwwroot/uploads", uniqueFileName);

                        using (var fileStream = new FileStream(filePath, FileMode.Create))
                        {
                            await documentFile.CopyToAsync(fileStream);
                        }

                        submission.FileUrl = "/uploads/" + uniqueFileName;
                        submission.FileName = fileName;
                    }
                    else
                    {
                        // Giữ nguyên thông tin file cũ
                        submission.FileUrl = existingSubmission.FileUrl;
                        submission.FileName = existingSubmission.FileName;
                    }

                    _context.Update(submission);
                    await _context.SaveChangesAsync();

                    TempData["Message"] = "Bài viết đã được cập nhật thành công.";
                    return RedirectToAction(nameof(ManageSubmissions));
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!SubmissionExists(submission.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
            }

            // Nếu có lỗi, hiển thị lại form với thông báo lỗi
            var tournament = await _context.Tournaments.FindAsync(submission.TournamentId);
            var user = await _context.Users.FindAsync(submission.UserId);

            // Chỉ gán khi không null
            if (tournament != null)
            {
                submission.Tournament = tournament;
            }

            if (user != null)
            {
                submission.User = user;
            }

            return View(submission);
        }

        // POST: Tournament/DeleteSubmission/5
        [HttpPost, ActionName("DeleteSubmission")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> DeleteSubmissionConfirmed(int id)
        {
            var submission = await _context.TournamentSubmissions.FindAsync(id);
            if (submission != null)
            {
                // Xóa file đính kèm nếu có
                if (!string.IsNullOrEmpty(submission.FileUrl))
                {
                    var filePath = Path.Combine("wwwroot", submission.FileUrl.TrimStart('/'));
                    if (System.IO.File.Exists(filePath))
                    {
                        System.IO.File.Delete(filePath);
                    }
                }

                _context.TournamentSubmissions.Remove(submission);
                await _context.SaveChangesAsync();

                TempData["Message"] = "Bài viết đã được xóa thành công.";
            }

            return RedirectToAction(nameof(ManageSubmissions));
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

        // GET: Tournament/ManageTeamRegistrations
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> ManageTeamRegistrations()
        {
            var teamRegistrations = await _context.TournamentTeams
                .Include(r => r.Tournament)
                .Include(r => r.Team)
                    .ThenInclude(t => t.Players)
                .OrderByDescending(r => r.RegistrationDate)
                .ToListAsync();

            return View(teamRegistrations);
        }

        // POST: Tournament/UpdateTeamRegistrationStatus
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> UpdateTeamRegistrationStatus(int id, string status, string adminNotes = "")
        {
            var registration = await _context.TournamentTeams
                .Include(r => r.Tournament)
                .Include(r => r.Team)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (registration == null)
            {
                return NotFound();
            }

            var oldStatus = registration.Status;
            registration.Status = status;
            registration.Notes = adminNotes;
            _context.Update(registration);
            await _context.SaveChangesAsync();

            // Gửi email thông báo nếu trạng thái thay đổi
            if (oldStatus != status && (status == "Approved" || status == "Rejected"))
            {
                try
                {
                    // Lấy thông tin user từ team coach
                    var teamCoach = await _context.Users.FindAsync(registration.Team.Coach);
                    if (teamCoach != null && !string.IsNullOrEmpty(teamCoach.Email))
                    {
                        // Lấy danh sách cầu thủ của đội
                        var players = await _context.Players
                            .Where(p => p.TeamId == registration.Team.TeamId)
                            .Select(p => p.FullName)
                            .ToListAsync();

                        if (status == "Approved")
                        {
                            await _emailService.SendTeamRegistrationApprovedAsync(
                                teamCoach.Email,
                                teamCoach.FullName ?? teamCoach.UserName ?? "User",
                                registration.Team.Name,
                                registration.Tournament.Name
                            );
                        }
                        else if (status == "Rejected")
                        {
                            string reason = string.IsNullOrEmpty(adminNotes) ? "Không đáp ứng yêu cầu của giải đấu" : adminNotes;
                            await _emailService.SendTeamRegistrationRejectedAsync(
                                teamCoach.Email,
                                teamCoach.FullName ?? teamCoach.UserName ?? "User",
                                registration.Team.Name,
                                registration.Tournament.Name,
                                reason
                            );
                        }

                        TempData["Message"] = $"Đã cập nhật trạng thái đăng ký và gửi email thông báo cho {teamCoach.Email}.";
                    }
                    else
                    {
                        TempData["Message"] = "Đã cập nhật trạng thái đăng ký nhưng không thể gửi email (không tìm thấy email người dùng).";
                    }
                }
                catch (Exception ex)
                {
                    TempData["ErrorMessage"] = $"Đã cập nhật trạng thái nhưng gửi email thất bại: {ex.Message}";
                }
            }
            else
            {
                TempData["Message"] = "Đã cập nhật trạng thái đăng ký.";
            }

            return RedirectToAction(nameof(ManageTeamRegistrations));
        }

        // GET: Tournament/RegisterTeam/5
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> RegisterTeam(int? id)
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

            // Kiểm tra trạng thái đăng ký của giải đấu
            if (tournament.CalculatedStatus != "Mở đăng ký")
            {
                TempData["ErrorMessage"] = "Giải đấu này hiện không mở đăng ký.";
                return RedirectToAction(nameof(Details), new { id = tournament.Id });
            }

            // Lấy danh sách đội của người dùng hiện tại
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var userTeams = await _context.Teams
                .Where(t => t.Coach != null && userId != null && t.Coach.Contains(userId)) // Kiểm tra null trước khi sử dụng Contains
                .ToListAsync();

            ViewBag.TeamId = new SelectList(userTeams, "TeamId", "Name");
            return View(tournament);
        }

        // POST: Tournament/RegisterTeam/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> RegisterTeam(int id, int teamId, string notes)
        {
            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null)
            {
                return NotFound();
            }

            // Kiểm tra trạng thái đăng ký của giải đấu
            if (tournament.CalculatedStatus != "Mở đăng ký")
            {
                TempData["ErrorMessage"] = "Giải đấu này hiện không mở đăng ký.";
                return RedirectToAction(nameof(Details), new { id = tournament.Id });
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var team = await _context.Teams
                .Include(t => t.Players)
                .FirstOrDefaultAsync(t => t.TeamId == teamId);

            if (team == null)
            {
                TempData["ErrorMessage"] = "Không tìm thấy đội đã chọn.";
                return RedirectToAction(nameof(RegisterTeam), new { id = id });
            }

            // VALIDATION: Kiểm tra user có quyền đăng ký đội này không
            if (team.Coach != userId)
            {
                TempData["ErrorMessage"] = "Bạn không có quyền đăng ký đội này.";
                return RedirectToAction(nameof(Details), new { id = tournament.Id });
            }

            // VALIDATION: Kiểm tra đội có đủ cầu thủ không
            int minPlayers = tournament.Name.Contains("3v3") ? 3 : 5;
            if (team.Players.Count < minPlayers)
            {
                TempData["ErrorMessage"] = $"Đội '{team.Name}' cần có ít nhất {minPlayers} cầu thủ để tham gia giải đấu này.";
                return RedirectToAction("Details", "Teams", new { id = team.TeamId });
            }

            // Kiểm tra xem đội đã đăng ký giải đấu này chưa
            var existingTeamRegistration = await _context.TournamentTeams
                .FirstOrDefaultAsync(tt => tt.TournamentId == id && tt.TeamId == teamId);

            if (existingTeamRegistration != null)
            {
                TempData["ErrorMessage"] = "Đội này đã được đăng ký cho giải đấu.";
                return RedirectToAction(nameof(Details), new { id = id });
            }

            // Tạo đăng ký mới cho đội
            var teamRegistration = new TournamentTeam
            {
                TournamentId = id,
                TeamId = teamId,
                RegistrationDate = DateTime.Now,
                Status = "Pending",
                Notes = notes
            };

            _context.TournamentTeams.Add(teamRegistration);
            await _context.SaveChangesAsync();

            // Gửi thông báo cho admin về đăng ký mới
            try
            {
                var user = await _context.Users.FindAsync(userId);
                var playerNames = team.Players.Select(p => p.FullName).ToList();

                await _emailService.SendTeamRegistrationNotificationToAdminAsync(
                    team.Name,
                    tournament.Name,
                    user?.Email ?? "Unknown",
                    playerNames
                );
            }
            catch (Exception ex)
            {
                // Log error but don't fail the registration
                // _logger.LogError(ex, "Failed to send admin notification email");
            }

            TempData["Message"] = "Đăng ký đội cho giải đấu thành công. Vui lòng chờ phê duyệt.";
            return RedirectToAction(nameof(Details), new { id = id });
        }

        // GET: Tournament/CreateTeamForTournament/5
        [Authorize]
        public async Task<IActionResult> CreateTeamForTournament(int id)
        {
            var tournament = await _context.Tournaments
                .Include(t => t.Sports)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tournament == null)
            {
                return NotFound();
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Kiểm tra xem user đã được duyệt tham gia giải đấu này chưa
            var approvedRegistration = await _context.TournamentRegistrations
                .FirstOrDefaultAsync(r => r.TournamentId == id && r.UserId == userId && r.Status == "Approved");

            if (approvedRegistration == null)
            {
                TempData["ErrorMessage"] = "Bạn chưa được duyệt tham gia giải đấu này hoặc chưa đăng ký.";
                return RedirectToAction(nameof(Details), new { id = id });
            }

            // Kiểm tra xem user đã tạo đội cho giải đấu này chưa
            var existingTeam = await _context.Teams
                .Where(t => t.Coach == userId)
                .Join(_context.TournamentTeams.Where(tt => tt.TournamentId == id),
                      team => team.TeamId,
                      tt => tt.TeamId,
                      (team, tt) => team)
                .FirstOrDefaultAsync();

            if (existingTeam != null)
            {
                TempData["ErrorMessage"] = "Bạn đã tạo đội cho giải đấu này rồi.";
                return RedirectToAction(nameof(Details), new { id = id });
            }

            ViewBag.Tournament = tournament;
            return View();
        }

        // POST: Tournament/CreateTeamForTournament/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize]
        public async Task<IActionResult> CreateTeamForTournament(int id, string teamName, IFormFile logoFile)
        {
            var tournament = await _context.Tournaments
                .Include(t => t.Sports)
                .FirstOrDefaultAsync(t => t.Id == id);

            if (tournament == null)
            {
                return NotFound();
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Kiểm tra xem user đã được duyệt tham gia giải đấu này chưa
            var approvedRegistration = await _context.TournamentRegistrations
                .FirstOrDefaultAsync(r => r.TournamentId == id && r.UserId == userId && r.Status == "Approved");

            if (approvedRegistration == null)
            {
                TempData["ErrorMessage"] = "Bạn chưa được duyệt tham gia giải đấu này.";
                return RedirectToAction(nameof(Details), new { id = id });
            }

            // Validate team name
            if (string.IsNullOrWhiteSpace(teamName))
            {
                ModelState.AddModelError("teamName", "Tên đội không được để trống.");
                ViewBag.Tournament = tournament;
                return View();
            }

            // Kiểm tra tên đội đã tồn tại chưa
            var existingTeamName = await _context.Teams
                .AnyAsync(t => t.Name.ToLower() == teamName.ToLower());

            if (existingTeamName)
            {
                ModelState.AddModelError("teamName", "Tên đội đã tồn tại. Vui lòng chọn tên khác.");
                ViewBag.Tournament = tournament;
                return View();
            }

            // Process logo file if provided
            string logoUrl = string.Empty;
            if (logoFile != null && logoFile.Length > 0)
            {
                logoUrl = await SaveTeamLogo(logoFile);
            }

            // Create new team
            var newTeam = new Team
            {
                Name = teamName,
                Coach = userId,
                LogoUrl = logoUrl,
                Players = new List<Player>()
            };

            _context.Teams.Add(newTeam);
            await _context.SaveChangesAsync();

            // Register the new team for the tournament
            var teamRegistration = new TournamentTeam
            {
                TournamentId = id,
                TeamId = newTeam.TeamId,
                RegistrationDate = DateTime.Now,
                Status = "Approved", // Tự động duyệt vì user đã được duyệt
                Notes = "Đội được tạo bởi user đã được duyệt"
            };

            _context.TournamentTeams.Add(teamRegistration);
            await _context.SaveChangesAsync();

            // Auto approve team registration
            var teamRegistrationToApprove = await _context.TournamentTeams.FirstOrDefaultAsync(tt => tt.TournamentId == id && tt.TeamId == newTeam.TeamId);
            if (teamRegistrationToApprove != null)
            {
                teamRegistrationToApprove.Status = "Approved";
                await _context.SaveChangesAsync();
            }

            TempData["Message"] = $"Tạo đội '{teamName}' thành công và đã đăng ký cho giải đấu '{tournament.Name}'.";
            return RedirectToAction("Details", "Teams", new { id = newTeam.TeamId });
        }

        // GET: Tournament/MyApprovedTournaments
        [Authorize]
        public async Task<IActionResult> MyApprovedTournaments()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var approvedTournaments = await _context.TournamentRegistrations
                .Where(r => r.UserId == userId && r.Status == "Approved")
                .Include(r => r.Tournament)
                .ThenInclude(t => t.Sports)
                .Select(r => r.Tournament)
                .ToListAsync();

            return View(approvedTournaments);
        }
    }
}
