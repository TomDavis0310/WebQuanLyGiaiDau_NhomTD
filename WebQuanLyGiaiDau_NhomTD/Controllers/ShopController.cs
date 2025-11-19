using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class ShopController : Controller
    {
        private readonly ApplicationDbContext _context;

        public ShopController(ApplicationDbContext context)
        {
            _context = context;
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

        // Purchase endpoint - user redeems product
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Redeem(int productId)
        {
            var product = await _context.RewardProducts.FindAsync(productId);
            if (product == null) return NotFound();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return Challenge();

            if (user.Points < product.PointsCost)
            {
                TempData["Error"] = "Bạn không đủ điểm để đổi sản phẩm này.";
                return RedirectToAction(nameof(Index));
            }

            // perform deduction + transaction record atomically
            using (var dbTx = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    user.Points -= product.PointsCost;
                    _context.Update(user);

                    // Create a redeem transaction record
                    var tx = new RedeemTransaction
                    {
                        UserId = userId ?? string.Empty,
                        ProductId = product.Id,
                        PointsCost = product.PointsCost,
                        CreatedAt = DateTime.UtcNow,
                        Status = "Completed"
                    };
                    _context.RedeemTransactions.Add(tx);

                    await _context.SaveChangesAsync();
                    await dbTx.CommitAsync();

                    TempData["Success"] = "Đổi điểm thành công. Cảm ơn bạn!";
                    return RedirectToAction(nameof(Index));
                }
                catch (Exception)
                {
                    // rollback and report error
                    await dbTx.RollbackAsync();
                    // log if a logger is available (not injected here) — fallback to TempData message
                    TempData["Error"] = "Có lỗi khi xử lý đổi điểm. Vui lòng thử lại sau.";
                    return RedirectToAction(nameof(Index));
                }
            }
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
        public async Task<IActionResult> CreateProduct([Bind("Id,Name,PointsCost,Description")] RewardProduct product)
        {
            if (ModelState.IsValid)
            {
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
        public async Task<IActionResult> EditProduct(int id, [Bind("Id,Name,PointsCost,Description")] RewardProduct product)
        {
            if (id != product.Id) return NotFound();
            if (ModelState.IsValid)
            {
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
                _context.RewardProducts.Remove(product);
                await _context.SaveChangesAsync();
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
    }
}
