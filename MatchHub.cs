using Microsoft.AspNetCore.SignalR;

public class MatchHub : Hub
{
    public async Task SendMatchUpdate(string matchId, string score)
    {
        await Clients.All.SendAsync("ReceiveMatchUpdate", matchId, score);
    }
}
