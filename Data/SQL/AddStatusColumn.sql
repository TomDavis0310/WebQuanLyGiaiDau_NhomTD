-- Check if Status column exists
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Matches' AND COLUMN_NAME = 'Status'
)
BEGIN
    -- Add Status column if it doesn't exist
    ALTER TABLE Matches ADD Status nvarchar(50) NULL;
    
    -- Update existing records
    UPDATE Matches 
    SET Status = 
        CASE 
            WHEN MatchDate < GETDATE() THEN 'Completed'
            WHEN CAST(MatchDate AS DATE) = CAST(GETDATE() AS DATE) THEN 'InProgress'
            ELSE 'Upcoming'
        END;
    
    PRINT 'Status column added and updated successfully.';
END
ELSE
BEGIN
    PRINT 'Status column already exists.';
END
