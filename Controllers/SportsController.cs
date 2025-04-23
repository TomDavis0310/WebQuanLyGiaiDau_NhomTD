using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class SportsController : Controller
    {
        private readonly ApplicationDbContext _context;

        public SportsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // Trang chọn môn thể thao (hiển thị các logo môn thể thao)
        public IActionResult Index()
        {
            return View();
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
        // Ví dụ: /Sports/List?type=Bóng rổ
        public async Task<IActionResult> List(int? sportsId)
        {
            if (sportsId == null)
            {
                return NotFound();
            }

            // Lấy danh sách các giải đấu theo SportsId
            var tournaments = await _context.Tournaments
                .Where(t => t.SportsId == sportsId)
                .ToListAsync();

            if (tournaments == null || !tournaments.Any())
            {
                return NotFound();
            }

            // Trả về View với danh sách giải đấu
            return View(tournaments);
        }
    }
}
