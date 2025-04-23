using WebQuanLyGiaiDau_NhomTD.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using WebQuanLyGiaiDau_NhomTD.Repositories;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddIdentity<IdentityUser, IdentityRole>()
 .AddDefaultTokenProviders()
 .AddDefaultUI()
 .AddEntityFrameworkStores<ApplicationDbContext>();
builder.Services.AddRazorPages();

builder.Services.AddControllersWithViews();

builder.Services.AddScoped<ITeamRepository, EFTeamRepository>();
builder.Services.AddScoped<IPlayerRepository, EFPlayerRepository>();
// ??ng k� ApplicationDbContext v?i DI container
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));


// ??ng k� MVC (Controller + Views)


var app = builder.Build();



// C?u h�nh pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

// Map Controller (thay v� RazorPages)
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
