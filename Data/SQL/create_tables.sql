-- Thêm cột RegistrationStatus vào bảng Tournaments nếu chưa tồn tại
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Tournaments]') AND name = 'RegistrationStatus')
BEGIN
    ALTER TABLE [dbo].[Tournaments]
    ADD [RegistrationStatus] nvarchar(max) NOT NULL DEFAULT 'Open'
END

-- Tạo bảng TournamentRegistrations nếu chưa tồn tại
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
END

-- Tạo bảng TournamentTeams nếu chưa tồn tại
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
END
