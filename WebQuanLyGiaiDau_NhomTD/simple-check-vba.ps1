$baseUrl = "http://localhost:8080"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "KIỂM TRA DỮ LIỆU VBA 2025" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan

try {
    Write-Host "`nĐang kiểm tra API..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/api/TournamentApi" -Method GET
    
    if ($response -and $response.data) {
        $vbaTournament = $response.data | Where-Object { $_.name -match "VBA 2025" }
        
        if ($vbaTournament) {
            Write-Host "`n✅ Tìm thấy giải đấu VBA!" -ForegroundColor Green
            Write-Host "ID: $($vbaTournament.id)" -ForegroundColor White
            Write-Host "Tên: $($vbaTournament.name)" -ForegroundColor White
            Write-Host "Mô tả: $($vbaTournament.description)" -ForegroundColor White
            Write-Host "Truy cập: http://localhost:8080/Tournament/Details/$($vbaTournament.id)" -ForegroundColor Yellow
        } else {
            Write-Host "`n⚠️ Không tìm thấy giải đấu VBA 2025" -ForegroundColor Yellow
            Write-Host "Các giải đấu hiện có:" -ForegroundColor Gray
            foreach ($t in $response.data) {
                Write-Host "  - $($t.name) (ID: $($t.id))" -ForegroundColor Gray
            }
        }
    } else {
        Write-Host "`n❌ Không có dữ liệu trả về từ API" -ForegroundColor Red
    }
} catch {
    Write-Host "`n❌ Lỗi khi gọi API: $_" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Green