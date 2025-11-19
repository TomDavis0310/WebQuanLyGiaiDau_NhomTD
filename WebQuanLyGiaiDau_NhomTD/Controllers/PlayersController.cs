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
using WebQuanLyGiaiDau_NhomTD.Services;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Authorize]
    public class PlayersController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IImageUploadService _imageUploadService;
        private readonly IPermissionService _permissionService;

        public PlayersController(
            ApplicationDbContext context,
            IImageUploadService imageUploadService,
            IPermissionService permissionService)
        {
            _context = context;
            _imageUploadService = imageUploadService;
            _permissionService = permissionService;
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
                
                // Get teams where user is a player
                var playerTeamIds = _context.Players
                    .Where(p => p.UserId == userId)
                    .Select(p => p.TeamId)
                    .ToList();
                    
                var userTeams = _context.Teams
                    .Where(t => t.Coach == userId || playerTeamIds.Contains(t.TeamId))
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
                        player.ImageUrl = await _imageUploadService.SaveImageAsync(imageFile, "players");
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
        [Obsolete("Use IImageUploadService.SaveImageAsync instead")]
        private async Task<string> SaveImage(IFormFile image)
        {
            return await _imageUploadService.SaveImageAsync(image, "players");
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
                
                // Kiểm tra xem người dùng có phải là huấn luyện viên của đội không
                var isCoach = await _context.Teams
                    .AnyAsync(t => t.TeamId == player.TeamId && t.Coach == userId);
                    
                // Kiểm tra xem người dùng có phải là thành viên của đội không
                var isPlayer = await _context.Players
                    .AnyAsync(p => p.TeamId == player.TeamId && p.UserId == userId);
                    
                var isTeamOwner = isCoach || isPlayer;

                if (!isTeamOwner)
                {
                    TempData["ErrorMessage"] = "Bạn không có quyền chỉnh sửa cầu thủ này.";
                    return RedirectToAction(nameof(Index));
                }

                // Nếu không phải Admin, chỉ hiển thị các đội mà họ sở hữu
                // Get teams where user is coach
                var coachTeamIds = await _context.Teams
                    .Where(t => t.Coach == userId)
                    .Select(t => t.TeamId)
                    .ToListAsync();
                    
                // Get teams where user is a player
                var playerTeamIds = await _context.Players
                    .Where(p => p.UserId == userId)
                    .Select(p => p.TeamId)
                    .ToListAsync();
                    
                // Combine the two lists
                var userTeamIds = coachTeamIds.Union(playerTeamIds).ToList();
                
                var userTeams = await _context.Teams
                    .Where(t => userTeamIds.Contains(t.TeamId))
                    .ToListAsync();

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
                        // Delete old image
                        if (!string.IsNullOrEmpty(existingPlayer?.ImageUrl))
                        {
                            await _imageUploadService.DeleteImageAsync(existingPlayer.ImageUrl);
                        }
                        player.ImageUrl = await _imageUploadService.SaveImageAsync(imageFile, "players");
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
                
                // Kiểm tra xem người dùng có phải là huấn luyện viên của đội không
                var isCoach = await _context.Teams
                    .AnyAsync(t => t.TeamId == player.TeamId && t.Coach == userId);
                    
                // Kiểm tra xem người dùng có phải là thành viên của đội không
                var isPlayer = await _context.Players
                    .AnyAsync(p => p.TeamId == player.TeamId && p.UserId == userId);
                    
                var isTeamOwner = isCoach || isPlayer;

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
                        // If there are related records, show error message
                        TempData["ErrorMessage"] = "Không thể xóa cầu thủ này vì có thống kê liên quan.";
                        return RedirectToAction(nameof(Details), new { id = id });
                    }

                    _context.Players.Remove(player);
                    await _context.SaveChangesAsync();

                    // Delete associated image if exists
                    if (!string.IsNullOrEmpty(player.ImageUrl))
                    {
                        await _imageUploadService.DeleteImageAsync(player.ImageUrl);
                    }
                    
                    TempData["SuccessMessage"] = "Đã xóa cầu thủ thành công.";
                }
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                // Log the error and show to user
                Console.WriteLine("Error deleting player: " + ex.Message);
                TempData["ErrorMessage"] = "Lỗi khi xóa cầu thủ: " + ex.Message;
                return RedirectToAction(nameof(Details), new { id = id });
            }
        }

        private bool PlayerExists(int id)
        {
            return _context.Players.Any(e => e.PlayerId == id);
        }
    }
}