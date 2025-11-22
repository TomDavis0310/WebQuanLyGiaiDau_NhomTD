using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class ShopApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public ShopApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Lấy danh sách tất cả sản phẩm trong shop
        /// </summary>
        [HttpGet("products")]
        public async Task<ActionResult<IEnumerable<object>>> GetProducts()
        {
            var products = await _context.RewardProducts
                .OrderBy(p => p.PointsCost)
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.PointsCost,
                    p.Description,
                    p.ImageUrl
                })
                .ToListAsync();

            return Ok(products);
        }

        /// <summary>
        /// Lấy thông tin điểm của user hiện tại
        /// </summary>
        [Authorize]
        [HttpGet("my-points")]
        public async Task<ActionResult<object>> GetMyPoints()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null)
                return Unauthorized(new { message = "Chưa đăng nhập" });

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            return Ok(new
            {
                points = user.Points,
                username = user.UserName,
                fullName = user.FullName
            });
        }

        /// <summary>
        /// Lấy danh sách quà tặng đã đổi của user (túi quà)
        /// </summary>
        [Authorize]
        [HttpGet("my-rewards")]
        public async Task<ActionResult<IEnumerable<object>>> GetMyRewards()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null)
                return Unauthorized(new { message = "Chưa đăng nhập" });

            var transactions = await _context.RewardTransactions
                .Include(t => t.RewardProduct)
                .Where(t => t.UserId == userId)
                .OrderByDescending(t => t.TransactionDate)
                .Select(t => new
                {
                    t.Id,
                    t.TransactionDate,
                    t.PointsSpent,
                    t.RedemptionCode,
                    t.Status,
                    t.Notes,
                    Product = new
                    {
                        t.RewardProduct.Id,
                        t.RewardProduct.Name,
                        t.RewardProduct.Description,
                        t.RewardProduct.ImageUrl
                    }
                })
                .ToListAsync();

            return Ok(transactions);
        }

        /// <summary>
        /// Đổi điểm lấy sản phẩm
        /// </summary>
        [Authorize]
        [HttpPost("redeem/{productId}")]
        public async Task<ActionResult<object>> RedeemProduct(int productId)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (userId == null)
                return Unauthorized(new { message = "Chưa đăng nhập" });

            var product = await _context.RewardProducts.FindAsync(productId);
            if (product == null)
                return NotFound(new { message = "Không tìm thấy sản phẩm" });

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                return NotFound(new { message = "Không tìm thấy người dùng" });

            if (user.Points < product.PointsCost)
            {
                return BadRequest(new
                {
                    message = "Bạn không đủ điểm để đổi sản phẩm này",
                    currentPoints = user.Points,
                    requiredPoints = product.PointsCost
                });
            }

            // Generate redemption code
            var random = new Random();
            var randomCode = random.Next(10000, 99999);
            var redemptionCode = $"RWD-{DateTime.Now:yyyyMMdd}-{randomCode}";

            using (var dbTx = await _context.Database.BeginTransactionAsync())
            {
                try
                {
                    // Trừ điểm
                    user.Points -= product.PointsCost;
                    _context.Update(user);

                    // Tạo transaction
                    var transaction = new RewardTransaction
                    {
                        UserId = userId,
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

                    return Ok(new
                    {
                        message = "Đổi quà thành công!",
                        redemptionCode = redemptionCode,
                        remainingPoints = user.Points,
                        transaction = new
                        {
                            transaction.Id,
                            transaction.TransactionDate,
                            transaction.PointsSpent,
                            transaction.RedemptionCode,
                            Product = new
                            {
                                product.Id,
                                product.Name,
                                product.Description,
                                product.ImageUrl
                            }
                        }
                    });
                }
                catch (Exception ex)
                {
                    await dbTx.RollbackAsync();
                    return StatusCode(500, new
                    {
                        message = "Có lỗi khi xử lý đổi điểm. Vui lòng thử lại sau.",
                        error = ex.Message
                    });
                }
            }
        }

        /// <summary>
        /// Lấy chi tiết 1 sản phẩm
        /// </summary>
        [HttpGet("products/{id}")]
        public async Task<ActionResult<object>> GetProduct(int id)
        {
            var product = await _context.RewardProducts.FindAsync(id);
            if (product == null)
                return NotFound(new { message = "Không tìm thấy sản phẩm" });

            return Ok(new
            {
                product.Id,
                product.Name,
                product.PointsCost,
                product.Description,
                product.ImageUrl
            });
        }
    }
}
