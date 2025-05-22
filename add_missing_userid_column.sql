-- Add missing UserId column to Players table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Players]') AND name = 'UserId')
BEGIN
    ALTER TABLE [dbo].[Players]
    ADD [UserId] nvarchar(450) NULL
END

-- Print confirmation message
PRINT 'Missing UserId column added to Players table successfully.'
