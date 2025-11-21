﻿namespace WebQuanLyGiaiDau_NhomTD.Models
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

            // Ensure deleting a Team does NOT cascade-delete Players, and vice-versa.
            // By default EF created cascade on the Player -> Team FK. We explicitly set
            // SetNull so when a Team is deleted, Players' TeamId is set to NULL.
            modelBuilder.Entity<Player>()
                .HasOne(p => p.Team)
                .WithMany(t => t.Players)
                .HasForeignKey(p => p.TeamId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure TournamentTeam relationship:
            // When a Tournament is deleted, TournamentTeam records are cascade-deleted (NO ACTION is safer, but we allow cascade here for cleanup)
            // When a Team is deleted, TournamentTeam records are cascade-deleted (NO ACTION to prevent Team deletion if registered)
            // This ensures Teams are NOT deleted when Tournament is deleted, and Teams CANNOT be deleted when registered in Tournament
            modelBuilder.Entity<TournamentTeam>()
                .HasOne(tt => tt.Tournament)
                .WithMany()
                .HasForeignKey(tt => tt.TournamentId)
                .OnDelete(DeleteBehavior.Cascade); // Deleting Tournament will delete TournamentTeam records

            modelBuilder.Entity<TournamentTeam>()
                .HasOne(tt => tt.Team)
                .WithMany()
                .HasForeignKey(tt => tt.TeamId)
                .OnDelete(DeleteBehavior.Restrict); // Prevent Team deletion if it has TournamentTeam records
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
        
        // Điểm thưởng và sản phẩm đổi điểm
        public DbSet<RewardProduct> RewardProducts { get; set; }
        public DbSet<PointsSetting> PointsSettings { get; set; }
    public DbSet<RedeemTransaction> RedeemTransactions { get; set; }
    }
}