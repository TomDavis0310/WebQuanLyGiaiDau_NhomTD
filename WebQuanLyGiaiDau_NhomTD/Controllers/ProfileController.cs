    using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.ViewModels;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Authorize]
    public class ProfileController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly IWebHostEnvironment _webHostEnvironment;

        public ProfileController(ApplicationDbContext context, UserManager<ApplicationUser> userManager, IWebHostEnvironment webHostEnvironment)
        {
            _context = context;
            _userManager = userManager;
            _webHostEnvironment = webHostEnvironment;
        }

        // GET: Profile
        public async Task<IActionResult> Index()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _userManager.FindByIdAsync(userId);

            if (user == null)
            {
                return NotFound();
            }

            // Get user's teams (teams where user is coach)
            var currentUser = await _userManager.GetUserAsync(User);
            var userTeams = await _context.Teams
                .Where(t => t.Coach == currentUser.FullName ||
                           t.Coach == userId ||
                           t.Coach == User.Identity.Name)
                .Include(t => t.Players)
                .ToListAsync();
                
            // Get teams where user is a player
            var userPlayerTeamIds = await _context.Players
                .Where(p => p.UserId == userId && p.TeamId != null)
                .Select(p => p.TeamId.Value)
                .ToListAsync();
                
            var userPlayerTeams = await _context.Teams
                .Where(t => userPlayerTeamIds.Contains(t.TeamId))
                .Include(t => t.Players)
                .ToListAsync();
                
            // Combine the two lists
            userTeams = userTeams.Union(userPlayerTeams).ToList();

            // Get user's tournament registrations
            var userTournamentRegistrations = await _context.TournamentRegistrations
                .Where(tr => tr.UserId == userId)
                .Include(tr => tr.Tournament)
                .ThenInclude(t => t.Sports)
                .ToListAsync();

            // Get user's players
            var userPlayers = await _context.Players
                .Where(p => p.UserId == userId)
                .Include(p => p.Team)
                .ToListAsync();

            // Get user's statistics by PlayerName - Tạm comment Include để fix migration
            var userPlayerNames = userPlayers.Select(p => p.FullName).ToList();
            var userStats = await _context.Statistics
                .Where(s => userPlayerNames.Contains(s.PlayerName))
                // .Include(s => s.Match) // Tạm comment để fix migration
                // .ThenInclude(m => m.Tournament) // Tạm comment để fix migration
                .ToListAsync();

            var viewModel = new ProfileViewModel
            {
                User = user,
                Teams = userTeams,
                TournamentRegistrations = userTournamentRegistrations,
                Players = userPlayers,
                Statistics = userStats,
                ApprovedTournamentsWithoutTeam = GetApprovedTournamentsWithoutTeam(userId).Result
            };

            return View(viewModel);
        }

        private async Task<List<Tournament>> GetApprovedTournamentsWithoutTeam(string userId)
        {
            // Get tournaments where the user is approved but doesn't have a team registered
            var approvedTournaments = await _context.TournamentRegistrations
                .Where(tr => tr.UserId == userId && tr.Status == "Approved")
                .Select(tr => tr.TournamentId)
                .ToListAsync();

            // Get teams where user is coach
            var coachTeamIds = await _context.Teams
                .Where(t => t.Coach == userId)
                .Select(t => t.TeamId)
                .ToListAsync();
                
            // Get teams where user is a player
            var playerTeamIds = await _context.Players
                .Where(p => p.UserId == userId && p.TeamId != null)
                .Select(p => p.TeamId.Value)
                .ToListAsync();
                
            // Combine the two lists
            var userTeams = coachTeamIds.Union(playerTeamIds).ToList();

            var tournamentsWithTeam = await _context.TournamentTeams
                .Where(tt => approvedTournaments.Contains(tt.TournamentId) && userTeams.Contains(tt.TeamId))
                .Select(tt => tt.TournamentId)
                .ToListAsync();

            var tournamentsWithoutTeam = await _context.Tournaments
                .Where(t => approvedTournaments.Contains(t.Id) && !tournamentsWithTeam.Contains(t.Id))
                .Include(t => t.Sports)
                .ToListAsync();

            return tournamentsWithoutTeam;
        }

        // GET: Profile/Edit
        public async Task<IActionResult> Edit()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _userManager.FindByIdAsync(userId);

            if (user == null)
            {
                return NotFound();
            }

            var viewModel = new EditProfileViewModel
            {
                FullName = user.FullName,
                Email = user.Email,
                PhoneNumber = user.PhoneNumber,
                Address = user.Address,
                Age = user.Age,
                Gender = user.Gender,
                DateOfBirth = user.DateOfBirth,
                CurrentProfilePicture = user.ProfilePictureUrl
            };

            return View(viewModel);
        }

        // POST: Profile/Edit
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(EditProfileViewModel model, IFormFile? profilePicture)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _userManager.FindByIdAsync(userId);

            if (user == null)
            {
                return NotFound();
            }

            // Update user information
            user.FullName = model.FullName;
            user.PhoneNumber = model.PhoneNumber;
            user.Address = model.Address;
            user.Age = model.Age;
            user.Gender = model.Gender;
            user.DateOfBirth = model.DateOfBirth;

            // Handle profile picture upload
            if (profilePicture != null && profilePicture.Length > 0)
            {
                // Validate file size (5MB max)
                if (profilePicture.Length > 5 * 1024 * 1024)
                {
                    ModelState.AddModelError("profilePicture", "File quá lớn! Vui lòng chọn file nhỏ hơn 5MB.");
                    return View(model);
                }

                // Validate file type
                var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
                var fileExtension = Path.GetExtension(profilePicture.FileName).ToLowerInvariant();
                if (!allowedExtensions.Contains(fileExtension))
                {
                    ModelState.AddModelError("profilePicture", "Chỉ chấp nhận file JPG, JPEG, PNG!");
                    return View(model);
                }

                var uploadsFolder = Path.Combine(_webHostEnvironment.WebRootPath, "images", "profiles");
                Directory.CreateDirectory(uploadsFolder);

                var uniqueFileName = Guid.NewGuid().ToString() + "_" + profilePicture.FileName;
                var filePath = Path.Combine(uploadsFolder, uniqueFileName);

                using (var fileStream = new FileStream(filePath, FileMode.Create))
                {
                    await profilePicture.CopyToAsync(fileStream);
                }

                // Delete old profile picture if exists
                if (!string.IsNullOrEmpty(user.ProfilePictureUrl))
                {
                    var oldFilePath = Path.Combine(_webHostEnvironment.WebRootPath, user.ProfilePictureUrl.TrimStart('/'));
                    if (System.IO.File.Exists(oldFilePath))
                    {
                        System.IO.File.Delete(oldFilePath);
                    }
                }

                user.ProfilePictureUrl = "/images/profiles/" + uniqueFileName;
            }

            var result = await _userManager.UpdateAsync(user);

            if (result.Succeeded)
            {
                TempData["SuccessMessage"] = "Hồ sơ đã được cập nhật thành công!";
                return RedirectToAction(nameof(Index));
            }

            foreach (var error in result.Errors)
            {
                ModelState.AddModelError(string.Empty, error.Description);
            }

            model.CurrentProfilePicture = user.ProfilePictureUrl;
            return View(model);
        }
    }
}
