using Microsoft.AspNetCore.SignalR;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class MatchHub : Hub
    {
        public async Task JoinMatchGroup(int matchId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"match_{matchId}");
        }

        public async Task LeaveMatchGroup(int matchId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"match_{matchId}");
        }

        public async Task SendScoreUpdate(int matchId, string teamA, string teamB, int scoreA, int scoreB)
        {
            await Clients.Group($"match_{matchId}").SendAsync("ScoreUpdated", new
            {
                matchId,
                teamA,
                teamB,
                scoreA,
                scoreB,
                timestamp = DateTime.Now
            });
        }

        public async Task SendMatchStatusUpdate(int matchId, string status)
        {
            await Clients.Group($"match_{matchId}").SendAsync("MatchStatusUpdated", new
            {
                matchId,
                status,
                timestamp = DateTime.Now
            });
        }
    }
}
