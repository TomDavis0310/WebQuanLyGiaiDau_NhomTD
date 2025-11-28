using WebQuanLyGiaiDau_NhomTD.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;
using WebQuanLyGiaiDau_NhomTD;
using WebQuanLyGiaiDau_NhomTD.Data.Seed;
using WebQuanLyGiaiDau_NhomTD.Middleware;
using WebQuanLyGiaiDau_NhomTD.Services.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Threading;
using WebQuanLyGiaiDau_NhomTD.Services.Interfaces;
using WebQuanLyGiaiDau_NhomTD.Services;
using WebQuanLyGiaiDau_NhomTD.Models.Email;
using WebQuanLyGiaiDau_NhomTD.Models.FileUpload;
using Microsoft.AspNetCore.Identity.UI.Services;

var builder = WebApplication.CreateBuilder(args);
// Configure Kestrel to use the PORT environment variable (for local development)
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
// Listen on all network interfaces to allow mobile app connections
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// Đăng ký ApplicationDbContext với DI container
builder.Services.AddDbContext<WebQuanLyGiaiDau_NhomTD.Models.ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))
           .ConfigureWarnings(warnings => warnings.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning)));

// Cấu hình Authentication để hỗ trợ cả Cookie (MVC) và JWT Bearer (API)
builder.Services.AddAuthentication(options =>
{
    // Đặt Cookie làm scheme mặc định cho MVC/Razor Pages
    options.DefaultScheme = IdentityConstants.ApplicationScheme;
    options.DefaultSignInScheme = IdentityConstants.ExternalScheme;
})
.AddJwtBearer(options =>
{
    // JWT Bearer chỉ dùng cho API endpoints
    options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(
            System.Text.Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"] ?? "YourSuperSecretKeyThatIsAtLeast32CharactersLongForTDSports!"))
    };
});

Console.WriteLine("✅ JWT Bearer Authentication đã được cấu hình cho API!");

// Thêm Google Authentication
var googleClientId = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_ID")
    ?? builder.Configuration["Authentication:Google:ClientId"];
var googleClientSecret = Environment.GetEnvironmentVariable("GOOGLE_CLIENT_SECRET")
    ?? builder.Configuration["Authentication:Google:ClientSecret"];

// Thêm Google Authentication (nếu có cấu hình)
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
    Console.WriteLine("⚠️  Google OAuth chưa được cấu hình - Đăng nhập bằng Google sẽ không hoạt động.");
    Console.WriteLine("   🔧 Để kích hoạt Google OAuth:");
    Console.WriteLine("   📖 Xem hướng dẫn chi tiết: GOOGLE_OAUTH_HOÀN_THIỆN.md");
    Console.WriteLine("   ⚡ Hoặc hướng dẫn nhanh: GOOGLE_OAUTH_QUICK_START.md");
    Console.WriteLine("   ✅ Bạn vẫn có thể đăng nhập bằng tài khoản email thông thường.");
}

// Đăng ký Identity với ApplicationUser (phải đặt sau cấu hình Authentication)
builder.Services.AddDefaultIdentity<WebQuanLyGiaiDau_NhomTD.Models.ApplicationUser>(options =>
{
    // Sign-in settings
    options.SignIn.RequireConfirmedAccount = false; // Set to true for production
    
    // Password settings - Enhanced security
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireUppercase = false; // Keep flexible for now
    options.Password.RequireNonAlphanumeric = false; // Keep flexible for now
    options.Password.RequiredLength = 6;
    options.Password.RequiredUniqueChars = 0;
    
    // Lockout settings - Prevent brute force attacks
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;
    
    // User settings
    options.User.RequireUniqueEmail = true;
})
.AddRoles<IdentityRole>() // Add role management
.AddEntityFrameworkStores<WebQuanLyGiaiDau_NhomTD.Models.ApplicationDbContext>();

Console.WriteLine("✅ Identity với Cookie Authentication đã được cấu hình cho MVC!");

// Đăng ký MVC và Razor Pages (cho Identity)
builder.Services.AddControllersWithViews()
    .AddJsonOptions(options =>
    {
        // Configure JSON serialization to use camelCase for API responses
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    });
builder.Services.AddRazorPages();

// Add API Explorer and Swagger for API documentation
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "Tournament Management API",
        Version = "v1",
        Description = "API for Tournament Management System"
    });
});

// Add CORS for mobile app and other clients
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowMobileApp", policy =>
    {
        policy.WithOrigins(
                "http://localhost:*",
                "http://10.0.2.2:*",  // Android Emulator
                "http://127.0.0.1:*",
                "http://192.168.*:*"   // Local network devices
            )
            .SetIsOriginAllowedToAllowWildcardSubdomains()
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
    
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Add SignalR services
builder.Services.AddSignalR();

// Add Health Checks
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ApplicationDbContext>("database", tags: new[] { "database" })
    .AddCheck<DatabaseHealthCheck>("database_detailed", tags: new[] { "database", "detailed" })
    .AddCheck<ExternalServicesHealthCheck>("external_services", tags: new[] { "external" })
    .AddCheck<ApplicationHealthCheck>("application", tags: new[] { "application" });

// Add HttpClient for Health Checks
builder.Services.AddHttpClient<ExternalServicesHealthCheck>();

// Đăng ký Configuration Settings
builder.Services.Configure<WebQuanLyGiaiDau_NhomTD.Configuration.ImageUploadSettings>(
    builder.Configuration.GetSection("ImageUpload"));
builder.Services.Configure<WebQuanLyGiaiDau_NhomTD.Configuration.MatchSettings>(
    builder.Configuration.GetSection("MatchSettings"));

// Đăng ký các services
builder.Services.AddScoped<WebQuanLyGiaiDau_NhomTD.Services.TournamentScheduleService>();
builder.Services.AddScoped<WebQuanLyGiaiDau_NhomTD.Services.IYouTubeService, WebQuanLyGiaiDau_NhomTD.Services.YouTubeService>();

// Đăng ký Image Upload và Permission Services
builder.Services.AddScoped<WebQuanLyGiaiDau_NhomTD.Services.IImageUploadService, WebQuanLyGiaiDau_NhomTD.Services.ImageUploadService>();
builder.Services.AddScoped<WebQuanLyGiaiDau_NhomTD.Services.IPermissionService, WebQuanLyGiaiDau_NhomTD.Services.PermissionService>();

// Đăng ký Email Configuration
builder.Services.Configure<EmailConfiguration>(
    builder.Configuration.GetSection("EmailSettings"));

// Đăng ký Email Services
builder.Services.AddScoped<IEmailTemplateEngine, EmailTemplateEngine>();
builder.Services.AddScoped<IEmailService, AdvancedEmailService>();
builder.Services.AddScoped<ITournamentEmailService, TournamentEmailService>();
builder.Services.AddScoped<IEmailSender, AdvancedEmailService>(); // For ASP.NET Core Identity

// Đăng ký File Upload Services
builder.Services.AddSingleton<FileUploadConfiguration>(provider =>
{
    var config = new FileUploadConfiguration();
    builder.Configuration.GetSection("FileUpload").Bind(config);
    
    // Set default allowed file types
    if (!config.AllowedExtensions.Any())
    {
        config.AllowedExtensions.AddRange(FileTypes.Images.All);
        config.AllowedExtensions.AddRange(FileTypes.Documents.All);
    }
    
    if (!config.AllowedMimeTypes.Any())
    {
        config.AllowedMimeTypes.AddRange(FileTypes.Images.MimeTypes);
        config.AllowedMimeTypes.AddRange(FileTypes.Documents.MimeTypes);
    }
    
    return config;
});

builder.Services.AddScoped<IFileStorageProvider, LocalFileStorageProvider>();
builder.Services.AddScoped<IFileUploadService, FileUploadService>();

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

        // Seed Users với nhiều tài khoản
        Console.WriteLine("Seed dữ liệu Users...");
        await SeedUsersData.SeedUsers(services);
        Console.WriteLine("Seed dữ liệu Users thành công.");

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
        Console.WriteLine("Seed dữ liệu VotingSettings...");
        SeedVotingSettings(dbContext);
        Console.WriteLine("Seed dữ liệu VotingSettings thành công.");
        Console.WriteLine("Seed dữ liệu PointsSettings...");
        SeedPointsSettings(dbContext);
        Console.WriteLine("Seed dữ liệu PointsSettings thành công.");
        Console.WriteLine("Seed dữ liệu RewardProducts...");
        SeedRewardProducts(dbContext);
        Console.WriteLine("Seed dữ liệu RewardProducts thành công.");
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
    // Use Global Exception Handler for production
    app.UseMiddleware<GlobalExceptionMiddleware>();
    app.UseHsts();
}
else
{
    // Enable Swagger in development
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Tournament Management API v1");
        c.RoutePrefix = "api-docs"; // Swagger UI will be available at /api-docs
    });
    
    // Use Global Exception Handler in development too
    app.UseMiddleware<GlobalExceptionMiddleware>();
}

app.UseHttpsRedirection();

// Configure static files with custom file provider for uploads
app.UseStaticFiles();

// Serve upload files
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(
        Path.Combine(builder.Environment.ContentRootPath, "wwwroot", "uploads")),
    RequestPath = "/uploads"
});

app.UseRouting();

// Use CORS - Must be after UseRouting and before UseAuthentication
app.UseCors("AllowAll"); // Use AllowAll for development, switch to AllowMobileApp for production

app.UseAuthentication();
app.UseAuthorization();

// Add SignalR hub mapping
app.MapHub<MatchHub>("/matchHub");

// Health Check endpoints
app.MapHealthChecks("/health", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        
        var response = new
        {
            status = report.Status.ToString(),
            totalDuration = report.TotalDuration.TotalMilliseconds,
            checks = report.Entries.Select(entry => new
            {
                name = entry.Key,
                status = entry.Value.Status.ToString(),
                duration = entry.Value.Duration.TotalMilliseconds,
                description = entry.Value.Description,
                data = entry.Value.Data,
                exception = entry.Value.Exception?.Message,
                tags = entry.Value.Tags
            })
        };
        
        await context.Response.WriteAsync(System.Text.Json.JsonSerializer.Serialize(response, new System.Text.Json.JsonSerializerOptions
        {
            PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase
        }));
    }
});

// Health Check endpoints for specific checks
app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("database")
});

app.MapHealthChecks("/health/live", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("application")
});

// Simple health check endpoint
app.MapGet("/ping", () => Results.Ok(new { 
    status = "healthy", 
    timestamp = DateTime.UtcNow,
    message = "Tournament Management System is running!" 
}));

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
        // Check if the database exists
        Console.WriteLine("Kiểm tra cơ sở dữ liệu...");
        bool dbExists = dbContext.Database.CanConnect();
        
        if (!dbExists)
        {
            Console.WriteLine("Cơ sở dữ liệu không tồn tại. Đang tạo cơ sở dữ liệu mới...");
            try
            {
                dbContext.Database.EnsureCreated();
                Console.WriteLine("Đã tạo cơ sở dữ liệu thành công.");
            }
            catch (Exception createEx)
            {
                Console.WriteLine($"Lỗi khi tạo cơ sở dữ liệu: {createEx.Message}");
                throw; // Re-throw to stop the application
            }
        }
        else
        {
            Console.WriteLine("Cơ sở dữ liệu đã tồn tại.");
        }
        
        // Apply migrations
        try
        {
            Console.WriteLine("Đang áp dụng migrations...");
            dbContext.Database.Migrate();
            Console.WriteLine("Migrations đã được áp dụng thành công.");
        }
        catch (Exception migrationEx)
        {
            Console.WriteLine($"Lỗi khi áp dụng migrations: {migrationEx.Message}");
        }
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
            // Check if Tournaments table exists before trying to alter it
            try
            {
                dbContext.Database.ExecuteSqlRaw(@"
                    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Tournaments')
                    BEGIN
                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'TournamentFormatId' AND object_id = OBJECT_ID('Tournaments'))
                        BEGIN
                            ALTER TABLE [dbo].[Tournaments]
                            ADD [TournamentFormatId] [int] NULL,
                                [MaxTeams] [int] NULL,
                                [TeamsPerGroup] [int] NULL
                        END
                    END
                ");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi cập nhật bảng Tournaments: {ex.Message}");
            }
            Console.WriteLine("Đã tạo bảng TournamentFormats và cập nhật bảng Tournaments.");
        }
        Console.WriteLine("Cấu trúc cơ sở dữ liệu đã sẵn sàng.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Lỗi khi kiểm tra cơ sở dữ liệu: {ex.ToString()}"); // Log full exception
        
        // Check if this is a connection issue
        if (ex.ToString().Contains("A network-related or instance-specific error") || 
            ex.ToString().Contains("Cannot open database") ||
            ex.ToString().Contains("Login failed"))
        {
            Console.WriteLine("Có vẻ như có vấn đề với kết nối cơ sở dữ liệu. Vui lòng kiểm tra:");
            Console.WriteLine("1. SQL Server đã được cài đặt và đang chạy");
            Console.WriteLine("2. Chuỗi kết nối trong appsettings.json là chính xác");
            Console.WriteLine("3. Người dùng Windows hiện tại có quyền truy cập SQL Server");
            Console.WriteLine("4. Cơ sở dữ liệu 'WebQuanLyGiaiDau_NhomTD' đã tồn tại hoặc người dùng có quyền tạo cơ sở dữ liệu mới");
        }
    }    
}    
Console.WriteLine("Hoàn tất cấu hình pipeline và kiểm tra DB. Sẵn sàng chạy app.Run().");

// Add shutdown protection
app.Lifetime.ApplicationStopping.Register(() => 
{
    Console.WriteLine("Application is being stopped. Reason may be:");
    Console.WriteLine("1. Manual shutdown requested");
    Console.WriteLine("2. Host environment shutdown");
    Console.WriteLine("3. Unhandled exception in the application");
});

// Add a cancellation token source to prevent immediate shutdown
var cts = new CancellationTokenSource();
Console.CancelKeyPress += (sender, e) => {
    e.Cancel = true;
    cts.Cancel();
    Console.WriteLine("Cancellation requested by user. Application will shut down.");
};

// Log that we're about to run
Console.WriteLine("Hoàn tất cấu hình pipeline và kiểm tra DB. Sẵn sàng chạy app.Run().");

// Run the application with a hosted service to keep it alive
var hostTask = app.RunAsync();

// Add a background task to periodically check that the app is still running
_ = Task.Run(async () => {
    try {
        Console.WriteLine("Starting background health check task...");
        while (!cts.Token.IsCancellationRequested)
        {
            await Task.Delay(30000, cts.Token); // Check every 30 seconds
            Console.WriteLine("Application health check: Running");
        }
    }
    catch (OperationCanceledException) {
        Console.WriteLine("Health check task was canceled.");
    }
    catch (Exception ex) {
        Console.WriteLine($"Error in health check task: {ex.Message}");
    }
});

// Wait for the app to shut down or user cancellation
try
{
    Console.WriteLine("Application is now running. Press Ctrl+C to stop.");
    await hostTask;
}
catch (Exception ex)
{
    Console.WriteLine($"Exception from host: {ex.Message}");
}
finally
{
    Console.WriteLine("Application has stopped.");
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
                    LogoUrl = $"/images/teams/{teamName.Replace(" ", "").ToLower()}.png",
                    Players = new List<Player>(),
                    Matches = new List<Match>()
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

static void SeedVotingSettings(ApplicationDbContext context)
{
    if (!context.VotingSettings.Any())
    {
        var votingSettings = new VotingSettings
        {
            AllowMatchVoting = true,
            AllowTournamentVoting = true,
            LastUpdated = DateTime.Now,
            UpdatedBy = null
        };
        context.VotingSettings.Add(votingSettings);
        context.SaveChanges();
    }
}

static void SeedPointsSettings(ApplicationDbContext context)
{
    if (!context.PointsSettings.Any())
    {
        var pointsSettings = new PointsSetting
        {
            ReadNewsPoints = 5,
            ViewTournamentPoints = 10,
            VoteTeamPoints = 15,
            VoteTournamentPoints = 20
        };
        context.PointsSettings.Add(pointsSettings);
        context.SaveChanges();
        Console.WriteLine("Đã tạo cấu hình điểm mặc định: Đọc tin +5đ, Xem giải đấu +10đ, Vote đội +15đ, Vote giải đấu +20đ");
    }
}

static void SeedRewardProducts(ApplicationDbContext context)
{
    // Update ImageUrl for existing products if they don't have one
    var imageUpdates = new Dictionary<string, string>
    {
        { "Sticker TDSports", "/image/Sticker TDSports.jpg" },
        { "Móc khóa Bóng Rổ", "/image/Móc khóa Bóng Rổ.jpg" },
        { "Băng đô thể thao", "/image/Băng đô thể thao.jpg" },
        { "Tất thể thao TDSports", "/image/Tất thể thao TDSports.jpg" },
        { "Khăn lau mồ hôi thể thao", "/image/Khăn lau mồ hôi thể thao.jpg" },
        { "Bình nước thể thao 500ml", "/image/Bình nước thể thao 500ml.jpg" },
        { "Băng quấn cổ tay", "/image/Băng quấn cổ tay.jpg" },
        { "Túi đựng giày thể thao", "/image/Túi đựng giày thể thao.jpg" },
        { "Găng tay thể thao", "/image/Găng tay thể thao.jpg" },
        { "Áo thun thể thao TDSports", "/image/Áo thun thể thao TDSports.jpg" },
        { "Bình nước thể thao 1L", "/image/Bình nước thể thao 1L.jpg" },
        { "Túi thể thao đeo chéo", "/image/Túi thể thao đeo chéo.jpg" }
    };

    int updatedCount = 0;
    foreach (var (productName, imageUrl) in imageUpdates)
    {
        var product = context.RewardProducts.FirstOrDefault(p => p.Name == productName);
        if (product != null && string.IsNullOrEmpty(product.ImageUrl))
        {
            product.ImageUrl = imageUrl;
            updatedCount++;
        }
    }
    
    if (updatedCount > 0)
    {
        context.SaveChanges();
        Console.WriteLine($"✅ Đã cập nhật hình ảnh cho {updatedCount} sản phẩm!");
    }

    if (!context.RewardProducts.Any())
    {
        var rewardProducts = new List<RewardProduct>
        {
            // Phần thưởng cấp thấp (100-500 điểm)
            new RewardProduct
            {
                Name = "Sticker TDSports",
                PointsCost = 100,
                Description = "Bộ sticker độc quyền TDSports với thiết kế thể thao năng động. Hoàn hảo để trang trí laptop, điện thoại hoặc sổ tay.",
                ImageUrl = "/image/Sticker TDSports.jpg"
            },
            new RewardProduct
            {
                Name = "Móc khóa Bóng Rổ",
                PointsCost = 150,
                Description = "Móc khóa hình quả bóng rổ mini, chất liệu cao su bền đẹp. Phụ kiện nhỏ xinh cho fan bóng rổ.",
                ImageUrl = "/image/Móc khóa Bóng Rổ.jpg"
            },
            new RewardProduct
            {
                Name = "Băng đô thể thao",
                PointsCost = 200,
                Description = "Băng đô thấm mồ hôi cao cấp, thích hợp cho mọi hoạt động thể thao. Nhiều màu sắc lựa chọn.",
                ImageUrl = "/image/Băng đô thể thao.jpg"
            },
            new RewardProduct
            {
                Name = "Tất thể thao TDSports",
                PointsCost = 250,
                Description = "Đôi tất thể thao chuyên dụng, chất liệu cotton thoáng mát, có đệm bảo vệ. Size 39-43.",
                ImageUrl = "/image/Tất thể thao TDSports.jpg"
            },
            new RewardProduct
            {
                Name = "Khăn lau mồ hôi thể thao",
                PointsCost = 300,
                Description = "Khăn lau mồ hôi microfiber siêu thấm, kích thước 30x80cm. Logo TDSports in nổi bật.",
                ImageUrl = "/image/Khăn lau mồ hôi thể thao.jpg"
            },
            new RewardProduct
            {
                Name = "Bình nước thể thao 500ml",
                PointsCost = 400,
                Description = "Bình nước nhựa cao cấp không BPA, dung tích 500ml. Thiết kế tiện lợi, dễ mang theo.",
                ImageUrl = "/image/Bình nước thể thao 500ml.jpg"
            },
            new RewardProduct
            {
                Name = "Băng quấn cổ tay",
                PointsCost = 500,
                Description = "Cặp băng quấn cổ tay thể thao, hỗ trợ và bảo vệ cổ tay khi chơi thể thao. Chất liệu co giãn tốt.",
                ImageUrl = "/image/Băng quấn cổ tay.jpg"
            },

            // Phần thưởng cấp trung (600-1500 điểm)
            new RewardProduct
            {
                Name = "Túi đựng giày thể thao",
                PointsCost = 600,
                Description = "Túi đựng giày chống nước, có ngăn thoát khí. Tiện lợi để mang giày đến sân tập.",
                ImageUrl = "/image/Túi đựng giày thể thao.jpg"
            },
            new RewardProduct
            {
                Name = "Găng tay thể thao",
                PointsCost = 700,
                Description = "Găng tay tập gym và thể thao cao cấp, chống trượt, bảo vệ bàn tay. Size M, L, XL.",
                ImageUrl = "/image/Găng tay thể thao.jpg"
            },
            new RewardProduct
            {
                Name = "Áo thun thể thao TDSports",
                PointsCost = 800,
                Description = "Áo thun thể thao vải DRI-FIT, thoáng mát và nhanh khô. Logo TDSports độc quyền. Size S-XXL.",
                ImageUrl = "/image/Áo thun thể thao TDSports.jpg"
            },
            new RewardProduct
            {
                Name = "Bình nước thể thao 1L",
                PointsCost = 900,
                Description = "Bình nước Inox giữ nhiệt, dung tích 1 lít. Giữ lạnh 24h, giữ nóng 12h. Thiết kế cao cấp.",
                ImageUrl = "/image/Bình nước thể thao 1L.jpg"
            },
            new RewardProduct
            {
                Name = "Túi thể thao đeo chéo",
                PointsCost = 1000,
                Description = "Túi đeo chéo chống nước, nhiều ngăn tiện dụng. Phù hợp đựng đồ tập gym hoặc chạy bộ.",
                ImageUrl = "/image/Túi thể thao đeo chéo.jpg"
            },
            new RewardProduct
            {
                Name = "Dây nhảy thể thao Pro",
                PointsCost = 1200,
                Description = "Dây nhảy có đếm số và đếm calorie, tay cầm foam êm ái. Dây cáp thép bền bỉ, điều chỉnh được chiều dài."
            },
            new RewardProduct
            {
                Name = "Quần short thể thao",
                PointsCost = 1500,
                Description = "Quần short thể thao vải DRI-FIT, có túi khóa an toàn. Thích hợp tập luyện và thi đấu. Size S-XXL."
            },

            // Phần thưởng cấp cao (2000-5000 điểm)
            new RewardProduct
            {
                Name = "Ba lô thể thao TDSports",
                PointsCost = 2000,
                Description = "Ba lô thể thao cao cấp, chống nước, nhiều ngăn tiện dụng. Ngăn laptop 15 inch, ngăn giày riêng biệt."
            },
            new RewardProduct
            {
                Name = "Bộ quần áo thể thao",
                PointsCost = 2500,
                Description = "Set áo + quần thể thao DRI-FIT cao cấp. Thiết kế năng động, nhiều màu lựa chọn. Size S-XXL."
            },
            new RewardProduct
            {
                Name = "Giày thể thao TDSports",
                PointsCost = 3000,
                Description = "Giày thể thao đa năng, đế êm ái, bám tốt. Phù hợp chơi bóng rổ, chạy bộ và gym. Size 39-44."
            },
            new RewardProduct
            {
                Name = "Vé xem trận đấu VIP",
                PointsCost = 3500,
                Description = "Vé xem trận đấu bóng rổ khu vực VIP (2 vé). Bao gồm đồ uống và snack. Áp dụng cho các trận đấu trong mùa giải."
            },
            new RewardProduct
            {
                Name = "Quả bóng rổ Spalding chính hãng",
                PointsCost = 4000,
                Description = "Quả bóng rổ Spalding size 7 chính hãng. Chất liệu da composite cao cấp, bám tốt, độ bền cao."
            },
            new RewardProduct
            {
                Name = "Áo thi đấu có chữ ký cầu thủ",
                PointsCost = 5000,
                Description = "Áo thi đấu chính thức có chữ ký của cầu thủ nổi tiếng VBA. Phiên bản giới hạn, có chứng nhận."
            },

            // Phần thưởng đặc biệt (6000+ điểm)
            new RewardProduct
            {
                Name = "Thẻ tập gym 3 tháng",
                PointsCost = 6000,
                Description = "Thẻ tập gym 3 tháng tại các phòng gym đối tác của TDSports. Sử dụng mọi thiết bị và lớp học nhóm."
            },
            new RewardProduct
            {
                Name = "Đồng hồ thể thao thông minh",
                PointsCost = 8000,
                Description = "Đồng hồ thể thao đo nhịp tim, bước chân, calo. Kết nối Bluetooth với điện thoại. Pin 7 ngày."
            },
            new RewardProduct
            {
                Name = "Voucher mua sắm 1.000.000đ",
                PointsCost = 10000,
                Description = "Voucher mua sắm trị giá 1.000.000đ tại các cửa hàng thể thao đối tác. Áp dụng cho mọi sản phẩm."
            },
            new RewardProduct
            {
                Name = "Gặp gỡ cầu thủ VBA",
                PointsCost = 15000,
                Description = "Cơ hội gặp gỡ và chụp ảnh cùng cầu thủ VBA yêu thích. Bao gồm ăn trưa và quà tặng đặc biệt."
            },
            new RewardProduct
            {
                Name = "Vé mùa giải VIP trọn gói",
                PointsCost = 20000,
                Description = "Vé xem toàn bộ mùa giải VBA tại khu vực VIP (2 vé). Bao gồm đồ ăn, đồ uống và áo đội miễn phí."
            }
        };

        context.RewardProducts.AddRange(rewardProducts);
        context.SaveChanges();
        Console.WriteLine($"Đã thêm {rewardProducts.Count} sản phẩm đổi điểm vào cơ sở dữ liệu.");
    }
}
