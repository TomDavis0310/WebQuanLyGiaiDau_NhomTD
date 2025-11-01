﻿﻿namespace WebQuanLyGiaiDau_NhomTD.Models
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

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure the SportDetail entity to use NO ACTION for delete behavior
            modelBuilder.Entity<SportDetail>()
                .HasOne(sd => sd.Tournament)
                .WithMany()
                .HasForeignKey(sd => sd.TournamentId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<SportDetail>()
                .HasOne(sd => sd.Sport)
                .WithMany()
                .HasForeignKey(sd => sd.SportId)
                .OnDelete(DeleteBehavior.NoAction);
        }

        public DbSet<Team> Teams { get; set; }
        public DbSet<Player> Players { get; set; }
        public DbSet<Tournament> Tournaments { get; set; }

        public DbSet<Sports> Sports { get; set; }


        public DbSet<Match> Matches { get; set; }
        public DbSet<MatchSet> MatchSets { get; set; }
        public DbSet<Statistic> Statistics { get; set; }
        public DbSet<TournamentRegistration> TournamentRegistrations { get; set; }
        public DbSet<TournamentTeam> TournamentTeams { get; set; }

        public DbSet<News> News { get; set; }
        public DbSet<TournamentSubmission> TournamentSubmissions { get; set; }

        // Các bảng mới thêm vào
        public DbSet<Format> Formats { get; set; }
        public DbSet<Stage> Stages { get; set; }
        public DbSet<StageDetail> StageDetails { get; set; }
        public DbSet<SportDetail> SportDetails { get; set; }
        public DbSet<CoachDetail> CoachDetails { get; set; }
        public DbSet<Standing> Standings { get; set; }
        public DbSet<StandingDetail> StandingDetails { get; set; }
        public DbSet<PlayerDetail> PlayerDetails { get; set; }
        public DbSet<MatchDetail> MatchDetails { get; set; }
        public DbSet<TournamentFormat> TournamentFormats { get; set; }
        public DbSet<PlayerScoring> PlayerScorings { get; set; }
        public DbSet<Notification> Notifications { get; set; }
    }
}