using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.FileUpload;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class ShopController : Controller
    {
        private readonly ApplicationDbContext _context;
        private readonly IFileUploadService _fileUploadService;

        public ShopController(ApplicationDbContext context, IFileUploadService fileUploadService)
        {
            _context = context;
            _fileUploadService = fileUploadService;
        }

        // Public shop page - view products and user's points
        public async Task<IActionResult> Index()
        {
            var products = await _context.RewardProducts.OrderBy(p => p.PointsCost).ToListAsync();

            int userPoints = 0;
            if (User?.Identity?.IsAuthenticated == true)
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var user = await _context.Users.FindAsync(userId);
                if (user != null) userPoints = user.Points;
            }

            ViewData["UserPoints"] = userPoints;
            return View(products);
        }

        // User: Redeem product confirmation page
        [Authorize]
        public async Task<IActionResult> RedeemProduct(int? id)
        {
            if (id == null) return NotFound();
            var product = await _context.RewardProducts.FindAsync(id);
            if (product == null) return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return Challenge();

            ViewData["UserPoints"] = user.Points;
            ViewData["CanAfford"] = user.Points >= product.PointsCost;
            return View(product);
        }

        // User: Process redemption with code generation
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RedeemProduct(int id)
        {
            var product = await _context.RewardProducts.FindAsync(id);
            if (product == null) return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return Challenge();

            if (user.Points < product.PointsCost)
            {
                TempData["Error"] = "Bạn không đủ điểm để đổi sản phẩm này.";
                return RedirectToAction(nameof(Index));
            }

            // Generate redemption code
            var random = new Random();
            var randomCode = random.Next(10000, 99999);
            var redemptionCode = $"RWD-{DateTime.Now:yyyyMMdd}-{randomCode}";

            using (var dbTx = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    user.Points -= product.PointsCost;
                    _context.Update(user);

                    // Create reward transaction with redemption code
                    var transaction = new RewardTransaction
                    {
                        UserId = userId ?? string.Empty,
                        RewardProductId = product.Id,
                        PointsSpent = product.PointsCost,
                        RedemptionCode = redemptionCode,
                        Status = RewardTransactionStatus.Pending,
                        TransactionDate = DateTime.Now,
                        Notes = $"Đổi {product.Name}"
                    };
                    _context.RewardTransactions.Add(transaction);

                    await _context.SaveChangesAsync();
                    await dbTx.CommitAsync();

                    TempData["Success"] = $"Đổi quà thành công! Mã quà tặng của bạn: {redemptionCode}";
                    return RedirectToAction(nameof(MyRewards));
                }
                catch (Exception)
                {
                    await dbTx.RollbackAsync();
                    TempData["Error"] = "Có lỗi khi xử lý đổi điểm. Vui lòng thử lại sau.";
                    return RedirectToAction(nameof(Index));
                }
            }
        }

        // User: View gift bag (redeemed rewards)
        [Authorize]
        public async Task<IActionResult> MyRewards()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Challenge();

            var transactions = await _context.RewardTransactions
                .Include(t => t.RewardProduct)
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.TransactionDate)
                .ToListAsync();

            var user = await _context.Users.FindAsync(userId);
            ViewData["UserPoints"] = user?.Points ?? 0;

            return View(transactions);
        }

        // User: view own transactions
        [Authorize]
        public async Task<IActionResult> Transactions()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null) return Challenge();
            var txs = await _context.RedeemTransactions
                .Include(t => t.Product)
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync();
            return View(txs);
        }

        // Admin: manage products
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> ManageProducts()
        {
            var products = await _context.RewardProducts.ToListAsync();
            return View(products);
        }

        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public IActionResult CreateProduct()
        {
            return View();
        }

        [HttpPost]
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateProduct([Bind("Id,Name,PointsCost,Description")] RewardProduct product, IFormFile? imageFile)
        {
            if (ModelState.IsValid)
            {
                // Upload image if provided
                if (imageFile != null && imageFile.Length > 0)
                {
                    var uploadResult = await _fileUploadService.UploadFileAsync(imageFile, new FileUploadOptions
                    {
                        SubFolder = "rewards",
                        GenerateThumbnail = true,
                        CompressImage = true
                    });
                    if (uploadResult.IsSuccess && uploadResult.FileInfo != null)
                    {
                        product.ImageUrl = uploadResult.FileInfo.Url;
                    }
                }

                _context.Add(product);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(ManageProducts));
            }
            return View(product);
        }

        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> EditProduct(int? id)
        {
            if (id == null) return NotFound();
            var product = await _context.RewardProducts.FindAsync(id);
            if (product == null) return NotFound();
            return View(product);
        }

        [HttpPost]
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditProduct(int id, [Bind("Id,Name,PointsCost,Description,ImageUrl")] RewardProduct product, IFormFile? imageFile)
        {
            if (id != product.Id) return NotFound();
            if (ModelState.IsValid)
            {
                // Upload new image if provided
                if (imageFile != null && imageFile.Length > 0)
                {
                    var uploadResult = await _fileUploadService.UploadFileAsync(imageFile, new FileUploadOptions
                    {
                        SubFolder = "rewards",
                        GenerateThumbnail = true,
                        CompressImage = true
                    });
                    if (uploadResult.IsSuccess && uploadResult.FileInfo != null)
                    {
                        // Delete old image if exists
                        if (!string.IsNullOrEmpty(product.ImageUrl))
                        {
                            await _fileUploadService.DeleteFileAsync(product.ImageUrl);
                        }
                        product.ImageUrl = uploadResult.FileInfo.Url;
                    }
                }

                _context.Update(product);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(ManageProducts));
            }
            return View(product);
        }

        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> DeleteProduct(int? id)
        {
            if (id == null) return NotFound();
            var product = await _context.RewardProducts.FindAsync(id);
            if (product == null) return NotFound();
            return View(product);
        }

        [HttpPost, ActionName("DeleteProduct")]
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteProductConfirmed(int id)
        {
            var product = await _context.RewardProducts.FindAsync(id);
            if (product != null)
            {
                // Delete image if exists
                if (!string.IsNullOrEmpty(product.ImageUrl))
                {
                    await _fileUploadService.DeleteFileAsync(product.ImageUrl);
                }
                _context.RewardProducts.Remove(product);
                await _context.SaveChangesAsync();
                TempData["Success"] = "Đã xóa sản phẩm thành công.";
            }
            return RedirectToAction(nameof(ManageProducts));
        }

        // Admin: manage points settings
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> ManagePoints()
        {
            var cfg = await _context.PointsSettings.FirstOrDefaultAsync();
            if (cfg == null)
            {
                cfg = new PointsSetting();
                _context.PointsSettings.Add(cfg);
                await _context.SaveChangesAsync();
            }
            return View(cfg);
        }

        [HttpPost]
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ManagePoints(PointsSetting model)
        {
            if (ModelState.IsValid)
            {
                var cfg = await _context.PointsSettings.FirstOrDefaultAsync();
                if (cfg == null)
                {
                    _context.PointsSettings.Add(model);
                }
                else
                {
                    cfg.ReadNewsPoints = model.ReadNewsPoints;
                    cfg.ViewTournamentPoints = model.ViewTournamentPoints;
                    cfg.VoteTeamPoints = model.VoteTeamPoints;
                    cfg.VoteTournamentPoints = model.VoteTournamentPoints;
                    _context.Update(cfg);
                }
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(ManagePoints));
            }
            return View(model);
        }

        // Admin: Add points to user (for testing/admin purposes)
        [Authorize(Roles = Models.UserModel.SD.Role_Admin)]
        public async Task<IActionResult> AddPointsToUser(string email, int points)
        {
            if (string.IsNullOrEmpty(email))
            {
                return Json(new { success = false, message = "Email không được để trống" });
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null)
            {
                return Json(new { success = false, message = $"Không tìm thấy user với email: {email}" });
            }

            user.Points += points;
            await _context.SaveChangesAsync();

            return Json(new { 
                success = true, 
                message = $"Đã thêm {points:N0} điểm cho {user.Email}", 
                email = user.Email,
                fullName = user.FullName,
                totalPoints = user.Points
            });
        }
    }
}
