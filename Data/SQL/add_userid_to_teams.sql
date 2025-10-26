-- Add missing UserId column to Teams table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Teams]') AND name = 'UserId')
BEGIN
    ALTER TABLE [dbo].[Teams]
    ADD [UserId] nvarchar(450) NULL
END

-- Print confirmation message
PRINT 'UserId column added to Teams table successfully.'