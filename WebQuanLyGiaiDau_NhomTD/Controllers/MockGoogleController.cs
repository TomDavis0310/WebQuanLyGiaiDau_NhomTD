using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Route("Identity/Account/[action]")]
    public class MockGoogleController : Controller
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly ILogger<MockGoogleController> _logger;

        public MockGoogleController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            ILogger<MockGoogleController> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _logger = logger;
        }

        [HttpGet]
        public IActionResult MockGoogleLogin()
        {
            // Tạo view để user nhập thông tin Google giả lập
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> MockGoogleLogin(string email, string name)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(name))
            {
                ModelState.AddModelError("", "Vui lòng nhập đầy đủ thông tin");
                return View();
            }

            // Tìm user existing hoặc tạo mới
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser
                {
                    UserName = email,
                    Email = email,
                    EmailConfirmed = true,
                    FullName = name
                };

                var result = await _userManager.CreateAsync(user);
                if (!result.Succeeded)
                {
                    foreach (var error in result.Errors)
                    {
                        ModelState.AddModelError("", error.Description);
                    }
                    return View();
                }

                _logger.LogInformation("User đã tạo tài khoản mới thông qua Google giả lập: {Email}", email);
            }

            // Đăng nhập user
            await _signInManager.SignInAsync(user, isPersistent: false);
            _logger.LogInformation("User đã đăng nhập thông qua Google giả lập: {Email}", email);

            // Redirect về trang chủ
            return RedirectToAction("Index", "Home");
        }
    }
}