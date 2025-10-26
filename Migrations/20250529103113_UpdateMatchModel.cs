using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebQuanLyGiaiDau_NhomTD.Migrations
{
    /// <inheritdoc />
    public partial class UpdateMatchModel : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CoachDetails_Teams_TeamId",
                table: "CoachDetails");

            migrationBuilder.AddColumn<string>(
                name: "HighlightsVideoUrl",
                table: "Matches",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "LiveStreamUrl",
                table: "Matches",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "VideoDescription",
                table: "Matches",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_CoachDetails_Teams_TeamId",
                table: "CoachDetails",
                column: "TeamId",
                principalTable: "Teams",
                principalColumn: "TeamId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CoachDetails_Teams_TeamId",
                table: "CoachDetails");

            migrationBuilder.DropColumn(
                name: "HighlightsVideoUrl",
                table: "Matches");

            migrationBuilder.DropColumn(
                name: "LiveStreamUrl",
                table: "Matches");

            migrationBuilder.DropColumn(
                name: "VideoDescription",
                table: "Matches");

            migrationBuilder.AddForeignKey(
                name: "FK_CoachDetails_Teams_TeamId",
                table: "CoachDetails",
                column: "TeamId",
                principalTable: "Teams",
                principalColumn: "TeamId");
        }
    }
}
