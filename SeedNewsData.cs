using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using WebQuanLyGiaiDau_NhomTD.Models;
using Microsoft.EntityFrameworkCore.Infrastructure;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class SeedNewsData
    {
        public static void Initialize(ApplicationDbContext context)
        {
            // Đảm bảo cơ sở dữ liệu đã được tạo
            context.Database.EnsureCreated();

            // Tạo bảng News nếu chưa tồn tại
            try
            {
                // Kiểm tra xem bảng News đã tồn tại chưa
                bool tableExists = false;
                try
                {
                    // Thử truy vấn bảng News
                    var newsItem = context.News.OrderBy(n => n.NewsId).FirstOrDefault();
                    tableExists = true;
                }
                catch
                {
                    // Bảng chưa tồn tại
                    tableExists = false;
                }

                // Nếu bảng chưa tồn tại, tạo bảng
                if (!tableExists)
                {
                    context.Database.ExecuteSqlRaw(@"
                        CREATE TABLE [News] (
                            [NewsId] int NOT NULL IDENTITY,
                            [Title] nvarchar(200) NOT NULL,
                            [Summary] nvarchar(500) NOT NULL,
                            [Content] nvarchar(max) NOT NULL,
                            [ImageUrl] nvarchar(max) NULL,
                            [PublishDate] datetime2 NOT NULL,
                            [Author] nvarchar(max) NULL,
                            [ViewCount] int NOT NULL,
                            [Category] nvarchar(max) NULL,
                            [IsVisible] bit NOT NULL,
                            [IsFeatured] bit NOT NULL,
                            [SportsId] int NULL,
                            CONSTRAINT [PK_News] PRIMARY KEY ([NewsId]),
                            CONSTRAINT [FK_News_Sports_SportsId] FOREIGN KEY ([SportsId]) REFERENCES [Sports] ([Id]) ON DELETE NO ACTION
                        );
                    ");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi tạo bảng News: {ex.Message}");
            }

            // Kiểm tra xem đã có tin tức nào chưa
            try
            {
                if (context.News.Any())
                {
                    return; // Đã có dữ liệu, không cần seed
                }
            }
            catch
            {
                // Nếu không thể truy vấn, có thể bảng chưa được tạo đúng
                Console.WriteLine("Không thể kiểm tra dữ liệu tin tức.");
                return;
            }

            // Lấy ID của môn thể thao bóng rổ
            var basketball = context.Sports.OrderBy(s => s.Id).FirstOrDefault(s => s.Name == "Bóng Rổ");
            int? basketballId = basketball?.Id;

            // Tạo dữ liệu mẫu cho tin tức
            var news = new News[]
            {
                new News
                {
                    Title = "Giải bóng rổ 3v3 mùa xuân 2024 sắp khởi tranh",
                    Summary = "Giải đấu bóng rổ 3v3 mùa xuân 2024 sẽ chính thức khởi tranh vào ngày 15/5/2024 với sự tham gia của 6 đội bóng hàng đầu.",
                    Content = "<p>Giải đấu bóng rổ 3v3 mùa xuân 2024 sẽ chính thức khởi tranh vào ngày 15/5/2024 với sự tham gia của 6 đội bóng hàng đầu. Đây là giải đấu thường niên được tổ chức nhằm thúc đẩy phong trào bóng rổ 3v3 trong cộng đồng.</p><p>Các đội tham gia sẽ thi đấu theo thể thức vòng tròn một lượt, sau đó là vòng bán kết và chung kết. Đội vô địch sẽ nhận được cúp và phần thưởng giá trị.</p><p>Giải đấu năm nay có sự tham gia của các đội: Saigon Heat, Hanoi Buffaloes, Danang Dragons, Cantho Catfish, HCMC Wings và Thang Long Warriors.</p>",
                    ImageUrl = "/images/news/basketball-tournament.jpg",
                    PublishDate = DateTime.Now.AddDays(-5),
                    Author = "Admin",
                    ViewCount = 120,
                    Category = "Giải đấu",
                    IsVisible = true,
                    IsFeatured = true,
                    SportsId = basketballId
                },
                new News
                {
                    Title = "Kỹ thuật ném rổ cơ bản cho người mới chơi bóng rổ",
                    Summary = "Hướng dẫn chi tiết các kỹ thuật ném rổ cơ bản dành cho người mới bắt đầu chơi bóng rổ.",
                    Content = "<p>Bóng rổ là môn thể thao đòi hỏi sự kết hợp giữa kỹ thuật, sức mạnh và sự nhanh nhẹn. Đối với người mới bắt đầu, việc nắm vững các kỹ thuật ném rổ cơ bản là rất quan trọng.</p><p><strong>1. Kỹ thuật ném rổ một tay:</strong> Đây là kỹ thuật phổ biến nhất. Bạn cần giữ bóng bằng một tay, tay còn lại hỗ trợ, khuỷu tay tạo góc 90 độ, và ném bóng theo đường cong.</p><p><strong>2. Kỹ thuật ném rổ hai tay:</strong> Phù hợp cho người mới bắt đầu hoặc khi ném từ khoảng cách xa. Hai tay cầm bóng ngang ngực, đẩy bóng lên theo đường cong.</p><p><strong>3. Kỹ thuật ném rổ móc:</strong> Sử dụng khi có đối thủ phòng ngự trước mặt. Bạn cầm bóng một tay và ném theo đường cong từ bên hông.</p><p>Để nâng cao kỹ năng, bạn nên tập luyện đều đặn và tìm hiểu thêm các kỹ thuật nâng cao khi đã thành thạo các kỹ thuật cơ bản.</p>",
                    ImageUrl = "/images/news/basketball-shooting.jpg",
                    PublishDate = DateTime.Now.AddDays(-3),
                    Author = "Coach Mike",
                    ViewCount = 85,
                    Category = "Kỹ thuật",
                    IsVisible = true,
                    IsFeatured = false,
                    SportsId = basketballId
                },
                new News
                {
                    Title = "Top 5 cầu thủ xuất sắc nhất giải bóng rổ 3v3 mùa thu 2023",
                    Summary = "Điểm qua 5 cầu thủ có màn trình diễn ấn tượng nhất tại giải bóng rổ 3v3 mùa thu 2023 vừa qua.",
                    Content = "<p>Giải bóng rổ 3v3 mùa thu 2023 đã khép lại với nhiều màn trình diễn ấn tượng. Dưới đây là top 5 cầu thủ xuất sắc nhất giải đấu:</p><p><strong>1. Nguyễn Văn A (Saigon Heat):</strong> Với trung bình 15 điểm/trận, anh là chân sút hàng đầu giải đấu và đóng góp lớn vào chức vô địch của đội.</p><p><strong>2. Trần Văn B (Hanoi Buffaloes):</strong> Tuy đội chỉ về nhì, nhưng anh là cầu thủ toàn diện nhất với khả năng ghi điểm, kiến tạo và phòng ngự đều tốt.</p><p><strong>3. Lê Văn C (Danang Dragons):</strong> Tân binh ấn tượng với khả năng ném 3 điểm chuẩn xác, đạt tỷ lệ 45% trong giải.</p><p><strong>4. Phạm Văn D (Cantho Catfish):</strong> Cầu thủ phòng ngự xuất sắc nhất giải với trung bình 5 chắn bóng/trận.</p><p><strong>5. Hoàng Văn E (HCMC Wings):</strong> Đội trưởng kinh nghiệm với khả năng lãnh đạo tuyệt vời, giúp đội vào đến bán kết dù gặp nhiều khó khăn.</p>",
                    ImageUrl = "/images/news/top-players.jpg",
                    PublishDate = DateTime.Now.AddDays(-7),
                    Author = "Sports Analyst",
                    ViewCount = 210,
                    Category = "Cầu thủ",
                    IsVisible = true,
                    IsFeatured = true,
                    SportsId = basketballId
                },
                new News
                {
                    Title = "Luật thi đấu bóng rổ 3v3 - Những điều cần biết",
                    Summary = "Tìm hiểu về luật thi đấu bóng rổ 3v3, khác biệt so với bóng rổ 5v5 truyền thống.",
                    Content = "<p>Bóng rổ 3v3 là biến thể của bóng rổ truyền thống, với một số luật khác biệt quan trọng:</p><p><strong>1. Sân đấu:</strong> Sân đấu 3v3 nhỏ hơn, chỉ sử dụng nửa sân của bóng rổ truyền thống.</p><p><strong>2. Thời gian:</strong> Trận đấu kéo dài 10 phút hoặc đến khi một đội đạt 21 điểm, tùy điều kiện nào đến trước.</p><p><strong>3. Tính điểm:</strong> Ném rổ trong vạch 2 điểm được tính 1 điểm, ngoài vạch được tính 2 điểm.</p><p><strong>4. Sau khi đối phương ghi điểm:</strong> Đội vừa thủng lưới phải đưa bóng ra ngoài vạch 2 điểm để bắt đầu tấn công.</p><p><strong>5. Thời gian tấn công:</strong> Mỗi đội có 12 giây để tấn công, ngắn hơn so với 24 giây trong bóng rổ truyền thống.</p><p><strong>6. Không có hiệp phụ:</strong> Nếu hòa sau thời gian chính thức, đội nào ghi được 2 điểm trước sẽ thắng.</p><p>Hiểu rõ luật chơi sẽ giúp bạn tận hưởng và tham gia môn thể thao này một cách hiệu quả hơn.</p>",
                    ImageUrl = "/images/news/3v3-rules.jpg",
                    PublishDate = DateTime.Now.AddDays(-10),
                    Author = "Referee John",
                    ViewCount = 150,
                    Category = "Luật chơi",
                    IsVisible = true,
                    IsFeatured = false,
                    SportsId = basketballId
                },
                new News
                {
                    Title = "Lịch thi đấu giải bóng rổ 3v3 mùa xuân 2024",
                    Summary = "Thông tin chi tiết về lịch thi đấu của giải bóng rổ 3v3 mùa xuân 2024 sắp diễn ra.",
                    Content = "<p>Giải bóng rổ 3v3 mùa xuân 2024 sẽ diễn ra từ ngày 15/5/2024 đến 30/5/2024. Dưới đây là lịch thi đấu chi tiết:</p><p><strong>Ngày 15/5/2024:</strong><br>- 15:00: Saigon Heat vs Hanoi Buffaloes<br>- 15:30: Danang Dragons vs Cantho Catfish<br>- 16:00: HCMC Wings vs Thang Long Warriors</p><p><strong>Ngày 18/5/2024:</strong><br>- 15:00: Hanoi Buffaloes vs Danang Dragons<br>- 15:30: Cantho Catfish vs HCMC Wings<br>- 16:00: Thang Long Warriors vs Saigon Heat</p><p><strong>Ngày 21/5/2024:</strong><br>- 15:00: Saigon Heat vs Cantho Catfish<br>- 15:30: Hanoi Buffaloes vs HCMC Wings<br>- 16:00: Danang Dragons vs Thang Long Warriors</p><p><strong>Ngày 24/5/2024:</strong><br>- 15:00: Bán kết 1<br>- 15:30: Bán kết 2</p><p><strong>Ngày 30/5/2024:</strong><br>- 15:00: Tranh hạng 3<br>- 15:30: Chung kết</p><p>Tất cả các trận đấu sẽ diễn ra tại Nhà thi đấu Thể thao Phú Thọ, TP.HCM. Vé xem trận đấu có thể mua trực tuyến hoặc tại quầy vé của nhà thi đấu.</p>",
                    ImageUrl = "/images/news/schedule.jpg",
                    PublishDate = DateTime.Now.AddDays(-2),
                    Author = "Admin",
                    ViewCount = 180,
                    Category = "Lịch thi đấu",
                    IsVisible = true,
                    IsFeatured = true,
                    SportsId = basketballId
                }
            };

            // Thêm dữ liệu vào cơ sở dữ liệu
            context.News.AddRange(news);
            context.SaveChanges();

            Console.WriteLine("Đã thêm dữ liệu mẫu cho tin tức thành công!");
        }
    }
}
