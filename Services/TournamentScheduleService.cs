using System;
using System.Collections.Generic;
using System.Linq;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    public class TournamentScheduleService
    {
        private readonly ApplicationDbContext _context;

        public TournamentScheduleService(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Tạo lịch thi đấu tự động dựa trên thể thức thi đấu được chọn
        /// </summary>
        /// <param name="tournamentId">ID của giải đấu</param>
        /// <returns>Danh sách các trận đấu đã được tạo</returns>
        public List<Match> GenerateSchedule(int tournamentId)
        {
            var tournament = _context.Tournaments
                .FirstOrDefault(t => t.Id == tournamentId);

            if (tournament == null)
                throw new ArgumentException("Không tìm thấy giải đấu", nameof(tournamentId));

            // Lấy danh sách các đội tham gia giải đấu
            var teams = _context.TournamentTeams
                .Where(tt => tt.TournamentId == tournamentId && tt.Status == "Approved")
                .Select(tt => tt.Team)
                .ToList();

            if (teams == null || !teams.Any())
                throw new InvalidOperationException("Không có đội nào tham gia giải đấu này");

            // Xóa lịch thi đấu cũ (nếu có)
            var existingMatches = _context.Matches.Where(m => m.TournamentId == tournamentId).ToList();
            if (existingMatches.Any())
            {
                _context.Matches.RemoveRange(existingMatches);
                _context.SaveChanges();
            }

            List<Match> matches = new List<Match>();

            // Tạo lịch thi đấu dựa trên thể thức
            if (tournament.TournamentFormat != null)
            {
                switch (tournament.TournamentFormat.Name)
                {
                    case "Loại trực tiếp (Knockout)":
                        matches = GenerateKnockoutSchedule(tournament, teams);
                        break;
                    case "Vòng tròn (Round Robin)":
                        matches = GenerateRoundRobinSchedule(tournament, teams);
                        break;
                    case "Vòng bảng + Hệ thống Thụy Sĩ":
                        matches = GenerateGroupStageSwissSchedule(tournament, teams);
                        break;
                    case "Vòng bảng":
                        matches = GenerateGroupStageSchedule(tournament, teams);
                        break;
                    default:
                        // Mặc định sử dụng thể thức vòng tròn
                        matches = GenerateRoundRobinSchedule(tournament, teams);
                        break;
                }
            }
            else
            {
                // Nếu không có thể thức, sử dụng thể thức vòng tròn
                matches = GenerateRoundRobinSchedule(tournament, teams);
            }

            // Lưu lịch thi đấu vào cơ sở dữ liệu
            _context.Matches.AddRange(matches);
            _context.SaveChanges();

            return matches;
        }

        /// <summary>
        /// Tạo lịch thi đấu theo thể thức loại trực tiếp (Knockout)
        /// </summary>
        private List<Match> GenerateKnockoutSchedule(Tournament tournament, List<Team> teams)
        {
            List<Match> matches = new List<Match>();
            DateTime matchDate = tournament.StartDate;

            // Tính toán số vòng đấu cần thiết
            int teamCount = teams.Count;
            int rounds = (int)Math.Ceiling(Math.Log(teamCount, 2));
            int matchesInFirstRound = (int)Math.Pow(2, rounds - 1);

            // Tạo các trận đấu vòng đầu tiên
            for (int i = 0; i < matchesInFirstRound; i++)
            {
                Team? teamA = i < teamCount ? teams[i] : null;
                Team? teamB = (teamCount - 1 - i) < teamCount && (teamCount - 1 - i) >= 0 ? teams[teamCount - 1 - i] : null;

                // Nếu không đủ đội, một số trận sẽ có bye (đội tự động vào vòng sau)
                if (teamA == null && teamB == null)
                    continue;

                var match = new Match
                {
                    TournamentId = tournament.Id,
                    // Lưu thông tin vòng đấu vào Status (tạm thời)
                    Status = "Round 1",
                    MatchDate = matchDate,
                    TeamA = teamA?.Name ?? "TBD",
                    TeamB = teamB?.Name ?? "TBD"
                    // Không sử dụng TeamAId và TeamBId vì chưa có trong cơ sở dữ liệu
                };

                matches.Add(match);
                matchDate = matchDate.AddDays(1);
            }

            // Tạo các trận đấu cho các vòng tiếp theo (chưa biết đội nào tham gia)
            for (int round = 2; round <= rounds; round++)
            {
                int matchesInRound = (int)Math.Pow(2, rounds - round);
                for (int i = 0; i < matchesInRound; i++)
                {
                    var match = new Match
                    {
                        TournamentId = tournament.Id,
                        MatchDate = matchDate,
                        TeamA = "TBD", // To Be Determined
                        TeamB = "TBD",
                        Status = $"Round {round}" // Lưu thông tin vòng đấu vào Status (tạm thời)
                    };

                    matches.Add(match);
                    matchDate = matchDate.AddDays(1);
                }
            }

            return matches;
        }

        /// <summary>
        /// Tạo lịch thi đấu theo thể thức vòng tròn (Round Robin)
        /// </summary>
        private List<Match> GenerateRoundRobinSchedule(Tournament tournament, List<Team> teams)
        {
            List<Match> matches = new List<Match>();
            DateTime matchDate = tournament.StartDate;

            int teamCount = teams.Count;

            // Nếu số đội lẻ, thêm một đội "bye"
            if (teamCount % 2 != 0)
            {
                teamCount++;
            }

            // Số vòng đấu = số đội - 1
            int rounds = teamCount - 1;

            // Tạo mảng chứa các đội
            int[] teamIndices = new int[teamCount];
            for (int i = 0; i < teamCount; i++)
            {
                teamIndices[i] = i;
            }

            // Tạo lịch thi đấu vòng tròn
            for (int round = 0; round < rounds; round++)
            {
                for (int match = 0; match < teamCount / 2; match++)
                {
                    int home = teamIndices[match];
                    int away = teamIndices[teamCount - 1 - match];

                    // Bỏ qua nếu một trong hai đội là "bye"
                    if (home >= teams.Count || away >= teams.Count)
                        continue;

                    var newMatch = new Match
                    {
                        TournamentId = tournament.Id,
                        MatchDate = matchDate,
                        TeamA = teams[home].Name,
                        TeamB = teams[away].Name,
                        Status = $"Round {round + 1}" // Lưu thông tin vòng đấu vào Status (tạm thời)
                    };

                    matches.Add(newMatch);
                    matchDate = matchDate.AddDays(1);
                }

                // Xoay vòng các đội (giữ nguyên đội đầu tiên)
                int temp = teamIndices[1];
                for (int i = 1; i < teamCount - 1; i++)
                {
                    teamIndices[i] = teamIndices[i + 1];
                }
                teamIndices[teamCount - 1] = temp;
            }

            return matches;
        }

        /// <summary>
        /// Tạo lịch thi đấu theo thể thức vòng bảng kết hợp hệ thống Thụy Sĩ
        /// </summary>
        private List<Match> GenerateGroupStageSwissSchedule(Tournament tournament, List<Team> teams)
        {
            List<Match> matches = new List<Match>();

            // Bước 1: Tạo các bảng đấu
            int teamsPerGroup = tournament.TeamsPerGroup ?? 4;
            int groupCount = (int)Math.Ceiling((double)teams.Count / teamsPerGroup);

            // Chia các đội vào các bảng
            List<List<Team>> groups = new List<List<Team>>();
            for (int i = 0; i < groupCount; i++)
            {
                groups.Add(new List<Team>());
            }

            for (int i = 0; i < teams.Count; i++)
            {
                groups[i % groupCount].Add(teams[i]);
            }

            // Bước 2: Tạo lịch thi đấu vòng bảng
            DateTime matchDate = tournament.StartDate;
            int groupMatchCount = 0;

            for (int groupIndex = 0; groupIndex < groups.Count; groupIndex++)
            {
                var groupTeams = groups[groupIndex];
                var groupMatches = GenerateRoundRobinSchedule(tournament, groupTeams);

                // Cập nhật thông tin bảng đấu
                foreach (var match in groupMatches)
                {
                    // Lưu thông tin bảng đấu vào Status (tạm thời)
                    match.Status = $"Bảng {(char)('A' + groupIndex)} - {match.Status}";
                    match.MatchDate = matchDate.AddDays(groupMatchCount % 3); // Mỗi ngày tối đa 3 trận
                    groupMatchCount++;
                }

                matches.AddRange(groupMatches);
            }

            // Bước 3: Tạo các trận đấu vòng Thụy Sĩ (sẽ được cập nhật sau khi kết thúc vòng bảng)
            matchDate = matchDate.AddDays(7); // Bắt đầu vòng Thụy Sĩ sau vòng bảng 1 tuần
            int swissRounds = 3; // Số vòng đấu Thụy Sĩ

            for (int round = 1; round <= swissRounds; round++)
            {
                for (int i = 0; i < groupCount; i++)
                {
                    var match = new Match
                    {
                        TournamentId = tournament.Id,
                        MatchDate = matchDate.AddDays(round - 1),
                        TeamA = "TBD", // To Be Determined
                        TeamB = "TBD",
                        Status = $"Thụy Sĩ - Vòng {round}" // Lưu thông tin vòng đấu vào Status (tạm thời)
                    };

                    matches.Add(match);
                }
            }

            return matches;
        }

        /// <summary>
        /// Tạo lịch thi đấu theo thể thức vòng bảng
        /// </summary>
        private List<Match> GenerateGroupStageSchedule(Tournament tournament, List<Team> teams)
        {
            List<Match> matches = new List<Match>();

            // Tạo các bảng đấu
            int teamsPerGroup = tournament.TeamsPerGroup ?? 4;
            int groupCount = (int)Math.Ceiling((double)teams.Count / teamsPerGroup);

            // Chia các đội vào các bảng
            List<List<Team>> groups = new List<List<Team>>();
            for (int i = 0; i < groupCount; i++)
            {
                groups.Add(new List<Team>());
            }

            for (int i = 0; i < teams.Count; i++)
            {
                groups[i % groupCount].Add(teams[i]);
            }

            // Tạo lịch thi đấu cho từng bảng
            DateTime matchDate = tournament.StartDate;
            int groupMatchCount = 0;

            for (int groupIndex = 0; groupIndex < groups.Count; groupIndex++)
            {
                var groupTeams = groups[groupIndex];
                var groupMatches = GenerateRoundRobinSchedule(tournament, groupTeams);

                // Cập nhật thông tin bảng đấu
                foreach (var match in groupMatches)
                {
                    // Lưu thông tin bảng đấu vào Status (tạm thời)
                    match.Status = $"Bảng {(char)('A' + groupIndex)} - {match.Status}";
                    match.MatchDate = matchDate.AddDays(groupMatchCount % 3); // Mỗi ngày tối đa 3 trận
                    groupMatchCount++;
                }

                matches.AddRange(groupMatches);
            }

            return matches;
        }
    }
}
