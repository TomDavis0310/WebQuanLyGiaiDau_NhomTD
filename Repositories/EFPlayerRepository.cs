namespace WebQuanLyGiaiDau_NhomTD.Repositories
{
    using WebQuanLyGiaiDau_NhomTD.Models;
    using Microsoft.EntityFrameworkCore;
    using System.Collections.Generic;
    using System.Threading.Tasks;

    public class EFPlayerRepository : IPlayerRepository
    {
        private readonly ApplicationDbContext _context;

        public EFPlayerRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        // Thêm một cầu thủ mới
        public async Task AddAsync(Player player)
        {
            await _context.Players.AddAsync(player);
            await _context.SaveChangesAsync();
        }

        // Xóa cầu thủ theo ID
        public async Task DeleteAsync(int id)
        {
            var player = await _context.Players.FindAsync(id);
            if (player != null)
            {
                _context.Players.Remove(player);
                await _context.SaveChangesAsync();
            }
        }

        // Lấy danh sách tất cả cầu thủ
        public async Task<IEnumerable<Player>> GetAllAsync()
        {
            return await _context.Players
                .Include(p => p.Team) // Bao gồm thông tin đội bóng
                .ToListAsync();
        }

        // Lấy thông tin cầu thủ theo ID
        public async Task<Player> GetByIdAsync(int id)
        {
            return await _context.Players
                .Include(p => p.Team) // Bao gồm thông tin đội bóng
                .FirstOrDefaultAsync(p => p.PlayerId == id);
        }

        // Cập nhật thông tin cầu thủ
        public async Task UpdateAsync(Player player)
        {
            var existingPlayer = await _context.Players.FindAsync(player.PlayerId);
            if (existingPlayer != null)
            {
                existingPlayer.FullName = player.FullName;
                existingPlayer.Position = player.Position;
                existingPlayer.Number = player.Number;
                existingPlayer.ImageUrl = player.ImageUrl;
                existingPlayer.TeamId = player.TeamId;

                _context.Players.Update(existingPlayer);
                await _context.SaveChangesAsync();
            }
        }
    }
}
