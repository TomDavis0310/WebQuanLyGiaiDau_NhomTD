using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    // Không yêu cầu đăng nhập để xem luật
    public class RulesController : Controller
    {
        private readonly ApplicationDbContext _context;

        public RulesController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: Rules
        public IActionResult Index()
        {
            // Chuyển hướng đến trang Wiki mới
            return RedirectToAction("Wiki");
        }

        // GET: Rules/Wiki
        public IActionResult Wiki()
        {
            // Tạo danh sách các mục luật bóng rổ
            var basketballRules = new List<RuleCategory>
            {
                new RuleCategory
                {
                    Id = 1,
                    Name = "Luật cơ bản",
                    Description = "Các luật cơ bản trong bóng rổ",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 1,
                            Title = "Sân đấu",
                            Content = "Sân bóng rổ tiêu chuẩn có kích thước 28m x 15m (FIBA). Vạch 3 điểm cách rổ 6.75m (FIBA) hoặc 7.24m (NBA). Sân được chia thành khu vực phòng ngự và tấn công bởi đường giữa sân. Vòng tròn giữa sân có đường kính 3.6m và được sử dụng cho việc nhảy tranh bóng."
                        },
                        new Rule
                        {
                            Id = 2,
                            Title = "Bóng",
                            Content = "Bóng rổ có chu vi 75-78cm cho nam và 72-74cm cho nữ. Trọng lượng bóng từ 567-650g cho nam và 510-567g cho nữ. Bóng phải được bơm đủ áp suất để khi thả từ độ cao 1.8m xuống sàn, bóng nảy lên đến độ cao 1.2-1.4m."
                        },
                        new Rule
                        {
                            Id = 3,
                            Title = "Đội hình",
                            Content = "Mỗi đội có 5 cầu thủ trên sân và tối đa 7 cầu thủ dự bị. Các vị trí thường gặp trong bóng rổ bao gồm: Point Guard (PG), Shooting Guard (SG), Small Forward (SF), Power Forward (PF) và Center (C). Mỗi đội phải có ít nhất 5 cầu thủ để bắt đầu trận đấu và tối thiểu 2 cầu thủ để tiếp tục trận đấu."
                        }
                    }
                },
                new RuleCategory
                {
                    Id = 2,
                    Name = "Thời gian",
                    Description = "Các luật liên quan đến thời gian thi đấu",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 4,
                            Title = "Thời gian trận đấu",
                            Content = "Trận đấu gồm 4 hiệp, mỗi hiệp 10 phút (FIBA) hoặc 12 phút (NBA). Giữa hiệp 1-2 và 3-4 có thời gian nghỉ 2 phút. Giữa hiệp 2-3 (nghỉ giữa trận) có thời gian nghỉ 15 phút. Nếu tỷ số hòa sau 4 hiệp, trận đấu sẽ được kéo dài thêm hiệp phụ 5 phút cho đến khi có đội thắng."
                        },
                        new Rule
                        {
                            Id = 5,
                            Title = "Thời gian tấn công",
                            Content = "Mỗi đội có 24 giây để tấn công và ném bóng vào rổ. Đồng hồ 24 giây sẽ được reset khi bóng chạm vành rổ hoặc khi đội phòng ngự phạm lỗi. Nếu đội tấn công không ném bóng trong 24 giây, đội phòng ngự sẽ được quyền ném biên."
                        },
                        new Rule
                        {
                            Id = 6,
                            Title = "Thời gian hết bóng",
                            Content = "Đội có 8 giây để đưa bóng qua giữa sân từ phần sân nhà. Nếu không thực hiện được, đội phòng ngự sẽ được quyền ném biên. Đồng hồ 8 giây sẽ được reset khi đội phòng ngự kiểm soát bóng hoặc khi có lỗi kỹ thuật."
                        },
                        new Rule
                        {
                            Id = 7,
                            Title = "Thời gian tạm dừng (Timeout)",
                            Content = "Mỗi đội được phép yêu cầu 2 timeout trong hiệp 1, 3 timeout trong hiệp 2, và 1 timeout trong mỗi hiệp phụ. Mỗi timeout kéo dài 1 phút. Timeout chỉ có thể được yêu cầu bởi huấn luyện viên hoặc đội trưởng khi bóng chết hoặc khi đội đó đang kiểm soát bóng."
                        },
                        new Rule
                        {
                            Id = 8,
                            Title = "Thay người",
                            Content = "Việc thay người chỉ được thực hiện khi bóng chết và đồng hồ trận đấu đã dừng. Cầu thủ thay người phải báo cáo với thư ký và chờ trọng tài cho phép vào sân. Không giới hạn số lần thay người trong một trận đấu."
                        }
                    }
                },
                new RuleCategory
                {
                    Id = 3,
                    Name = "Tính điểm",
                    Description = "Các luật về cách tính điểm",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 9,
                            Title = "Ném rổ 2 điểm",
                            Content = "Ném rổ từ bên trong vạch 3 điểm được tính 2 điểm. Bóng phải đi qua vành rổ từ trên xuống và không chạm sàn trước khi đi vào rổ. Nếu cầu thủ vô tình ném bóng vào rổ của đội mình, điểm sẽ được tính cho đội đối phương."
                        },
                        new Rule
                        {
                            Id = 10,
                            Title = "Ném rổ 3 điểm",
                            Content = "Ném rổ từ ngoài vạch 3 điểm được tính 3 điểm. Cầu thủ ném phải nhảy từ ngoài vạch 3 điểm và không được chạm vạch hoặc khu vực bên trong vạch trước khi thả bóng. Trọng tài sẽ giơ tay với 3 ngón tay để báo hiệu ném 3 điểm thành công."
                        },
                        new Rule
                        {
                            Id = 11,
                            Title = "Ném phạt",
                            Content = "Ném phạt được tính 1 điểm. Cầu thủ được đứng sau vạch ném phạt và có 5 giây để thực hiện. Cầu thủ không được bước vào khu vực ném phạt cho đến khi bóng chạm vành rổ. Số lượng ném phạt phụ thuộc vào loại lỗi và vị trí xảy ra lỗi."
                        },
                        new Rule
                        {
                            Id = 12,
                            Title = "Tính điểm và xếp hạng",
                            Content = "Trong giải đấu, đội thắng được 2 điểm, đội thua được 1 điểm, đội bỏ cuộc được 0 điểm. Thứ hạng được xác định theo tổng điểm. Nếu hai đội có cùng điểm, kết quả đối đầu trực tiếp sẽ được xem xét. Nếu vẫn bằng nhau, hiệu số điểm (điểm ghi - điểm thủng) sẽ được sử dụng."
                        }
                    }
                },
                new RuleCategory
                {
                    Id = 4,
                    Name = "Vi phạm cơ bản",
                    Description = "Các luật về vi phạm cơ bản trong bóng rổ",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 13,
                            Title = "Lỗi cá nhân",
                            Content = "Tiếp xúc bất hợp pháp với đối phương. Sau 5 lỗi cá nhân (FIBA) hoặc 6 lỗi (NBA), cầu thủ sẽ bị truất quyền thi đấu. Các loại lỗi cá nhân bao gồm: chặn, đẩy, giữ, va chạm bất hợp pháp, và cản trở di chuyển của đối phương."
                        },
                        new Rule
                        {
                            Id = 14,
                            Title = "Vi phạm di chuyển",
                            Content = "Cầu thủ không được di chuyển quá 2 bước khi đang cầm bóng mà không dribble. Sau khi dừng dribble, cầu thủ chỉ được phép xoay người quanh chân trụ mà không được nhấc chân trụ lên. Vi phạm di chuyển sẽ bị phạt bằng việc mất quyền kiểm soát bóng."
                        },
                        new Rule
                        {
                            Id = 15,
                            Title = "Vi phạm dẫn bóng kép",
                            Content = "Cầu thủ không được dribble lần thứ hai sau khi đã dừng dribble lần đầu. Nếu cầu thủ chạm bóng bằng cả hai tay cùng lúc trong quá trình dribble, đó cũng được coi là vi phạm dẫn bóng kép. Hình phạt cho vi phạm này là mất quyền kiểm soát bóng."
                        },
                        new Rule
                        {
                            Id = 16,
                            Title = "Vi phạm 3 giây",
                            Content = "Cầu thủ tấn công không được đứng trong khu vực 3 giây (khu vực giới hạn dưới rổ) quá 3 giây liên tục khi đội của họ đang kiểm soát bóng ở phần sân tấn công. Vi phạm này sẽ bị phạt bằng việc mất quyền kiểm soát bóng."
                        }
                    }
                },
                new RuleCategory
                {
                    Id = 5,
                    Name = "Vi phạm kỹ thuật",
                    Description = "Các luật về vi phạm kỹ thuật và cách xử phạt",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 17,
                            Title = "Lỗi kỹ thuật",
                            Content = "Lỗi kỹ thuật là hành vi phi thể thao không liên quan đến tiếp xúc cơ thể, như phản ứng với trọng tài, khiêu khích đối phương, trì hoãn trận đấu, hoặc bám vào vành rổ. Hình phạt cho lỗi kỹ thuật là 1 lần ném phạt cho đội đối phương và quyền kiểm soát bóng."
                        },
                        new Rule
                        {
                            Id = 18,
                            Title = "Lỗi phi thể thao",
                            Content = "Lỗi phi thể thao là tiếp xúc bất hợp pháp với đối phương khi không có ý định chơi bóng. Hình phạt cho lỗi phi thể thao là 2 lần ném phạt cho đội đối phương và quyền kiểm soát bóng. Cầu thủ phạm 2 lỗi phi thể thao trong một trận đấu sẽ bị truất quyền thi đấu."
                        },
                        new Rule
                        {
                            Id = 19,
                            Title = "Lỗi truất quyền thi đấu",
                            Content = "Lỗi truất quyền thi đấu là hành vi bạo lực hoặc phi thể thao nghiêm trọng. Cầu thủ phạm lỗi này sẽ bị truất quyền thi đấu ngay lập tức và phải rời khỏi khu vực thi đấu. Hình phạt cho lỗi này là 2 lần ném phạt cho đội đối phương và quyền kiểm soát bóng."
                        },
                        new Rule
                        {
                            Id = 20,
                            Title = "Lỗi đội",
                            Content = "Lỗi đội là tổng số lỗi cá nhân, kỹ thuật, và phi thể thao mà các cầu thủ của một đội phạm phải trong một hiệp. Sau khi một đội phạm 4 lỗi đội trong một hiệp, mỗi lỗi cá nhân tiếp theo sẽ bị phạt 2 lần ném phạt, bất kể lỗi xảy ra ở đâu."
                        }
                    }
                },
                new RuleCategory
                {
                    Id = 6,
                    Name = "Trang bị và đồng phục",
                    Description = "Quy định về trang bị và đồng phục cầu thủ",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 21,
                            Title = "Đồng phục cầu thủ",
                            Content = "Tất cả cầu thủ trong một đội phải mặc đồng phục cùng màu, cả áo và quần. Số áo phải được in rõ ràng ở cả mặt trước (tối thiểu 10cm) và mặt sau (tối thiểu 20cm). Các số được phép sử dụng là từ 0-99. Cầu thủ không được đeo trang sức hoặc các vật dụng nguy hiểm khác."
                        },
                        new Rule
                        {
                            Id = 22,
                            Title = "Giày và tất",
                            Content = "Cầu thủ phải mang giày thể thao phù hợp với bóng rổ, có đế cao su không để lại vết trên sàn. Tất phải có cùng màu chủ đạo cho tất cả cầu thủ trong đội và phải được kéo lên để nhìn thấy được."
                        },
                        new Rule
                        {
                            Id = 23,
                            Title = "Thiết bị bảo hộ",
                            Content = "Cầu thủ được phép sử dụng các thiết bị bảo hộ như băng đầu gối, kính bảo hộ, mặt nạ bảo vệ mũi, và băng tay, miễn là chúng không gây nguy hiểm cho các cầu thủ khác. Tất cả thiết bị bảo hộ phải có màu đen hoặc trùng với màu đồng phục."
                        },
                        new Rule
                        {
                            Id = 24,
                            Title = "Trang bị của đội",
                            Content = "Mỗi đội phải có ít nhất hai bộ đồng phục với màu sắc khác nhau (sáng và tối). Đội được liệt kê đầu tiên trong lịch thi đấu (đội chủ nhà) sẽ mặc màu sáng, đội còn lại (đội khách) sẽ mặc màu tối. Tuy nhiên, nếu hai đội đồng ý, họ có thể đổi màu đồng phục cho nhau."
                        }
                    }
                },
                new RuleCategory
                {
                    Id = 7,
                    Name = "Trọng tài và tín hiệu",
                    Description = "Vai trò của trọng tài và các tín hiệu tay",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 25,
                            Title = "Đội ngũ trọng tài",
                            Content = "Một trận đấu bóng rổ chính thức có 3 trọng tài: 1 trọng tài chính và 2 trọng tài phụ. Ngoài ra còn có các nhân viên bàn gồm: thư ký, trợ lý thư ký, người bấm giờ, và người điều khiển đồng hồ 24 giây. Trọng tài chính có quyền quyết định cuối cùng trong mọi tình huống tranh cãi."
                        },
                        new Rule
                        {
                            Id = 26,
                            Title = "Tín hiệu tay cho điểm số",
                            Content = "Trọng tài sử dụng các tín hiệu tay để báo hiệu điểm số: 1 ngón tay cho ném phạt, 2 ngón tay cho ném rổ 2 điểm, và 3 ngón tay (1 tay giơ lên) cho ném rổ 3 điểm. Khi ném rổ thành công, trọng tài sẽ giơ tay với số ngón tay tương ứng, sau đó hạ tay xuống để xác nhận điểm."
                        },
                        new Rule
                        {
                            Id = 27,
                            Title = "Tín hiệu tay cho lỗi",
                            Content = "Khi có lỗi xảy ra, trọng tài sẽ thổi còi và giơ nắm đấm lên để báo hiệu lỗi. Sau đó, trọng tài sẽ chỉ vào cầu thủ phạm lỗi và sử dụng các tín hiệu tay khác nhau để chỉ ra loại lỗi (đẩy, chặn, giữ, v.v.). Cuối cùng, trọng tài sẽ chỉ hướng tấn công để xác định đội được quyền kiểm soát bóng."
                        },
                        new Rule
                        {
                            Id = 28,
                            Title = "Tín hiệu tay cho vi phạm",
                            Content = "Khi có vi phạm xảy ra, trọng tài sẽ thổi còi và sử dụng các tín hiệu tay để chỉ ra loại vi phạm (di chuyển, dẫn bóng kép, 3 giây, v.v.). Sau đó, trọng tài sẽ chỉ hướng tấn công để xác định đội được quyền kiểm soát bóng. Không giống như lỗi, vi phạm không được ghi vào biên bản trận đấu."
                        }
                    }
                },
                new RuleCategory
                {
                    Id = 8,
                    Name = "Luật Bóng Rổ 3x3",
                    Description = "Các luật đặc thù của bóng rổ 3x3 theo tiêu chuẩn FIBA",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 29,
                            Title = "Sân đấu 3x3",
                            Content = "Sân đấu bóng rổ 3x3 có kích thước 15m x 11m, chỉ sử dụng nửa sân của sân bóng rổ tiêu chuẩn. Vạch 3 điểm (trong bóng rổ 3x3 gọi là vạch 2 điểm) cách rổ 6.75m, giống như trong bóng rổ 5v5 FIBA. Khu vực giới hạn (khu vực 3 giây) cũng giống như trong bóng rổ 5v5."
                        },
                        new Rule
                        {
                            Id = 30,
                            Title = "Đội hình 3x3",
                            Content = "Mỗi đội bóng rổ 3x3 gồm 4 cầu thủ: 3 cầu thủ chính thức trên sân và 1 cầu thủ dự bị. Không có huấn luyện viên chính thức trong bóng rổ 3x3, các cầu thủ tự điều chỉnh chiến thuật. Mỗi đội phải có ít nhất 3 cầu thủ để bắt đầu trận đấu và tối thiểu 2 cầu thủ để tiếp tục trận đấu."
                        },
                        new Rule
                        {
                            Id = 31,
                            Title = "Thời gian thi đấu 3x3",
                            Content = "Trận đấu bóng rổ 3x3 gồm 1 hiệp duy nhất kéo dài 10 phút theo thời gian thi đấu thực tế (đồng hồ dừng khi bóng chết). Tuy nhiên, trận đấu sẽ kết thúc sớm nếu một đội đạt 21 điểm. Nếu tỷ số hòa sau 10 phút, trận đấu sẽ được kéo dài thêm hiệp phụ, đội nào ghi được 2 điểm trước sẽ thắng."
                        },
                        new Rule
                        {
                            Id = 32,
                            Title = "Tính điểm trong 3x3",
                            Content = "Trong bóng rổ 3x3, ném rổ từ bên trong vạch 2 điểm (tương đương vạch 3 điểm trong bóng rổ 5v5) được tính 1 điểm. Ném rổ từ ngoài vạch 2 điểm được tính 2 điểm. Ném phạt vẫn được tính 1 điểm, giống như trong bóng rổ 5v5. Đội đầu tiên đạt 21 điểm sẽ thắng, bất kể thời gian còn lại."
                        },
                        new Rule
                        {
                            Id = 33,
                            Title = "Thời gian tấn công 3x3",
                            Content = "Trong bóng rổ 3x3, mỗi đội chỉ có 12 giây để tấn công và ném bóng vào rổ, thay vì 24 giây như trong bóng rổ 5v5. Đồng hồ 12 giây sẽ được reset khi bóng chạm vành rổ hoặc khi đội phòng ngự phạm lỗi. Quy định này nhằm tạo ra nhịp độ trận đấu nhanh hơn và nhiều cơ hội ghi điểm hơn."
                        },
                        new Rule
                        {
                            Id = 34,
                            Title = "Bắt đầu trận đấu 3x3",
                            Content = "Trận đấu bóng rổ 3x3 bắt đầu bằng việc tung đồng xu, không phải nhảy tranh bóng như trong bóng rổ 5v5. Đội thắng khi tung đồng xu có thể chọn bắt đầu với bóng hoặc nhường cho đối phương. Không có sự thay đổi rổ tấn công trong suốt trận đấu, các đội tấn công cùng một rổ từ đầu đến cuối."
                        },
                        new Rule
                        {
                            Id = 35,
                            Title = "Xử lý bóng sau khi ghi điểm",
                            Content = "Sau khi một đội ghi điểm, đội thủng lưới sẽ tiếp tục với bóng từ dưới rổ. Họ phải dribble hoặc chuyền bóng ra ngoài vạch 2 điểm (vạch 3 điểm trong bóng rổ 5v5) trước khi có thể tấn công. Đội vừa ghi điểm không được phép phòng ngự trong khu vực bán nguyệt dưới rổ (no-charge semi-circle)."
                        },
                        new Rule
                        {
                            Id = 36,
                            Title = "Lỗi và ném phạt trong 3x3",
                            Content = "Trong bóng rổ 3x3, sau khi một đội phạm 6 lỗi đội, mỗi lỗi tiếp theo sẽ bị phạt 2 lần ném phạt. Lỗi khi ném rổ bên trong vạch 2 điểm được phạt 1 lần ném phạt, lỗi khi ném rổ ngoài vạch 2 điểm được phạt 2 lần ném phạt. Lỗi khi ném rổ thành công vẫn được tính điểm và thêm 1 lần ném phạt."
                        },
                        new Rule
                        {
                            Id = 37,
                            Title = "Timeout và thay người",
                            Content = "Mỗi đội chỉ có 1 timeout 30 giây trong toàn trận đấu. Timeout có thể được yêu cầu bởi bất kỳ cầu thủ nào khi bóng chết. Việc thay người có thể được thực hiện bởi bất kỳ đội nào khi bóng chết và trước khi bóng được kiểm soát. Không cần sự cho phép của trọng tài hoặc bàn thư ký để thay người."
                        },
                        new Rule
                        {
                            Id = 38,
                            Title = "Kiểm soát bóng và 'check ball'",
                            Content = "Trong bóng rổ 3x3, mỗi khi bóng chết (sau khi có vi phạm, lỗi không dẫn đến ném phạt, hoặc bóng ra ngoài), trận đấu sẽ tiếp tục với 'check ball' ở đỉnh vạch 2 điểm. Cầu thủ phòng ngự chuyền bóng cho cầu thủ tấn công, và trận đấu tiếp tục sau khi bóng được chuyền lại. Đồng hồ 12 giây được reset sau mỗi lần 'check ball'."
                        }
                    }
                }
            };

            // Tạo thông tin về sự khác biệt giữa bóng rổ 3x3 và 5x5
            var differences = new List<RuleDifference>
            {
                new RuleDifference
                {
                    Id = 1,
                    Category = "Sân đấu",
                    Rule5v5 = "Sân đấu kích thước 28m x 15m, sử dụng toàn bộ sân",
                    Rule3x3 = "Sân đấu kích thước 15m x 11m, chỉ sử dụng nửa sân của sân bóng rổ tiêu chuẩn"
                },
                new RuleDifference
                {
                    Id = 2,
                    Category = "Số lượng cầu thủ",
                    Rule5v5 = "5 cầu thủ chính và tối đa 7 cầu thủ dự bị",
                    Rule3x3 = "3 cầu thủ chính và 1 cầu thủ dự bị"
                },
                new RuleDifference
                {
                    Id = 3,
                    Category = "Thời gian trận đấu",
                    Rule5v5 = "4 hiệp, mỗi hiệp 10 phút",
                    Rule3x3 = "1 hiệp duy nhất, 10 phút hoặc đến khi một đội đạt 21 điểm"
                },
                new RuleDifference
                {
                    Id = 4,
                    Category = "Thời gian tấn công",
                    Rule5v5 = "24 giây",
                    Rule3x3 = "12 giây"
                },
                new RuleDifference
                {
                    Id = 5,
                    Category = "Tính điểm",
                    Rule5v5 = "2 điểm trong vạch, 3 điểm ngoài vạch",
                    Rule3x3 = "1 điểm trong vạch, 2 điểm ngoài vạch"
                },
                new RuleDifference
                {
                    Id = 6,
                    Category = "Bắt đầu trận đấu",
                    Rule5v5 = "Nhảy tranh bóng ở giữa sân",
                    Rule3x3 = "Tung đồng xu để quyết định đội nào bắt đầu với bóng"
                },
                new RuleDifference
                {
                    Id = 7,
                    Category = "Sau khi ghi điểm",
                    Rule5v5 = "Đội thủng lưới ném biên từ đường biên dưới",
                    Rule3x3 = "Đội thủng lưới tiếp tục với bóng từ dưới rổ, phải dribble hoặc chuyền bóng ra ngoài vạch 3 điểm trước khi tấn công"
                },
                new RuleDifference
                {
                    Id = 8,
                    Category = "Hiệp phụ",
                    Rule5v5 = "Hiệp phụ 5 phút",
                    Rule3x3 = "Đội nào ghi được 2 điểm trước sẽ thắng"
                },
                new RuleDifference
                {
                    Id = 9,
                    Category = "Lỗi đội",
                    Rule5v5 = "Sau 4 lỗi đội trong một hiệp, mỗi lỗi tiếp theo bị phạt 2 lần ném phạt",
                    Rule3x3 = "Sau 6 lỗi đội, mỗi lỗi tiếp theo bị phạt 2 lần ném phạt"
                },
                new RuleDifference
                {
                    Id = 10,
                    Category = "Timeout",
                    Rule5v5 = "Mỗi đội có 2 timeout trong hiệp 1, 3 timeout trong hiệp 2",
                    Rule3x3 = "Mỗi đội có 1 timeout 30 giây trong toàn trận đấu"
                }
            };

            // Tạo danh sách câu hỏi thường gặp (FAQ)
            var faqs = new List<FAQ>
            {
                new FAQ
                {
                    Id = 1,
                    Question = "Bóng rổ được phát minh khi nào và bởi ai?",
                    Answer = "Bóng rổ được phát minh vào tháng 12 năm 1891 bởi Dr. James Naismith, một giáo viên giáo dục thể chất tại Trường Đào tạo Quốc tế YMCA (nay là Đại học Springfield) ở Springfield, Massachusetts, Hoa Kỳ. Ban đầu, người ta sử dụng giỏ đào để làm rổ, và từ đó có tên gọi 'basketball'."
                },
                new FAQ
                {
                    Id = 2,
                    Question = "Tại sao cầu thủ bóng rổ thường cao?",
                    Answer = "Chiều cao là một lợi thế trong bóng rổ vì nó giúp cầu thủ dễ dàng ném bóng vào rổ, bắt bóng bật ra, và phòng thủ tốt hơn. Tuy nhiên, không phải tất cả cầu thủ bóng rổ đều cao. Nhiều cầu thủ thấp hơn thành công nhờ tốc độ, kỹ thuật, và khả năng xử lý bóng tốt."
                },
                new FAQ
                {
                    Id = 3,
                    Question = "Luật 3 giây trong bóng rổ là gì?",
                    Answer = "Luật 3 giây quy định rằng cầu thủ tấn công không được đứng trong khu vực giới hạn (khu vực hình chữ nhật dưới rổ) quá 3 giây liên tục khi đội của họ đang kiểm soát bóng ở phần sân tấn công. Mục đích của luật này là ngăn cầu thủ cao lớn đứng gần rổ quá lâu, tạo lợi thế không công bằng."
                },
                new FAQ
                {
                    Id = 4,
                    Question = "Sự khác biệt giữa NBA và FIBA là gì?",
                    Answer = "NBA (Hiệp hội Bóng rổ Quốc gia) và FIBA (Liên đoàn Bóng rổ Quốc tế) có một số khác biệt về luật: NBA có 4 hiệp mỗi hiệp 12 phút, trong khi FIBA có 4 hiệp mỗi hiệp 10 phút. Vạch 3 điểm của NBA xa hơn (7.24m so với 6.75m của FIBA). NBA có luật 3 giây phòng ngự, trong khi FIBA không có. Ngoài ra còn có sự khác biệt về kích thước sân, luật phạm lỗi, và các quy định khác."
                },
                new FAQ
                {
                    Id = 5,
                    Question = "Bóng rổ 3x3 có phải là môn Olympic không?",
                    Answer = "Có, bóng rổ 3x3 đã trở thành môn thể thao Olympic chính thức từ Thế vận hội Mùa hè 2020 (được tổ chức vào năm 2021 do đại dịch COVID-19). Đây là một phiên bản nhanh hơn và ngắn gọn hơn của bóng rổ truyền thống, với các luật riêng biệt được FIBA quy định."
                },
                new FAQ
                {
                    Id = 6,
                    Question = "Tại sao có luật 24 giây trong bóng rổ?",
                    Answer = "Luật 24 giây (shot clock) được đưa vào để ngăn các đội giữ bóng quá lâu mà không cố gắng ghi điểm, làm trận đấu trở nên chậm chạp và kém hấp dẫn. Luật này buộc đội tấn công phải ném bóng vào rổ trong vòng 24 giây, tạo ra nhịp độ nhanh hơn và nhiều cơ hội ghi điểm hơn."
                },
                new FAQ
                {
                    Id = 7,
                    Question = "Cầu thủ bóng rổ có được phép đeo trang sức không?",
                    Answer = "Không, cầu thủ bóng rổ không được phép đeo trang sức trong khi thi đấu, bao gồm nhẫn, vòng cổ, vòng tay, hoa tai, và các loại trang sức khác. Điều này nhằm đảm bảo an toàn cho tất cả cầu thủ, tránh gây thương tích khi va chạm."
                },
                new FAQ
                {
                    Id = 8,
                    Question = "Khi nào một cầu thủ bị truất quyền thi đấu?",
                    Answer = "Một cầu thủ bị truất quyền thi đấu khi: (1) Phạm 5 lỗi cá nhân (FIBA) hoặc 6 lỗi cá nhân (NBA); (2) Phạm 2 lỗi phi thể thao; (3) Phạm 2 lỗi kỹ thuật; (4) Phạm 1 lỗi kỹ thuật và 1 lỗi phi thể thao; hoặc (5) Phạm 1 lỗi truất quyền thi đấu (hành vi bạo lực hoặc phi thể thao nghiêm trọng)."
                },
                new FAQ
                {
                    Id = 9,
                    Question = "Làm thế nào để xác định đội nào tấn công bên nào?",
                    Answer = "Ở đầu trận đấu, việc này được quyết định bằng cách nhảy tranh bóng ở giữa sân. Sau đó, các đội sẽ đổi rổ tấn công sau hiệp 2 (giữa trận). Trong bóng rổ 3x3, đội thắng khi tung đồng xu sẽ quyết định có muốn bắt đầu với bóng hay không, và không có sự thay đổi rổ tấn công trong suốt trận đấu."
                },
                new FAQ
                {
                    Id = 10,
                    Question = "Tại sao cầu thủ bóng rổ thường vỗ tay vào bột trước khi thi đấu?",
                    Answer = "Cầu thủ bóng rổ thường sử dụng bột magnesium carbonate (chalk) hoặc nhựa thông (rosin) để làm khô mồ hôi trên tay, giúp cải thiện độ bám khi cầm và xử lý bóng. Việc vỗ tay vào bột đã trở thành một nghi thức quen thuộc của nhiều cầu thủ trước khi thi đấu hoặc thực hiện ném phạt."
                }
            };

            ViewBag.BasketballRules = basketballRules;
            ViewBag.Differences = differences;
            ViewBag.FAQs = faqs;

            return View("Wiki");
        }

        // GET: Rules/Basketball - Giữ lại để tương thích với các liên kết cũ
        public IActionResult Basketball()
        {
            // Chuyển hướng đến trang Wiki mới
            return RedirectToAction("Wiki");
        }
    }
}

