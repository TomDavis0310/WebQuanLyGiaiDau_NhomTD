namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.EntityFrameworkCore;
    using WebQuanLyGiaiDau_NhomTD.Models;

    public class StatisticController : Controller
    {
        private readonly ApplicationDbContext _context;

        public StatisticController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var stats = await _context.Statistics.Include(s => s.Match).ToListAsync();
            return View(stats);
        }

        public IActionResult Create() => View();

        [HttpPost]
        public async Task<IActionResult> Create(Statistic stat)
        {
            if (ModelState.IsValid)
            {
                _context.Statistics.Add(stat);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(stat);
        }
    }

}
