using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Authorize]
    public class PlayersController : Controller
    {
        private readonly ApplicationDbContext _context;

        public PlayersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Players
        public async Task<IActionResult> Index(string searchString)
        {
            var playersQuery = _context.Players
                .Include(p => p.Team)
                .AsQueryable();

            // Áp dụng tìm kiếm nếu có
            if (!string.IsNullOrEmpty(searchString))
            {
                searchString = searchString.ToLower();
                playersQuery = playersQuery.Where(p =>
                    p.FullName.ToLower().Contains(searchString) ||
                    (p.Position != null && p.Position.ToLower().Contains(searchString)) ||
                    (p.Team != null && p.Team.Name.ToLower().Contains(searchString)));
            }

            var players = await playersQuery.ToListAsync();

            // Lưu searchString để hiển thị lại trong form
            ViewData["CurrentFilter"] = searchString;

            return View(players);
        }

        // GET: Players/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var player = await _context.Players
                .Include(p => p.Team)
                .FirstOrDefaultAsync(m => m.PlayerId == id);
            if (player == null)
            {
                return NotFound();
            }

            // Get player statistics
            var playerStats = await _context.Statistics
                .Include(s => s.Match)
                .Where(s => s.PlayerName == player.FullName)
                .ToListAsync();

            ViewData["PlayerStatistics"] = playerStats;

            // Calculate average statistics
            if (playerStats.Any())
            {
                ViewData["AvgPoints"] = playerStats.Average(s => s.Points);
                ViewData["AvgAssists"] = playerStats.Average(s => s.Assists);
                ViewData["AvgRebounds"] = playerStats.Average(s => s.Rebounds);
                ViewData["TotalGames"] = playerStats.Count;
            }

            return View(player);
        }

        // GET: Players/Create
        [Authorize] // Allow all authenticated users
        public IActionResult Create()
        {
            // Nếu không phải Admin, chỉ hiển thị các đội mà họ sở hữu
            if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var userTeams = _context.TournamentTeams
                    .Where(tt => tt.Team.Players.Any(p => p.UserId == userId))
                    .Select(tt => tt.Team)
                    .Distinct()
                    .ToList();

                ViewData["TeamId"] = new SelectList(userTeams, "TeamId", "Name");
            }
            else
            {
                ViewData["TeamId"] = new SelectList(_context.Teams, "TeamId", "Name");
            }

            return View();
        }

        // POST: Players/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Create([Bind("PlayerId,FullName,Position,Number,TeamId")] Player player, IFormFile imageFile)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Xử lý tải lên hình ảnh nếu có
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        player.ImageUrl = await SaveImage(imageFile);
                    }

                    // Nếu người dùng không phải Admin, lưu UserId
                    if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
                    {
                        player.UserId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                    }

                    _context.Add(player);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }
            ViewData["TeamId"] = new SelectList(_context.Teams, "TeamId", "Name", player.TeamId);
            return View(player);
        }

        // Phương thức lưu hình ảnh
        private async Task<string> SaveImage(IFormFile image)
        {
            try
            {
                // Đảm bảo tên file không chứa ký tự đặc biệt
                string fileName = Path.GetFileName(image.FileName);
                // Thêm timestamp để tránh trùng tên file
                string uniqueFileName = DateTime.Now.Ticks + "_" + fileName;

                // Tạo đường dẫn đầy đủ
                string uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "players");

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
                return "/images/players/" + uniqueFileName;
            }
            catch (Exception ex)
            {
                // Log lỗi
                Console.WriteLine("Lỗi khi lưu ảnh: " + ex.Message);
                throw;
            }
        }

        // GET: Players/Edit/5
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var player = await _context.Players.Include(p => p.Team).FirstOrDefaultAsync(p => p.PlayerId == id);
            if (player == null)
            {
                return NotFound();
            }

            // Kiểm tra quyền: Admin có thể sửa tất cả, người dùng thường chỉ có thể sửa cầu thủ trong đội của họ
            if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                // Kiểm tra xem cầu thủ này có thuộc đội của người dùng hiện tại không
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var isTeamOwner = await _context.TournamentTeams
                    .AnyAsync(tt => tt.TeamId == player.TeamId && tt.Team.Players.Any(p => p.UserId == userId));

                if (!isTeamOwner)
                {
                    TempData["ErrorMessage"] = "Bạn không có quyền chỉnh sửa cầu thủ này.";
                    return RedirectToAction(nameof(Index));
                }

                // Nếu không phải Admin, chỉ hiển thị các đội mà họ sở hữu
                var userTeams = _context.TournamentTeams
                    .Where(tt => tt.Team.Players.Any(p => p.UserId == userId))
                    .Select(tt => tt.Team)
                    .Distinct()
                    .ToList();

                ViewData["TeamId"] = new SelectList(userTeams, "TeamId", "Name", player.TeamId);
            }
            else
            {
                ViewData["TeamId"] = new SelectList(_context.Teams, "TeamId", "Name", player.TeamId);
            }

            return View(player);
        }

        // POST: Players/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Edit(int id, [Bind("PlayerId,FullName,Position,Number,TeamId")] Player player, IFormFile imageFile)
        {
            if (id != player.PlayerId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Lấy thông tin cầu thủ hiện tại để giữ lại URL hình ảnh nếu không có hình mới
                    var existingPlayer = await _context.Players.AsNoTracking().FirstOrDefaultAsync(p => p.PlayerId == id);

                    // Xử lý tải lên hình ảnh mới nếu có
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        player.ImageUrl = await SaveImage(imageFile);
                    }
                    else if (existingPlayer != null)
                    {
                        // Giữ lại URL hình ảnh cũ nếu không có hình mới
                        player.ImageUrl = existingPlayer.ImageUrl;
                    }

                    _context.Update(player);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!PlayerExists(player.PlayerId))
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
            ViewData["TeamId"] = new SelectList(_context.Teams, "TeamId", "Name", player.TeamId);
            return View(player);
        }

        // GET: Players/Delete/5
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var player = await _context.Players
                .Include(p => p.Team)
                .FirstOrDefaultAsync(m => m.PlayerId == id);
            if (player == null)
            {
                return NotFound();
            }

            // Kiểm tra quyền: Admin có thể xóa tất cả, người dùng thường chỉ có thể xóa cầu thủ trong đội của họ
            if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                // Kiểm tra xem cầu thủ này có thuộc đội của người dùng hiện tại không
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var isTeamOwner = await _context.TournamentTeams
                    .AnyAsync(tt => tt.TeamId == player.TeamId && tt.Team.Players.Any(p => p.UserId == userId));

                if (!isTeamOwner)
                {
                    TempData["ErrorMessage"] = "Bạn không có quyền xóa cầu thủ này.";
                    return RedirectToAction(nameof(Index));
                }
            }

            return View(player);
        }

        // POST: Players/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var player = await _context.Players.FindAsync(id);
                if (player != null)
                {
                    // Check if there are any statistics for this player
                    var hasStatistics = await _context.Statistics
                        .AnyAsync(s => s.PlayerName == player.FullName);

                    if (hasStatistics)
                    {
                        // If there are related records, return to the delete view with an error message
                        ViewData["error"] = "Không thể xóa cầu thủ này vì có thống kê liên quan.";
                        player = await _context.Players
                            .Include(p => p.Team)
                            .FirstOrDefaultAsync(m => m.PlayerId == id);
                        return View(player);
                    }

                    _context.Players.Remove(player);
                    await _context.SaveChangesAsync();
                }
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                // Handle any other exceptions
                var player = await _context.Players
                    .Include(p => p.Team)
                    .FirstOrDefaultAsync(m => m.PlayerId == id);
                ViewData["error"] = "Lỗi khi xóa cầu thủ: " + ex.Message;
                return View(player);
            }
        }

        private bool PlayerExists(int id)
        {
            return _context.Players.Any(e => e.PlayerId == id);
        }
    }
}
