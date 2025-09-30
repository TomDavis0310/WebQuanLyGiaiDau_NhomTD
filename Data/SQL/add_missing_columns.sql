-- Add missing columns to Matches table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Matches]') AND name = 'GroupName')
BEGIN
    ALTER TABLE [dbo].[Matches]
    ADD [GroupName] nvarchar(max) NULL
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Matches]') AND name = 'Round')
BEGIN
    ALTER TABLE [dbo].[Matches]
    ADD [Round] int NULL
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Matches]') AND name = 'TeamAId')
BEGIN
    ALTER TABLE [dbo].[Matches]
    ADD [TeamAId] int NULL
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Matches]') AND name = 'TeamBId')
BEGIN
    ALTER TABLE [dbo].[Matches]
    ADD [TeamBId] int NULL
END

-- Print confirmation message
PRINT 'Missing columns added to Matches table successfully.'
