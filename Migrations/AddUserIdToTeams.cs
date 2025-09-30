using Microsoft.EntityFrameworkCore.Migrations;

namespace WebQuanLyGiaiDau_NhomTD.Migrations
{
    public partial class AddUserIdToTeams : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "UserId",
                table: "Teams",
                type: "nvarchar(450)",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "UserId",
                table: "Teams");
        }
    }
}