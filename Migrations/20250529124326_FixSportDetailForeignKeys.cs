using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebQuanLyGiaiDau_NhomTD.Migrations
{
    /// <inheritdoc />
    public partial class FixSportDetailForeignKeys : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SportDetails_Sports_SportId",
                table: "SportDetails");

            migrationBuilder.DropForeignKey(
                name: "FK_SportDetails_Tournaments_TournamentId",
                table: "SportDetails");

            migrationBuilder.AddForeignKey(
                name: "FK_SportDetails_Sports_SportId",
                table: "SportDetails",
                column: "SportId",
                principalTable: "Sports",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_SportDetails_Tournaments_TournamentId",
                table: "SportDetails",
                column: "TournamentId",
                principalTable: "Tournaments",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SportDetails_Sports_SportId",
                table: "SportDetails");

            migrationBuilder.DropForeignKey(
                name: "FK_SportDetails_Tournaments_TournamentId",
                table: "SportDetails");

            migrationBuilder.AddForeignKey(
                name: "FK_SportDetails_Sports_SportId",
                table: "SportDetails",
                column: "SportId",
                principalTable: "Sports",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_SportDetails_Tournaments_TournamentId",
                table: "SportDetails",
                column: "TournamentId",
                principalTable: "Tournaments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
