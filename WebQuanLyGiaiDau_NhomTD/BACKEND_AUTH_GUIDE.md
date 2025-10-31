# 🔐 Backend Authentication API Guide

## 📋 Mục Lục
1. [Tạo AuthApiController](#1-tạo-authapicontroller)
2. [Setup JWT Authentication](#2-setup-jwt-authentication)
3. [User Model & Database](#3-user-model--database)
4. [Testing APIs](#4-testing-apis)

---

## 1. Tạo AuthApiController

### **File: `Controllers/Api/AuthApiController.cs`**

```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers.Api
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthApiController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;

        public AuthApiController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
        }

        // POST: api/Auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Dữ liệu không hợp lệ"
                    });
                }

                var user = await _userManager.FindByEmailAsync(request.Email);
                if (user == null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Email hoặc mật khẩu không đúng"
                    });
                }

                var result = await _signInManager.CheckPasswordSignInAsync(
                    user, request.Password, lockoutOnFailure: false);

                if (!result.Succeeded)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Email hoặc mật khẩu không đúng"
                    });
                }

                // Generate JWT token
                var token = await GenerateJwtToken(user);

                return Ok(new
                {
                    success = true,
                    message = "Đăng nhập thành công",
                    token = token,
                    user = new
                    {
                        id = user.Id,
                        email = user.Email,
                        userName = user.UserName,
                        fullName = user.FullName,
                        phoneNumber = user.PhoneNumber,
                        avatarUrl = user.AvatarUrl,
                        role = (await _userManager.GetRolesAsync(user)).FirstOrDefault(),
                        createdAt = user.CreatedAt
                    }
                });
            }
            catch (Exception ex)
            {
                return Ok(new
                {
                    success = false,
                    message = $"Lỗi: {ex.Message}"
                });
            }
        }

        // POST: api/Auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Dữ liệu không hợp lệ"
                    });
                }

                if (request.Password != request.ConfirmPassword)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Mật khẩu xác nhận không khớp"
                    });
                }

                // Check if email exists
                var existingUser = await _userManager.FindByEmailAsync(request.Email);
                if (existingUser != null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Email đã được sử dụng"
                    });
                }

                // Check if username exists
                var existingUsername = await _userManager.FindByNameAsync(request.UserName);
                if (existingUsername != null)
                {
                    return Ok(new
                    {
                        success = false,
                        message = "Tên đăng nhập đã được sử dụng"
                    });
                }

                // Create new user
                var user = new ApplicationUser
                {
                    Email = request.Email,
                    UserName = request.UserName,
                    FullName = request.FullName,
                    PhoneNumber = request.PhoneNumber,
                    CreatedAt = DateTime.Now,
                    EmailConfirmed = true // Auto-confirm for now
                };

                var result = await _userManager.CreateAsync(user, request.Password);

                if (!result.Succeeded)
                {
                    var errors = string.Join(", ", result.Errors.Select(e => e.Description));
                    return Ok(new
                    {
                        success = false,
                        message = $"Đăng ký thất bại: {errors}"
                    });
                }

                // Assign default role
                await _userManager.AddToRoleAsync(user, "User");

                // Generate JWT token
                var token = await GenerateJwtToken(user);

                return Ok(new
                {
                    success = true,
                    message = "Đăng ký thành công",
                    token = token,
                    user = new
                    {
                        id = user.Id,
                        email = user.Email,
                        userName = user.UserName,
                        fullName = user.FullName,
                        phoneNumber = user.PhoneNumber,
                        role = "User",
                        createdAt = user.CreatedAt
                    }
                });
            }
            catch (Exception ex)
            {
                return Ok(new
                {
                    success = false,
                    message = $"Lỗi: {ex.Message}"
                });
            }
        }

        // GET: api/Auth/validate
        [HttpGet("validate")]
        [Authorize]
        public IActionResult ValidateToken()
        {
            return Ok(new
            {
                success = true,
                message = "Token hợp lệ"
            });
        }

        // Helper: Generate JWT Token
        private async Task<string> GenerateJwtToken(ApplicationUser user)
        {
            var roles = await _userManager.GetRolesAsync(user);
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Name, user.UserName)
            };

            // Add role claims
            foreach (var role in roles)
            {
                claims.Add(new Claim(ClaimTypes.Role, role));
            }

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddDays(7),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }

    // Request Models
    public class LoginRequest
    {
        public string Email { get; set; }
        public string Password { get; set; }
        public bool RememberMe { get; set; }
    }

    public class RegisterRequest
    {
        public string Email { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string ConfirmPassword { get; set; }
        public string? FullName { get; set; }
        public string? PhoneNumber { get; set; }
    }
}
```

---

## 2. Setup JWT Authentication

### **Step 1: Install NuGet Packages**

```powershell
cd d:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD

dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package System.IdentityModel.Tokens.Jwt
```

### **Step 2: Add JWT Settings to `appsettings.json`**

```json
{
  "Jwt": {
    "Key": "YourSuperSecretKeyThatIsAtLeast32CharactersLong!",
    "Issuer": "WebQuanLyGiaiDau",
    "Audience": "TDSportsApp",
    "ExpireDays": 7
  },
  "ConnectionStrings": {
    "DefaultConnection": "Your existing connection string"
  }
}
```

### **Step 3: Update `Program.cs`**

Add JWT authentication configuration:

```csharp
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// ... existing code ...

// Add JWT Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
    };
});

// ... existing services ...

var app = builder.Build();

// ... existing middleware ...

// Add Authentication & Authorization
app.UseAuthentication();
app.UseAuthorization();

// ... rest of the code ...
```

---

## 3. User Model & Database

### **Step 1: Update ApplicationUser Model**

File: `Models/ApplicationUser.cs` (hoặc tạo mới nếu chưa có)

```csharp
using Microsoft.AspNetCore.Identity;

namespace WebQuanLyGiaiDau_NhomTD.Models
{
    public class ApplicationUser : IdentityUser
    {
        public string? FullName { get; set; }
        public string? AvatarUrl { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public DateTime? UpdatedAt { get; set; }
    }
}
```

### **Step 2: Update ApplicationDbContext**

File: `Data/ApplicationDbContext.cs`

```csharp
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        // Your existing DbSets
        public DbSet<Sport> Sports { get; set; }
        public DbSet<Tournament> Tournaments { get; set; }
        // ... other DbSets ...

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Additional configurations
            builder.Entity<ApplicationUser>(entity =>
            {
                entity.Property(e => e.FullName).HasMaxLength(100);
                entity.Property(e => e.AvatarUrl).HasMaxLength(500);
            });
        }
    }
}
```

### **Step 3: Create Migration**

```powershell
dotnet ef migrations add AddAuthenticationSupport
dotnet ef database update
```

### **Step 4: Seed Default Roles and Admin User**

File: `Data/Seed/SeedRoles.cs`

```csharp
using Microsoft.AspNetCore.Identity;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Data.Seed
{
    public static class SeedRoles
    {
        public static async Task Initialize(
            IServiceProvider serviceProvider,
            UserManager<ApplicationUser> userManager,
            RoleManager<IdentityRole> roleManager)
        {
            // Create roles
            string[] roleNames = { "Admin", "User", "Organizer" };
            
            foreach (var roleName in roleNames)
            {
                if (!await roleManager.RoleExistsAsync(roleName))
                {
                    await roleManager.CreateAsync(new IdentityRole(roleName));
                }
            }

            // Create admin user
            var adminEmail = "admin@tdsports.com";
            var adminUser = await userManager.FindByEmailAsync(adminEmail);

            if (adminUser == null)
            {
                var admin = new ApplicationUser
                {
                    UserName = "admin",
                    Email = adminEmail,
                    FullName = "Admin User",
                    EmailConfirmed = true,
                    CreatedAt = DateTime.Now
                };

                var result = await userManager.CreateAsync(admin, "Admin@123");
                
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(admin, "Admin");
                }
            }
        }
    }
}
```

Call this in `Program.cs`:

```csharp
// After app.Build() and before app.Run()
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();
    var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();
    
    await SeedRoles.Initialize(services, userManager, roleManager);
}
```

---

## 4. Testing APIs

### **Test với PowerShell**

#### **1. Test Register:**

```powershell
$registerData = @{
    email = "test@example.com"
    userName = "testuser"
    password = "Test@123"
    confirmPassword = "Test@123"
    fullName = "Test User"
    phoneNumber = "0123456789"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5194/api/Auth/register" `
    -Method POST `
    -Body $registerData `
    -ContentType "application/json"
```

#### **2. Test Login:**

```powershell
$loginData = @{
    email = "test@example.com"
    password = "Test@123"
    rememberMe = $true
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:5194/api/Auth/login" `
    -Method POST `
    -Body $loginData `
    -ContentType "application/json"

# Save token
$token = $response.token
Write-Host "Token: $token"
```

#### **3. Test Validate Token:**

```powershell
$headers = @{
    "Authorization" = "Bearer $token"
}

Invoke-RestMethod -Uri "http://localhost:5194/api/Auth/validate" `
    -Method GET `
    -Headers $headers
```

### **Test với Swagger:**

1. Navigate to `http://localhost:5194/swagger`
2. Find `Auth` endpoints
3. Try out Register → Login → Validate

---

## ✅ Checklist Hoàn Thành

- [ ] Install JWT packages
- [ ] Add JWT configuration to appsettings.json
- [ ] Update Program.cs với Authentication
- [ ] Create/Update ApplicationUser model
- [ ] Update ApplicationDbContext
- [ ] Create migration và update database
- [ ] Create AuthApiController
- [ ] Seed roles và admin user
- [ ] Test Register API
- [ ] Test Login API
- [ ] Test Validate Token API
- [ ] Update Flutter app để remove mock authentication

---

## 🔒 Security Best Practices

1. **JWT Key:** Sử dụng key mạnh (ít nhất 32 ký tự)
2. **HTTPS:** Bắt buộc cho production
3. **Password:** Enforce strong password policy
4. **Token Expiration:** Set reasonable expiration time
5. **Refresh Tokens:** Implement cho long-term sessions
6. **Rate Limiting:** Prevent brute force attacks
7. **Input Validation:** Validate tất cả inputs
8. **Error Messages:** Không expose sensitive info

---

## 📚 Resources

- [ASP.NET Core Identity](https://docs.microsoft.com/en-us/aspnet/core/security/authentication/identity)
- [JWT Authentication](https://jwt.io/)
- [Entity Framework Core](https://docs.microsoft.com/en-us/ef/core/)

---

**🎉 Sau khi hoàn thành backend, Flutter app sẽ hoạt động với real authentication!**
