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
using System.Security.Claims;
using System.IO;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using WebQuanLyGiaiDau_NhomTD.Services;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class NewsController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _webHostEnvironment;
        private readonly IImageUploadService _imageUploadService;

        public NewsController(
            ApplicationDbContext context, 
            IWebHostEnvironment webHostEnvironment,
            IImageUploadService imageUploadService)
        {
            _context = context;
            _webHostEnvironment = webHostEnvironment;
            _imageUploadService = imageUploadService;
        }

        // GET: News
        public async Task<IActionResult> Index(string searchString)
        {
            var newsQuery = _context.News.AsQueryable();

            // Áp dụng tìm kiếm nếu có
            if (!string.IsNullOrEmpty(searchString))
            {
                searchString = searchString.ToLower();
                newsQuery = newsQuery.Where(n =>
                    n.Title.ToLower().Contains(searchString) ||
                    n.Summary.ToLower().Contains(searchString) ||
                    n.Content.ToLower().Contains(searchString) ||
                    n.Category.ToLower().Contains(searchString));
            }

            // Chỉ hiển thị tin tức có IsVisible = true cho người dùng không phải admin
            if (!User.IsInRole(SD.Role_Admin))
            {
                newsQuery = newsQuery.Where(n => n.IsVisible);
            }

            var news = await newsQuery
                .OrderByDescending(n => n.PublishDate)
                .ToListAsync();

            // Lưu searchString để hiển thị lại trong form
            ViewData["CurrentFilter"] = searchString;

            return View(news);
        }

        // GET: News/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var news = await _context.News
                .FirstOrDefaultAsync(m => m.NewsId == id);

            if (news == null)
            {
                return NotFound();
            }

            // Tăng lượt xem
            news.ViewCount++;
            _context.Update(news);
            await _context.SaveChangesAsync();

            // Nếu người dùng đã đăng nhập, cộng điểm theo cấu hình
            if (User?.Identity?.IsAuthenticated == true)
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (!string.IsNullOrEmpty(userId))
                {
                    var user = await _context.Users.FindAsync(userId);
                    if (user != null)
                    {
                        var cfg = await _context.PointsSettings.FirstOrDefaultAsync();
                        var add = cfg?.ReadNewsPoints ?? 1;
                        user.Points += add;
                        _context.Update(user);
                        await _context.SaveChangesAsync();
                    }
                }
            }

            return View(news);
        }

        // GET: News/Create
        [Authorize(Roles = SD.Role_Admin)]
        public IActionResult Create()
        {
            return View();
        }

        // POST: News/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Create([Bind("NewsId,Title,Summary,Content,ImageUrl,PublishDate,Author,ViewCount,Category,IsVisible,IsFeatured")] News news, IFormFile imageFile)
        {
            if (ModelState.IsValid)
            {
                // Xử lý tải lên hình ảnh nếu có
                if (imageFile != null && imageFile.Length > 0)
                {
                    news.ImageUrl = await _imageUploadService.SaveImageAsync(imageFile, "news");
                }

                _context.Add(news);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(news);
        }

        // GET: News/Edit/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var news = await _context.News.FindAsync(id);
            if (news == null)
            {
                return NotFound();
            }
            return View(news);
        }

        // POST: News/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, [Bind("NewsId,Title,Summary,Content,ImageUrl,PublishDate,Author,ViewCount,Category,IsVisible,IsFeatured")] News news, IFormFile imageFile)
        {
            if (id != news.NewsId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Get existing news to preserve image URL if no new image
                    var existingNews = await _context.News.AsNoTracking().FirstOrDefaultAsync(n => n.NewsId == id);

                    // Xử lý tải lên hình ảnh mới nếu có
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        // Delete old image
                        if (!string.IsNullOrEmpty(existingNews?.ImageUrl))
                        {
                            await _imageUploadService.DeleteImageAsync(existingNews.ImageUrl);
                        }
                        news.ImageUrl = await _imageUploadService.SaveImageAsync(imageFile, "news");
                    }
                    else if (existingNews != null)
                    {
                        // Preserve old image URL if no new image
                        news.ImageUrl = existingNews.ImageUrl;
                    }

                    _context.Update(news);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!NewsExists(news.NewsId))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            return View(news);
        }

        // GET: News/Delete/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var news = await _context.News
                .FirstOrDefaultAsync(m => m.NewsId == id);
            if (news == null)
            {
                return NotFound();
            }

            return View(news);
        }

        // POST: News/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var news = await _context.News.FindAsync(id);
                if (news != null)
                {
                    _context.News.Remove(news);
                    await _context.SaveChangesAsync();

                    // Delete associated image if exists
                    if (!string.IsNullOrEmpty(news.ImageUrl))
                    {
                        await _imageUploadService.DeleteImageAsync(news.ImageUrl);
                    }
                    
                    TempData["SuccessMessage"] = "Đã xóa tin tức thành công.";
                }
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi xóa tin tức: {ex.Message}");
                TempData["ErrorMessage"] = "Không thể xóa tin tức này. Vui lòng thử lại.";
                return RedirectToAction(nameof(Details), new { id = id });
            }
        }

        private bool NewsExists(int id)
        {
            return _context.News.Any(e => e.NewsId == id);
        }

        // API để lấy tin tức mới nhất cho AJAX
        [HttpGet]
        public async Task<IActionResult> GetLatestNews(int count = 5)
        {
            var latestNews = await _context.News
                .Where(n => n.IsVisible)
                .OrderByDescending(n => n.PublishDate)
                .Take(count)
                .Select(n => new
                {
                    n.NewsId,
                    n.Title,
                    n.Summary,
                    n.ImageUrl,
                    PublishDate = n.PublishDate.ToString("dd/MM/yyyy HH:mm"),
                    n.ViewCount,
                    n.Category,
                    n.IsFeatured
                })
                .ToListAsync();

            return Json(latestNews);
        }

        // API để lấy tin tức nổi bật cho AJAX
        [HttpGet]
        public async Task<IActionResult> GetFeaturedNews(int count = 3)
        {
            var featuredNews = await _context.News
                .Where(n => n.IsVisible && n.IsFeatured)
                .OrderByDescending(n => n.PublishDate)
                .Take(count)
                .Select(n => new
                {
                    n.NewsId,
                    n.Title,
                    n.Summary,
                    n.ImageUrl,
                    PublishDate = n.PublishDate.ToString("dd/MM/yyyy HH:mm"),
                    n.ViewCount,
                    n.Category
                })
                .ToListAsync();

            return Json(featuredNews);
        }

        // Phương thức lưu hình ảnh tin tức
        [Obsolete("Use IImageUploadService.SaveImageAsync instead")]
        private async Task<string> SaveNewsImage(IFormFile image)
        {
            return await _imageUploadService.SaveImageAsync(image, "news");
        }
    }
}
