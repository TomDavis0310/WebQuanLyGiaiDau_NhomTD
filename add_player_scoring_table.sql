-- Add PlayerScorings table if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_NAME = 'PlayerScorings'
)
BEGIN
    CREATE TABLE [dbo].[PlayerScorings](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [MatchId] [int] NOT NULL,
        [PlayerId] [int] NOT NULL,
        [Points] [int] NOT NULL,
        [ScoringTime] [datetime2](7) NOT NULL,
        [Notes] [nvarchar](max) NULL,
        CONSTRAINT [PK_PlayerScorings] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_PlayerScorings_Matches_MatchId] FOREIGN KEY([MatchId]) REFERENCES [dbo].[Matches] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_PlayerScorings_Players_PlayerId] FOREIGN KEY([PlayerId]) REFERENCES [dbo].[Players] ([PlayerId]) ON DELETE CASCADE
    )
    
    CREATE INDEX [IX_PlayerScorings_MatchId] ON [dbo].[PlayerScorings] ([MatchId])
    CREATE INDEX [IX_PlayerScorings_PlayerId] ON [dbo].[PlayerScorings] ([PlayerId])
    
    PRINT 'PlayerScorings table created successfully.'
END
ELSE
BEGIN
    PRINT 'PlayerScorings table already exists.'
END
