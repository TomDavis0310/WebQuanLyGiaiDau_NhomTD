using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class SeedBasketball5v5Data
    {
        public static async Task SeedBasketball5v5Tournaments(IServiceProvider serviceProvider)
        {
            using var scope = serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

            // Check if we already have basketball sport
            var basketball = await context.Sports.FirstOrDefaultAsync(s => s.Name == "Bóng Rổ");
            if (basketball == null)
            {
                basketball = new Sports
                {
                    Name = "Bóng Rổ",
                    ImageUrl = "/images/basketball.jpg"
                };
                context.Sports.Add(basketball);
                await context.SaveChangesAsync();
            }

            // Get existing 5v5 tournaments
            var pastTournament = await context.Tournaments
                .AsNoTracking() // Use AsNoTracking to avoid tracking issues
                .FirstOrDefaultAsync(t => t.Name == "Giải Bóng Rổ 5v5 Mùa Hè 2023" && t.SportsId == basketball.Id);

            var openTournament = await context.Tournaments
                .AsNoTracking() // Use AsNoTracking to avoid tracking issues
                .FirstOrDefaultAsync(t => t.Name == "Giải Bóng Rổ 5v5 Mùa Đông 2024" && t.SportsId == basketball.Id);

            // Force reseeding of teams and players for existing tournaments
            await ForceReseedTeamsAndPlayers(context, basketball.Id, pastTournament, openTournament);

            // If tournaments don't exist, create them
            if (pastTournament == null && openTournament == null)
            {
                // Lấy thể thức thi đấu vòng tròn
                var roundRobinFormat = await context.TournamentFormats.FirstOrDefaultAsync(f => f.Name == "Vòng tròn (Round Robin)");
                int? formatId = roundRobinFormat?.Id;

                // Create past tournament (completed)
                pastTournament = new Tournament
                {
                    Name = "Giải Bóng Rổ 5v5 Mùa Hè 2023",
                    Description = "Giải đấu bóng rổ 5v5 theo luật NBA với 8 đội tham gia, mỗi đội 12 thành viên. Mỗi trận đấu gồm 4 hiệp, mỗi hiệp 12 phút với thời gian nghỉ 2 phút 30 giây giữa hiệp 1-2 và 3-4, 15 phút nghỉ giữa hiệp 2-3. Áp dụng luật 24 giây tấn công, 3 giây trong vùng cấm và 8 giây đưa bóng qua nửa sân. Giải đấu đã kết thúc với nhiều trận đấu hấp dẫn và kịch tính.",
                    StartDate = new DateTime(2023, 6, 1),
                    EndDate = new DateTime(2023, 8, 15),
                    ImageUrl = "/images/basketball5v5_past.jpg",
                    RegistrationStatus = "Completed",
                    SportsId = basketball.Id,
                    TournamentFormatId = formatId,
                    MaxTeams = 8,
                    TeamsPerGroup = 8,
                    Location = "Nhà thi đấu Phú Thọ, TP.HCM"
                };

                // Create open tournament (registration open)
                openTournament = new Tournament
                {
                    Name = "Giải Bóng Rổ 5v5 Mùa Đông 2024",
                    Description = "Giải đấu bóng rổ 5v5 theo luật NBA với 8 đội tham gia, mỗi đội 12 thành viên. Mỗi trận đấu gồm 4 hiệp, mỗi hiệp 12 phút với thời gian nghỉ 2 phút 30 giây giữa hiệp 1-2 và 3-4, 15 phút nghỉ giữa hiệp 2-3. Áp dụng luật 24 giây tấn công, 3 giây trong vùng cấm và 8 giây đưa bóng qua nửa sân. Đăng ký ngay để tham gia giải đấu hấp dẫn này!",
                    StartDate = new DateTime(2024, 12, 1),
                    EndDate = new DateTime(2025, 2, 28),
                    ImageUrl = "/images/basketball5v5_open.jpg",
                    RegistrationStatus = "Open",
                    SportsId = basketball.Id,
                    TournamentFormatId = formatId,
                    MaxTeams = 8,
                    TeamsPerGroup = 8,
                    Location = "Nhà thi đấu Quân khu 7, TP.HCM"
                };

                context.Tournaments.Add(pastTournament);
                context.Tournaments.Add(openTournament);
                await context.SaveChangesAsync();

                // Create 8 teams for each tournament
                var teamNames = new List<string>
                {
                    "Hanoi Buffaloes", "Saigon Heat", "Danang Dragons", "Cantho Catfish",
                    "HCMC Wings", "Thang Long Warriors", "Nha Trang Dolphins", "Vung Tau Waves"
                };

                var teams = new List<Team>();
                var players = new List<Player>();
                var random = new Random();

                // Create teams first
                foreach (var teamName in teamNames)
                {
                    var team = new Team
                    {
                        Name = teamName,
                        Coach = $"HLV {GenerateRandomName(random)}",
                        LogoUrl = $"/images/team_logos/{teamName.ToLower().Replace(" ", "_")}.png"
                    };
                    teams.Add(team);
                    context.Teams.Add(team);
                }
                await context.SaveChangesAsync();

                // Now create players for each team
                foreach (var team in teams)
                {
                    // Create 12 players for each team
                    for (int i = 0; i < 12; i++)
                    {
                        var positions = new[] { "PG", "SG", "SF", "PF", "C" };
                        var player = new Player
                        {
                            FullName = GenerateRandomName(random),
                            Number = random.Next(0, 100),
                            Position = positions[random.Next(positions.Length)],
                            ImageUrl = $"/images/players/player_{random.Next(1, 10)}.jpg",
                            TeamId = team.TeamId
                        };
                        players.Add(player);
                        context.Players.Add(player);
                    }
                }
                await context.SaveChangesAsync();

                // Create tournament teams associations
                foreach (var team in teams)
                {
                    // Add to past tournament
                    var pastTournamentTeam = new TournamentTeam
                    {
                        TournamentId = pastTournament.Id,
                        TeamId = team.TeamId,
                        RegistrationDate = pastTournament.StartDate.AddDays(-random.Next(10, 30)),
                        Status = "Approved"
                    };
                    context.TournamentTeams.Add(pastTournamentTeam);

                    // Add to open tournament (all teams for 5v5 tournament)
                    var openTournamentTeam = new TournamentTeam
                    {
                        TournamentId = openTournament.Id,
                        TeamId = team.TeamId,
                        RegistrationDate = DateTime.Now.AddDays(-random.Next(1, 10)),
                        Status = "Approved" // All teams are approved for the 5v5 tournament
                    };
                    context.TournamentTeams.Add(openTournamentTeam);
                }
                await context.SaveChangesAsync();

                // Create matches for past tournament (round-robin format)
                var matches = new List<Match>();
                for (int i = 0; i < teams.Count; i++)
                {
                    for (int j = i + 1; j < teams.Count; j++)
                    {
                        var matchDate = pastTournament.StartDate.AddDays(random.Next(0, (int)(pastTournament.EndDate - pastTournament.StartDate).TotalDays));
                        var match = new Match
                        {
                            TeamA = teams[i].Name,
                            TeamB = teams[j].Name,
                            MatchDate = matchDate,
                            MatchTime = new TimeSpan(15, 0, 0), // 15:00 (3 PM)
                            Location = pastTournament.Location, // Use tournament location
                            TournamentId = pastTournament.Id
                        };
                        matches.Add(match);
                        context.Matches.Add(match);
                    }
                }
                await context.SaveChangesAsync();

                // Add scores to matches (all matches in past tournament are completed)
                var statistics = new List<Statistic>();
                foreach (var match in matches)
                {
                    // For 5v5 basketball, scores are typically higher
                    match.ScoreTeamA = random.Next(60, 110);
                    match.ScoreTeamB = random.Next(60, 110);

                    // Make sure there's no tie
                    if (match.ScoreTeamA == match.ScoreTeamB)
                    {
                        match.ScoreTeamA += 1;
                    }

                    // Get players from both teams
                    var teamAPlayers = players.Where(p => p.Team.Name == match.TeamA).ToList();
                    var teamBPlayers = players.Where(p => p.Team.Name == match.TeamB).ToList();

                    // Add stats for each player in Team A
                    foreach (var player in teamAPlayers)
                    {
                        // For 5v5 basketball, distribute points among players
                        int playerPoints = random.Next(0, 30); // Individual player scores

                        statistics.Add(new Statistic
                        {
                            PlayerName = player.FullName,
                            Points = playerPoints,
                            Assists = random.Next(0, 15),
                            Rebounds = random.Next(0, 20),
                            MatchId = match.Id
                        });
                    }

                    // Add stats for each player in Team B
                    foreach (var player in teamBPlayers)
                    {
                        int playerPoints = random.Next(0, 30); // Individual player scores

                        statistics.Add(new Statistic
                        {
                            PlayerName = player.FullName,
                            Points = playerPoints,
                            Assists = random.Next(0, 15),
                            Rebounds = random.Next(0, 20),
                            MatchId = match.Id
                        });
                    }
                }

                // Update matches with scores
                context.Matches.UpdateRange(matches);
                await context.SaveChangesAsync();

                // Add statistics
                context.Statistics.AddRange(statistics);
                await context.SaveChangesAsync();

                Console.WriteLine("Two 5v5 basketball tournaments seeded successfully!");
            }
            else
            {
                Console.WriteLine("5v5 basketball tournaments already exist, skipping seeding.");
            }
        }

        private static async Task ForceReseedTeamsAndPlayers(ApplicationDbContext context, int basketballId, Tournament pastTournament, Tournament openTournament)
        {
            // If both tournaments exist, check if they have teams and players
            if (pastTournament != null || openTournament != null)
            {
                // Check if there are any tournament teams for these tournaments
                bool hasPastTournamentTeams = false;
                bool hasOpenTournamentTeams = false;

                if (pastTournament != null)
                {
                    hasPastTournamentTeams = await context.TournamentTeams
                        .AnyAsync(tt => tt.TournamentId == pastTournament.Id);
                }

                if (openTournament != null)
                {
                    hasOpenTournamentTeams = await context.TournamentTeams
                        .AnyAsync(tt => tt.TournamentId == openTournament.Id);
                }

                // If either tournament doesn't have teams, create them
                if (!hasPastTournamentTeams || !hasOpenTournamentTeams)
                {
                    Console.WriteLine("Reseeding teams and players for 5v5 basketball tournaments...");

                    // Create 8 teams for each tournament
                    var teamNames = new List<string>
                    {
                        "Hanoi Buffaloes", "Saigon Heat", "Danang Dragons", "Cantho Catfish",
                        "HCMC Wings", "Thang Long Warriors", "Nha Trang Dolphins", "Vung Tau Waves"
                    };

                    var teams = new List<Team>();
                    var players = new List<Player>();
                    var random = new Random();

                    // Check if teams already exist
                    var existingTeams = await context.Teams
                        .Where(t => teamNames.Contains(t.Name))
                        .ToListAsync();

                    // Create teams that don't exist
                    foreach (var teamName in teamNames)
                    {
                        var team = existingTeams.FirstOrDefault(t => t.Name == teamName);
                        if (team == null)
                        {
                            team = new Team
                            {
                                Name = teamName,
                                Coach = $"HLV {GenerateRandomName(random)}",
                                LogoUrl = $"/images/team_logos/{teamName.ToLower().Replace(" ", "_")}.png"
                            };
                            teams.Add(team);
                            context.Teams.Add(team);
                        }
                        else
                        {
                            teams.Add(team);
                        }
                    }
                    await context.SaveChangesAsync();

                    // Check if players already exist for these teams
                    foreach (var team in teams)
                    {
                        var existingPlayers = await context.Players
                            .Where(p => p.TeamId == team.TeamId)
                            .ToListAsync();

                        // If team doesn't have enough players, create more
                        if (existingPlayers.Count < 12)
                        {
                            // Create 12 players for each team
                            for (int i = existingPlayers.Count; i < 12; i++)
                            {
                                var positions = new[] { "PG", "SG", "SF", "PF", "C" };
                                var player = new Player
                                {
                                    FullName = GenerateRandomName(random),
                                    Number = random.Next(0, 100),
                                    Position = positions[random.Next(positions.Length)],
                                    ImageUrl = $"/images/players/player_{random.Next(1, 10)}.jpg",
                                    TeamId = team.TeamId
                                };
                                players.Add(player);
                                context.Players.Add(player);
                            }
                        }
                    }
                    await context.SaveChangesAsync();

                    // Create tournament teams associations if they don't exist
                    foreach (var team in teams)
                    {
                        // Add to past tournament if it exists and doesn't have this team
                        if (pastTournament != null && !hasPastTournamentTeams)
                        {
                            var existingTournamentTeam = await context.TournamentTeams
                                .FirstOrDefaultAsync(tt => tt.TournamentId == pastTournament.Id && tt.TeamId == team.TeamId);

                            if (existingTournamentTeam == null)
                            {
                                var pastTournamentTeam = new TournamentTeam
                                {
                                    TournamentId = pastTournament.Id,
                                    TeamId = team.TeamId,
                                    RegistrationDate = pastTournament.StartDate.AddDays(-random.Next(10, 30)),
                                    Status = "Approved"
                                };
                                context.TournamentTeams.Add(pastTournamentTeam);
                            }
                        }

                        // Add to open tournament if it exists and doesn't have this team
                        if (openTournament != null && !hasOpenTournamentTeams)
                        {
                            var existingTournamentTeam = await context.TournamentTeams
                                .FirstOrDefaultAsync(tt => tt.TournamentId == openTournament.Id && tt.TeamId == team.TeamId);

                            if (existingTournamentTeam == null)
                            {
                                var openTournamentTeam = new TournamentTeam
                                {
                                    TournamentId = openTournament.Id,
                                    TeamId = team.TeamId,
                                    RegistrationDate = DateTime.Now.AddDays(-random.Next(1, 10)),
                                    Status = "Approved" // All teams are approved for the 5v5 tournament
                                };
                                context.TournamentTeams.Add(openTournamentTeam);
                            }
                        }
                    }
                    await context.SaveChangesAsync();

                    // Create matches for past tournament if it exists and doesn't have matches
                    if (pastTournament != null)
                    {
                        var existingMatches = await context.Matches
                            .Where(m => m.TournamentId == pastTournament.Id)
                            .ToListAsync();

                        if (existingMatches.Count == 0)
                        {
                            var matches = new List<Match>();
                            for (int i = 0; i < teams.Count; i++)
                            {
                                for (int j = i + 1; j < teams.Count; j++)
                                {
                                    var matchDate = pastTournament.StartDate.AddDays(random.Next(0, (int)(pastTournament.EndDate - pastTournament.StartDate).TotalDays));
                                    var match = new Match
                                    {
                                        TeamA = teams[i].Name,
                                        TeamB = teams[j].Name,
                                        MatchDate = matchDate,
                                        MatchTime = new TimeSpan(15, 0, 0), // 15:00 (3 PM)
                                        Location = pastTournament.Location, // Use tournament location
                                        TournamentId = pastTournament.Id
                                    };
                                    matches.Add(match);
                                    context.Matches.Add(match);
                                }
                            }
                            await context.SaveChangesAsync();

                            // Add scores to matches (all matches in past tournament are completed)
                            var statistics = new List<Statistic>();
                            foreach (var match in matches)
                            {
                                // For 5v5 basketball, scores are typically higher
                                match.ScoreTeamA = random.Next(60, 110);
                                match.ScoreTeamB = random.Next(60, 110);

                                // Make sure there's no tie
                                if (match.ScoreTeamA == match.ScoreTeamB)
                                {
                                    match.ScoreTeamA += 1;
                                }

                                // Get players from both teams
                                var teamAPlayers = await context.Players
                                    .Where(p => p.Team.Name == match.TeamA)
                                    .ToListAsync();

                                var teamBPlayers = await context.Players
                                    .Where(p => p.Team.Name == match.TeamB)
                                    .ToListAsync();

                                // Add stats for each player in Team A
                                foreach (var player in teamAPlayers)
                                {
                                    // For 5v5 basketball, distribute points among players
                                    int playerPoints = random.Next(0, 30); // Individual player scores

                                    statistics.Add(new Statistic
                                    {
                                        PlayerName = player.FullName,
                                        Points = playerPoints,
                                        Assists = random.Next(0, 15),
                                        Rebounds = random.Next(0, 20),
                                        MatchId = match.Id
                                    });
                                }

                                // Add stats for each player in Team B
                                foreach (var player in teamBPlayers)
                                {
                                    int playerPoints = random.Next(0, 30); // Individual player scores

                                    statistics.Add(new Statistic
                                    {
                                        PlayerName = player.FullName,
                                        Points = playerPoints,
                                        Assists = random.Next(0, 15),
                                        Rebounds = random.Next(0, 20),
                                        MatchId = match.Id
                                    });
                                }
                            }

                            // Update matches with scores
                            context.Matches.UpdateRange(matches);
                            await context.SaveChangesAsync();

                            // Add statistics
                            context.Statistics.AddRange(statistics);
                            await context.SaveChangesAsync();
                        }
                    }

                    Console.WriteLine("Teams and players reseeded successfully for 5v5 basketball tournaments!");
                }
            }
        }

        private static string GenerateRandomName(Random random)
        {
            string[] firstNames = { "Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Phan", "Vũ", "Võ", "Đặng", "Bùi", "Đỗ", "Hồ", "Ngô", "Dương", "Lý" };
            string[] middleNames = { "Văn", "Thị", "Hữu", "Đức", "Công", "Quang", "Minh", "Hoàng", "Huy", "Thanh", "Tuấn", "Anh", "Thành", "Đình", "Xuân", "Bá" };
            string[] lastNames = { "An", "Bình", "Cường", "Dũng", "Đạt", "Hải", "Hùng", "Khoa", "Linh", "Mạnh", "Nam", "Phong", "Quân", "Sơn", "Thắng", "Trung", "Tú", "Việt", "Vũ", "Xuân" };

            return $"{firstNames[random.Next(firstNames.Length)]} {middleNames[random.Next(middleNames.Length)]} {lastNames[random.Next(lastNames.Length)]}";
        }
    }
}
