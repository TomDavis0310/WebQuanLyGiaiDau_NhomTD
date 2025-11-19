using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using WebQuanLyGiaiDau_NhomTD.Models;
using WebQuanLyGiaiDau_NhomTD.Models.UserModel;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    /// <summary>
    /// Service for handling permission checks across the application
    /// </summary>
    public class PermissionService : IPermissionService
    {
        private readonly ApplicationDbContext _context;

        public PermissionService(ApplicationDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Gets the current user ID from claims
        /// </summary>
        public string GetUserId(ClaimsPrincipal user)
        {
            return user?.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        /// <summary>
        /// Checks if the user is in a specific role
        /// </summary>
        public bool IsInRole(ClaimsPrincipal user, string role)
        {
            return user?.IsInRole(role) ?? false;
        }

        /// <summary>
        /// Checks if the user is admin
        /// </summary>
        public bool IsAdmin(ClaimsPrincipal user)
        {
            return IsInRole(user, SD.Role_Admin);
        }

        /// <summary>
        /// Checks if the user can manage a specific team
        /// </summary>
        public async Task<bool> CanUserManageTeamAsync(ClaimsPrincipal user, int teamId)
        {
            // Admin can manage all teams
            if (IsAdmin(user))
            {
                return true;
            }

            var userId = GetUserId(user);
            if (string.IsNullOrEmpty(userId))
            {
                return false;
            }

            // Check if user is the coach/owner of the team
            var team = await _context.Teams.FindAsync(teamId);
            if (team != null && team.Coach == userId)
            {
                return true;
            }

            // Check if user has players in this team
            var hasPlayersInTeam = await _context.Players
                .AnyAsync(p => p.TeamId == teamId && p.UserId == userId);

            return hasPlayersInTeam;
        }

        /// <summary>
        /// Checks if the user can manage a specific tournament
        /// </summary>
        public async Task<bool> CanUserManageTournamentAsync(ClaimsPrincipal user, int tournamentId)
        {
            // Admin can manage all tournaments
            if (IsAdmin(user))
            {
                return true;
            }

            var userId = GetUserId(user);
            if (string.IsNullOrEmpty(userId))
            {
                return false;
            }

            // Check if user is the creator of the tournament
            var isTournamentCreator = await _context.TournamentRegistrations
                .AnyAsync(tr => tr.TournamentId == tournamentId && 
                               tr.UserId == userId && 
                               tr.Status == "Creator");

            return isTournamentCreator;
        }

        /// <summary>
        /// Checks if the user can manage a specific player
        /// </summary>
        public async Task<bool> CanUserManagePlayerAsync(ClaimsPrincipal user, int playerId)
        {
            // Admin can manage all players
            if (IsAdmin(user))
            {
                return true;
            }

            var userId = GetUserId(user);
            if (string.IsNullOrEmpty(userId))
            {
                return false;
            }

            // Get player's team
            var player = await _context.Players
                .Include(p => p.Team)
                .FirstOrDefaultAsync(p => p.PlayerId == playerId);

            if (player == null)
            {
                return false;
            }

            // Check if user is the coach of the player's team
            if (player.Team != null && player.Team.Coach == userId)
            {
                return true;
            }

            // Check if user is a player in the same team
            var isPlayerInTeam = await _context.Players
                .AnyAsync(p => p.TeamId == player.TeamId && p.UserId == userId);

            return isPlayerInTeam;
        }
    }
}
