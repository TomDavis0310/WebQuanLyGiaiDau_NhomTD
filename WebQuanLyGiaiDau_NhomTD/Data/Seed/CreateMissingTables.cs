﻿using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class CreateMissingTables
    {
        private readonly ApplicationDbContext _context;

        public CreateMissingTables(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task CreateTablesAsync()
        {
            try
            {
                // Kiểm tra xem bảng Formats đã tồn tại chưa bằng cách sử dụng DbContext
                bool formatsTableExists = false;

                try
                {
                    // Sử dụng cách kiểm tra an toàn hơn
                    var result = await _context.Database.ExecuteSqlRawAsync(
                        "SELECT CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Formats') THEN 1 ELSE 0 END");
                    formatsTableExists = result > 0;

                    // Kiểm tra thêm bằng cách thử truy cập DbSet
                    try
                    {
                        var formatCount = await _context.Formats.CountAsync();
                        formatsTableExists = true; // Nếu không có lỗi, bảng tồn tại
                    }
                    catch
                    {
                        // Nếu có lỗi khi truy cập DbSet, có thể bảng chưa tồn tại
                        // Nhưng chúng ta đã kiểm tra bằng SQL rồi, nên giữ nguyên kết quả
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Lỗi khi kiểm tra bảng Formats: {ex.Message}");
                    formatsTableExists = false;
                }

                // Nếu bảng chưa tồn tại, tạo các bảng mới
                if (!formatsTableExists)
                {
                    Console.WriteLine("Bắt đầu tạo các bảng mới...");

                    // Sử dụng EF Core Migrations thay vì tạo bảng trực tiếp
                    // Đây là cách an toàn hơn để tạo bảng
                    Console.WriteLine("Các bảng sẽ được tạo thông qua EF Core Migrations.");
                    Console.WriteLine("Vui lòng chạy lệnh: dotnet ef database update");

                    // Không tạo bảng trực tiếp nữa, thay vào đó sử dụng migrations
                }
                else
                {
                    Console.WriteLine("Các bảng đã tồn tại, không cần tạo lại.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Lỗi khi tạo các bảng mới: {ex.Message}");
            }
        }
    }
}
