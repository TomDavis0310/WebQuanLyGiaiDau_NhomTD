using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class SeedBasketballTournament
    {
        public static void Initialize(ApplicationDbContext context)
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
                    ImageUrl = "/images/sports/basketball.png" // Make sure this image exists in your wwwroot/images/sports folder
                };
                context.Sports.Add(basketball);
                context.SaveChanges();
            }

            // Check if we already have a basketball tournament
            var tournamentExists = context.Tournaments.Any(t => t.Name == "Giải Bóng Rổ Mùa Hè 2025" && t.SportsId == basketball.Id);
            if (tournamentExists)
            {
                // Tournament already exists, no need to seed
                return;
            }

            // Create a basketball tournament
            var tournament = new Tournament
            {
                Name = "Giải Bóng Rổ Mùa Hè 2025",
                Description = "Giải đấu bóng rổ mùa hè với 6 đội tham gia, thi đấu theo thể thức vòng tròn.",
                StartDate = DateTime.Now,
                EndDate = DateTime.Now.AddMonths(2),
                SportsId = basketball.Id,
                ImageUrl = "/images/tournaments/basketball-tournament.jpg" // Make sure this image exists
            };
            context.Tournaments.Add(tournament);
            context.SaveChanges();

            // Create 6 teams
            var teams = new List<Team>
            {
                new Team { Name = "Saigon Heat", Coach = "Nguyễn Văn A", LogoUrl = "/images/teams/team1.png" },
                new Team { Name = "Hanoi Buffaloes", Coach = "Trần Văn B", LogoUrl = "/images/teams/team2.png" },
                new Team { Name = "Danang Dragons", Coach = "Lê Văn C", LogoUrl = "/images/teams/team3.png" },
                new Team { Name = "Cantho Catfish", Coach = "Phạm Văn D", LogoUrl = "/images/teams/team4.png" },
                new Team { Name = "Thang Long Warriors", Coach = "Hoàng Văn E", LogoUrl = "/images/teams/team5.png" },
                new Team { Name = "HCMC Wings", Coach = "Vũ Văn F", LogoUrl = "/images/teams/team6.png" }
            };

            context.Teams.AddRange(teams);
            context.SaveChanges();

            // Create 30 players (5 per team)
            var positions = new[] { "Point Guard", "Shooting Guard", "Small Forward", "Power Forward", "Center" };
            var players = new List<Player>();

            foreach (var team in teams)
            {
                for (int i = 0; i < 5; i++)
                {
                    players.Add(new Player
                    {
                        FullName = $"Cầu thủ {i + 1} của {team.Name}",
                        Position = positions[i],
                        Number = i + 1,
                        TeamId = team.TeamId,
                        ImageUrl = $"/images/players/player{team.TeamId}_{i + 1}.png" // Make sure these images exist
                    });
                }
            }

            context.Players.AddRange(players);
            context.SaveChanges();

            // Create round-robin schedule
            // In a round-robin tournament with n teams, each team plays against every other team once
            // Total number of matches = n * (n - 1) / 2
            // For 6 teams, that's 6 * 5 / 2 = 15 matches

            var matches = new List<Match>();
            var startDate = tournament.StartDate;

            // Create matches for round-robin tournament
            for (int i = 0; i < teams.Count; i++)
            {
                for (int j = i + 1; j < teams.Count; j++)
                {
                    var matchDate = startDate.AddDays((i * teams.Count) + j);
                    var isCompleted = matchDate < DateTime.Now;
                    var isToday = matchDate.Date == DateTime.Now.Date;

                    var match = new Match
                    {
                        TeamA = teams[i].Name,
                        TeamB = teams[j].Name,
                        MatchDate = matchDate,
                        TournamentId = tournament.Id
                    };

                    // We don't need to set Status explicitly anymore
                    // The CalculatedStatus property will handle this

                    // Add scores for completed matches
                    if (isCompleted)
                    {
                        var random = new Random();
                        match.ScoreTeamA = random.Next(60, 121); // Basketball scores typically 60-120
                        match.ScoreTeamB = random.Next(60, 121);
                    }

                    matches.Add(match);
                }
            }

            context.Matches.AddRange(matches);
            context.SaveChanges();

            // Add statistics for completed matches
            var statistics = new List<Statistic>();
            var statsRandom = new Random();

            // Get completed matches based on CalculatedStatus
            var completedMatches = matches.Where(m => m.CalculatedStatus == "Completed").ToList();

            foreach (var match in completedMatches)
            {
                // Get players from both teams
                var teamAPlayers = players.Where(p => p.Team.Name == match.TeamA).ToList();
                var teamBPlayers = players.Where(p => p.Team.Name == match.TeamB).ToList();

                int totalTeamAPoints = 0;
                int totalTeamBPoints = 0;

                // Add stats for each player in Team A
                foreach (var player in teamAPlayers)
                {
                    // For basketball, make sure player points add up to team score
                    int playerPoints = statsRandom.Next(0, 25); // Individual player scores
                    totalTeamAPoints += playerPoints;

                    statistics.Add(new Statistic
                    {
                        PlayerName = player.FullName,
                        Points = playerPoints,
                        Assists = statsRandom.Next(0, 10),
                        Rebounds = statsRandom.Next(0, 15),
                        MatchId = match.Id
                    });
                }

                // Add stats for each player in Team B
                foreach (var player in teamBPlayers)
                {
                    int playerPoints = statsRandom.Next(0, 25);
                    totalTeamBPoints += playerPoints;

                    statistics.Add(new Statistic
                    {
                        PlayerName = player.FullName,
                        Points = playerPoints,
                        Assists = statsRandom.Next(0, 10),
                        Rebounds = statsRandom.Next(0, 15),
                        MatchId = match.Id
                    });
                }

                // Adjust the last player's points to match the team score
                if (teamAPlayers.Any() && match.ScoreTeamA.HasValue)
                {
                    var lastPlayerA = statistics.Last(s => s.MatchId == match.Id && teamAPlayers.Any(p => p.FullName == s.PlayerName));
                    lastPlayerA.Points += (match.ScoreTeamA.Value - totalTeamAPoints);
                }

                if (teamBPlayers.Any() && match.ScoreTeamB.HasValue)
                {
                    var lastPlayerB = statistics.Last(s => s.MatchId == match.Id && teamBPlayers.Any(p => p.FullName == s.PlayerName));
                    lastPlayerB.Points += (match.ScoreTeamB.Value - totalTeamBPoints);
                }
            }

            context.Statistics.AddRange(statistics);
            context.SaveChanges();

            Console.WriteLine("Basketball tournament data seeded successfully!");
        }
    }
}
