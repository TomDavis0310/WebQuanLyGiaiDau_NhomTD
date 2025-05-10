namespace WebQuanLyGiaiDau_NhomTD.Models
{
    using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
    using Microsoft.CodeAnalysis.Elfie.Diagnostics;
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
        public DbSet<Tournament> Tournaments { get; set; }

        public DbSet<Sports> Sports { get; set; }


        public DbSet<Match> Matches { get; set; }
        public DbSet<Statistic> Statistics { get; set; }
        public DbSet<TournamentRegistration> TournamentRegistrations { get; set; }
        public DbSet<TournamentTeam> TournamentTeams { get; set; }

        public DbSet<News> News { get; set; }
        public DbSet<TournamentSubmission> TournamentSubmissions { get; set; }

    }
}