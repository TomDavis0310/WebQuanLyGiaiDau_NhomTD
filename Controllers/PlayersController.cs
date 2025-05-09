using System;
using System.Collections.Generic;
using System.Linq;
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
    public class PlayersController : Controller
    {
        private readonly ApplicationDbContext _context;

        public PlayersController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Players
        public async Task<IActionResult> Index()
        {
            var applicationDbContext = _context.Players.Include(p => p.Team);
            return View(await applicationDbContext.ToListAsync());
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
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public IActionResult Create()
        {
            ViewData["TeamId"] = new SelectList(_context.Teams, "TeamId", "Name");
            return View();
        }

        // POST: Players/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
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
            var savePath = Path.Combine("wwwroot/images/players", image.FileName);

            // Đảm bảo thư mục tồn tại
            var directory = Path.GetDirectoryName(savePath);
            if (!Directory.Exists(directory))
            {
                Directory.CreateDirectory(directory);
            }

            using (var fileStream = new FileStream(savePath, FileMode.Create))
            {
                await image.CopyToAsync(fileStream);
            }
            return "/images/players/" + image.FileName;
        }

        // GET: Players/Edit/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var player = await _context.Players.FindAsync(id);
            if (player == null)
            {
                return NotFound();
            }
            ViewData["TeamId"] = new SelectList(_context.Teams, "TeamId", "Name", player.TeamId);
            return View(player);
        }

        // POST: Players/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
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
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
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

            return View(player);
        }

        // POST: Players/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
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
