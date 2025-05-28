﻿using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebQuanLyGiaiDau_NhomTD.Migrations
{
    /// <inheritdoc />
    public partial class AddMissingTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Tạo bảng Format
            migrationBuilder.CreateTable(
                name: "Formats",
                columns: table => new
                {
                    FormatId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FormatName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Formats", x => x.FormatId);
                });

            // Tạo bảng Stage
            migrationBuilder.CreateTable(
                name: "Stages",
                columns: table => new
                {
                    StageId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StageName = table.Column<string>(type: "nvarchar(225)", maxLength: 225, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Stages", x => x.StageId);
                });

            // Tạo bảng StageDetail
            migrationBuilder.CreateTable(
                name: "StageDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StageId = table.Column<int>(type: "int", nullable: false),
                    FormatId = table.Column<int>(type: "int", nullable: false),
                    TournamentId = table.Column<int>(type: "int", nullable: false),
                    Order = table.Column<int>(type: "int", nullable: true),
                    StartDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    EndDate = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StageDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StageDetails_Formats_FormatId",
                        column: x => x.FormatId,
                        principalTable: "Formats",
                        principalColumn: "FormatId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StageDetails_Stages_StageId",
                        column: x => x.StageId,
                        principalTable: "Stages",
                        principalColumn: "StageId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StageDetails_Tournaments_TournamentId",
                        column: x => x.TournamentId,
                        principalTable: "Tournaments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            // Tạo bảng SportDetail
            migrationBuilder.CreateTable(
                name: "SportDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TournamentId = table.Column<int>(type: "int", nullable: false),
                    SportId = table.Column<int>(type: "int", nullable: false),
                    Rules = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    MaxTeams = table.Column<int>(type: "int", nullable: true),
                    PlayersPerTeam = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SportDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SportDetails_Sports_SportId",
                        column: x => x.SportId,
                        principalTable: "Sports",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_SportDetails_Tournaments_TournamentId",
                        column: x => x.TournamentId,
                        principalTable: "Tournaments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            // Tạo bảng CoachDetail
            migrationBuilder.CreateTable(
                name: "CoachDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TeamId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    CoachName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Experience = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CoachDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CoachDetails_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CoachDetails_Teams_TeamId",
                        column: x => x.TeamId,
                        principalTable: "Teams",
                        principalColumn: "TeamId",
                        onDelete: ReferentialAction.Cascade);
                });

            // Tạo bảng Standing
            migrationBuilder.CreateTable(
                name: "Standings",
                columns: table => new
                {
                    StandingId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TournamentId = table.Column<int>(type: "int", nullable: false),
                    SportId = table.Column<int>(type: "int", nullable: false),
                    GroupName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LastUpdated = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Standings", x => x.StandingId);
                    table.ForeignKey(
                        name: "FK_Standings_Sports_SportId",
                        column: x => x.SportId,
                        principalTable: "Sports",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Standings_Tournaments_TournamentId",
                        column: x => x.TournamentId,
                        principalTable: "Tournaments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            // Tạo bảng StandingDetail
            migrationBuilder.CreateTable(
                name: "StandingDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StandingId = table.Column<int>(type: "int", nullable: false),
                    TeamId = table.Column<int>(type: "int", nullable: false),
                    NumberOfWins = table.Column<int>(type: "int", nullable: false),
                    NumberOfLoses = table.Column<int>(type: "int", nullable: false),
                    NumberOfDraws = table.Column<int>(type: "int", nullable: false),
                    PointsScored = table.Column<int>(type: "int", nullable: true),
                    PointsAgainst = table.Column<int>(type: "int", nullable: true),
                    Rank = table.Column<int>(type: "int", nullable: true),
                    TotalPoints = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StandingDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StandingDetails_Standings_StandingId",
                        column: x => x.StandingId,
                        principalTable: "Standings",
                        principalColumn: "StandingId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_StandingDetails_Teams_TeamId",
                        column: x => x.TeamId,
                        principalTable: "Teams",
                        principalColumn: "TeamId",
                        onDelete: ReferentialAction.Cascade);
                });

            // Tạo bảng PlayerDetail
            migrationBuilder.CreateTable(
                name: "PlayerDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PlayerId = table.Column<int>(type: "int", nullable: false),
                    TeamId = table.Column<int>(type: "int", nullable: false),
                    JerseyNumber = table.Column<int>(type: "int", nullable: true),
                    DateOfBirth = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Achievements = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TotalPoints = table.Column<int>(type: "int", nullable: true),
                    TotalAssists = table.Column<int>(type: "int", nullable: true),
                    TotalRebounds = table.Column<int>(type: "int", nullable: true),
                    GamesPlayed = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlayerDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PlayerDetails_Players_PlayerId",
                        column: x => x.PlayerId,
                        principalTable: "Players",
                        principalColumn: "PlayerId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_PlayerDetails_Teams_TeamId",
                        column: x => x.TeamId,
                        principalTable: "Teams",
                        principalColumn: "TeamId",
                        onDelete: ReferentialAction.NoAction);
                });

            // Tạo bảng MatchDetail
            migrationBuilder.CreateTable(
                name: "MatchDetails",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MatchId = table.Column<int>(type: "int", nullable: false),
                    Team1Id = table.Column<int>(type: "int", nullable: false),
                    Team2Id = table.Column<int>(type: "int", nullable: false),
                    ScoreTeam1 = table.Column<int>(type: "int", nullable: true),
                    ScoreTeam2 = table.Column<int>(type: "int", nullable: true),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MatchDetails", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MatchDetails_Matches_MatchId",
                        column: x => x.MatchId,
                        principalTable: "Matches",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MatchDetails_Teams_Team1Id",
                        column: x => x.Team1Id,
                        principalTable: "Teams",
                        principalColumn: "TeamId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MatchDetails_Teams_Team2Id",
                        column: x => x.Team2Id,
                        principalTable: "Teams",
                        principalColumn: "TeamId",
                        onDelete: ReferentialAction.Restrict);
                });

            // Tạo các index
            migrationBuilder.CreateIndex(
                name: "IX_CoachDetails_TeamId",
                table: "CoachDetails",
                column: "TeamId");

            migrationBuilder.CreateIndex(
                name: "IX_CoachDetails_UserId",
                table: "CoachDetails",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_MatchDetails_MatchId",
                table: "MatchDetails",
                column: "MatchId");

            migrationBuilder.CreateIndex(
                name: "IX_MatchDetails_Team1Id",
                table: "MatchDetails",
                column: "Team1Id");

            migrationBuilder.CreateIndex(
                name: "IX_MatchDetails_Team2Id",
                table: "MatchDetails",
                column: "Team2Id");

            migrationBuilder.CreateIndex(
                name: "IX_PlayerDetails_PlayerId",
                table: "PlayerDetails",
                column: "PlayerId");

            migrationBuilder.CreateIndex(
                name: "IX_PlayerDetails_TeamId",
                table: "PlayerDetails",
                column: "TeamId");

            migrationBuilder.CreateIndex(
                name: "IX_SportDetails_SportId",
                table: "SportDetails",
                column: "SportId");

            migrationBuilder.CreateIndex(
                name: "IX_SportDetails_TournamentId",
                table: "SportDetails",
                column: "TournamentId");

            migrationBuilder.CreateIndex(
                name: "IX_StageDetails_FormatId",
                table: "StageDetails",
                column: "FormatId");

            migrationBuilder.CreateIndex(
                name: "IX_StageDetails_StageId",
                table: "StageDetails",
                column: "StageId");

            migrationBuilder.CreateIndex(
                name: "IX_StageDetails_TournamentId",
                table: "StageDetails",
                column: "TournamentId");

            migrationBuilder.CreateIndex(
                name: "IX_StandingDetails_StandingId",
                table: "StandingDetails",
                column: "StandingId");

            migrationBuilder.CreateIndex(
                name: "IX_StandingDetails_TeamId",
                table: "StandingDetails",
                column: "TeamId");

            migrationBuilder.CreateIndex(
                name: "IX_Standings_SportId",
                table: "Standings",
                column: "SportId");

            migrationBuilder.CreateIndex(
                name: "IX_Standings_TournamentId",
                table: "Standings",
                column: "TournamentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CoachDetails");

            migrationBuilder.DropTable(
                name: "MatchDetails");

            migrationBuilder.DropTable(
                name: "PlayerDetails");

            migrationBuilder.DropTable(
                name: "SportDetails");

            migrationBuilder.DropTable(
                name: "StageDetails");

            migrationBuilder.DropTable(
                name: "StandingDetails");

            migrationBuilder.DropTable(
                name: "Formats");

            migrationBuilder.DropTable(
                name: "Stages");

            migrationBuilder.DropTable(
                name: "Standings");
        }
    }
}
