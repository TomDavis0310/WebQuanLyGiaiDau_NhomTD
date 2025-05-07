using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Authorize]
    public class TournamentController : Controller
    {
        private readonly ApplicationDbContext _context;

        public TournamentController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Tournament

        public async Task<IActionResult> Index()
        {
            return View(await _context.Tournaments.ToListAsync());
        }


        // GET: Tournament/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments
                .FirstOrDefaultAsync(m => m.Id == id);
            if (tournament == null)
            {
                return NotFound();
            }

            return View(tournament);
        }

        // GET: Tournament/Create
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public IActionResult Create()
        {
            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name");
            return View();
        }

        // POST: Tournament/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Create(Tournament tournament, IFormFile imageUrl)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (imageUrl != null)
                    {
                        tournament.ImageUrl = await SaveImage(imageUrl);

                    }
                    _context.Add(tournament);
                    await _context.SaveChangesAsync();
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "Lỗi khi lưu dữ liệu: " + ex.Message);
                }
            }
            else
            {
                foreach (var modelState in ViewData.ModelState.Values)
                {
                    foreach (var error in modelState.Errors)
                    {
                        Console.WriteLine(error.ErrorMessage); // Debug
                    }
                }
            }

            var sports = _context.Sports.ToList();
            ViewBag.Sports = new SelectList(sports, "Id", "Name");
            return View(tournament);
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


        // GET: Tournament/Edit/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null)
            {
                return NotFound();
            }
            return View(tournament);
        }

        // POST: Tournament/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Name,Description,StartDate,EndDate,ImageUrl")] Tournament tournament)
        {
            if (id != tournament.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(tournament);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!TournamentExists(tournament.Id))
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
            return View(tournament);
        }

        // GET: Tournament/Delete/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments
                .FirstOrDefaultAsync(m => m.Id == id);
            if (tournament == null)
            {
                return NotFound();
            }

            return View(tournament);
        }

        // POST: Tournament/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament != null)
            {
                _context.Tournaments.Remove(tournament);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool TournamentExists(int id)
        {
            return _context.Tournaments.Any(e => e.Id == id);
        }

        // GET: Tournament/Register/5
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)]
        public async Task<IActionResult> Register(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var tournament = await _context.Tournaments
                .Include(t => t.Sports)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (tournament == null)
            {
                return NotFound();
            }

            // Check if user has already registered for this tournament
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var existingRegistration = await _context.TournamentRegistrations
                .FirstOrDefaultAsync(r => r.TournamentId == id && r.UserId == userId);

            if (existingRegistration != null)
            {
                // User has already registered
                ViewBag.AlreadyRegistered = true;
                ViewBag.RegistrationStatus = existingRegistration.Status;
            }
            else
            {
                ViewBag.AlreadyRegistered = false;
            }

            return View(tournament);
        }

        // POST: Tournament/Register/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)]
        public async Task<IActionResult> Register(int id, string notes)
        {
            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null)
            {
                return NotFound();
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Check if user has already registered
            var existingRegistration = await _context.TournamentRegistrations
                .FirstOrDefaultAsync(r => r.TournamentId == id && r.UserId == userId);

            if (existingRegistration != null)
            {
                // User has already registered
                TempData["Message"] = "Bạn đã đăng ký giải đấu này rồi.";
                return RedirectToAction(nameof(Index));
            }

            // Create new registration
            var registration = new TournamentRegistration
            {
                TournamentId = id,
                UserId = userId,
                RegistrationDate = DateTime.Now,
                Status = "Pending",
                Notes = notes
            };

            _context.TournamentRegistrations.Add(registration);
            await _context.SaveChangesAsync();

            TempData["Message"] = "Đăng ký giải đấu thành công. Vui lòng chờ phê duyệt.";
            return RedirectToAction(nameof(Index));
        }

        // GET: Tournament/MyRegistrations
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)]
        public async Task<IActionResult> MyRegistrations()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var registrations = await _context.TournamentRegistrations
                .Include(r => r.Tournament)
                .Where(r => r.UserId == userId)
                .ToListAsync();

            return View(registrations);
        }

        // GET: Tournament/ManageRegistrations
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> ManageRegistrations()
        {
            var registrations = await _context.TournamentRegistrations
                .Include(r => r.Tournament)
                .Include(r => r.User)
                .ToListAsync();

            return View(registrations);
        }

        // POST: Tournament/UpdateRegistrationStatus
        [HttpPost]
        [ValidateAntiForgeryToken]
        [Authorize(Roles = WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> UpdateRegistrationStatus(int id, string status)
        {
            var registration = await _context.TournamentRegistrations.FindAsync(id);
            if (registration == null)
            {
                return NotFound();
            }

            registration.Status = status;
            _context.Update(registration);
            await _context.SaveChangesAsync();

            return RedirectToAction(nameof(ManageRegistrations));
        }
    }
}
