using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Text.RegularExpressions;
using System.Security.Claims;
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
        public async Task<IActionResult> Index(string searchString)
        {
            var teamsQuery = _context.Teams.AsQueryable();

            // Áp dụng tìm kiếm nếu có
            if (!string.IsNullOrEmpty(searchString))
            {
                searchString = searchString.ToLower();
                teamsQuery = teamsQuery.Where(t =>
                    t.Name.ToLower().Contains(searchString) ||
                    (t.Coach != null && t.Coach.ToLower().Contains(searchString)));
            }

            var teams = await teamsQuery.ToListAsync();

            // Lưu searchString để hiển thị lại trong form
            ViewData["CurrentFilter"] = searchString;

            return View(teams);
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
        [Authorize] // Allow all authenticated users
        public IActionResult Create()
        {
            return View();
        }

        // POST: Teams/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
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
            try
            {
                // Đảm bảo tên file không chứa ký tự đặc biệt
                string fileName = Path.GetFileName(image.FileName);
                // Thêm timestamp để tránh trùng tên file
                string uniqueFileName = DateTime.Now.Ticks + "_" + fileName;

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
                    await image.CopyToAsync(fileStream);
                }

                // Trả về đường dẫn tương đối để lưu vào database
                return "/images/teams/" + uniqueFileName;
            }
            catch (Exception ex)
            {
                // Log lỗi
                Console.WriteLine("Lỗi khi lưu ảnh: " + ex.Message);
                throw;
            }
        }

        // GET: Teams/Edit/5
        [Authorize] // Allow all authenticated users
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

            // Kiểm tra quyền: Admin có thể sửa tất cả, người dùng thường chỉ có thể sửa đội của mình
            if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                // Kiểm tra xem đội này có thuộc về người dùng hiện tại không
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var isTeamOwner = await _context.TournamentTeams
                    .AnyAsync(tt => tt.TeamId == id && tt.Team.Players.Any(p => p.UserId == userId));

                if (!isTeamOwner)
                {
                    TempData["ErrorMessage"] = "Bạn không có quyền chỉnh sửa đội này.";
                    return RedirectToAction(nameof(Index));
                }
            }

            return View(team);
        }

        // POST: Teams/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
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
        [Authorize] // Allow all authenticated users
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

            // Kiểm tra quyền: Admin có thể xóa tất cả, người dùng thường chỉ có thể xóa đội của mình
            if (!User.IsInRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                // Kiểm tra xem đội này có thuộc về người dùng hiện tại không
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var isTeamOwner = await _context.TournamentTeams
                    .AnyAsync(tt => tt.TeamId == id && tt.Team.Players.Any(p => p.UserId == userId));

                if (!isTeamOwner)
                {
                    TempData["ErrorMessage"] = "Bạn không có quyền xóa đội này.";
                    return RedirectToAction(nameof(Index));
                }
            }

            return View(team);
        }

        // POST: Teams/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize] // Allow all authenticated users
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
            // Lưu teamId để sử dụng trong trường hợp lỗi
            int teamId = player.TeamId;

            try
            {
                // Kiểm tra đội bóng có tồn tại không
                var team = await _context.Teams.FindAsync(player.TeamId);
                if (team == null)
                {
                    TempData["ErrorMessage"] = "Đội bóng không tồn tại.";
                    return RedirectToAction(nameof(Index));
                }

                // Kiểm tra số áo có hợp lệ không
                if (player.Number < 0 || player.Number > 99)
                {
                    TempData["ErrorMessage"] = "Số áo phải từ 0 đến 99.";
                    return RedirectToAction(nameof(AddPlayer), new { teamId = player.TeamId });
                }

                // Kiểm tra số áo đã tồn tại trong đội chưa
                bool numberExists = await _context.Players
                    .AnyAsync(p => p.TeamId == player.TeamId && p.Number == player.Number);

                if (numberExists)
                {
                    TempData["ErrorMessage"] = $"Số áo {player.Number} đã được sử dụng trong đội {team.Name}.";
                    return RedirectToAction(nameof(AddPlayer), new { teamId = player.TeamId });
                }

                // Kiểm tra tên cầu thủ không được để trống
                if (string.IsNullOrWhiteSpace(player.FullName))
                {
                    TempData["ErrorMessage"] = "Vui lòng nhập họ tên cầu thủ.";
                    return RedirectToAction(nameof(AddPlayer), new { teamId = player.TeamId });
                }

                // Kiểm tra vị trí không được để trống
                if (string.IsNullOrWhiteSpace(player.Position))
                {
                    TempData["ErrorMessage"] = "Vui lòng nhập vị trí thi đấu.";
                    return RedirectToAction(nameof(AddPlayer), new { teamId = player.TeamId });
                }

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

                        // Thêm thông báo thành công
                        TempData["SuccessMessage"] = $"Đã thêm cầu thủ {player.FullName} vào đội {team.Name} thành công.";

                        return RedirectToAction(nameof(Details), new { id = player.TeamId });
                    }
                    catch (Exception ex)
                    {
                        TempData["ErrorMessage"] = "Lỗi khi lưu dữ liệu: " + ex.Message;
                        Console.WriteLine("Lỗi thêm cầu thủ: " + ex.ToString());
                        return RedirectToAction(nameof(AddPlayer), new { teamId = player.TeamId });
                    }
                }
                else
                {
                    // Log lỗi validation
                    var errors = string.Join("; ", ModelState.Values
                        .SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage));

                    TempData["ErrorMessage"] = "Lỗi dữ liệu: " + errors;
                    Console.WriteLine("Lỗi validation: " + errors);

                    return RedirectToAction(nameof(AddPlayer), new { teamId = player.TeamId });
                }
            }
            catch (Exception ex)
            {
                // Xử lý ngoại lệ không mong muốn
                Console.WriteLine("Lỗi không mong muốn: " + ex.ToString());
                TempData["ErrorMessage"] = "Đã xảy ra lỗi: " + ex.Message;
                return RedirectToAction(nameof(AddPlayer), new { teamId = teamId });
            }
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
            // Lưu teamId để sử dụng trong trường hợp lỗi
            int teamId = player.TeamId;

            try
            {
                if (id != player.PlayerId)
                {
                    TempData["ErrorMessage"] = "ID cầu thủ không hợp lệ.";
                    return RedirectToAction(nameof(Details), new { id = teamId });
                }

                // Kiểm tra cầu thủ có tồn tại không
                var existingPlayer = await _context.Players.AsNoTracking().FirstOrDefaultAsync(p => p.PlayerId == id);
                if (existingPlayer == null)
                {
                    TempData["ErrorMessage"] = "Không tìm thấy cầu thủ cần chỉnh sửa.";
                    return RedirectToAction(nameof(Details), new { id = teamId });
                }

                // Kiểm tra đội bóng có tồn tại không
                var team = await _context.Teams.FindAsync(player.TeamId);
                if (team == null)
                {
                    TempData["ErrorMessage"] = "Đội bóng không tồn tại.";
                    return RedirectToAction(nameof(Index));
                }

                // Kiểm tra số áo có hợp lệ không
                if (player.Number < 0 || player.Number > 99)
                {
                    TempData["ErrorMessage"] = "Số áo phải từ 0 đến 99.";
                    return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = player.TeamId });
                }

                // Kiểm tra số áo đã tồn tại trong đội chưa (trừ cầu thủ hiện tại)
                bool numberExists = await _context.Players
                    .AnyAsync(p => p.TeamId == player.TeamId && p.Number == player.Number && p.PlayerId != player.PlayerId);

                if (numberExists)
                {
                    TempData["ErrorMessage"] = $"Số áo {player.Number} đã được sử dụng trong đội {team.Name}.";
                    return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = player.TeamId });
                }

                // Kiểm tra tên cầu thủ không được để trống
                if (string.IsNullOrWhiteSpace(player.FullName))
                {
                    TempData["ErrorMessage"] = "Vui lòng nhập họ tên cầu thủ.";
                    return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = player.TeamId });
                }

                // Kiểm tra vị trí không được để trống
                if (string.IsNullOrWhiteSpace(player.Position))
                {
                    TempData["ErrorMessage"] = "Vui lòng nhập vị trí thi đấu.";
                    return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = player.TeamId });
                }

                if (ModelState.IsValid)
                {
                    try
                    {
                        // Xử lý tải lên ảnh mới nếu có
                        if (imageFile != null && imageFile.Length > 0)
                        {
                            player.ImageUrl = await SavePlayerImage(imageFile);
                        }
                        else
                        {
                            // Giữ lại URL ảnh cũ nếu không có ảnh mới
                            player.ImageUrl = existingPlayer.ImageUrl;
                        }

                        _context.Update(player);
                        await _context.SaveChangesAsync();

                        // Thêm thông báo thành công
                        TempData["SuccessMessage"] = $"Đã cập nhật thông tin cầu thủ {player.FullName} thành công.";

                        return RedirectToAction(nameof(Details), new { id = player.TeamId });
                    }
                    catch (DbUpdateConcurrencyException)
                    {
                        if (!PlayerExists(player.PlayerId))
                        {
                            TempData["ErrorMessage"] = "Không tìm thấy cầu thủ cần chỉnh sửa.";
                            return RedirectToAction(nameof(Details), new { id = teamId });
                        }
                        else
                        {
                            TempData["ErrorMessage"] = "Lỗi cập nhật dữ liệu: Dữ liệu đã bị thay đổi bởi người khác.";
                            return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = player.TeamId });
                        }
                    }
                    catch (Exception ex)
                    {
                        TempData["ErrorMessage"] = "Lỗi khi cập nhật dữ liệu: " + ex.Message;
                        Console.WriteLine("Lỗi cập nhật cầu thủ: " + ex.ToString());
                        return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = player.TeamId });
                    }
                }
                else
                {
                    // Log lỗi validation
                    var errors = string.Join("; ", ModelState.Values
                        .SelectMany(v => v.Errors)
                        .Select(e => e.ErrorMessage));

                    TempData["ErrorMessage"] = "Lỗi dữ liệu: " + errors;
                    Console.WriteLine("Lỗi validation: " + errors);

                    return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = player.TeamId });
                }
            }
            catch (Exception ex)
            {
                // Xử lý ngoại lệ không mong muốn
                Console.WriteLine("Lỗi không mong muốn: " + ex.ToString());
                TempData["ErrorMessage"] = "Đã xảy ra lỗi: " + ex.Message;
                return RedirectToAction(nameof(EditPlayer), new { id = player.PlayerId, teamId = teamId });
            }
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
                // Kiểm tra teamId có hợp lệ không
                var team = await _context.Teams.FindAsync(teamId);
                if (team == null)
                {
                    TempData["ErrorMessage"] = "Không tìm thấy đội bóng.";
                    return RedirectToAction(nameof(Index));
                }

                // Kiểm tra cầu thủ có tồn tại không
                var player = await _context.Players
                    .Include(p => p.Team)
                    .FirstOrDefaultAsync(m => m.PlayerId == id);

                if (player == null)
                {
                    TempData["ErrorMessage"] = "Không tìm thấy cầu thủ cần xóa.";
                    return RedirectToAction(nameof(Details), new { id = teamId });
                }

                // Kiểm tra cầu thủ có thuộc đội bóng không
                if (player.TeamId != teamId)
                {
                    TempData["ErrorMessage"] = "Cầu thủ không thuộc đội bóng này.";
                    return RedirectToAction(nameof(Details), new { id = teamId });
                }

                // Lưu tên cầu thủ để hiển thị thông báo sau khi xóa
                string playerName = player.FullName;
                string teamName = player.Team?.Name ?? "không xác định";

                // Kiểm tra xem cầu thủ có thống kê liên quan không
                var hasStatistics = await _context.Statistics
                    .AnyAsync(s => s.PlayerName == player.FullName);

                if (hasStatistics)
                {
                    // Nếu có thống kê liên quan, không cho phép xóa
                    TempData["ErrorMessage"] = $"Không thể xóa cầu thủ {playerName} vì có thống kê liên quan trong các trận đấu.";
                    return RedirectToAction(nameof(Details), new { id = teamId });
                }

                // Tiến hành xóa cầu thủ
                _context.Players.Remove(player);
                await _context.SaveChangesAsync();

                // Thông báo thành công
                TempData["SuccessMessage"] = $"Đã xóa cầu thủ {playerName} khỏi đội {teamName} thành công.";

                return RedirectToAction(nameof(Details), new { id = teamId });
            }
            catch (DbUpdateException ex)
            {
                // Xử lý lỗi khi xóa dữ liệu liên quan đến ràng buộc khóa ngoại
                Console.WriteLine("Lỗi khi xóa cầu thủ (DbUpdateException): " + ex.ToString());
                TempData["ErrorMessage"] = "Không thể xóa cầu thủ vì có dữ liệu liên quan.";
                return RedirectToAction(nameof(Details), new { id = teamId });
            }
            catch (Exception ex)
            {
                // Xử lý các ngoại lệ khác
                Console.WriteLine("Lỗi khi xóa cầu thủ: " + ex.ToString());
                TempData["ErrorMessage"] = "Lỗi khi xóa cầu thủ: " + ex.Message;
                return RedirectToAction(nameof(Details), new { id = teamId });
            }
        }

        private bool PlayerExists(int id)
        {
            return _context.Players.Any(e => e.PlayerId == id);
        }

        // Phương thức lưu hình ảnh cầu thủ
        private async Task<string> SavePlayerImage(IFormFile image)
        {
            try
            {
                if (image == null || image.Length == 0)
                {
                    return null;
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
                // Loại bỏ ký tự đặc biệt từ tên file
                fileName = Regex.Replace(fileName, @"[^\w\d]", "_");
                // Thêm timestamp để tránh trùng tên file
                string uniqueFileName = DateTime.Now.Ticks + "_" + fileName + extension;

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
                Console.WriteLine("Lỗi khi lưu ảnh cầu thủ: " + ex.Message);
                throw new Exception("Lỗi khi lưu ảnh cầu thủ: " + ex.Message);
            }
        }
    }
}
