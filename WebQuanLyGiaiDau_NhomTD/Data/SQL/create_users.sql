-- Script tạo users trực tiếp trong database
-- Chạy script này trong SQL Server Management Studio hoặc Azure Data Studio

USE [qlgddb];
GO

-- Tạo thêm users vào AspNetUsers
-- Lưu ý: Password đã được hash bằng ASP.NET Identity

-- Hàm hash password (chỉ mô phỏng, thực tế cần dùng Identity)
-- Các password hash dưới đây tương ứng với:
-- Admin@123, Organizer@123, User@123, Test@123, Demo@123

DECLARE @AdminId1 NVARCHAR(450) = NEWID();
DECLARE @AdminId2 NVARCHAR(450) = NEWID();
DECLARE @OrganizerId1 NVARCHAR(450) = NEWID();
DECLARE @OrganizerId2 NVARCHAR(450) = NEWID();
DECLARE @UserId1 NVARCHAR(450) = NEWID();
DECLARE @UserId2 NVARCHAR(450) = NEWID();
DECLARE @UserId3 NVARCHAR(450) = NEWID();
DECLARE @UserId4 NVARCHAR(450) = NEWID();
DECLARE @UserId5 NVARCHAR(450) = NEWID();
DECLARE @TestUserId NVARCHAR(450) = NEWID();
DECLARE @DemoUserId NVARCHAR(450) = NEWID();

-- Chèn users (sử dụng password hash mẫu - CHÚ Ý: Cần tạo qua API để có hash đúng)
-- Dưới đây chỉ là cấu trúc mẫu, cần chạy API register để có password hash chính xác

-- Admin users
IF NOT EXISTS (SELECT 1 FROM AspNetUsers WHERE Email = 'admin@tdsports.com')
BEGIN
    INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PhoneNumber, FullName, PasswordHash, SecurityStamp, ConcurrencyStamp, AccessFailedCount, LockoutEnabled, TwoFactorEnabled, PhoneNumberConfirmed)
    VALUES (@AdminId1, 'admin@tdsports.com', 'ADMIN@TDSPORTS.COM', 'admin@tdsports.com', 'ADMIN@TDSPORTS.COM', 1, '0901234567', N'Quản Trị Viên TD Sports', 
            'AQAAAAIAAYagAAAAEDummyHashNeedToUseAPIForRealHash==', NEWID(), NEWID(), 0, 1, 0, 1);
    PRINT 'Đã tạo user: admin@tdsports.com';
END
ELSE
    PRINT 'User đã tồn tại: admin@tdsports.com';

-- Organizer users
IF NOT EXISTS (SELECT 1 FROM AspNetUsers WHERE Email = 'organizer1@tdsports.com')
BEGIN
    INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PhoneNumber, FullName, PasswordHash, SecurityStamp, ConcurrencyStamp, AccessFailedCount, LockoutEnabled, TwoFactorEnabled, PhoneNumberConfirmed)
    VALUES (@OrganizerId1, 'organizer1@tdsports.com', 'ORGANIZER1@TDSPORTS.COM', 'organizer1@tdsports.com', 'ORGANIZER1@TDSPORTS.COM', 1, '0902345678', N'Ban Tổ Chức 1', 
            'AQAAAAIAAYagAAAAEDummyHashNeedToUseAPIForRealHash==', NEWID(), NEWID(), 0, 1, 0, 1);
    PRINT 'Đã tạo user: organizer1@tdsports.com';
END
ELSE
    PRINT 'User đã tồn tại: organizer1@tdsports.com';

IF NOT EXISTS (SELECT 1 FROM AspNetUsers WHERE Email = 'organizer2@tdsports.com')
BEGIN
    INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PhoneNumber, FullName, PasswordHash, SecurityStamp, ConcurrencyStamp, AccessFailedCount, LockoutEnabled, TwoFactorEnabled, PhoneNumberConfirmed)
    VALUES (@OrganizerId2, 'organizer2@tdsports.com', 'ORGANIZER2@TDSPORTS.COM', 'organizer2@tdsports.com', 'ORGANIZER2@TDSPORTS.COM', 1, '0902345679', N'Ban Tổ Chức 2', 
            'AQAAAAIAAYagAAAAEDummyHashNeedToUseAPIForRealHash==', NEWID(), NEWID(), 0, 1, 0, 1);
    PRINT 'Đã tạo user: organizer2@tdsports.com';
END
ELSE
    PRINT 'User đã tồn tại: organizer2@tdsports.com';

-- Regular users
IF NOT EXISTS (SELECT 1 FROM AspNetUsers WHERE Email = 'user1@example.com')
BEGIN
    INSERT INTO AspNetUsers (Id, UserName, NormalizedUserName, Email, NormalizedEmail, EmailConfirmed, PhoneNumber, FullName, PasswordHash, SecurityStamp, ConcurrencyStamp, AccessFailedCount, LockoutEnabled, TwoFactorEnabled, PhoneNumberConfirmed)
    VALUES (@UserId1, 'user1@example.com', 'USER1@EXAMPLE.COM', 'user1@example.com', 'USER1@EXAMPLE.COM', 1, '0903456789', N'Nguyễn Văn A', 
            'AQAAAAIAAYagAAAAEDummyHashNeedToUseAPIForRealHash==', NEWID(), NEWID(), 0, 1, 0, 1);
    PRINT 'Đã tạo user: user1@example.com';
END
ELSE
    PRINT 'User đã tồn tại: user1@example.com';

-- (Tiếp tục cho các users khác...)

GO

PRINT '';
PRINT '========================================';
PRINT '           HOÀN TẤT';
PRINT '========================================';
PRINT 'LƯU Ý: Password hash trong script này chỉ là mẫu!';
PRINT 'Để tạo users với password thực, vui lòng:';
PRINT '1. Khởi động backend API';
PRINT '2. Chạy script PowerShell: .\create-users.ps1';
PRINT 'HOẶC';
PRINT '3. Sử dụng API /api/Auth/register để đăng ký';
PRINT '========================================';
GO
