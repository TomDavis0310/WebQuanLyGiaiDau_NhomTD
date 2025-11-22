-- Cập nhật điểm thưởng cho tài khoản doduong0949447395@gmail.com
-- Nạp 999,999 điểm

UPDATE AspNetUsers 
SET Points = 999999 
WHERE Email = 'doduong0949447395@gmail.com';

-- Kiểm tra kết quả
SELECT 
    Email, 
    FullName,
    Points,
    UserName
FROM AspNetUsers 
WHERE Email = 'doduong0949447395@gmail.com';

PRINT '✅ Đã nạp 999,999 điểm thưởng cho tài khoản doduong0949447395@gmail.com';
