-- Add Location column to Tournaments table if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Tournaments' AND COLUMN_NAME = 'Location'
)
BEGIN
    ALTER TABLE Tournaments
    ADD Location NVARCHAR(MAX) NULL;
    
    PRINT 'Location column added to Tournaments table.';
END
ELSE
BEGIN
    PRINT 'Location column already exists in Tournaments table.';
END
