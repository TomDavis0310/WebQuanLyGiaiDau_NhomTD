namespace WebQuanLyGiaiDau_NhomTD.Models
{
    using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
    // Data/AppDbContext.cs
    using Microsoft.EntityFrameworkCore;
    using Microsoft.VisualStudio.Web.CodeGenerators.Mvc.Templates.General;
    using System.Collections.Generic;
    using System.Numerics;

    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<Team> Teams { get; set; }
        public DbSet<Player> Players { get; set; }
    }
}