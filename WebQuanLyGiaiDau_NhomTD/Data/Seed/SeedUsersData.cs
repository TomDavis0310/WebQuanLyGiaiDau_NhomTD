using Microsoft.AspNetCore.Identity;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD.Data.Seed
{
    public static class SeedUsersData
    {
        public static async Task SeedUsers(IServiceProvider serviceProvider)
        {
            var userManager = serviceProvider.GetRequiredService<UserManager<ApplicationUser>>();
            var roleManager = serviceProvider.GetRequiredService<RoleManager<IdentityRole>>();

            // Tạo các roles nếu chưa có
            string[] roles = { "Admin", "User", "Organizer" };
            foreach (var role in roles)
            {
                if (!await roleManager.RoleExistsAsync(role))
                {
                    await roleManager.CreateAsync(new IdentityRole(role));
                    Console.WriteLine($"Đã tạo role: {role}");
                }
            }

            // Danh sách users cần tạo
            var usersToCreate = new List<(string Email, string Password, string FullName, string? PhoneNumber, string Role)>
            {
                // Admin users
                ("admin@tdsports.com", "Admin@123", "Quản Trị Viên", "0901234567", "Admin"),
                ("admin@example.com", "Admin123!", "Admin User", "0901234568", "Admin"),
                
                // Organizer users
                ("organizer1@tdsports.com", "Organizer@123", "Ban Tổ Chức 1", "0902345678", "Organizer"),
                ("organizer2@tdsports.com", "Organizer@123", "Ban Tổ Chức 2", "0902345679", "Organizer"),
                
                // Regular users
                ("user1@example.com", "User@123", "Nguyễn Văn A", "0903456789", "User"),
                ("user2@example.com", "User@123", "Trần Thị B", "0903456790", "User"),
                ("user3@example.com", "User@123", "Lê Văn C", "0903456791", "User"),
                ("user4@example.com", "User@123", "Phạm Thị D", "0903456792", "User"),
                ("user5@example.com", "User@123", "Hoàng Văn E", "0903456793", "User"),
                
                // Test users
                ("test@example.com", "Test@123", "Test User", "0904567890", "User"),
                ("demo@tdsports.com", "Demo@123", "Demo User", "0904567891", "User"),
            };

            int createdCount = 0;
            int existingCount = 0;

            foreach (var (email, password, fullName, phoneNumber, role) in usersToCreate)
            {
                // Kiểm tra user đã tồn tại chưa
                var existingUser = await userManager.FindByEmailAsync(email);
                if (existingUser == null)
                {
                    var user = new ApplicationUser
                    {
                        UserName = email,
                        Email = email,
                        EmailConfirmed = true,
                        FullName = fullName,
                        PhoneNumber = phoneNumber
                    };

                    var result = await userManager.CreateAsync(user, password);
                    
                    if (result.Succeeded)
                    {
                        await userManager.AddToRoleAsync(user, role);
                        Console.WriteLine($"✅ Đã tạo user: {email} - Role: {role}");
                        createdCount++;
                    }
                    else
                    {
                        Console.WriteLine($"❌ Lỗi khi tạo user {email}: {string.Join(", ", result.Errors.Select(e => e.Description))}");
                    }
                }
                else
                {
                    Console.WriteLine($"ℹ️ User đã tồn tại: {email}");
                    existingCount++;
                }
            }

            Console.WriteLine($"\n📊 Tổng kết seed users:");
            Console.WriteLine($"   - Đã tạo mới: {createdCount} users");
            Console.WriteLine($"   - Đã tồn tại: {existingCount} users");
            Console.WriteLine($"   - Tổng số users trong danh sách: {usersToCreate.Count}");
        }
    }
}
