using WebQuanLyGiaiDau_NhomTD.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;
using WebQuanLyGiaiDau_NhomTD;

// Define the seeding method here so it's accessible within the try block if needed as a local function,
// or keep it outside if it's cleaner. For this change, keeping its definition at the end is fine.

try
{
    var builder = WebApplication.CreateBuilder(args);

    // Đăng ký ApplicationDbContext với DI container
    builder.Services.AddDbContext<WebQuanLyGiaiDau_NhomTD.Models.ApplicationDbContext>(options =>
        options.UseSqlServer(builder.Configuration.GetConnectionString("ApplicationDbContextConnection")));

    // Đăng ký Identity với ApplicationUser thay vì IdentityUser
    builder.Services.AddDefaultIdentity<WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser>(options =>
    {
        options.SignIn.RequireConfirmedAccount = false;
    })
    .AddRoles<IdentityRole>() // Add role management
    .AddEntityFrameworkStores<WebQuanLyGiaiDau_NhomTD.Models.ApplicationDbContext>();

    // Thêm Google Authentication
    var googleClientId = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_ID")
        ?? builder.Configuration["Authentication:Google:ClientId"];
    var googleClientSecret = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_SECRET")
        ?? builder.Configuration["Authentication:Google:ClientSecret"];

    // Only add Google authentication if credentials are properly configured
    if (!string.IsNullOrEmpty(googleClientId) &&
        !string.IsNullOrEmpty(googleClientSecret) &&
        googleClientId != "YOUR_GOOGLE_CLIENT_ID_HERE" &&
        googleClientSecret != "YOUR_GOOGLE_CLIENT_SECRET_HERE")
    {
        builder.Services.AddAuthentication()
            .AddGoogle(googleOptions =>
            {
                googleOptions.ClientId = googleClientId;
                googleOptions.ClientSecret = googleClientSecret;
                googleOptions.CallbackPath = "/signin-google";
            });

        Console.WriteLine("✅ Google OAuth đã được cấu hình thành công!");
    }
    else
    {
        Console.WriteLine("⚠️  Google OAuth chưa được cấu hình. Vui lòng xem hướng dẫn trong GOOGLE_OAUTH_SETUP.md");
    }

    // Đăng ký MVC và Razor Pages (cho Identity)
    builder.Services.AddControllersWithViews();
    builder.Services.AddRazorPages();

    // Đăng ký các services
    builder.Services.AddScoped<WebQuanLyGiaiDau_NhomTD.Services.TournamentScheduleService>();
    builder.Services.AddScoped<WebQuanLyGiaiDau_NhomTD.Services.IYouTubeService, WebQuanLyGiaiDau_NhomTD.Services.YouTubeService>();
    builder.Services.AddScoped<WebQuanLyGiaiDau_NhomTD.Services.ITournamentEmailService, WebQuanLyGiaiDau_NhomTD.Services.TournamentEmailService>();

    // Add authorization policies
    builder.Services.AddAuthorization(options =>
    {
        options.AddPolicy("AdminOnly", policy => policy.RequireRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin));
        // Removed UserOnly policy - all authenticated users have same access
    });

    var app = builder.Build();

    // Create admin user and seed data
    using (var scope = app.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        // This inner try-catch is for seeding specific errors
        try
        {
            var userManager = services.GetRequiredService<UserManager<WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser>>();
            var roleManager = services.GetRequiredService<RoleManager<IdentityRole>>();

            if (!await roleManager.RoleExistsAsync(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin))
            {
                await roleManager.CreateAsync(new IdentityRole(WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin));
            }

            string adminEmail = "admin@example.com";
            string adminPassword = "Admin123!";
            if (await userManager.FindByEmailAsync(adminEmail) == null)
            {
                var adminUser = new WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser
                {
                    UserName = adminEmail, Email = adminEmail, EmailConfirmed = true, FullName = "Admin User"
                };
                var result = await userManager.CreateAsync(adminUser, adminPassword);
                if (result.Succeeded)
                {
                    await userManager.AddToRoleAsync(adminUser, WebQuanLyGiaiDau_NhomTD.Models.UserModel.SD.Role_Admin);
                }
                else
                {
                    Console.WriteLine($"Lỗi khi tạo admin user: {string.Join(", ", result.Errors.Select(e => e.Description))}");
                }
            }

            var dbContext = services.GetRequiredService<ApplicationDbContext>();
            Console.WriteLine("Bắt đầu quá trình seed dữ liệu...");
            Console.WriteLine("Seed dữ liệu TournamentFormats...");
            await SeedTournamentFormatData.SeedTournamentFormats(services);
            Console.WriteLine("Seed dữ liệu TournamentFormats thành công.");
            Console.WriteLine("Seed dữ liệu MissingTablesData...");
            SeedMissingTablesData.Initialize(dbContext);
            Console.WriteLine("Seed dữ liệu MissingTablesData thành công.");
            Console.WriteLine("Seed dữ liệu TwoBasketballTournaments...");
            SeedTwoBasketballTournaments(dbContext); // Synchronous
            Console.WriteLine("Seed dữ liệu TwoBasketballTournaments thành công.");
            Console.WriteLine("Seed dữ liệu Basketball5v5Data...");
            await SeedBasketball5v5Data.SeedBasketball5v5Tournaments(services);
            Console.WriteLine("Seed dữ liệu Basketball5v5Data thành công.");
            Console.WriteLine("Seed dữ liệu NewsData...");
            SeedNewsData.Initialize(dbContext);
            Console.WriteLine("Seed dữ liệu NewsData thành công.");
            Console.WriteLine("Quá trình seed dữ liệu hoàn tất.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"LỖI TRONG QUÁ TRÌNH KHỞI TẠO USER/ROLE HOẶC SEED DỮ LIỆU: {ex.ToString()}");
        }
    }

    // Configure the HTTP request pipeline.
    if (!app.Environment.IsDevelopment())
    {
        app.UseExceptionHandler("/Error");
        app.UseHsts();
    }

    app.UseHttpsRedirection();
    app.UseStaticFiles();
    app.UseRouting();
    app.UseAuthentication();
    app.UseAuthorization();

    app.MapControllerRoute(
        name: "default",
        pattern: "{controller=Home}/{action=Index}/{id?}");
    app.MapRazorPages();

    // Database structure check
    using (var scope = app.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        var dbContext = services.GetRequiredService<WebQuanLyGiaiDau_NhomTD.Models.ApplicationDbContext>();
        // This inner try-catch is for DB structure check specific errors
        try
        {
            dbContext.Database.EnsureCreated();
            Console.WriteLine("Kiểm tra cấu trúc cơ sở dữ liệu...");
            // ... (rest of the database check logic, including its own try-catch for TournamentFormats)
            bool tournamentFormatsTableExists = false;
            try
            {
                tournamentFormatsTableExists = dbContext.TournamentFormats.Any();
            }
            catch (Exception)
            {
                Console.WriteLine("Bảng TournamentFormats chưa tồn tại. Đang tạo bảng...");
                dbContext.Database.ExecuteSqlRaw(@"
                    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TournamentFormats')
                    BEGIN
                        CREATE TABLE [dbo].[TournamentFormats](
                            [Id] [int] IDENTITY(1,1) NOT NULL,
                            [Name] [nvarchar](max) NOT NULL,
                            [Description] [nvarchar](max) NOT NULL,
                            [ScoringRules] [nvarchar](max) NOT NULL,
                            [WinnerDetermination] [nvarchar](max) NOT NULL,
                            CONSTRAINT [PK_TournamentFormats] PRIMARY KEY CLUSTERED ([Id] ASC)
                        )
                    END
                ");
                dbContext.Database.ExecuteSqlRaw(@"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'TournamentFormatId' AND object_id = OBJECT_ID('Tournaments'))
                    BEGIN
                        ALTER TABLE [dbo].[Tournaments]
                        ADD [TournamentFormatId] [int] NULL,
                            [MaxTeams] [int] NULL,
                            [TeamsPerGroup] [int] NULL
                    END
                ");
                Console.WriteLine("Đã tạo bảng TournamentFormats và cập nhật bảng Tournaments.");
            }
            Console.WriteLine("Cấu trúc cơ sở dữ liệu đã sẵn sàng.");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Lỗi khi kiểm tra cơ sở dữ liệu: {ex.ToString()}"); // Log full exception
        }
    }

    Console.WriteLine("Hoàn tất cấu hình pipeline và kiểm tra DB. Sẵn sàng chạy app.Run().");
    app.Run();
    Console.WriteLine("App đã chạy xong (nếu app.Run() trả về)."); // Should not be reached for web apps
}
catch (Exception ex)
{
    Console.WriteLine($"CRITICAL STARTUP FAILURE (OUTERMOST CATCH): {ex.ToString()}");
    // Environment.Exit(1); // Force exit with an error code
    throw; // Rethrow to ensure dotnet watch sees the failure
}

// Method to seed two basketball tournaments (definition remains outside)
static void SeedTwoBasketballTournaments(ApplicationDbContext context)
{
    // Ensure the database is created
    context.Database.EnsureCreated();

    // Check if we already have basketball sport
    var basketball = context.Sports.OrderBy(s => s.Id).FirstOrDefault(s => s.Name == "Bóng Rổ");
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
        // Lấy thể thức thi đấu vòng tròn
        var roundRobinFormat = context.TournamentFormats.FirstOrDefault(f => f.Name == "Vòng tròn (Round Robin)");
        int? formatId = roundRobinFormat?.Id;

        var completedTournament = new Tournament
        {
            Name = "Giải Bóng Rổ 3v3 Mùa Xuân 2024",
            Description = "Giải đấu bóng rổ 3v3 mùa xuân 2024 đã kết thúc với sự tham gia của 6 đội mạnh nhất. Mỗi đội gồm 5 cầu thủ (3 chính thức + 2 dự bị) thi đấu theo thể thức 3v3. Mỗi trận đấu kéo dài 15 phút hoặc đến khi một đội đạt 21 điểm.",
            StartDate = DateTime.Now.AddMonths(-3), // Started 3 months ago
            EndDate = DateTime.Now.AddDays(-15),    // Ended 15 days ago
            SportsId = basketball.Id,
            ImageUrl = "/images/basketball-tournament.jpg",
            TournamentFormatId = formatId,
            MaxTeams = 6,
            TeamsPerGroup = 6,
            Location = "Nhà thi đấu Tân Bình, TP.HCM"
        };
        context.Tournaments.Add(completedTournament);
        context.SaveChanges();

        // Create teams for the completed tournament (reuse existing teams if they exist)
        var existingTeams = context.Teams.ToList();
        var teamNames = new[] { "Saigon Heat", "Hanoi Buffaloes", "Danang Dragons", "Cantho Catfish", "Thang Long Warriors", "HCMC Wings" };
        var teams = new List<Team>();

        foreach (var teamName in teamNames)
        {
            var team = existingTeams.OrderBy(t => t.TeamId).FirstOrDefault(t => t.Name == teamName);
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
                    MatchTime = new TimeSpan(15, 0, 0), // 15:00 (3 PM)
                    Location = completedTournament.Location, // Use tournament location
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
        // Lấy thể thức thi đấu vòng tròn
        var roundRobinFormat = context.TournamentFormats.FirstOrDefault(f => f.Name == "Vòng tròn (Round Robin)");
        int? formatId = roundRobinFormat?.Id;

        var openTournament = new Tournament
        {
            Name = "Giải Bóng Rổ 3v3 Mùa Thu 2024",
            Description = "Giải đấu bóng rổ 3v3 mùa thu 2024 đang mở đăng ký. Mỗi đội đăng ký 5 cầu thủ (3 chính thức + 2 dự bị), thi đấu theo thể thức 3v3. Mỗi trận đấu kéo dài 15 phút hoặc đến khi một đội đạt 21 điểm. Hãy nhanh tay đăng ký tham gia!",
            StartDate = DateTime.Now.AddMonths(1),  // Will start in 1 month
            EndDate = DateTime.Now.AddMonths(2),    // Will end in 2 months
            SportsId = basketball.Id,
            ImageUrl = "/images/basketball-tournament.jpg",
            TournamentFormatId = formatId,
            MaxTeams = 6,
            TeamsPerGroup = 6,
            Location = "Nhà thi đấu Hoa Lư, TP.HCM"
        };
        context.Tournaments.Add(openTournament);
        context.SaveChanges();

        // For this tournament, we don't create any matches yet since it's still in registration phase
    }

    Console.WriteLine("Two basketball tournaments seeded successfully!");
}
