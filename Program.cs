using WebQuanLyGiaiDau_NhomTD.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;
using WebQuanLyGiaiDau_NhomTD;

var builder = WebApplication.CreateBuilder(args);

// Đăng ký ApplicationDbContext với DI container
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Đăng ký Identity với ApplicationUser thay vì IdentityUser
builder.Services.AddDefaultIdentity<WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser>(options =>
{
    options.SignIn.RequireConfirmedAccount = false;
})
.AddRoles<IdentityRole>() // Add role management
.AddEntityFrameworkStores<ApplicationDbContext>();

// Đăng ký MVC và Razor Pages (cho Identity)
builder.Services.AddControllersWithViews();
builder.Services.AddRazorPages();

// Add SignalR services
builder.Services.AddSignalR();

// Add authorization policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin));
    options.AddPolicy("UserOnly", policy => policy.RequireRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User));
});

var app = builder.Build();

// Create admin user if it doesn't exist
using (var scope = app.Services.CreateScope())
{
    var userManager = scope.ServiceProvider.GetRequiredService<UserManager<WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser>>();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();

    // Ensure roles exist
    if (!roleManager.RoleExistsAsync(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin).GetAwaiter().GetResult())
    {
        roleManager.CreateAsync(new IdentityRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin)).GetAwaiter().GetResult();
    }

    if (!roleManager.RoleExistsAsync(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User).GetAwaiter().GetResult())
    {
        roleManager.CreateAsync(new IdentityRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User)).GetAwaiter().GetResult();
    }

    // Create admin user
    string adminEmail = "admin@example.com";
    string adminPassword = "Admin123!";

    if (userManager.FindByEmailAsync(adminEmail).GetAwaiter().GetResult() == null)
    {
        var adminUser = new WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser
        {
            UserName = adminEmail,
            Email = adminEmail,
            EmailConfirmed = true,
            FullName = "Admin User"
        };

        var result = userManager.CreateAsync(adminUser, adminPassword).GetAwaiter().GetResult();

        if (result.Succeeded)
        {
            userManager.AddToRoleAsync(adminUser, WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin).GetAwaiter().GetResult();
        }
    }

    // Create a regular user
    string userEmail = "user@example.com";
    string userPassword = "User123!";

    if (userManager.FindByEmailAsync(userEmail).GetAwaiter().GetResult() == null)
    {
        var regularUser = new WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser
        {
            UserName = userEmail,
            Email = userEmail,
            EmailConfirmed = true,
            FullName = "Regular User"
        };

        var result = userManager.CreateAsync(regularUser, userPassword).GetAwaiter().GetResult();

        if (result.Succeeded)
        {
            userManager.AddToRoleAsync(regularUser, WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_User).GetAwaiter().GetResult();
        }
    }

    // Seed basketball tournament data
    var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    SeedBasketballTournament.Initialize(dbContext);
}

// Cấu hình pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

// Đảm bảo gọi Middleware Authentication trước Authorization
app.UseAuthentication();
app.UseAuthorization();

app.MapHub<MatchHub>("/matchHub");

// Ánh xạ Route cho Controllers
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Ánh xạ các Razor Pages (các trang Identity, ví dụ: đăng nhập, đăng ký)
app.MapRazorPages();

app.Run();
