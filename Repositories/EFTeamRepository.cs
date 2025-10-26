namespace WebQuanLyGiaiDau_NhomTD.Repositories
{
    using WebQuanLyGiaiDau_NhomTD.Models;
    using Microsoft.EntityFrameworkCore;
    using System.Collections.Generic;
    using System.Threading.Tasks;

    public class EFTeamRepository : ITeamRepository
    {
        private readonly ApplicationDbContext _context;

        public EFTeamRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        // Lấy danh sách tất cả các đội
        public async Task<IEnumerable<Team>> GetAllAsync()
        {
            return await _context.Teams
                .Include(t => t.Players) // Bao gồm danh sách cầu thủ của đội
                .ToListAsync();
        }

        // Lấy thông tin đội theo ID
        public async Task<Team> GetByIdAsync(int id)
        {
            return await _context.Teams
                .Include(t => t.Players) // Bao gồm danh sách cầu thủ của đội
                .FirstOrDefaultAsync(t => t.TeamId == id);
        }

        // Thêm một đội mới
        public async Task AddAsync(Team team)
        {
            await _context.Teams.AddAsync(team);
            await _context.SaveChangesAsync();
        }

        // Cập nhật thông tin đội
        public async Task UpdateAsync(Team team)
        {
            var existingTeam = await _context.Teams.FindAsync(team.TeamId);
            if (existingTeam != null)
            {
                existingTeam.Name = team.Name;
                existingTeam.Coach = team.Coach;
                existingTeam.LogoUrl = team.LogoUrl;

                _context.Teams.Update(existingTeam);
                await _context.SaveChangesAsync();
            }
        }

        // Xóa đội theo ID
        public async Task DeleteAsync(int id)
        {
            var team = await _context.Teams.FindAsync(id);
            if (team != null)
            {
                _context.Teams.Remove(team);
                await _context.SaveChangesAsync();
            }
        }
    }
}
