using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD
{
    public static class SeedTournamentFormatData
    {
        public static async Task SeedTournamentFormats(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            try
            {
                // Kiểm tra xem bảng TournamentFormats đã tồn tại chưa
                bool tableExists = false;
                try
                {
                    // Thử truy vấn bảng TournamentFormats
                    tableExists = await context.TournamentFormats.AnyAsync();
                    Console.WriteLine("Bảng TournamentFormats đã tồn tại.");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Bảng TournamentFormats chưa tồn tại: {ex.Message}");

                    // Tạo bảng TournamentFormats bằng SQL trực tiếp
                    await context.Database.ExecuteSqlRawAsync(@"
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

                    // Thêm cột TournamentFormatId vào bảng Tournaments nếu chưa tồn tại
                    await context.Database.ExecuteSqlRawAsync(@"
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

                // Kiểm tra xem đã có dữ liệu trong bảng TournamentFormats chưa
                if (tableExists && await context.TournamentFormats.AnyAsync())
                {
                    Console.WriteLine("Dữ liệu thể thức thi đấu đã tồn tại, bỏ qua khởi tạo.");
                    return; // Đã có dữ liệu, không cần khởi tạo
                }

                await InitializeAsync(context);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi khởi tạo dữ liệu thể thức thi đấu: {ex.Message}");
            }
        }

        public static void Initialize(ApplicationDbContext context)
        {
            // Kiểm tra xem đã có dữ liệu trong bảng TournamentFormats chưa
            if (context.TournamentFormats.Any())
            {
                Console.WriteLine("Dữ liệu thể thức thi đấu đã tồn tại, bỏ qua khởi tạo.");
                return; // Đã có dữ liệu, không cần khởi tạo
            }

            // Gọi phương thức InitializeAsync nhưng chạy đồng bộ
            InitializeAsync(context).GetAwaiter().GetResult();
        }

        public static async Task InitializeAsync(ApplicationDbContext context)
        {
            // Tạo các thể thức thi đấu
            var formats = new TournamentFormat[]
            {
                new TournamentFormat
                {
                    Name = "Loại trực tiếp (Knockout)",
                    Description = "Đội thua sẽ bị loại khỏi giải đấu, đội thắng sẽ tiếp tục thi đấu ở vòng kế tiếp cho đến khi xác định được nhà vô địch.",
                    ScoringRules = "Mỗi trận đấu sẽ xác định một đội thắng và một đội thua. Không có trận hòa.",
                    WinnerDetermination = "Đội thắng sẽ tiếp tục thi đấu ở vòng kế tiếp. Đội cuối cùng còn lại sau tất cả các vòng đấu sẽ là nhà vô địch."
                },
                new TournamentFormat
                {
                    Name = "Vòng tròn (Round Robin)",
                    Description = "Mỗi đội sẽ thi đấu với tất cả các đội còn lại trong giải, đội có điểm số cao nhất sau khi kết thúc tất cả các trận đấu sẽ là nhà vô địch.",
                    ScoringRules = "Thắng: 2 điểm, Thua: 0 điểm. Trong trường hợp bóng rổ, không có trận hòa.",
                    WinnerDetermination = "Đội có tổng điểm cao nhất sẽ là nhà vô địch. Nếu có hai hoặc nhiều đội có cùng điểm số, sẽ xét đến hiệu số điểm, số điểm ghi được, và kết quả đối đầu trực tiếp."
                },
                new TournamentFormat
                {
                    Name = "Vòng bảng + Hệ thống Thụy Sĩ",
                    Description = "Các đội được chia thành các bảng đấu, thi đấu vòng tròn trong bảng. Sau đó, các đội xuất sắc nhất của mỗi bảng sẽ vào vòng đấu loại theo hệ thống Thụy Sĩ (đội thắng sẽ gặp đội thắng, đội thua sẽ gặp đội thua).",
                    ScoringRules = "Vòng bảng: Thắng: 2 điểm, Thua: 0 điểm. Vòng Thụy Sĩ: Đội thắng sẽ tiếp tục thi đấu với đội thắng khác, đội thua sẽ thi đấu với đội thua khác.",
                    WinnerDetermination = "Các đội đứng đầu mỗi bảng sẽ vào vòng Thụy Sĩ. Đội thắng ở trận chung kết của vòng Thụy Sĩ sẽ là nhà vô địch."
                },
                new TournamentFormat
                {
                    Name = "Vòng bảng",
                    Description = "Các đội được chia thành các bảng đấu, thi đấu vòng tròn trong bảng. Đội có thành tích tốt nhất trong mỗi bảng sẽ được xác định là nhà vô địch của bảng đó.",
                    ScoringRules = "Thắng: 2 điểm, Thua: 0 điểm. Trong trường hợp bóng rổ, không có trận hòa.",
                    WinnerDetermination = "Đội có tổng điểm cao nhất trong mỗi bảng sẽ là nhà vô địch của bảng đó. Nếu có hai hoặc nhiều đội có cùng điểm số, sẽ xét đến hiệu số điểm, số điểm ghi được, và kết quả đối đầu trực tiếp."
                }
            };

            // Thêm vào database
            context.TournamentFormats.AddRange(formats);
            await context.SaveChangesAsync();

            Console.WriteLine("Đã khởi tạo dữ liệu cho các thể thức thi đấu.");
        }
    }
}
