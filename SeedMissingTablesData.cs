﻿using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class SeedMissingTablesData
    {
        public static void Initialize(ApplicationDbContext context)
        {
            try
            {
                // Đảm bảo cơ sở dữ liệu đã được tạo
                context.Database.EnsureCreated();

                // Kiểm tra xem bảng Formats đã tồn tại chưa
                bool formatsTableExists = false;
                try
                {
                    // Sử dụng cách kiểm tra an toàn hơn
                    var result = context.Database.ExecuteSqlRaw(
                        "SELECT CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Formats') THEN 1 ELSE 0 END");
                    formatsTableExists = result > 0;

                    // Kiểm tra thêm bằng cách thử truy cập DbSet
                    try
                    {
                        var formatCount = context.Formats.Count();
                        formatsTableExists = true; // Nếu không có lỗi, bảng tồn tại
                    }
                    catch
                    {
                        // Nếu có lỗi khi truy cập DbSet, có thể bảng chưa tồn tại
                        // Nhưng chúng ta đã kiểm tra bằng SQL rồi, nên giữ nguyên kết quả
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Lỗi khi kiểm tra bảng Formats: {ex.Message}");
                    formatsTableExists = false;
                }

                // Nếu bảng chưa tồn tại, không tiếp tục
                if (!formatsTableExists)
                {
                    Console.WriteLine("Bảng Formats chưa tồn tại. Hãy chạy migration trước khi seed dữ liệu.");
                    return;
                }

                // Kiểm tra xem đã có dữ liệu trong các bảng mới chưa
                if (context.Formats.Any() || context.Stages.Any())
                {
                    return; // Đã có dữ liệu, không cần seed
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi kiểm tra dữ liệu: {ex.Message}");
                // Không tiếp tục thực hiện nếu có lỗi
                return;
            }

            // Thêm dữ liệu cho bảng Format
            var formats = new Format[]
            {
                new Format { FormatName = "Vòng tròn", Description = "Mỗi đội sẽ thi đấu với tất cả các đội khác" },
                new Format { FormatName = "Loại trực tiếp", Description = "Đội thua sẽ bị loại khỏi giải đấu" },
                new Format { FormatName = "Vòng bảng", Description = "Các đội được chia thành các bảng và thi đấu vòng tròn trong bảng" },
                new Format { FormatName = "Vòng bảng + Loại trực tiếp", Description = "Vòng bảng để xác định các đội vào vòng loại trực tiếp" }
            };
            context.Formats.AddRange(formats);
            context.SaveChanges();

            // Thêm dữ liệu cho bảng Stage
            var stages = new Stage[]
            {
                new Stage { StageName = "Vòng bảng", Description = "Giai đoạn vòng bảng" },
                new Stage { StageName = "Vòng 1/8", Description = "Vòng 1/8 loại trực tiếp" },
                new Stage { StageName = "Tứ kết", Description = "Vòng tứ kết" },
                new Stage { StageName = "Bán kết", Description = "Vòng bán kết" },
                new Stage { StageName = "Chung kết", Description = "Trận chung kết" }
            };
            context.Stages.AddRange(stages);
            context.SaveChanges();

            // Lấy dữ liệu từ các bảng hiện có
            var tournaments = context.Tournaments.OrderBy(t => t.Id).ToList();
            var basketballSport = context.Sports.OrderBy(s => s.Id).FirstOrDefault(s => s.Name == "Bóng Rổ");

            // Nếu không tìm thấy môn bóng rổ, tạo mới
            if (basketballSport == null)
            {
                basketballSport = new Sports
                {
                    Name = "Bóng Rổ",
                    ImageUrl = "/images/basketball-icon.png"
                };
                context.Sports.Add(basketballSport);
                context.SaveChanges();
            }

            if (basketballSport != null && tournaments.Any())
            {
                // Thêm dữ liệu cho bảng SportDetail
                foreach (var tournament in tournaments)
                {
                    var sportDetail = new SportDetail
                    {
                        TournamentId = tournament.Id,
                        SportId = basketballSport.Id,
                        Rules = "Áp dụng luật bóng rổ NBA",
                        MaxTeams = tournament.Name.Contains("3v3") ? 6 : 8,
                        PlayersPerTeam = tournament.Name.Contains("3v3") ? 5 : 12
                    };
                    context.SportDetails.Add(sportDetail);
                }
                context.SaveChanges();

                // Thêm dữ liệu cho bảng StageDetail
                var formatVongTron = context.Formats.OrderBy(f => f.FormatId).FirstOrDefault(f => f.FormatName == "Vòng tròn");
                var formatLoaiTrucTiep = context.Formats.OrderBy(f => f.FormatId).FirstOrDefault(f => f.FormatName == "Loại trực tiếp");
                var stageVongBang = context.Stages.OrderBy(s => s.StageId).FirstOrDefault(s => s.StageName == "Vòng bảng");
                var stageBanKet = context.Stages.OrderBy(s => s.StageId).FirstOrDefault(s => s.StageName == "Bán kết");
                var stageChungKet = context.Stages.OrderBy(s => s.StageId).FirstOrDefault(s => s.StageName == "Chung kết");

                if (formatVongTron != null && formatLoaiTrucTiep != null &&
                    stageVongBang != null && stageBanKet != null && stageChungKet != null)
                {
                    foreach (var tournament in tournaments)
                    {
                        // Vòng bảng
                        context.StageDetails.Add(new StageDetail
                        {
                            TournamentId = tournament.Id,
                            StageId = stageVongBang.StageId,
                            FormatId = formatVongTron.FormatId,
                            Order = 1,
                            StartDate = tournament.StartDate,
                            EndDate = tournament.StartDate.AddDays(7)
                        });

                        // Bán kết
                        context.StageDetails.Add(new StageDetail
                        {
                            TournamentId = tournament.Id,
                            StageId = stageBanKet.StageId,
                            FormatId = formatLoaiTrucTiep.FormatId,
                            Order = 2,
                            StartDate = tournament.StartDate.AddDays(10),
                            EndDate = tournament.StartDate.AddDays(11)
                        });

                        // Chung kết
                        context.StageDetails.Add(new StageDetail
                        {
                            TournamentId = tournament.Id,
                            StageId = stageChungKet.StageId,
                            FormatId = formatLoaiTrucTiep.FormatId,
                            Order = 3,
                            StartDate = tournament.StartDate.AddDays(14),
                            EndDate = tournament.StartDate.AddDays(14)
                        });
                    }
                    context.SaveChanges();
                }

                // Thêm dữ liệu cho bảng Standing
                foreach (var tournament in tournaments)
                {
                    var standing = new Standing
                    {
                        TournamentId = tournament.Id,
                        SportId = basketballSport.Id,
                        GroupName = "Bảng xếp hạng chính thức",
                        Description = "Bảng xếp hạng giải đấu " + tournament.Name,
                        LastUpdated = DateTime.Now
                    };
                    context.Standings.Add(standing);
                }
                context.SaveChanges();

                // Thêm dữ liệu cho bảng StandingDetail
                var standings = context.Standings.ToList();
                var teams = context.Teams.ToList();
                var tournamentTeams = context.TournamentTeams.ToList();

                foreach (var standing in standings)
                {
                    var teamsInTournament = tournamentTeams
                        .Where(tt => tt.TournamentId == standing.TournamentId)
                        .Select(tt => tt.TeamId)
                        .ToList();

                    // Nếu không có đội nào trong giải đấu, thêm tất cả các đội
                    if (!teamsInTournament.Any())
                    {
                        // Lấy tất cả các trận đấu trong giải đấu
                        var matchesInTournament = context.Matches
                            .Where(m => m.TournamentId == standing.TournamentId)
                            .ToList();

                        // Lấy tên các đội từ các trận đấu
                        var teamNames = new HashSet<string>();
                        foreach (var match in matchesInTournament)
                        {
                            teamNames.Add(match.TeamA);
                            teamNames.Add(match.TeamB);
                        }

                        // Tìm ID của các đội từ tên
                        foreach (var teamName in teamNames)
                        {
                            var team = teams.OrderBy(t => t.TeamId).FirstOrDefault(t => t.Name == teamName);
                            if (team != null && !teamsInTournament.Contains(team.TeamId))
                            {
                                teamsInTournament.Add(team.TeamId);
                            }
                        }

                        // Nếu vẫn không có đội nào, thêm tất cả các đội
                        if (!teamsInTournament.Any())
                        {
                            teamsInTournament = teams.Select(t => t.TeamId).ToList();
                        }
                    }

                    var random = new Random();
                    int rank = 1;

                    foreach (var teamId in teamsInTournament)
                    {
                        var wins = random.Next(0, 5);
                        var losses = random.Next(0, 5);
                        var draws = random.Next(0, 2);
                        var pointsScored = random.Next(50, 150);
                        var pointsAgainst = random.Next(40, 130);

                        context.StandingDetails.Add(new StandingDetail
                        {
                            StandingId = standing.StandingId,
                            TeamId = teamId,
                            NumberOfWins = wins,
                            NumberOfLoses = losses,
                            NumberOfDraws = draws,
                            PointsScored = pointsScored,
                            PointsAgainst = pointsAgainst,
                            Rank = rank++,
                            TotalPoints = wins * 3 + draws
                        });
                    }
                }
                context.SaveChanges();

                // Thêm dữ liệu cho bảng PlayerDetail
                var players = context.Players.ToList();
                foreach (var player in players)
                {
                    var random = new Random();
                    context.PlayerDetails.Add(new PlayerDetail
                    {
                        PlayerId = player.PlayerId,
                        TeamId = player.TeamId,
                        JerseyNumber = player.Number,
                        DateOfBirth = DateTime.Now.AddYears(-random.Next(18, 35)),
                        Achievements = "Cầu thủ xuất sắc giải đấu 2023",
                        TotalPoints = random.Next(50, 500),
                        TotalAssists = random.Next(10, 200),
                        TotalRebounds = random.Next(20, 300),
                        GamesPlayed = random.Next(5, 50)
                    });
                }
                context.SaveChanges();

                // Thêm dữ liệu cho bảng MatchDetail
                var matches = context.Matches.ToList();
                foreach (var match in matches)
                {
                    try
                    {
                        // Tìm ID của các đội từ tên đội
                        var team1 = teams.OrderBy(t => t.TeamId).FirstOrDefault(t => t.Name == match.TeamA);
                        var team2 = teams.OrderBy(t => t.TeamId).FirstOrDefault(t => t.Name == match.TeamB);

                        // Nếu không tìm thấy đội, tạo mới
                        if (team1 == null)
                        {
                            team1 = new Team
                            {
                                Name = match.TeamA,
                                Coach = "HLV " + match.TeamA,
                                LogoUrl = "/images/teams/default.png"
                            };
                            context.Teams.Add(team1);
                            context.SaveChanges();
                            teams.Add(team1);
                        }

                        if (team2 == null)
                        {
                            team2 = new Team
                            {
                                Name = match.TeamB,
                                Coach = "HLV " + match.TeamB,
                                LogoUrl = "/images/teams/default.png"
                            };
                            context.Teams.Add(team2);
                            context.SaveChanges();
                            teams.Add(team2);
                        }

                        // Kiểm tra lại một lần nữa
                        if (team1 != null && team2 != null)
                        {
                            context.MatchDetails.Add(new MatchDetail
                            {
                                MatchId = match.Id,
                                Team1Id = team1.TeamId,
                                Team2Id = team2.TeamId,
                                ScoreTeam1 = match.ScoreTeamA,
                                ScoreTeam2 = match.ScoreTeamB,
                                Notes = "Trận đấu giữa " + match.TeamA + " và " + match.TeamB
                            });
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Lỗi khi tạo MatchDetail cho trận đấu {match.Id}: {ex.Message}");
                    }
                }
                context.SaveChanges();

                // Thêm dữ liệu cho bảng CoachDetail
                foreach (var team in teams)
                {
                    // Tạo một huấn luyện viên cho mỗi đội
                    // Lưu ý: Cần có UserId hợp lệ, ở đây chúng ta sẽ sử dụng admin user hoặc user đầu tiên
                    var adminUser = context.Users.OrderBy(u => u.Id).FirstOrDefault(u => u.UserName == "admin@example.com");

                    // Nếu không tìm thấy admin user, sử dụng user đầu tiên
                    if (adminUser == null)
                    {
                        adminUser = context.Users.OrderBy(u => u.Id).FirstOrDefault();
                    }

                    if (adminUser != null)
                    {
                        context.CoachDetails.Add(new CoachDetail
                        {
                            TeamId = team.TeamId,
                            UserId = adminUser.Id,
                            CoachName = team.Coach,
                            PhoneNumber = "0123456789",
                            Email = "coach_" + team.Name.ToLower().Replace(" ", "_") + "@example.com",
                            Experience = "5 năm kinh nghiệm huấn luyện",
                            ImageUrl = "/images/coaches/default.jpg"
                        });
                    }
                }
                context.SaveChanges();
            }

            Console.WriteLine("Đã thêm dữ liệu mẫu cho các bảng mới thành công!");
        }
    }
}
