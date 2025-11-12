using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebQuanLyGiaiDau_NhomTD.Migrations.PointsShopMigrations
{
    /// <inheritdoc />
    public partial class AddRedeemTransaction_v2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "UserId",
                table: "RedeemTransactions",
                type: "nvarchar(450)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(max)");

            migrationBuilder.CreateIndex(
                name: "IX_RedeemTransactions_UserId",
                table: "RedeemTransactions",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_RedeemTransactions_AspNetUsers_UserId",
                table: "RedeemTransactions",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RedeemTransactions_AspNetUsers_UserId",
                table: "RedeemTransactions");

            migrationBuilder.DropIndex(
                name: "IX_RedeemTransactions_UserId",
                table: "RedeemTransactions");

            migrationBuilder.AlterColumn<string>(
                name: "UserId",
                table: "RedeemTransactions",
                type: "nvarchar(max)",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)");
        }
    }
}
