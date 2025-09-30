-- Add MatchTime column to Matches table if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Matches' AND COLUMN_NAME = 'MatchTime'
)
BEGIN
    ALTER TABLE Matches
    ADD MatchTime TIME NULL DEFAULT '15:00:00';

    PRINT 'MatchTime column added to Matches table with default value 15:00.';
END
ELSE
BEGIN
    PRINT 'MatchTime column already exists in Matches table.';
END

-- Add Location column to Matches table if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'Matches' AND COLUMN_NAME = 'Location'
)
BEGIN
    ALTER TABLE Matches
    ADD Location NVARCHAR(MAX) NULL;

    PRINT 'Location column added to Matches table.';
END
ELSE
BEGIN
    PRINT 'Location column already exists in Matches table.';
END
