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

    // Create two basketball tournaments (one completed and one open for registration)
    SeedTwoBasketballTournaments(dbContext);

    // Seed news data
    SeedNewsData.Initialize(dbContext);
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

// Ánh xạ Route cho Controllers
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Ánh xạ các Razor Pages (các trang Identity, ví dụ: đăng nhập, đăng ký)
app.MapRazorPages();

// Tạo các bảng cần thiết
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var dbContext = services.GetRequiredService<ApplicationDbContext>();
    var createTables = new CreateTables(dbContext);
    createTables.CreateTablesAsync().Wait();
}

app.Run();

// Method to seed two basketball tournaments
void SeedTwoBasketballTournaments(ApplicationDbContext context)
{
    // Ensure the database is created
    context.Database.EnsureCreated();

    // Check if we already have basketball sport
    var basketball = context.Sports.FirstOrDefault(s => s.Name == "Bóng Rổ");
    if (basketball == null)
    {
        // Create basketball sport
        basketball = new Sports
        {
            Name = "Bóng Rổ",
            ImageUrl = "/images/basketball-icon.png"
        };
        context.Sports.Add(basketball);
        context.SaveChanges();
    }

    // 1. Create a completed basketball tournament (already ended)
    var completedTournamentExists = context.Tournaments.Any(t => t.Name == "Giải Bóng Rổ 3v3 Mùa Xuân 2024" && t.SportsId == basketball.Id);
    if (!completedTournamentExists)
    {
        var completedTournament = new Tournament
        {
            Name = "Giải Bóng Rổ 3v3 Mùa Xuân 2024",
            Description = "Giải đấu bóng rổ 3v3 mùa xuân 2024 đã kết thúc với sự tham gia của 6 đội mạnh nhất. Mỗi đội gồm 5 cầu thủ (3 chính thức + 2 dự bị) thi đấu theo thể thức 3v3. Mỗi trận đấu kéo dài 15 phút hoặc đến khi một đội đạt 21 điểm.",
            StartDate = DateTime.Now.AddMonths(-3), // Started 3 months ago
            EndDate = DateTime.Now.AddDays(-15),    // Ended 15 days ago
            SportsId = basketball.Id,
            ImageUrl = "/images/basketball-tournament.jpg"
        };
        context.Tournaments.Add(completedTournament);
        context.SaveChanges();

        // Create teams for the completed tournament (reuse existing teams if they exist)
        var existingTeams = context.Teams.ToList();
        var teamNames = new[] { "Saigon Heat", "Hanoi Buffaloes", "Danang Dragons", "Cantho Catfish", "Thang Long Warriors", "HCMC Wings" };
        var teams = new List<Team>();

        foreach (var teamName in teamNames)
        {
            var team = existingTeams.FirstOrDefault(t => t.Name == teamName);
            if (team == null)
            {
                team = new Team
                {
                    Name = teamName,
                    Coach = $"HLV của {teamName}",
                    LogoUrl = $"/images/teams/{teamName.Replace(" ", "").ToLower()}.png"
                };
                context.Teams.Add(team);
                context.SaveChanges();
            }
            teams.Add(team);
        }

        // Create matches for the completed tournament (all matches are completed)
        var matches = new List<Match>();
        var startDate = completedTournament.StartDate;

        for (int i = 0; i < teams.Count; i++)
        {
            for (int j = i + 1; j < teams.Count; j++)
            {
                var matchDate = startDate.AddDays((i * teams.Count) + j);

                var match = new Match
                {
                    TeamA = teams[i].Name,
                    TeamB = teams[j].Name,
                    MatchDate = matchDate,
                    TournamentId = completedTournament.Id
                };

                // Add scores for all matches (since tournament is completed)
                // For 3v3 basketball, scores are typically lower (15-21 points)
                var random = new Random();
                match.ScoreTeamA = random.Next(15, 22); // 3v3 basketball scores
                match.ScoreTeamB = random.Next(15, 22);

                // Đảm bảo không có trận hòa trong bóng rổ 3v3
                if (match.ScoreTeamA == match.ScoreTeamB)
                {
                    // Một đội phải thắng, không có hòa
                    if (random.Next(2) == 0)
                        match.ScoreTeamA += 1;
                    else
                        match.ScoreTeamB += 1;
                }

                matches.Add(match);
            }
        }

        context.Matches.AddRange(matches);
        context.SaveChanges();
    }

    // 2. Create a tournament that is open for registration
    var openTournamentExists = context.Tournaments.Any(t => t.Name == "Giải Bóng Rổ 3v3 Mùa Thu 2024" && t.SportsId == basketball.Id);
    if (!openTournamentExists)
    {
        var openTournament = new Tournament
        {
            Name = "Giải Bóng Rổ 3v3 Mùa Thu 2024",
            Description = "Giải đấu bóng rổ 3v3 mùa thu 2024 đang mở đăng ký. Mỗi đội đăng ký 5 cầu thủ (3 chính thức + 2 dự bị), thi đấu theo thể thức 3v3. Mỗi trận đấu kéo dài 15 phút hoặc đến khi một đội đạt 21 điểm. Hãy nhanh tay đăng ký tham gia!",
            StartDate = DateTime.Now.AddMonths(1),  // Will start in 1 month
            EndDate = DateTime.Now.AddMonths(2),    // Will end in 2 months
            SportsId = basketball.Id,
            ImageUrl = "/images/basketball-tournament.jpg"
        };
        context.Tournaments.Add(openTournament);
        context.SaveChanges();

        // For this tournament, we don't create any matches yet since it's still in registration phase
    }

    Console.WriteLine("Two basketball tournaments seeded successfully!");
}
