# Script để tạo nhiều users thông qua API
$baseUrl = "http://localhost:5194/api/Auth/register"

# Danh sách users cần tạo
$users = @(
    @{
        email = "admin@tdsports.com"
        userName = "admin_tdsports"
        password = "Admin@123"
        confirmPassword = "Admin@123"
        fullName = "Quản Trị Viên TD Sports"
        phoneNumber = "0901234567"
    },
    @{
        email = "organizer1@tdsports.com"
        userName = "organizer1"
        password = "Organizer@123"
        confirmPassword = "Organizer@123"
        fullName = "Ban Tổ Chức 1"
        phoneNumber = "0902345678"
    },
    @{
        email = "organizer2@tdsports.com"
        userName = "organizer2"
        password = "Organizer@123"
        confirmPassword = "Organizer@123"
        fullName = "Ban Tổ Chức 2"
        phoneNumber = "0902345679"
    },
    @{
        email = "user1@example.com"
        userName = "user1"
        password = "User@123"
        confirmPassword = "User@123"
        fullName = "Nguyễn Văn A"
        phoneNumber = "0903456789"
    },
    @{
        email = "user2@example.com"
        userName = "user2"
        password = "User@123"
        confirmPassword = "User@123"
        fullName = "Trần Thị B"
        phoneNumber = "0903456790"
    },
    @{
        email = "user3@example.com"
        userName = "user3"
        password = "User@123"
        confirmPassword = "User@123"
        fullName = "Lê Văn C"
        phoneNumber = "0903456791"
    },
    @{
        email = "user4@example.com"
        userName = "user4"
        password = "User@123"
        confirmPassword = "User@123"
        fullName = "Phạm Thị D"
        phoneNumber = "0903456792"
    },
    @{
        email = "user5@example.com"
        userName = "user5"
        password = "User@123"
        confirmPassword = "User@123"
        fullName = "Hoàng Văn E"
        phoneNumber = "0903456793"
    },
    @{
        email = "test@example.com"
        userName = "testuser"
        password = "Test@123"
        confirmPassword = "Test@123"
        fullName = "Test User"
        phoneNumber = "0904567890"
    },
    @{
        email = "demo@tdsports.com"
        userName = "demouser"
        password = "Demo@123"
        confirmPassword = "Demo@123"
        fullName = "Demo User"
        phoneNumber = "0904567891"
    }
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   TẠO USERS CHO HỆ THỐNG TD SPORTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$successCount = 0
$failedCount = 0
$existingCount = 0

foreach ($user in $users) {
    Write-Host "Đang tạo user: $($user.email)..." -NoNewline
    
    try {
        $body = $user | ConvertTo-Json
        $response = Invoke-RestMethod -Uri $baseUrl `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -ErrorAction Stop
        
        if ($response.success -eq $true) {
            Write-Host " ✅ Thành công" -ForegroundColor Green
            $successCount++
        }
        elseif ($response.message -like "*đã được sử dụng*") {
            Write-Host " ℹ️  Đã tồn tại" -ForegroundColor Yellow
            $existingCount++
        }
        else {
            Write-Host " ❌ Thất bại: $($response.message)" -ForegroundColor Red
            $failedCount++
        }
    }
    catch {
        Write-Host " ❌ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
        $failedCount++
    }
    
    Start-Sleep -Milliseconds 500
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "           TỔNG KẾT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Tạo mới thành công: $successCount users" -ForegroundColor Green
Write-Host "ℹ️  Đã tồn tại trước đó: $existingCount users" -ForegroundColor Yellow
Write-Host "❌ Thất bại: $failedCount users" -ForegroundColor Red
Write-Host "📊 Tổng số users xử lý: $($users.Count) users" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     DANH SÁCH TẤT CẢ TÀI KHOẢN" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔑 ADMIN ACCOUNTS:" -ForegroundColor Magenta
Write-Host "   • admin@tdsports.com / Admin@123" -ForegroundColor White
Write-Host "   • admin@example.com / Admin123!" -ForegroundColor White
Write-Host ""
Write-Host "🎯 ORGANIZER ACCOUNTS:" -ForegroundColor Magenta
Write-Host "   • organizer1@tdsports.com / Organizer@123" -ForegroundColor White
Write-Host "   • organizer2@tdsports.com / Organizer@123" -ForegroundColor White
Write-Host ""
Write-Host "👥 USER ACCOUNTS:" -ForegroundColor Magenta
Write-Host "   • user1@example.com / User@123" -ForegroundColor White
Write-Host "   • user2@example.com / User@123" -ForegroundColor White
Write-Host "   • user3@example.com / User@123" -ForegroundColor White
Write-Host "   • user4@example.com / User@123" -ForegroundColor White
Write-Host "   • user5@example.com / User@123" -ForegroundColor White
Write-Host ""
Write-Host "🧪 TEST ACCOUNTS:" -ForegroundColor Magenta
Write-Host "   • test@example.com / Test@123" -ForegroundColor White
Write-Host "   • demo@tdsports.com / Demo@123" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Hoàn tất!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
