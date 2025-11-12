# ========================================
# SCRIPT THIẾT LẬP GIẢI ĐẤU VBA
# ========================================
# Script này sẽ tạo dữ liệu mẫu cho giải đấu VBA (Vietnam Basketball Association)
# Bao gồm: Giải đấu, đội bóng, cầu thủ, huấn luyện viên, trận đấu, video highlights

$baseUrl = "http://localhost:8080"
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "THIẾT LẬP DỮ LIỆU GIẢI ĐẤU VBA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to make API call
function Invoke-ApiCall {
    param(
        [string]$Method,
        [string]$Endpoint,
        [object]$Body = $null
    )
    
    try {
        $url = "$baseUrl$Endpoint"
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        if ($Body) {
            $jsonBody = $Body | ConvertTo-Json -Depth 10
            Write-Host "→ $Method $url" -ForegroundColor Yellow
            $response = Invoke-RestMethod -Uri $url -Method $Method -Headers $headers -Body $jsonBody
        } else {
            Write-Host "→ $Method $url" -ForegroundColor Yellow
            $response = Invoke-RestMethod -Uri $url -Method $Method -Headers $headers
        }
        
        Write-Host "✓ Success" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "✗ Error: $_" -ForegroundColor Red
        return $null
    }
}

# Function to get Sport ID for Basketball
function Get-BasketballSportId {
    Write-Host "`n--- Tìm ID môn Bóng rổ ---" -ForegroundColor Cyan
    $sports = Invoke-ApiCall -Method "GET" -Endpoint "/api/SportsApi"
    
    if ($sports -and $sports.data) {
        foreach ($sport in $sports.data) {
            if ($sport.name -match "Bóng rổ" -or $sport.name -match "Basketball") {
                Write-Host "✓ Tìm thấy môn Bóng rổ (ID: $($sport.id))" -ForegroundColor Green
                return $sport.id
            }
        }
    }
    
    Write-Host "✗ Không tìm thấy môn Bóng rổ" -ForegroundColor Red
    return $null
}

# ========================================
# 1. TẠO GIẢI ĐẤU VBA
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "1. TẠO GIẢI ĐẤU VBA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$sportsId = Get-BasketballSportId

if (-not $sportsId) {
    Write-Host "Không thể tiếp tục vì không tìm thấy môn Bóng rổ" -ForegroundColor Red
    exit 1
}

$tournament = @{
    name = "VBA 2025 - Vietnam Basketball Association"
    description = "Giải bóng rổ chuyên nghiệp hàng đầu Việt Nam mùa giải 2025. VBA là giải đấu bóng rổ cao cấp nhất tại Việt Nam, quy tụ các đội bóng mạnh nhất từ các tỉnh thành trên cả nước."
    location = "Nhà thi đấu Phú Thọ, TP.HCM & Cung thể thao Trịnh Hoài Đức, Hà Nội"
    startDate = "2025-03-15"
    endDate = "2025-08-30"
    imageUrl = "https://vba.vn/wp-content/uploads/2024/01/vba-2024-logo.jpg"
    sportsId = $sportsId
    maxTeams = 8
    teamsPerGroup = 4
}

Write-Host "`n→ Tạo giải đấu VBA..." -ForegroundColor Yellow
$tournamentResult = Invoke-ApiCall -Method "POST" -Endpoint "/Tournament/Create" -Body $tournament

if (-not $tournamentResult) {
    Write-Host "Không thể tạo giải đấu. Kiểm tra API endpoint." -ForegroundColor Red
    exit 1
}

# Get tournament ID (assume it's the latest one or from response)
Write-Host "`n→ Lấy ID giải đấu vừa tạo..." -ForegroundColor Yellow
$tournaments = Invoke-ApiCall -Method "GET" -Endpoint "/api/TournamentApi"
$vbaTournament = $tournaments.data | Where-Object { $_.name -match "VBA 2025" } | Select-Object -First 1

if (-not $vbaTournament) {
    Write-Host "Không tìm thấy giải đấu VBA vừa tạo" -ForegroundColor Red
    exit 1
}

$tournamentId = $vbaTournament.id
Write-Host "✓ Giải đấu VBA đã được tạo (ID: $tournamentId)" -ForegroundColor Green

# ========================================
# 2. TẠO CÁC ĐỘI BÓNG
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "2. TẠO CÁC ĐỘI BÓNG VBA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$teams = @(
    @{
        name = "Saigon Heat"
        coach = "HLV Nguyễn Minh Chiến"
        logoUrl = "https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Saigon_Heat_logo.svg/200px-Saigon_Heat_logo.svg.png"
    },
    @{
        name = "Hanoi Buffaloes"
        coach = "HLV Phạm Đức Thuận"
        logoUrl = "https://vba.vn/wp-content/uploads/2023/01/hanoi-buffaloes-logo.png"
    },
    @{
        name = "Danang Dragons"
        coach = "HLV Trần Quốc Tuấn"
        logoUrl = "https://vba.vn/wp-content/uploads/2023/01/danang-dragons-logo.png"
    },
    @{
        name = "Cantho Catfish"
        coach = "HLV Lê Văn Hùng"
        logoUrl = "https://vba.vn/wp-content/uploads/2023/01/cantho-catfish-logo.png"
    },
    @{
        name = "Nha Trang Dolphins"
        coach = "HLV Trương Minh Đức"
        logoUrl = "https://vba.vn/wp-content/uploads/2023/01/nhatrang-dolphins-logo.png"
    },
    @{
        name = "Thang Long Warriors"
        coach = "HLV Nguyễn Hải Đăng"
        logoUrl = "https://vba.vn/wp-content/uploads/2023/01/thanglong-warriors-logo.png"
    },
    @{
        name = "Ho Chi Minh City Wings"
        coach = "HLV Lê Hoàng Anh"
        logoUrl = "https://vba.vn/wp-content/uploads/2023/01/hcmc-wings-logo.png"
    },
    @{
        name = "Vung Tau Waves"
        coach = "HLV Phạm Văn Tùng"
        logoUrl = "https://vba.vn/wp-content/uploads/2023/01/vungtau-waves-logo.png"
    }
)

$teamIds = @{}

foreach ($team in $teams) {
    Write-Host "`n→ Tạo đội: $($team.name)" -ForegroundColor Yellow
    $teamResult = Invoke-ApiCall -Method "POST" -Endpoint "/Teams/Create" -Body $team
    
    if ($teamResult) {
        # Get the team ID
        Start-Sleep -Milliseconds 500
        $allTeams = Invoke-ApiCall -Method "GET" -Endpoint "/api/TeamsApi"
        $createdTeam = $allTeams.data | Where-Object { $_.name -eq $team.name } | Select-Object -First 1
        
        if ($createdTeam) {
            $teamIds[$team.name] = $createdTeam.teamId
            Write-Host "✓ Đội $($team.name) đã được tạo (ID: $($createdTeam.teamId))" -ForegroundColor Green
        }
    }
}

# ========================================
# 3. TẠO CẦU THỦ CHO MỖI ĐỘI
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "3. TẠO CẦU THỦ CHO CÁC ĐỘI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$playerTemplates = @(
    @{ position = "Point Guard"; numbers = @(1, 2, 3) },
    @{ position = "Shooting Guard"; numbers = @(4, 5, 6) },
    @{ position = "Small Forward"; numbers = @(7, 8, 9) },
    @{ position = "Power Forward"; numbers = @(10, 11, 12) },
    @{ position = "Center"; numbers = @(13, 14, 15) }
)

$firstNames = @("Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Võ", "Đặng", "Bùi", "Đỗ")
$middleNames = @("Văn", "Thị", "Minh", "Quốc", "Đức", "Hoàng", "Hải", "Anh", "Tuấn", "Tấn")
$lastNames = @("Hưng", "Long", "Nam", "Khoa", "Dũng", "Thắng", "Phong", "Tài", "Kiên", "Đạt")

foreach ($teamName in $teamIds.Keys) {
    $teamId = $teamIds[$teamName]
    Write-Host "`n--- Tạo cầu thủ cho đội: $teamName (ID: $teamId) ---" -ForegroundColor Cyan
    
    $playerCount = 0
    foreach ($template in $playerTemplates) {
        foreach ($number in $template.numbers) {
            $playerCount++
            
            $firstName = $firstNames | Get-Random
            $middleName = $middleNames | Get-Random
            $lastName = $lastNames | Get-Random
            $fullName = "$firstName $middleName $lastName"
            
            $player = @{
                fullName = $fullName
                position = $template.position
                number = $number
                teamId = $teamId
                imageUrl = "https://via.placeholder.com/200x200?text=$number"
            }
            
            Write-Host "  → Cầu thủ #$number - $fullName ($($template.position))" -ForegroundColor Yellow
            $playerResult = Invoke-ApiCall -Method "POST" -Endpoint "/Players/Create" -Body $player
            
            if ($playerResult) {
                Write-Host "  ✓ Đã tạo" -ForegroundColor Green
            }
            
            Start-Sleep -Milliseconds 200
        }
    }
    
    Write-Host "✓ Đã tạo $playerCount cầu thủ cho đội $teamName" -ForegroundColor Green
}

# ========================================
# 4. TẠO LỊCH THI ĐẤU
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "4. TẠO LỊCH THI ĐẤU VBA 2025" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Sample YouTube video URLs for highlights
$sampleVideos = @(
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "https://www.youtube.com/watch?v=9bZkp7q19f0",
    "https://www.youtube.com/watch?v=kJQP7kiw5Fk",
    "https://www.youtube.com/watch?v=hT_nvWreIhg"
)

$matchesData = @()
$teamNamesList = $teamIds.Keys | ForEach-Object { $_ }
$startDate = Get-Date "2025-03-20"
$matchDay = 0

# Tạo vòng bảng (mỗi đội đấu với nhau 1 lần)
Write-Host "`n--- VÒNG BẢNG ---" -ForegroundColor Yellow
for ($i = 0; $i -lt $teamNamesList.Count; $i++) {
    for ($j = $i + 1; $j -lt $teamNamesList.Count; $j++) {
        $teamA = $teamNamesList[$i]
        $teamB = $teamNamesList[$j]
        
        $matchDate = $startDate.AddDays($matchDay * 2)
        $round = [Math]::Floor($matchDay / 4) + 1
        
        # Random scores for completed matches (past dates)
        $scoreA = $null
        $scoreB = $null
        if ($matchDate -lt (Get-Date)) {
            $scoreA = Get-Random -Minimum 70 -Maximum 110
            $scoreB = Get-Random -Minimum 70 -Maximum 110
        }
        
        $match = @{
            teamA = $teamA
            teamAId = $teamIds[$teamA]
            teamB = $teamB
            teamBId = $teamIds[$teamB]
            scoreTeamA = $scoreA
            scoreTeamB = $scoreB
            round = $round
            groupName = "Vòng Bảng"
            matchDate = $matchDate.ToString("yyyy-MM-dd")
            matchTime = "19:00:00"
            location = if ($matchDay % 2 -eq 0) { "Nhà thi đấu Phú Thọ, TP.HCM" } else { "Cung thể thao Trịnh Hoài Đức, Hà Nội" }
            tournamentId = $tournamentId
            highlightsVideoUrl = if ($scoreA) { $sampleVideos | Get-Random } else { $null }
            videoDescription = if ($scoreA) { "Highlights trận $teamA vs $teamB - VBA 2025" } else { $null }
        }
        
        $matchesData += $match
        $matchDay++
        
        Write-Host "  → Trận $matchDay : $teamA vs $teamB ($($match.matchDate))" -ForegroundColor Yellow
        $matchResult = Invoke-ApiCall -Method "POST" -Endpoint "/Match/Create" -Body $match
        
        if ($matchResult) {
            Write-Host "  ✓ Đã tạo" -ForegroundColor Green
        }
        
        Start-Sleep -Milliseconds 300
    }
}

Write-Host "`n✓ Đã tạo $($matchesData.Count) trận đấu" -ForegroundColor Green

# ========================================
# 5. TẠO TIN TỨC/BÀI VIẾT
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "5. TẠO TIN TỨC VBA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$newsArticles = @(
    @{
        title = "Khai mạc VBA 2025: Mùa giải đầy hứa hẹn"
        content = "Giải bóng rổ chuyên nghiệp VBA 2025 chính thức khai mạc với sự tham gia của 8 đội bóng mạnh nhất cả nước. Đây hứa hẹn sẽ là một mùa giải đầy kịch tính và hấp dẫn với nhiều cầu thủ tài năng."
        imageUrl = "https://vba.vn/wp-content/uploads/2024/01/vba-2024-opening.jpg"
        publishDate = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")
    },
    @{
        title = "Saigon Heat: Ứng cử viên nặng ký cho chức vô địch"
        content = "Với đội hình mạnh và kinh nghiệm dày dặn, Saigon Heat được đánh giá cao là ứng cử viên sáng giá nhất cho chức vô địch VBA 2025."
        imageUrl = "https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Saigon_Heat_logo.svg/200px-Saigon_Heat_logo.svg.png"
        publishDate = (Get-Date).AddDays(-25).ToString("yyyy-MM-dd")
    },
    @{
        title = "Hanoi Buffaloes tuyen them ngoai binh chat luong"
        content = "Hanoi Buffaloes vua hoan tat viec ky hop dong voi ngoai binh nguoi My Marcus Johnson, hua hen se la su bo sung quan trong cho doi."
        imageUrl = "https://vba.vn/wp-content/uploads/2023/01/hanoi-buffaloes-logo.png"
        publishDate = (Get-Date).AddDays(-20).ToString("yyyy-MM-dd")
    },
    @{
        title = "Lịch thi đấu VBA 2025 chính thức được công bố"
        content = "Ban tổ chức VBA đã công bố lịch thi đấu chính thức cho mùa giải 2025 với 56 trận đấu trong giai đoạn vòng bảng."
        imageUrl = "https://vba.vn/wp-content/uploads/2024/01/vba-schedule.jpg"
        publishDate = (Get-Date).AddDays(-15).ToString("yyyy-MM-dd")
    }
)

foreach ($news in $newsArticles) {
    Write-Host "`n→ Tạo tin: $($news.title)" -ForegroundColor Yellow
    $newsResult = Invoke-ApiCall -Method "POST" -Endpoint "/News/Create" -Body $news
    
    if ($newsResult) {
        Write-Host "✓ Đã tạo tin tức" -ForegroundColor Green
    }
    
    Start-Sleep -Milliseconds 300
}

# ========================================
# 6. KIỂM TRA DỮ LIỆU
# ========================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "6. KIỂM TRA DỮ LIỆU ĐÃ TẠO" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n→ Kiểm tra giải đấu..." -ForegroundColor Yellow
$checkTournament = Invoke-ApiCall -Method "GET" -Endpoint "/api/TournamentApi/$tournamentId"
if ($checkTournament -and $checkTournament.data) {
    Write-Host "✓ Giải đấu: $($checkTournament.data.name)" -ForegroundColor Green
}

Write-Host "`n→ Kiểm tra đội bóng..." -ForegroundColor Yellow
$checkTeams = Invoke-ApiCall -Method "GET" -Endpoint "/api/TeamsApi"
if ($checkTeams -and $checkTeams.data) {
    Write-Host "✓ Tổng số đội: $($checkTeams.data.Count)" -ForegroundColor Green
}

Write-Host "`n→ Kiểm tra trận đấu..." -ForegroundColor Yellow
$checkMatches = Invoke-ApiCall -Method "GET" -Endpoint "/api/MatchesApi/tournament/$tournamentId"
if ($checkMatches -and $checkMatches.data) {
    Write-Host "✓ Tổng số trận đấu: $($checkMatches.data.Count)" -ForegroundColor Green
}

# ========================================
# HOÀN THÀNH
# ========================================
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "✓ HOÀN TẤT THIẾT LẬP GIẢI ĐẤU VBA" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nDữ liệu đã được tạo:" -ForegroundColor Cyan
Write-Host "  • 1 Giải đấu VBA 2025" -ForegroundColor White
Write-Host "  • 8 Đội bóng" -ForegroundColor White
Write-Host "  • ~120 Cầu thủ (15 cầu thủ/đội)" -ForegroundColor White
Write-Host "  • 28 Trận đấu vòng bảng" -ForegroundColor White
Write-Host "  • 4 Bài tin tức" -ForegroundColor White

Write-Host "`nTruy cập web để kiểm tra:" -ForegroundColor Cyan
Write-Host "  → Trang chủ: http://localhost:8080/" -ForegroundColor Yellow
Write-Host "  → Giải đấu: http://localhost:8080/Tournament/Details/$tournamentId" -ForegroundColor Yellow
Write-Host "  → Danh sách đội: http://localhost:8080/Teams" -ForegroundColor Yellow
Write-Host "  → Lịch thi đấu: http://localhost:8080/Match" -ForegroundColor Yellow
Write-Host "  → API Swagger: http://localhost:8080/api-docs" -ForegroundColor Yellow

Write-Host "`n✓ Script hoàn thành!" -ForegroundColor Green
