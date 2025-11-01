using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Controllers
{
    [Route("api/rules")]
    [ApiController]
    public class RulesApiController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public RulesApiController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/rules/{tournamentId}
        [HttpGet("{tournamentId}")]
        public async Task<ActionResult<object>> GetTournamentRules(int tournamentId)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return NotFound(new { message = "Không tìm thấy giải đấu" });
                }

                // Generate default rules based on sport type
                var rules = GenerateRulesForTournament(tournament);

                return Ok(new
                {
                    success = true,
                    data = new
                    {
                        tournamentId = tournament.Id,
                        tournamentName = tournament.Name,
                        sportName = tournament.Sports?.Name ?? "Unknown",
                        rules = rules
                    }
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi tải luật giải đấu",
                    error = ex.Message
                });
            }
        }

        // GET: api/rules/{tournamentId}/category/{category}
        [HttpGet("{tournamentId}/category/{category}")]
        public async Task<ActionResult<object>> GetRulesByCategory(int tournamentId, string category)
        {
            try
            {
                var tournament = await _context.Tournaments
                    .Include(t => t.Sports)
                    .FirstOrDefaultAsync(t => t.Id == tournamentId);

                if (tournament == null)
                {
                    return NotFound(new { message = "Không tìm thấy giải đấu" });
                }

                var allRules = GenerateRulesForTournament(tournament);
                var categoryRules = allRules.FirstOrDefault(r => r.Category.ToLower() == category.ToLower());

                if (categoryRules == null)
                {
                    return NotFound(new { message = $"Không tìm thấy danh mục '{category}'" });
                }

                return Ok(new
                {
                    success = true,
                    data = categoryRules
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    success = false,
                    message = "Lỗi khi tải luật theo danh mục",
                    error = ex.Message
                });
            }
        }

        private List<RuleCategory> GenerateRulesForTournament(Tournament tournament)
        {
            var sportName = tournament.Sports?.Name ?? "Unknown";
            var isSoccer = sportName.Contains("Bóng đá", StringComparison.OrdinalIgnoreCase) ||
                          sportName.Contains("Football", StringComparison.OrdinalIgnoreCase);

            return new List<RuleCategory>
            {
                new RuleCategory
                {
                    Category = "General",
                    CategoryName = "Quy định chung",
                    Icon = "info",
                    Description = "Các quy định cơ bản của giải đấu",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 1,
                            Title = "Tư cách tham dự",
                            Content = isSoccer
                                ? "- Tất cả các đội đăng ký phải có đủ tối thiểu 11 cầu thủ chính và 5 cầu thủ dự bị\n- Mỗi đội phải có ban huấn luyện hợp lệ\n- Đội trưởng phải từ 18 tuổi trở lên\n- Mỗi đội chỉ được đăng ký tối đa 23 cầu thủ"
                                : "- Tất cả các đội đăng ký phải đáp ứng đủ yêu cầu về số lượng thành viên\n- Mỗi đội phải có ban huấn luyện hợp lệ\n- Đội trưởng phải từ 18 tuổi trở lên",
                            OrderIndex = 1,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 2,
                            Title = "Thời gian thi đấu",
                            Content = isSoccer
                                ? "- Mỗi trận đấu gồm 2 hiệp, mỗi hiệp 45 phút\n- Giữa 2 hiệp nghỉ 15 phút\n- Thời gian bù giờ do trọng tài quyết định\n- Trường hợp hòa (vòng loại trực tiếp): phạt đền 11m"
                                : "- Thời gian thi đấu theo quy định của môn thể thao\n- Thời gian nghỉ giữa các hiệp\n- Quy định về bù giờ và gia hạn",
                            OrderIndex = 2,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 3,
                            Title = "Trang phục thi đấu",
                            Content = "- Tất cả cầu thủ phải mặc đồng phục của đội\n- Số áo phải rõ ràng, không trùng lặp\n- Phải đeo bảo hộ ống đồng theo quy định\n- Không được đeo đồ trang sức khi thi đấu",
                            OrderIndex = 3,
                            IsImportant = false
                        },
                        new Rule
                        {
                            Id = 4,
                            Title = "Thay người",
                            Content = isSoccer
                                ? "- Mỗi đội được thay tối đa 5 cầu thủ trong 1 trận\n- Thay người chỉ được thực hiện khi bóng chết và có sự cho phép của trọng tài\n- Cầu thủ đã bị thay ra không được vào lại"
                                : "- Quy định về số lượng thay người theo môn thể thao\n- Thời điểm được phép thay người\n- Thủ tục thay người",
                            OrderIndex = 4,
                            IsImportant = false
                        }
                    }
                },
                new RuleCategory
                {
                    Category = "Scoring",
                    CategoryName = "Tính điểm",
                    Icon = "score",
                    Description = "Quy định về cách tính điểm và xếp hạng",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 5,
                            Title = "Điểm số vòng bảng",
                            Content = "- Thắng: 3 điểm\n- Hòa: 1 điểm\n- Thua: 0 điểm\n- Bỏ cuộc: 0 điểm và bị xử thua 0-3",
                            OrderIndex = 1,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 6,
                            Title = "Xếp hạng",
                            Content = "Thứ tự ưu tiên xếp hạng:\n1. Tổng số điểm\n2. Hiệu số bàn thắng\n3. Tổng số bàn thắng\n4. Đối kháng trực tiếp (nếu 2 đội)\n5. Bốc thăm",
                            OrderIndex = 2,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 7,
                            Title = "Ghi bàn",
                            Content = isSoccer
                                ? "- Bàn thắng được công nhận khi bóng hoàn toàn vượt qua vạch gôn\n- Bàn thắng từ penalty: 1 điểm\n- Không có bàn thắng vàng hay bạc\n- Own goal (phản lưới) được tính cho đối phương"
                                : "- Quy định về cách tính điểm/bàn thắng\n- Các trường hợp đặc biệt\n- Xác nhận điểm số",
                            OrderIndex = 3,
                            IsImportant = false
                        },
                        new Rule
                        {
                            Id = 8,
                            Title = "Phạt đền (Penalty)",
                            Content = isSoccer
                                ? "- Vị trí: Cách gôn 11m (penalty spot)\n- Thủ môn phải đứng trên vạch gôn\n- Cầu thủ sút không được chạm bóng 2 lần liên tiếp\n- Các cầu thủ khác phải đứng ngoài vòng cấm địa"
                                : "- Quy định về phạt đền theo môn thể thao\n- Vị trí và cách thực hiện\n- Xử lý các tình huống đặc biệt",
                            OrderIndex = 4,
                            IsImportant = false
                        }
                    }
                },
                new RuleCategory
                {
                    Category = "Penalties",
                    CategoryName = "Xử phạt",
                    Icon = "warning",
                    Description = "Quy định về thẻ phạt và xử lý vi phạm",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 9,
                            Title = "Thẻ vàng",
                            Content = "Các hành vi nhận thẻ vàng:\n- Phản ứng không đúng mực với quyết định\n- Liên tục vi phạm luật thi đấu\n- Cản trở việc tái lập thi đấu\n- Vào/rời sân không xin phép\n- Hành vi phi thể thao",
                            OrderIndex = 1,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 10,
                            Title = "Thẻ đỏ",
                            Content = "Các hành vi nhận thẻ đỏ trực tiếp:\n- Phạm lỗi nghiêm trọng\n- Hành vi bạo lực\n- Nhổ nước bọt vào người khác\n- Cản phá bàn thắng bằng tay\n- Cản phá cơ hội ghi bàn rõ ràng\n- Ngôn ngữ/cử chỉ xúc phạm",
                            OrderIndex = 2,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 11,
                            Title = "Tích lũy thẻ",
                            Content = "- 2 thẻ vàng trong 1 trận = 1 thẻ đỏ (đuổi khỏi sân)\n- 3 thẻ vàng tích lũy: Nghỉ 1 trận\n- 5 thẻ vàng tích lũy: Nghỉ 2 trận\n- Thẻ đỏ: Nghỉ ít nhất 1 trận (có thể nhiều hơn tùy mức độ)",
                            OrderIndex = 3,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 12,
                            Title = "Kỷ luật đội",
                            Content = "- Đội bỏ cuộc: Bị loại khỏi giải, thua tất cả các trận 0-3\n- Vi phạm quy định về cầu thủ: Thua 0-3 và trừ điểm\n- Gây rối trật tự: Phạt tiền và có thể cấm thi đấu\n- Tiêu cực (bán độ): Tước quyền thi đấu vĩnh viễn",
                            OrderIndex = 4,
                            IsImportant = true
                        }
                    }
                },
                new RuleCategory
                {
                    Category = "Equipment",
                    CategoryName = "Trang thiết bị",
                    Icon = "sports",
                    Description = "Yêu cầu về dụng cụ và thiết bị thi đấu",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 13,
                            Title = isSoccer ? "Quả bóng" : "Dụng cụ thi đấu",
                            Content = isSoccer
                                ? "- Size 5 (chu vi 68-70cm)\n- Áp suất: 0.6 - 1.1 atm\n- Trọng lượng: 410-450g\n- Được cung cấp bởi ban tổ chức\n- Phải được trọng tài kiểm tra trước khi thi đấu"
                                : "- Dụng cụ theo tiêu chuẩn môn thể thao\n- Được cung cấp hoặc phê duyệt bởi ban tổ chức\n- Phải được kiểm tra trước khi thi đấu",
                            OrderIndex = 1,
                            IsImportant = false
                        },
                        new Rule
                        {
                            Id = 14,
                            Title = "Sân thi đấu",
                            Content = isSoccer
                                ? "- Chiều dài: 100-110m\n- Chiều rộng: 64-75m\n- Khung thành: 7.32m x 2.44m\n- Vòng cấm: Bán kính 16.5m từ điểm penalty\n- Mặt sân cỏ tự nhiên hoặc nhân tạo"
                                : "- Sân thi đấu theo tiêu chuẩn\n- Kích thước và đánh dấu rõ ràng\n- Đảm bảo an toàn cho vận động viên",
                            OrderIndex = 2,
                            IsImportant = false
                        },
                        new Rule
                        {
                            Id = 15,
                            Title = "Bảo hộ cá nhân",
                            Content = "- Ống đồng (bắt buộc)\n- Giày đinh (không đinh kim loại nhọn)\n- Băng bảo vệ (nếu cần)\n- Không được mang vật dụng nguy hiểm\n- Kính bảo hộ (nếu bác sĩ chỉ định)",
                            OrderIndex = 3,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 16,
                            Title = "Y tế",
                            Content = "- Mỗi đội phải có người phụ trách y tế\n- Túi sơ cứu bắt buộc\n- Cầu thủ bị chấn thương phải rời sân ngay\n- Không được tái xuất nếu chưa được y tế cho phép\n- Cáng và xe cứu thương dự phòng tại sân",
                            OrderIndex = 4,
                            IsImportant = true
                        }
                    }
                },
                new RuleCategory
                {
                    Category = "Registration",
                    CategoryName = "Đăng ký",
                    Icon = "assignment",
                    Description = "Quy trình đăng ký và giấy tờ cần thiết",
                    Rules = new List<Rule>
                    {
                        new Rule
                        {
                            Id = 17,
                            Title = "Hồ sơ đăng ký",
                            Content = "Mỗi đội phải nộp:\n- Đơn đăng ký đội (có xác nhận)\n- Danh sách cầu thủ (kèm ảnh 3x4)\n- CMND/CCCD photo công chứng\n- Giấy khám sức khỏe (còn hạn 6 tháng)\n- Phí đăng ký: " + (isSoccer ? "3.000.000 VNĐ" : "Theo thông báo"),
                            OrderIndex = 1,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 18,
                            Title = "Thời hạn đăng ký",
                            Content = $"- Đăng ký đội: Trước ngày {tournament.StartDate.AddDays(-14):dd/MM/yyyy}\n- Đăng ký cầu thủ: Trước ngày {tournament.StartDate.AddDays(-7):dd/MM/yyyy}\n- Bổ sung cầu thủ: Chỉ trong vòng bảng\n- Hồ sơ muộn không được chấp nhận",
                            OrderIndex = 2,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 19,
                            Title = "Điều kiện cầu thủ",
                            Content = "- Độ tuổi: Từ 16 tuổi trở lên\n- Không đang trong thời gian bị cấm thi đấu\n- Không đang thi đấu cho đội khác cùng giải\n- Có giấy tờ tùy thân hợp lệ\n- Ký cam kết tuân thủ luật giải",
                            OrderIndex = 3,
                            IsImportant = true
                        },
                        new Rule
                        {
                            Id = 20,
                            Title = "Hoàn phí",
                            Content = "- Rút lui trước 30 ngày: Hoàn 100%\n- Rút lui trước 15 ngày: Hoàn 50%\n- Rút lui trước 7 ngày: Hoàn 20%\n- Rút lui sau 7 ngày: Không hoàn\n- Bị loại do vi phạm: Không hoàn",
                            OrderIndex = 4,
                            IsImportant = false
                        }
                    }
                }
            };
        }

        // Helper classes for rule structure
        public class RuleCategory
        {
            public string Category { get; set; } = string.Empty;
            public string CategoryName { get; set; } = string.Empty;
            public string Icon { get; set; } = string.Empty;
            public string Description { get; set; } = string.Empty;
            public List<Rule> Rules { get; set; } = new List<Rule>();
        }

        public class Rule
        {
            public int Id { get; set; }
            public string Title { get; set; } = string.Empty;
            public string Content { get; set; } = string.Empty;
            public int OrderIndex { get; set; }
            public bool IsImportant { get; set; }
        }
    }
}
