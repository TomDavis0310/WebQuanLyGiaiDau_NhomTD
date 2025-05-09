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
using Microsoft.AspNetCore.Http;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Authorize]
    public class TeamsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public TeamsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Teams
        public async Task<IActionResult> Index()
        {
            return View(await _context.Teams.ToListAsync());
        }

        // GET: Teams/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var team = await _context.Teams
                .Include(t => t.Players)
                .FirstOrDefaultAsync(m => m.TeamId == id);
            if (team == null)
            {
                return NotFound();
            }

            return View(team);
        }

        // GET: Teams/Create
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public IActionResult Create()
        {
            return View();
        }

        // POST: Teams/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Create([Bind("TeamId,Name,Coach")] Team team, IFormFile logoFile)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Xử lý tải lên logo nếu có
                    if (logoFile != null && logoFile.Length > 0)
                    {
                        team.LogoUrl = await SaveImage(logoFile);
                    }

                    _context.Add(team);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }
            return View(team);
        }

        // Phương thức lưu hình ảnh
        private async Task<string> SaveImage(IFormFile image)
        {
            var savePath = Path.Combine("wwwroot/images/teams", image.FileName);

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
            return "/images/teams/" + image.FileName;
        }

        // GET: Teams/Edit/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var team = await _context.Teams.FindAsync(id);
            if (team == null)
            {
                return NotFound();
            }
            return View(team);
        }

        // POST: Teams/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, [Bind("TeamId,Name,Coach")] Team team, IFormFile logoFile)
        {
            if (id != team.TeamId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Lấy thông tin đội bóng hiện tại để giữ lại URL logo nếu không có logo mới
                    var existingTeam = await _context.Teams.AsNoTracking().FirstOrDefaultAsync(t => t.TeamId == id);

                    // Xử lý tải lên logo mới nếu có
                    if (logoFile != null && logoFile.Length > 0)
                    {
                        team.LogoUrl = await SaveImage(logoFile);
                    }
                    else if (existingTeam != null)
                    {
                        // Giữ lại URL logo cũ nếu không có logo mới
                        team.LogoUrl = existingTeam.LogoUrl;
                    }

                    _context.Update(team);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!TeamExists(team.TeamId))
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
            return View(team);
        }

        // GET: Teams/Delete/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var team = await _context.Teams
                .FirstOrDefaultAsync(m => m.TeamId == id);
            if (team == null)
            {
                return NotFound();
            }

            return View(team);
        }

        // POST: Teams/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var team = await _context.Teams.FindAsync(id);
                if (team != null)
                {
                    // Check if there are any players in this team
                    var hasPlayers = await _context.Players
                        .AnyAsync(p => p.TeamId == id);

                    // Check if there are any matches for this team
                    var hasMatches = await _context.Matches
                        .AnyAsync(m => m.TeamA == team.Name || m.TeamB == team.Name);

                    if (hasPlayers || hasMatches)
                    {
                        // If there are related records, return to the delete view with an error message
                        ViewData["error"] = "Không thể xóa đội bóng này vì có cầu thủ hoặc trận đấu liên quan.";
                        team = await _context.Teams
                            .FirstOrDefaultAsync(m => m.TeamId == id);
                        return View(team);
                    }

                    _context.Teams.Remove(team);
                    await _context.SaveChangesAsync();
                }
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                // Handle any other exceptions
                var team = await _context.Teams
                    .FirstOrDefaultAsync(m => m.TeamId == id);
                ViewData["error"] = "Lỗi khi xóa đội bóng: " + ex.Message;
                return View(team);
            }
        }

        private bool TeamExists(int id)
        {
            return _context.Teams.Any(e => e.TeamId == id);
        }

        // GET: Teams/AddPlayer
        [Authorize(Roles = SD.Role_Admin)]
        public IActionResult AddPlayer(int teamId)
        {
            var team = _context.Teams.Find(teamId);
            if (team == null)
            {
                return NotFound();
            }

            ViewData["TeamId"] = teamId;
            ViewData["TeamName"] = team.Name;
            return View();
        }

        // POST: Teams/AddPlayer
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> AddPlayer([Bind("FullName,Position,Number,TeamId")] Player player, IFormFile imageFile)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    // Xử lý tải lên hình ảnh nếu có
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        player.ImageUrl = await SavePlayerImage(imageFile);
                    }

                    _context.Add(player);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Details), new { id = player.TeamId });
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }

            var team = _context.Teams.Find(player.TeamId);
            ViewData["TeamId"] = player.TeamId;
            ViewData["TeamName"] = team?.Name;
            return View(player);
        }

        // GET: Teams/EditPlayer/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> EditPlayer(int? id, int teamId)
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

            var team = await _context.Teams.FindAsync(teamId);
            if (team == null)
            {
                return NotFound();
            }

            ViewData["TeamId"] = teamId;
            ViewData["TeamName"] = team.Name;
            return View(player);
        }

        // POST: Teams/EditPlayer/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> EditPlayer(int id, [Bind("PlayerId,FullName,Position,Number,TeamId")] Player player, IFormFile imageFile)
        {
            if (id != player.PlayerId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Lấy thông tin cầu thủ hiện tại để giữ lại URL ảnh nếu không có ảnh mới
                    var existingPlayer = await _context.Players.AsNoTracking().FirstOrDefaultAsync(p => p.PlayerId == id);

                    // Xử lý tải lên ảnh mới nếu có
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        player.ImageUrl = await SavePlayerImage(imageFile);
                    }
                    else if (existingPlayer != null)
                    {
                        // Giữ lại URL ảnh cũ nếu không có ảnh mới
                        player.ImageUrl = existingPlayer.ImageUrl;
                    }

                    _context.Update(player);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Details), new { id = player.TeamId });
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

            var team = await _context.Teams.FindAsync(player.TeamId);
            ViewData["TeamId"] = player.TeamId;
            ViewData["TeamName"] = team?.Name;
            return View(player);
        }

        // GET: Teams/DeletePlayer/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> DeletePlayer(int? id, int teamId)
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

            ViewData["TeamId"] = teamId;
            return View(player);
        }

        // POST: Teams/DeletePlayer/5
        [HttpPost, ActionName("DeletePlayer")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> DeletePlayerConfirmed(int id, int teamId)
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
                        ViewData["TeamId"] = teamId;
                        return View(player);
                    }

                    _context.Players.Remove(player);
                    await _context.SaveChangesAsync();
                }
                return RedirectToAction(nameof(Details), new { id = teamId });
            }
            catch (Exception ex)
            {
                // Handle any other exceptions
                var player = await _context.Players
                    .Include(p => p.Team)
                    .FirstOrDefaultAsync(m => m.PlayerId == id);
                ViewData["error"] = "Lỗi khi xóa cầu thủ: " + ex.Message;
                ViewData["TeamId"] = teamId;
                return View(player);
            }
        }

        private bool PlayerExists(int id)
        {
            return _context.Players.Any(e => e.PlayerId == id);
        }

        // Phương thức lưu hình ảnh cầu thủ
        private async Task<string> SavePlayerImage(IFormFile image)
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
    }
}
