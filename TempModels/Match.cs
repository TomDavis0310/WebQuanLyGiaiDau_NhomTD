using System;
using System.Collections.Generic;

namespace WebQuanLyGiaiDau_NhomTD.TempModels;

public partial class Match
{
    public int Id { get; set; }

    public string TeamA { get; set; } = null!;

    public string TeamB { get; set; } = null!;

    public DateTime MatchDate { get; set; }

    public int TournamentId { get; set; }

    public int? TeamId { get; set; }

    public bool IsCompleted { get; set; }

    public int? ScoreTeamA { get; set; }

    public int? ScoreTeamB { get; set; }
}
