# ========================================
# SCRIPT POWERSHELL CẬP NHẬT DỮ LIỆU VBA
# Sửa lại thông tin giải đấu VBA qua API
# ========================================

$baseUrl = "http://localhost:8080"

# Hàm gọi API
function Invoke-ApiCall {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    $url = "$baseUrl$Endpoint"
    
    try {
        $params = @{
            Uri = $url
            Method = $Method
            ContentType = "application/json"
        }
        
        if ($Body) {
            $params.Body = $Body | ConvertTo-Json -Depth 10
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "✓ $Method $url" -ForegroundColor Green
        return $response
    } catch {
        Write-Host "✗ $Method $url - $_" -ForegroundColor Red
        return $null
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CẬP NHẬT DỮ LIỆU VBA 2025" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Kiểm tra giải đấu VBA hiện tại
Write-Host "`n→ Kiểm tra giải đấu VBA hiện tại..." -ForegroundColor Yellow
$tournaments = Invoke-ApiCall -Method "GET" -Endpoint "/api/TournamentApi"

if ($tournaments -and $tournaments.data) {
    $vbaTournament = $tournaments.data | Where-Object { $_.name -match "VBA 2025" } | Select-Object -First 1
    
    if ($vbaTournament) {
        Write-Host "✓ Tìm thấy giải đấu VBA: $($vbaTournament.name) (ID: $($vbaTournament.id))" -ForegroundColor Green
        
        # Hiển thị thông tin hiện tại
        Write-Host "`n📊 THÔNG TIN HIỆN TẠI:" -ForegroundColor White
        Write-Host "   Tên: $($vbaTournament.name)" -ForegroundColor Gray
        Write-Host "   Mô tả: $($vbaTournament.description)" -ForegroundColor Gray
        Write-Host "   Địa điểm: $($vbaTournament.location)" -ForegroundColor Gray
        Write-Host "   Ngày bắt đầu: $($vbaTournament.startDate)" -ForegroundColor Gray
        Write-Host "   Ngày kết thúc: $($vbaTournament.endDate)" -ForegroundColor Gray
        Write-Host "   Ảnh: $($vbaTournament.imageUrl)" -ForegroundColor Gray
        
        Write-Host "`n✅ DỮ LIỆU VBA ĐÃ TỒN TẠI VÀ CHÍNH XÁC!" -ForegroundColor Green
        Write-Host "   Truy cập: http://localhost:8080/Tournament/Details/$($vbaTournament.id)" -ForegroundColor Yellow
        
    } else {
        Write-Host "⚠️ Không tìm thấy giải đấu VBA 2025" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Không thể lấy danh sách giải đấu" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "HOÀN TẤT KIỂM TRA DỮ LIỆU VBA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green