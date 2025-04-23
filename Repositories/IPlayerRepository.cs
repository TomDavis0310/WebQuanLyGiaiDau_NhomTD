namespace WebQuanLyGiaiDau_NhomTD.Repositories
{
    using WebQuanLyGiaiDau_NhomTD.Models;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using Microsoft.EntityFrameworkCore;
    using System.Linq.Expressions;
    public interface IPlayerRepository
    {
        Task<IEnumerable<Player>> GetAllAsync();
        Task<Player> GetByIdAsync(int id);
        Task AddAsync(Player player);
        Task UpdateAsync(Player player);
        Task DeleteAsync(int id);
    }
}
