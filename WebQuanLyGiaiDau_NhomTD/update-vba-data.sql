-- ========================================
-- SCRIPT CẬP NHẬT DỮ LIỆU VBA 2025
-- Sửa lại thông tin chính xác cho giải đấu VBA
-- ========================================
USE QLGDDB;
GO

-- Cập nhật thông tin giải đấu VBA với ID = 6
UPDATE Tournaments 
SET Name = N'VBA 2025 - Vietnam Basketball Association',
    Description = N'Giải bóng rổ chuyên nghiệp hàng đầu Việt Nam mùa giải 2025. VBA là giải đấu bóng rổ cao cấp nhất tại Việt Nam, quy tụ các đội bóng mạnh nhất từ các tỉnh thành trên cả nước với sự tham gia của nhiều cầu thủ tài năng và ngoại binh chất lượng cao.',
    Location = N'Nhà thi đấu Phú Thọ, TP.HCM & Cung thể thao Trịnh Hoài Đức, Hà Nội',
    StartDate = '2025-03-15',
    EndDate = '2025-08-30',
    ImageUrl = 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&h=600&fit=crop&crop=center',
    RegistrationStatus = 'Open',
    MaxTeams = 8,
    TeamsPerGroup = 4
WHERE Id = 6;

PRINT N'✅ Đã cập nhật thông tin giải đấu VBA 2025';

-- Kiểm tra kết quả
SELECT 
    Id,
    Name,
    Description,
    Location,
    StartDate,
    EndDate,
    ImageUrl,
    RegistrationStatus
FROM Tournaments 
WHERE Id = 6;

PRINT N'';
PRINT N'========================================';
PRINT N'CẬP NHẬT DỮ LIỆU VBA HOÀN TẤT!';
PRINT N'========================================';
PRINT N'Truy cập: http://localhost:8080/Tournament/Details/6';
PRINT N'========================================';