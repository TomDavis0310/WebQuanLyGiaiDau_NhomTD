using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class SeedBasketballData
    {
        public static void Main(string[] args)
        {
            // Create a service collection
            var services = new ServiceCollection();

            // Add the database context
            services.AddDbContext<ApplicationDbContext>(options =>
                options.UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=WebQuanLyGiaiDau_NhomTD;Trusted_Connection=True;MultipleActiveResultSets=true"));

            // Build the service provider
            var serviceProvider = services.BuildServiceProvider();

            // Get the database context
            using (var scope = serviceProvider.CreateScope())
            {
                var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
                
                try
                {
                    // Seed the basketball tournament data
                    SeedBasketballTournament.Initialize(context);
                    Console.WriteLine("Basketball tournament data seeded successfully!");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"An error occurred while seeding the database: {ex.Message}");
                }
            }
        }
    }
}
