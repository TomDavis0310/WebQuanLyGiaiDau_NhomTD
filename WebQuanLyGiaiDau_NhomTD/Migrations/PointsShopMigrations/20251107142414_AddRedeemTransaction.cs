using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace WebQuanLyGiaiDau_NhomTD.Migrations.PointsShopMigrations
{
    /// <inheritdoc />
    public partial class AddRedeemTransaction : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "RedeemTransactions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    PointsCost = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RedeemTransactions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RedeemTransactions_RewardProducts_ProductId",
                        column: x => x.ProductId,
                        principalTable: "RewardProducts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RedeemTransactions_ProductId",
                table: "RedeemTransactions",
                column: "ProductId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RedeemTransactions");
        }
    }
}
