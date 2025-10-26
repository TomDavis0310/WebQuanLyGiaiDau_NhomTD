using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebQuanLyGiaiDau_NhomTD.Migrations
{
    /// <inheritdoc />
    public partial class AddTournamentRegistrationAndTeamsTables : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Thêm cột RegistrationStatus vào bảng Tournaments
            migrationBuilder.AddColumn<string>(
                name: "RegistrationStatus",
                table: "Tournaments",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "Open");

            // Tạo bảng TournamentTeams
            migrationBuilder.CreateTable(
                name: "TournamentTeams",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TournamentId = table.Column<int>(type: "int", nullable: false),
                    TeamId = table.Column<int>(type: "int", nullable: false),
                    RegistrationDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TournamentTeams", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TournamentTeams_Teams_TeamId",
                        column: x => x.TeamId,
                        principalTable: "Teams",
                        principalColumn: "TeamId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_TournamentTeams_Tournaments_TournamentId",
                        column: x => x.TournamentId,
                        principalTable: "Tournaments",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            // Tạo index cho TournamentTeams
            // Index cho TournamentRegistrations đã được tạo ở migration trước đó
            migrationBuilder.CreateIndex(
                name: "IX_TournamentTeams_TeamId",
                table: "TournamentTeams",
                column: "TeamId");

            migrationBuilder.CreateIndex(
                name: "IX_TournamentTeams_TournamentId",
                table: "TournamentTeams",
                column: "TournamentId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Xóa bảng TournamentTeams
            migrationBuilder.DropTable(
                name: "TournamentTeams");

            // Xóa cột RegistrationStatus từ bảng Tournaments
            // Bảng TournamentRegistrations được xóa ở migration trước đó nếu rollback
            migrationBuilder.DropColumn(
                name: "RegistrationStatus",
                table: "Tournaments");
        }
    }
}
