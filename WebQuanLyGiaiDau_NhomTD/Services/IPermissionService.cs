using System.Security.Claims;

namespace WebQuanLyGiaiDau_NhomTD.Services
{
    /// <summary>
    /// Service interface for handling permission checks
    /// </summary>
    public interface IPermissionService
    {
        /// <summary>
        /// Checks if the user can manage a specific team
        /// </summary>
        Task<bool> CanUserManageTeamAsync(ClaimsPrincipal user, int teamId);

        /// <summary>
        /// Checks if the user can manage a specific tournament
        /// </summary>
        Task<bool> CanUserManageTournamentAsync(ClaimsPrincipal user, int tournamentId);

        /// <summary>
        /// Checks if the user can manage a specific player
        /// </summary>
        Task<bool> CanUserManagePlayerAsync(ClaimsPrincipal user, int playerId);

        /// <summary>
        /// Gets the current user ID from claims
        /// </summary>
        string GetUserId(ClaimsPrincipal user);

        /// <summary>
        /// Checks if the user is in a specific role
        /// </summary>
        bool IsInRole(ClaimsPrincipal user, string role);

        /// <summary>
        /// Checks if the user is admin
        /// </summary>
        bool IsAdmin(ClaimsPrincipal user);
    }
}
