using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class NewsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public NewsApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy danh sách tất cả tin tức
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<object>> GetNews(
            string? category = null,
            bool? isFeatured = null,
            int? sportsId = null,
            int page = 1,
            int pageSize = 10)
        {
            try
            {
                var query = _context.News
                    .Where(n => n.IsVisible)
                    .AsQueryable();

                // Filter by category
                if (!string.IsNullOrEmpty(category))
                {
                    query = query.Where(n => n.Category == category);
                }

                // Filter by featured
                if (isFeatured.HasValue)
                {
                    query = query.Where(n => n.IsFeatured == isFeatured.Value);
                }

                // Get total count
                var totalCount = await query.CountAsync();

                // Pagination
                var news = await query
                    .OrderByDescending(n => n.PublishDate)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(n => new
                    {
                        n.NewsId,
                        n.Title,
                        n.Summary,
                        n.ImageUrl,
                        n.PublishDate,
                        n.Author,
                        n.ViewCount,
                        n.Category,
                        n.IsFeatured
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách tin tức thành công",
                    data = news,
                    pagination = new
                    {
                        page,
                        pageSize,
                        totalCount,
                        totalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy tin tức nổi bật
        /// </summary>
        [HttpGet("featured")]
        public async Task<ActionResult<object>> GetFeaturedNews(int count = 5)
        {
            try
            {
                var news = await _context.News
                    .Where(n => n.IsVisible && n.IsFeatured)
                    .OrderByDescending(n => n.PublishDate)
                    .Take(count)
                    .Select(n => new
                    {
                        n.NewsId,
                        n.Title,
                        n.Summary,
                        n.ImageUrl,
                        n.PublishDate,
                        n.Author,
                        n.ViewCount,
                        n.Category
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy tin tức nổi bật thành công",
                    data = news,
                    count = news.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy chi tiết tin tức
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetNewsDetail(int id)
        {
            try
            {
                var news = await _context.News
                    .Where(n => n.NewsId == id && n.IsVisible)
                    .Select(n => new
                    {
                        n.NewsId,
                        n.Title,
                        n.Summary,
                        n.Content,
                        n.ImageUrl,
                        n.PublishDate,
                        n.Author,
                        n.ViewCount,
                        n.Category,
                        n.IsFeatured
                    })
                    .FirstOrDefaultAsync();

                if (news == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy tin tức"
                    });
                }

                // Increment view count
                var newsEntity = await _context.News.FindAsync(id);
                if (newsEntity != null)
                {
                    newsEntity.ViewCount++;
                    await _context.SaveChangesAsync();
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy chi tiết tin tức thành công",
                    data = news
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy tin tức liên quan
        /// </summary>
        [HttpGet("{id}/related")]
        public async Task<ActionResult<object>> GetRelatedNews(int id, int count = 5)
        {
            try
            {
                // Get current news
                var currentNews = await _context.News
                    .Where(n => n.NewsId == id)
                    .FirstOrDefaultAsync();

                if (currentNews == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy tin tức"
                    });
                }

                // Get related news (same category)
                var relatedNews = await _context.News
                    .Where(n => n.IsVisible && 
                                n.NewsId != id &&
                                n.Category == currentNews.Category)
                    .OrderByDescending(n => n.PublishDate)
                    .Take(count)
                    .Select(n => new
                    {
                        n.NewsId,
                        n.Title,
                        n.Summary,
                        n.ImageUrl,
                        n.PublishDate,
                        n.ViewCount,
                        n.Category
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy tin tức liên quan thành công",
                    data = relatedNews,
                    count = relatedNews.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }

        /// <summary>
        /// Lấy danh sách categories
        /// </summary>
        [HttpGet("categories")]
        public async Task<ActionResult<object>> GetCategories()
        {
            try
            {
                var categories = await _context.News
                    .Where(n => n.IsVisible)
                    .Select(n => n.Category)
                    .Distinct()
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách categories thành công",
                    data = categories
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi server: " + ex.Message
                });
            }
        }
    }
}
