using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    public class AccountController : Controller
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly ILogger<AccountController> _logger;
        private readonly ITwoFactorService _twoFactorService;

        public AccountController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            ILogger<AccountController> logger,
            ITwoFactorService twoFactorService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _logger = logger;
            _twoFactorService = twoFactorService;
        }

        // GET: /Account/Login
        [HttpGet]
        [AllowAnonymous]
        public IActionResult Login(string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        // POST: /Account/Login
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;

            if (ModelState.IsValid)
            {
                // First check if user exists and password is correct
                var user = await _userManager.FindByEmailAsync(model.Email);
                
                if (user == null)
                {
                    ModelState.AddModelError(string.Empty, "Email hoặc mật khẩu không đúng.");
                    return View(model);
                }

                // Check if password is correct
                var passwordCheck = await _userManager.CheckPasswordAsync(user, model.Password);
                if (!passwordCheck)
                {
                    ModelState.AddModelError(string.Empty, "Email hoặc mật khẩu không đúng.");
                    return View(model);
                }

                // Check if 2FA is enabled
                if (user.IsTwoFactorEnabled)
                {
                    // Generate OTP code
                    var otpCode = _twoFactorService.GenerateOtpCode();
                    user.TwoFactorCode = otpCode;
                    user.TwoFactorExpiry = DateTime.UtcNow.AddMinutes(5);
                    await _userManager.UpdateAsync(user);

                    // Send OTP based on preferred method
                    bool otpSent = false;
                    switch (user.PreferredVerificationMethod?.ToLower())
                    {
                        case "email":
                            otpSent = await _twoFactorService.SendOtpViaEmailAsync(user.Email!, otpCode, user.FullName);
                            break;
                        case "sms":
                            if (!string.IsNullOrEmpty(user.PhoneNumber))
                            {
                                otpSent = await _twoFactorService.SendOtpViaSmsAsync(user.PhoneNumber, otpCode);
                            }
                            break;
                        case "zalo":
                            if (!string.IsNullOrEmpty(user.ZaloId))
                            {
                                otpSent = await _twoFactorService.SendOtpViaZaloAsync(user.ZaloId, otpCode);
                            }
                            break;
                        default:
                            // Default to email if no method specified
                            otpSent = await _twoFactorService.SendOtpViaEmailAsync(user.Email!, otpCode, user.FullName);
                            break;
                    }

                    if (!otpSent)
                    {
                        ModelState.AddModelError(string.Empty, "Không thể gửi mã xác thực. Vui lòng thử lại.");
                        return View(model);
                    }

                    // Store email in TempData for verification page
                    TempData["TwoFactorEmail"] = model.Email;
                    TempData["ReturnUrl"] = returnUrl;
                    
                    return RedirectToAction(nameof(VerifyTwoFactor));
                }

                // If 2FA is not enabled, proceed with normal login
                var result = await _signInManager.PasswordSignInAsync(
                    model.Email, 
                    model.Password, 
                    model.RememberMe, 
                    lockoutOnFailure: false);

                if (result.Succeeded)
                {
                    _logger.LogInformation("User logged in.");
                    return RedirectToLocal(returnUrl);
                }
                if (result.IsLockedOut)
                {
                    _logger.LogWarning("User account locked out.");
                    return View("Lockout");
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Email hoặc mật khẩu không đúng.");
                    return View(model);
                }
            }

            return View(model);
        }

        // GET: /Account/Register
        [HttpGet]
        [AllowAnonymous]
        public IActionResult Register(string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        // POST: /Account/Register
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Register(RegisterViewModel model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;

            if (ModelState.IsValid)
            {
                var user = new ApplicationUser
                {
                    UserName = model.Email,
                    Email = model.Email,
                    FullName = model.FullName,
                    EmailConfirmed = true
                };

                var result = await _userManager.CreateAsync(user, model.Password);

                if (result.Succeeded)
                {
                    _logger.LogInformation("User created a new account with password.");

                    await _signInManager.SignInAsync(user, isPersistent: false);
                    return RedirectToLocal(returnUrl);
                }

                foreach (var error in result.Errors)
                {
                    ModelState.AddModelError(string.Empty, error.Description);
                }
            }

            return View(model);
        }

        // POST: /Account/Logout
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            await _signInManager.SignOutAsync();
            _logger.LogInformation("User logged out.");
            return RedirectToAction("Index", "Home");
        }

        // GET: /Account/Manage
        [HttpGet]
        [Authorize]
        public async Task<IActionResult> Manage()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound($"Unable to load user with ID '{_userManager.GetUserId(User)}'.");
            }

            var model = new ManageViewModel
            {
                Email = user.Email ?? string.Empty,
                FullName = user.FullName ?? string.Empty,
                PhoneNumber = user.PhoneNumber ?? string.Empty,
                IsEmailConfirmed = user.EmailConfirmed
            };

            return View(model);
        }

        // POST: /Account/Manage
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Manage(ManageViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound($"Unable to load user with ID '{_userManager.GetUserId(User)}'.");
            }

            user.FullName = model.FullName;
            user.PhoneNumber = model.PhoneNumber;

            var result = await _userManager.UpdateAsync(user);

            if (result.Succeeded)
            {
                TempData["StatusMessage"] = "Thông tin của bạn đã được cập nhật.";
                return RedirectToAction(nameof(Manage));
            }

            foreach (var error in result.Errors)
            {
                ModelState.AddModelError(string.Empty, error.Description);
            }

            return View(model);
        }

        // GET: /Account/ChangePassword
        [HttpGet]
        [Authorize]
        public IActionResult ChangePassword()
        {
            return View();
        }

        // POST: /Account/ChangePassword
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> ChangePassword(ChangePasswordViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound($"Unable to load user with ID '{_userManager.GetUserId(User)}'.");
            }

            var result = await _userManager.ChangePasswordAsync(user, model.OldPassword, model.NewPassword);

            if (result.Succeeded)
            {
                await _signInManager.RefreshSignInAsync(user);
                _logger.LogInformation("User changed their password successfully.");
                TempData["StatusMessage"] = "Mật khẩu của bạn đã được thay đổi.";
                return RedirectToAction(nameof(Manage));
            }

            foreach (var error in result.Errors)
            {
                ModelState.AddModelError(string.Empty, error.Description);
            }

            return View(model);
        }

        // GET: /Account/GoogleLogin
        [HttpGet]
        [AllowAnonymous]
        public IActionResult GoogleLogin()
        {
            return View();
        }

        // POST: /Account/GoogleLogin
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> GoogleLogin(string email, string name)
        {
            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(name))
            {
                ModelState.AddModelError("", "Vui lòng nhập đầy đủ thông tin");
                return View();
            }

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

                _logger.LogInformation("User created account via Google: {Email}", email);
            }

            await _signInManager.SignInAsync(user, isPersistent: false);
            _logger.LogInformation("User logged in via Google: {Email}", email);

            return RedirectToAction("Index", "Home");
        }

        // GET: /Account/AccessDenied
        [HttpGet]
        public IActionResult AccessDenied()
        {
            return View();
        }

        // ==================== TWO-FACTOR AUTHENTICATION ====================

        // GET: /Account/VerifyTwoFactor
        [HttpGet]
        [AllowAnonymous]
        public IActionResult VerifyTwoFactor()
        {
            var email = TempData["TwoFactorEmail"] as string;
            if (string.IsNullOrEmpty(email))
            {
                return RedirectToAction(nameof(Login));
            }

            TempData.Keep("TwoFactorEmail");
            TempData.Keep("ReturnUrl");
            
            return View(new VerifyTwoFactorViewModel { Email = email });
        }

        // POST: /Account/VerifyTwoFactor
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> VerifyTwoFactor(VerifyTwoFactorViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null)
            {
                ModelState.AddModelError(string.Empty, "Không tìm thấy người dùng.");
                return View(model);
            }

            // Verify OTP code
            if (_twoFactorService.VerifyOtpCode(user.TwoFactorCode, user.TwoFactorExpiry, model.Code))
            {
                // Clear the OTP code
                user.TwoFactorCode = null;
                user.TwoFactorExpiry = null;
                await _userManager.UpdateAsync(user);

                // Sign in the user
                await _signInManager.SignInAsync(user, isPersistent: model.RememberMe);
                _logger.LogInformation("User logged in with 2FA.");

                var returnUrl = TempData["ReturnUrl"] as string;
                return RedirectToLocal(returnUrl);
            }
            else
            {
                ModelState.AddModelError(string.Empty, "Mã xác thực không đúng hoặc đã hết hạn.");
                return View(model);
            }
        }

        // GET: /Account/TwoFactorSettings
        [HttpGet]
        [Authorize]
        public async Task<IActionResult> TwoFactorSettings()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound($"Unable to load user with ID '{_userManager.GetUserId(User)}'.");
            }

            var model = new TwoFactorSettingsViewModel
            {
                IsTwoFactorEnabled = user.IsTwoFactorEnabled,
                PreferredVerificationMethod = user.PreferredVerificationMethod ?? "Email",
                HasPhoneNumber = !string.IsNullOrEmpty(user.PhoneNumber),
                IsPhoneNumberVerified = user.IsPhoneNumberVerified,
                HasZaloId = !string.IsNullOrEmpty(user.ZaloId),
                IsZaloVerified = user.IsZaloVerified
            };

            return View(model);
        }

        // POST: /Account/EnableTwoFactor
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EnableTwoFactor(string verificationMethod)
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound($"Unable to load user with ID '{_userManager.GetUserId(User)}'.");
            }

            // Validate verification method
            if (verificationMethod == "SMS" && string.IsNullOrEmpty(user.PhoneNumber))
            {
                TempData["ErrorMessage"] = "Bạn cần thêm số điện thoại trước khi sử dụng xác thực qua SMS.";
                return RedirectToAction(nameof(TwoFactorSettings));
            }

            if (verificationMethod == "Zalo" && string.IsNullOrEmpty(user.ZaloId))
            {
                TempData["ErrorMessage"] = "Bạn cần liên kết tài khoản Zalo trước khi sử dụng xác thực qua Zalo.";
                return RedirectToAction(nameof(TwoFactorSettings));
            }

            user.IsTwoFactorEnabled = true;
            user.PreferredVerificationMethod = verificationMethod;
            await _userManager.UpdateAsync(user);

            _logger.LogInformation($"User enabled 2FA with {verificationMethod} method.");
            TempData["StatusMessage"] = $"Xác thực 2 bước đã được bật với phương thức {verificationMethod}.";
            
            return RedirectToAction(nameof(TwoFactorSettings));
        }

        // POST: /Account/DisableTwoFactor
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DisableTwoFactor()
        {
            var user = await _userManager.GetUserAsync(User);
            if (user == null)
            {
                return NotFound($"Unable to load user with ID '{_userManager.GetUserId(User)}'.");
            }

            user.IsTwoFactorEnabled = false;
            user.PreferredVerificationMethod = null;
            user.TwoFactorCode = null;
            user.TwoFactorExpiry = null;
            await _userManager.UpdateAsync(user);

            _logger.LogInformation("User disabled 2FA.");
            TempData["StatusMessage"] = "Xác thực 2 bước đã được tắt.";
            
            return RedirectToAction(nameof(TwoFactorSettings));
        }

        // POST: /Account/SendOtp
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> SendOtp(string email)
        {
            var user = await _userManager.FindByEmailAsync(email);
            if (user == null)
            {
                return Json(new { success = false, message = "Không tìm thấy người dùng." });
            }

            // Generate new OTP
            var otpCode = _twoFactorService.GenerateOtpCode();
            user.TwoFactorCode = otpCode;
            user.TwoFactorExpiry = DateTime.UtcNow.AddMinutes(5);
            await _userManager.UpdateAsync(user);

            // Send OTP
            bool sent = false;
            switch (user.PreferredVerificationMethod?.ToLower())
            {
                case "email":
                    sent = await _twoFactorService.SendOtpViaEmailAsync(user.Email!, otpCode, user.FullName);
                    break;
                case "sms":
                    if (!string.IsNullOrEmpty(user.PhoneNumber))
                    {
                        sent = await _twoFactorService.SendOtpViaSmsAsync(user.PhoneNumber, otpCode);
                    }
                    break;
                case "zalo":
                    if (!string.IsNullOrEmpty(user.ZaloId))
                    {
                        sent = await _twoFactorService.SendOtpViaZaloAsync(user.ZaloId, otpCode);
                    }
                    break;
                default:
                    sent = await _twoFactorService.SendOtpViaEmailAsync(user.Email!, otpCode, user.FullName);
                    break;
            }

            if (sent)
            {
                return Json(new { success = true, message = "Mã xác thực mới đã được gửi." });
            }
            else
            {
                return Json(new { success = false, message = "Không thể gửi mã xác thực. Vui lòng thử lại." });
            }
        }

        private IActionResult RedirectToLocal(string? returnUrl)
        {
            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
        }
    }

    // View Models
    public class LoginViewModel
    {
        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Email là bắt buộc")]
        [System.ComponentModel.DataAnnotations.EmailAddress(ErrorMessage = "Email không hợp lệ")]
        public string Email { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Mật khẩu là bắt buộc")]
        [System.ComponentModel.DataAnnotations.DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        public string Password { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Display(Name = "Ghi nhớ đăng nhập?")]
        public bool RememberMe { get; set; }
    }

    public class RegisterViewModel
    {
        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Họ và tên là bắt buộc")]
        [System.ComponentModel.DataAnnotations.Display(Name = "Họ và tên")]
        public string FullName { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Email là bắt buộc")]
        [System.ComponentModel.DataAnnotations.EmailAddress(ErrorMessage = "Email không hợp lệ")]
        public string Email { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Mật khẩu là bắt buộc")]
        [System.ComponentModel.DataAnnotations.StringLength(100, ErrorMessage = "{0} phải có ít nhất {2} và tối đa {1} ký tự.", MinimumLength = 6)]
        [System.ComponentModel.DataAnnotations.DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        [System.ComponentModel.DataAnnotations.Display(Name = "Mật khẩu")]
        public string Password { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        [System.ComponentModel.DataAnnotations.Display(Name = "Xác nhận mật khẩu")]
        [System.ComponentModel.DataAnnotations.Compare("Password", ErrorMessage = "Mật khẩu và xác nhận mật khẩu không khớp.")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }

    public class ManageViewModel
    {
        public string Email { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Họ và tên là bắt buộc")]
        [System.ComponentModel.DataAnnotations.Display(Name = "Họ và tên")]
        public string FullName { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Phone(ErrorMessage = "Số điện thoại không hợp lệ")]
        [System.ComponentModel.DataAnnotations.Display(Name = "Số điện thoại")]
        public string PhoneNumber { get; set; } = string.Empty;

        public bool IsEmailConfirmed { get; set; }
    }

    public class ChangePasswordViewModel
    {
        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Mật khẩu cũ là bắt buộc")]
        [System.ComponentModel.DataAnnotations.DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        [System.ComponentModel.DataAnnotations.Display(Name = "Mật khẩu cũ")]
        public string OldPassword { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Mật khẩu mới là bắt buộc")]
        [System.ComponentModel.DataAnnotations.StringLength(100, ErrorMessage = "{0} phải có ít nhất {2} và tối đa {1} ký tự.", MinimumLength = 6)]
        [System.ComponentModel.DataAnnotations.DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        [System.ComponentModel.DataAnnotations.Display(Name = "Mật khẩu mới")]
        public string NewPassword { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.DataType(System.ComponentModel.DataAnnotations.DataType.Password)]
        [System.ComponentModel.DataAnnotations.Display(Name = "Xác nhận mật khẩu mới")]
        [System.ComponentModel.DataAnnotations.Compare("NewPassword", ErrorMessage = "Mật khẩu mới và xác nhận mật khẩu không khớp.")]
        public string ConfirmPassword { get; set; } = string.Empty;
    }

    // Two-Factor Authentication View Models
    public class VerifyTwoFactorViewModel
    {
        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Email là bắt buộc")]
        public string Email { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Required(ErrorMessage = "Mã xác thực là bắt buộc")]
        [System.ComponentModel.DataAnnotations.Display(Name = "Mã xác thực")]
        [System.ComponentModel.DataAnnotations.StringLength(6, MinimumLength = 6, ErrorMessage = "Mã xác thực phải có 6 chữ số")]
        public string Code { get; set; } = string.Empty;

        [System.ComponentModel.DataAnnotations.Display(Name = "Ghi nhớ đăng nhập?")]
        public bool RememberMe { get; set; }
    }

    public class TwoFactorSettingsViewModel
    {
        public bool IsTwoFactorEnabled { get; set; }
        public string PreferredVerificationMethod { get; set; } = "Email";
        public bool HasPhoneNumber { get; set; }
        public bool IsPhoneNumberVerified { get; set; }
        public bool HasZaloId { get; set; }
        public bool IsZaloVerified { get; set; }
    }
}
