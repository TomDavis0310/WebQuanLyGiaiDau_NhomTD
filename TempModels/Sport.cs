using System;
using System.Collections.Generic;

namespace WebQuanLyGiaiDau_NhomTD.TempModels;

public partial class Sport
{
    public int Id { get; set; }

    public string Name { get; set; } = null!;

    public string? ImageUrl { get; set; }
}
