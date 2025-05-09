using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Authorize]
    public class SportsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public SportsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Trang chọn môn thể thao (hiển thị các logo môn thể thao)
        public async Task<IActionResult> Index()
        {
            // Lấy danh sách tất cả các môn thể thao từ database
            var sports = await _context.Sports.ToListAsync();
            return View(sports);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult Search(string searchTerm)
        {
            var tournaments = _context.Tournaments
                .Where(t => t.Name.Contains(searchTerm))
                .ToList();
            return View("Index", tournaments);
        }

        // Hiển thị danh sách giải đấu theo môn thể thao
        // Ví dụ: /Sports/List?sportsId=1
        public async Task<IActionResult> List(int? sportsId)
        {
            if (sportsId == null)
            {
                return NotFound();
            }

            // Lấy thông tin môn thể thao
            var sport = await _context.Sports.FindAsync(sportsId);
            if (sport == null)
            {
                return NotFound();
            }

            // Lấy danh sách các giải đấu theo SportsId
            var tournaments = await _context.Tournaments
                .Where(t => t.SportsId == sportsId)
                .ToListAsync();

            // Truyền tên môn thể thao vào ViewBag
            ViewBag.SportName = sport.Name;
            ViewBag.SportId = sport.Id;

            // Trả về View với danh sách giải đấu (có thể rỗng)
            // Không cần kiểm tra tournaments.Any() vì view đã xử lý trường hợp danh sách rỗng
            return View(tournaments);
        }

        // GET: Sports/Create
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public IActionResult Create()
        {
            return View();
        }

        // POST: Sports/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Create(Sports sports, IFormFile imageUrl)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (imageUrl != null)
                    {
                        sports.ImageUrl = await SaveImage(imageUrl);
                    }

                    _context.Add(sports);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }
            return View(sports);
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

        // GET: Sports/Edit/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var sport = await _context.Sports.FindAsync(id);
            if (sport == null)
            {
                return NotFound();
            }
            return View(sport);
        }

        // POST: Sports/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, Sports sports, IFormFile imageUrl)
        {
            if (id != sports.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Get the existing sport to preserve the image URL if no new image is uploaded
                    var existingSport = await _context.Sports.AsNoTracking().FirstOrDefaultAsync(s => s.Id == id);

                    if (imageUrl != null)
                    {
                        // Upload new image
                        sports.ImageUrl = await SaveImage(imageUrl);
                    }
                    else if (existingSport != null)
                    {
                        // Keep existing image URL if no new image is uploaded
                        sports.ImageUrl = existingSport.ImageUrl;
                    }

                    _context.Update(sports);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!SportExists(sports.Id))
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
            return View(sports);
        }

        private bool SportExists(int id)
        {
            return _context.Sports.Any(e => e.Id == id);
        }

        // GET: Sports/Delete/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var sport = await _context.Sports
                .FirstOrDefaultAsync(m => m.Id == id);
            if (sport == null)
            {
                return NotFound();
            }

            return View(sport);
        }

        // POST: Sports/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var sport = await _context.Sports.FindAsync(id);
            if (sport != null)
            {
                _context.Sports.Remove(sport);
                await _context.SaveChangesAsync();
            }

            return RedirectToAction(nameof(Index));
        }
    }
}



