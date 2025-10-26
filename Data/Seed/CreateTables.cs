using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;
using WebQuanLyGiaiDau_NhomTD.Models;

namespace WebQuanLyGiaiDau_NhomTD
{
    public class CreateTables
    {
        private readonly ApplicationDbContext _context;

        public CreateTables(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task CreateTablesAsync()
        {
            // Lấy connection string từ DbContext
            var connectionString = _context.Database.GetConnectionString();

            using (var connection = new SqlConnection(connectionString))
            {
                await connection.OpenAsync();

                // Thêm cột RegistrationStatus vào bảng Tournaments nếu chưa tồn tại
                var addRegistrationStatusColumnSql = @"
                    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tournaments]') AND name = 'RegistrationStatus')
                    BEGIN
                        ALTER TABLE [dbo].[Tournaments]
                        ADD [RegistrationStatus] nvarchar(max) NOT NULL DEFAULT 'Open'
                    END";

                using (var command = new SqlCommand(addRegistrationStatusColumnSql, connection))
                {
                    await command.ExecuteNonQueryAsync();
                }

                // Tạo bảng TournamentRegistrations nếu chưa tồn tại
                var createTournamentRegistrationsSql = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TournamentRegistrations]') AND type in (N'U'))
                    BEGIN
                        CREATE TABLE [dbo].[TournamentRegistrations](
                            [Id] [int] IDENTITY(1,1) NOT NULL,
                            [UserId] [nvarchar](450) NOT NULL,
                            [TournamentId] [int] NOT NULL,
                            [RegistrationDate] [datetime2](7) NOT NULL,
                            [Status] [nvarchar](max) NOT NULL,
                            [Notes] [nvarchar](max) NULL,
                            CONSTRAINT [PK_TournamentRegistrations] PRIMARY KEY CLUSTERED
                            (
                                [Id] ASC
                            )
                        )

                        ALTER TABLE [dbo].[TournamentRegistrations]  WITH CHECK ADD  CONSTRAINT [FK_TournamentRegistrations_AspNetUsers_UserId] FOREIGN KEY([UserId])
                        REFERENCES [dbo].[AspNetUsers] ([Id])
                        ON DELETE CASCADE

                        ALTER TABLE [dbo].[TournamentRegistrations] CHECK CONSTRAINT [FK_TournamentRegistrations_AspNetUsers_UserId]

                        ALTER TABLE [dbo].[TournamentRegistrations]  WITH CHECK ADD  CONSTRAINT [FK_TournamentRegistrations_Tournaments_TournamentId] FOREIGN KEY([TournamentId])
                        REFERENCES [dbo].[Tournaments] ([Id])
                        ON DELETE CASCADE

                        ALTER TABLE [dbo].[TournamentRegistrations] CHECK CONSTRAINT [FK_TournamentRegistrations_Tournaments_TournamentId]

                        CREATE NONCLUSTERED INDEX [IX_TournamentRegistrations_TournamentId] ON [dbo].[TournamentRegistrations]
                        (
                            [TournamentId] ASC
                        )

                        CREATE NONCLUSTERED INDEX [IX_TournamentRegistrations_UserId] ON [dbo].[TournamentRegistrations]
                        (
                            [UserId] ASC
                        )
                    END";

                using (var command = new SqlCommand(createTournamentRegistrationsSql, connection))
                {
                    await command.ExecuteNonQueryAsync();
                }

                // Tạo bảng TournamentTeams nếu chưa tồn tại
                var createTournamentTeamsSql = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TournamentTeams]') AND type in (N'U'))
                    BEGIN
                        CREATE TABLE [dbo].[TournamentTeams](
                            [Id] [int] IDENTITY(1,1) NOT NULL,
                            [TournamentId] [int] NOT NULL,
                            [TeamId] [int] NOT NULL,
                            [RegistrationDate] [datetime2](7) NOT NULL,
                            [Status] [nvarchar](max) NOT NULL,
                            [Notes] [nvarchar](max) NULL,
                            CONSTRAINT [PK_TournamentTeams] PRIMARY KEY CLUSTERED
                            (
                                [Id] ASC
                            )
                        )

                        ALTER TABLE [dbo].[TournamentTeams]  WITH CHECK ADD  CONSTRAINT [FK_TournamentTeams_Teams_TeamId] FOREIGN KEY([TeamId])
                        REFERENCES [dbo].[Teams] ([TeamId])
                        ON DELETE CASCADE

                        ALTER TABLE [dbo].[TournamentTeams] CHECK CONSTRAINT [FK_TournamentTeams_Teams_TeamId]

                        ALTER TABLE [dbo].[TournamentTeams]  WITH CHECK ADD  CONSTRAINT [FK_TournamentTeams_Tournaments_TournamentId] FOREIGN KEY([TournamentId])
                        REFERENCES [dbo].[Tournaments] ([Id])
                        ON DELETE CASCADE

                        ALTER TABLE [dbo].[TournamentTeams] CHECK CONSTRAINT [FK_TournamentTeams_Tournaments_TournamentId]

                        CREATE NONCLUSTERED INDEX [IX_TournamentTeams_TeamId] ON [dbo].[TournamentTeams]
                        (
                            [TeamId] ASC
                        )

                        CREATE NONCLUSTERED INDEX [IX_TournamentTeams_TournamentId] ON [dbo].[TournamentTeams]
                        (
                            [TournamentId] ASC
                        )
                    END";

                using (var command = new SqlCommand(createTournamentTeamsSql, connection))
                {
                    await command.ExecuteNonQueryAsync();
                }

                // Tạo bảng TournamentSubmissions nếu chưa tồn tại
                var createTournamentSubmissionsSql = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TournamentSubmissions]') AND type in (N'U'))
                    BEGIN
                        CREATE TABLE [dbo].[TournamentSubmissions](
                            [Id] [int] IDENTITY(1,1) NOT NULL,
                            [UserId] [nvarchar](450) NOT NULL,
                            [TournamentId] [int] NOT NULL,
                            [SubmissionDate] [datetime2](7) NOT NULL,
                            [Title] [nvarchar](200) NOT NULL,
                            [Content] [nvarchar](max) NOT NULL,
                            [FileUrl] [nvarchar](max) NULL,
                            [FileName] [nvarchar](max) NULL,
                            [Status] [nvarchar](max) NOT NULL,
                            [AdminNotes] [nvarchar](max) NULL,
                            CONSTRAINT [PK_TournamentSubmissions] PRIMARY KEY CLUSTERED
                            (
                                [Id] ASC
                            )
                        )

                        ALTER TABLE [dbo].[TournamentSubmissions] WITH CHECK ADD CONSTRAINT [FK_TournamentSubmissions_AspNetUsers_UserId] FOREIGN KEY([UserId])
                        REFERENCES [dbo].[AspNetUsers] ([Id])
                        ON DELETE CASCADE

                        ALTER TABLE [dbo].[TournamentSubmissions] CHECK CONSTRAINT [FK_TournamentSubmissions_AspNetUsers_UserId]

                        ALTER TABLE [dbo].[TournamentSubmissions] WITH CHECK ADD CONSTRAINT [FK_TournamentSubmissions_Tournaments_TournamentId] FOREIGN KEY([TournamentId])
                        REFERENCES [dbo].[Tournaments] ([Id])
                        ON DELETE CASCADE

                        ALTER TABLE [dbo].[TournamentSubmissions] CHECK CONSTRAINT [FK_TournamentSubmissions_Tournaments_TournamentId]

                        CREATE NONCLUSTERED INDEX [IX_TournamentSubmissions_TournamentId] ON [dbo].[TournamentSubmissions]
                        (
                            [TournamentId] ASC
                        )

                        CREATE NONCLUSTERED INDEX [IX_TournamentSubmissions_UserId] ON [dbo].[TournamentSubmissions]
                        (
                            [UserId] ASC
                        )
                    END";

                using (var command = new SqlCommand(createTournamentSubmissionsSql, connection))
                {
                    await command.ExecuteNonQueryAsync();
                }
            }
        }
    }
}
