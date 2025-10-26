using System;
using System.Collections.Generic;

namespace WebQuanLyGiaiDau_NhomTD.TempModels;

public partial class Tournament
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public string Description { get; set; } = null!;

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public string? ImageUrl { get; set; }

    public int SportsId { get; set; }

    public string RegistrationStatus { get; set; } = null!;
}
