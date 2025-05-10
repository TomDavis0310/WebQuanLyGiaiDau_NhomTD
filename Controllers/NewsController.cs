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
using System.IO;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class NewsController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IWebHostEnvironment _webHostEnvironment;

        public NewsController(ApplicationDbContext context, IWebHostEnvironment webHostEnvironment)
        {
            _context = context;
            _webHostEnvironment = webHostEnvironment;
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
                .Include(n => n.Sports)
                .FirstOrDefaultAsync(m => m.NewsId == id);

            if (news == null)
            {
                return NotFound();
            }

            // Tăng lượt xem
            news.ViewCount++;
            _context.Update(news);
            await _context.SaveChangesAsync();

            return View(news);
        }

        // GET: News/Create
        [Authorize(Roles = SD.Role_Admin)]
        public IActionResult Create()
        {
            ViewData["SportsId"] = new SelectList(_context.Sports, "Id", "Name");
            return View();
        }

        // POST: News/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Create([Bind("NewsId,Title,Summary,Content,ImageUrl,PublishDate,Author,ViewCount,Category,IsVisible,IsFeatured,SportsId")] News news, IFormFile imageFile)
        {
            if (ModelState.IsValid)
            {
                // Xử lý tải lên hình ảnh nếu có
                if (imageFile != null && imageFile.Length > 0)
                {
                    news.ImageUrl = await SaveNewsImage(imageFile);
                }

                _context.Add(news);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            ViewData["SportsId"] = new SelectList(_context.Sports, "Id", "Name", news.SportsId);
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
            ViewData["SportsId"] = new SelectList(_context.Sports, "Id", "Name", news.SportsId);
            return View(news);
        }

        // POST: News/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, [Bind("NewsId,Title,Summary,Content,ImageUrl,PublishDate,Author,ViewCount,Category,IsVisible,IsFeatured,SportsId")] News news, IFormFile imageFile)
        {
            if (id != news.NewsId)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Xử lý tải lên hình ảnh mới nếu có
                    if (imageFile != null && imageFile.Length > 0)
                    {
                        news.ImageUrl = await SaveNewsImage(imageFile);
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
            ViewData["SportsId"] = new SelectList(_context.Sports, "Id", "Name", news.SportsId);
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
                .Include(n => n.Sports)
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
            var news = await _context.News.FindAsync(id);
            if (news != null)
            {
                _context.News.Remove(news);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
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
        private async Task<string> SaveNewsImage(IFormFile image)
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
                // Thêm timestamp để tránh trùng tên file
                string uniqueFileName = DateTime.Now.Ticks + "_" + fileName + extension;

                // Tạo đường dẫn đầy đủ
                string uploadsFolder = Path.Combine(_webHostEnvironment.WebRootPath, "images", "news");

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
                return "/images/news/" + uniqueFileName;
            }
            catch (Exception ex)
            {
                // Log lỗi
                Console.WriteLine("Lỗi khi lưu ảnh tin tức: " + ex.Message);
                throw new Exception("Lỗi khi lưu ảnh tin tức: " + ex.Message);
            }
        }
    }
}
