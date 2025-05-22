namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    using Microsoft.AspNetCore.Authorization;
    using Microsoft.AspNetCore.Mvc;
    using Microsoft.AspNetCore.Mvc.Rendering;
    using Microsoft.EntityFrameworkCore;
    using WebQuanLyGiaiDau_NhomTD.Models;
    using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

    [Authorize]
    public class StatisticController : Controller
    {
        private readonly ApplicationDbContext _context;

        public StatisticController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Statistic
        public async Task<IActionResult> Index()
        {
            var stats = await _context.Statistics
                .Include(s => s.Match)
                .ToListAsync();
            return View(stats);
        }

        // GET: Statistic/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var statistic = await _context.Statistics
                .Include(s => s.Match)
                .FirstOrDefaultAsync(s => s.Id == id);
            if (statistic == null)
            {
                return NotFound();
            }

            return View(statistic);
        }

        // GET: Statistic/Create
        [Authorize(Roles = SD.Role_Admin)]
        public IActionResult Create()
        {
            ViewData["MatchId"] = new SelectList(_context.Matches, "Id", "TeamA");
            return View();
        }

        // POST: Statistic/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Create(Statistic statistic)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    _context.Statistics.Add(statistic);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }
            ViewData["MatchId"] = new SelectList(_context.Matches, "Id", "TeamA", statistic.MatchId);
            return View(statistic);
        }

        // GET: Statistic/Edit/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var statistic = await _context.Statistics.FindAsync(id);
            if (statistic == null)
            {
                return NotFound();
            }
            ViewData["MatchId"] = new SelectList(_context.Matches, "Id", "TeamA", statistic.MatchId);
            return View(statistic);
        }

        // POST: Statistic/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, Statistic statistic)
        {
            if (id != statistic.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(statistic);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!StatisticExists(statistic.Id))
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
            ViewData["MatchId"] = new SelectList(_context.Matches, "Id", "TeamA", statistic.MatchId);
            return View(statistic);
        }

        // GET: Statistic/Delete/5
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var statistic = await _context.Statistics
                .Include(s => s.Match)
                .FirstOrDefaultAsync(s => s.Id == id);
            if (statistic == null)
            {
                return NotFound();
            }

            return View(statistic);
        }

        // POST: Statistic/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = SD.Role_Admin)]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            try
            {
                var statistic = await _context.Statistics.FindAsync(id);
                if (statistic != null)
                {
                    _context.Statistics.Remove(statistic);
                    await _context.SaveChangesAsync();
                }
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                // Handle foreign key constraint violation
                Console.WriteLine($"Lỗi khi xóa thống kê: {ex.Message}");
                return RedirectToAction(nameof(Delete), new { id = id, error = "Không thể xóa thống kê này vì có dữ liệu liên quan." });
            }
        }

        private bool StatisticExists(int id)
        {
            return _context.Statistics.Any(s => s.Id == id);
        }
    }
}
