namespace WebQuanLyGiaiDau_NhomTD.Repositories
{
    using WebQuanLyGiaiDau_NhomTD.Models;
    using System.Collections.Generic;
    using System.Threading.Tasks;
    using Microsoft.EntityFrameworkCore;
    public interface ITeamRepository
    {
        Task<IEnumerable<Team>> GetAllAsync();
        Task<Team> GetByIdAsync(int id);
        Task AddAsync(Team team);
        Task UpdateAsync(Team team);
        Task DeleteAsync(int id);
    }
}
