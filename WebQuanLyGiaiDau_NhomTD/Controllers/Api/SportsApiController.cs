using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class SportsApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public SportsApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy danh sách tất cả môn thể thao
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<object>> GetSports()
        {
            try
            {
                var sports = await _context.Sports
                    .Select(s => new
                    {
                        s.Id,
                        s.Name,
                        s.ImageUrl,
                        // s.Description, // Bỏ dòng này vì Sports model không có Description
                        // Đếm số giải đấu theo môn thể thao
                        TournamentCount = _context.Tournaments.Count(t => t.SportsId == s.Id)
                    })
                    .ToListAsync();

                return Ok(new
                {
                    success = true,
                    message = "Lấy danh sách môn thể thao thành công",
                    data = sports,
                    count = sports.Count()
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
        /// Lấy thông tin chi tiết một môn thể thao
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<object>> GetSport(int id)
        {
            try
            {
                var sport = await _context.Sports
                    .Where(s => s.Id == id)
                    .Select(s => new
                    {
                        s.Id,
                        s.Name,
                        s.ImageUrl,
                        // s.Description, // Bỏ dòng này vì Sports model không có Description
                        // Lấy danh sách giải đấu thuộc môn thể thao này
                        Tournaments = _context.Tournaments
                            .Where(t => t.SportsId == id)
                            .Select(t => new
                            {
                                t.Id,
                                t.Name,
                                t.StartDate,
                                t.EndDate,
                                t.Location,
                                t.RegistrationStatus,
                                t.ImageUrl
                            })
                            .ToList()
                    })
                    .FirstOrDefaultAsync();

                if (sport == null)
                {
                    return NotFound(new
                    {
                        success = false,
                        message = "Không tìm thấy môn thể thao"
                    });
                }

                return Ok(new
                {
                    success = true,
                    message = "Lấy thông tin môn thể thao thành công",
                    data = sport
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
