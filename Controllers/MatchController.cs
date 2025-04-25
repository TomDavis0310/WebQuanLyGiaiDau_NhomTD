namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.EntityFrameworkCore;
    using WebQuanLyGiaiDau_NhomTD.Models;

    public class MatchController : Controller
    {
        private readonly ApplicationDbContext _context;

        public MatchController(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var matches = await _context.Matches.Include(m => m.Tournament).ToListAsync();
            return View(matches);
        }

        public IActionResult Create() => View();

        [HttpPost]
        public async Task<IActionResult> Create(Match match)
        {
            if (ModelState.IsValid)
            {
                _context.Matches.Add(match);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(match);
        }
    }

}
