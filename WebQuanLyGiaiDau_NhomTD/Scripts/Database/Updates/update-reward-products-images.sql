-- Script để cập nhật ImageUrl cho các RewardProducts đã tồn tại
-- Chạy script này trong SQL Server Management Studio hoặc qua dotnet ef

-- Cập nhật ImageUrl cho từng sản phẩm dựa trên tên
UPDATE RewardProducts SET ImageUrl = '/image/Sticker TDSports.jpg' WHERE Name = 'Sticker TDSports';
UPDATE RewardProducts SET ImageUrl = '/image/Móc khóa Bóng Rổ.jpg' WHERE Name = 'Móc khóa Bóng Rổ';
UPDATE RewardProducts SET ImageUrl = '/image/Băng đô thể thao.jpg' WHERE Name = 'Băng đô thể thao';
UPDATE RewardProducts SET ImageUrl = '/image/Tất thể thao TDSports.jpg' WHERE Name = 'Tất thể thao TDSports';
UPDATE RewardProducts SET ImageUrl = '/image/Khăn lau mồ hôi thể thao.jpg' WHERE Name = 'Khăn lau mồ hôi thể thao';
UPDATE RewardProducts SET ImageUrl = '/image/Bình nước thể thao 500ml.jpg' WHERE Name = 'Bình nước thể thao 500ml';
UPDATE RewardProducts SET ImageUrl = '/image/Băng quấn cổ tay.jpg' WHERE Name = 'Băng quấn cổ tay';
UPDATE RewardProducts SET ImageUrl = '/image/Túi đựng giày thể thao.jpg' WHERE Name = 'Túi đựng giày thể thao';
UPDATE RewardProducts SET ImageUrl = '/image/Găng tay thể thao.jpg' WHERE Name = 'Găng tay thể thao';
UPDATE RewardProducts SET ImageUrl = '/image/Áo thun thể thao TDSports.jpg' WHERE Name = 'Áo thun thể thao TDSports';
UPDATE RewardProducts SET ImageUrl = '/image/Bình nước thể thao 1L.jpg' WHERE Name = 'Bình nước thể thao 1L';
UPDATE RewardProducts SET ImageUrl = '/image/Túi thể thao đeo chéo.jpg' WHERE Name = 'Túi thể thao đeo chéo';

-- Kiểm tra kết quả
SELECT Id, Name, PointsCost, ImageUrl FROM RewardProducts ORDER BY PointsCost;
