# Setup VBA Tournament Data
# Run with: powershell -ExecutionPolicy Bypass -File setup-vba-data.ps1

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$baseUrl = "http://localhost:8080"
$ErrorActionPreference = "Continue"

Write-Host "========================================"
Write-Host "SETUP VBA TOURNAMENT DATA"
Write-Host "========================================"

function Invoke-Api {
    param($Method, $Endpoint, $Body = $null)
    try {
        $url = "$baseUrl$Endpoint"
        $headers = @{ "Content-Type" = "application/json; charset=utf-8" }
        if ($Body) {
            $json = $Body | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri $url -Method $Method -Headers $headers -Body ([System.Text.Encoding]::UTF8.GetBytes($json))
        } else {
            $response = Invoke-RestMethod -Uri $url -Method $Method -Headers $headers
        }
        Write-Host "OK: $Method $url" -ForegroundColor Green
        return $response
    } catch {
        Write-Host "ERROR: $Method $url - $_" -ForegroundColor Red
        return $null
    }
}

# 1. Get Basketball Sport ID
Write-Host "`n1. Finding Basketball Sport..."
$basketballId = 1
Write-Host "Basketball Sport ID: $basketballId"

# 2. Create VBA Tournament
Write-Host "`n2. Creating VBA Tournament..."
$tournament = @{
    name = "VBA 2025 - Vietnam Basketball Association"
    description = "Giai bong ro chuyen nghiep hang dau Viet Nam mua giai 2025"
    location = "Nha thi dau Phu Tho, TP.HCM"
    startDate = "2025-03-15"
    endDate = "2025-08-30"
    imageUrl = "https://vba.vn/wp-content/uploads/2024/01/vba-2024-logo.jpg"
    sportsId = $basketballId
    maxTeams = 8
    teamsPerGroup = 4
}
Invoke-Api -Method POST -Endpoint "/Tournament/Create" -Body $tournament
Start-Sleep -Seconds 1

# Get Tournament ID
$tournaments = Invoke-Api -Method GET -Endpoint "/api/TournamentApi"
$vbaTournament = $tournaments.data | Where-Object { $_.name -match "VBA 2025" } | Select-Object -First 1
$tournamentId = $vbaTournament.id
Write-Host "VBA Tournament ID: $tournamentId"

# 3. Create Teams
Write-Host "`n3. Creating Teams..."
$teams = @(
    @{ name = "Saigon Heat"; coach = "HLV Nguyen Minh Chien"; logoUrl = "https://upload.wikimedia.org/wikipedia/en/thumb/9/9c/Saigon_Heat_logo.svg/200px-Saigon_Heat_logo.svg.png" },
    @{ name = "Hanoi Buffaloes"; coach = "HLV Pham Duc Thuan"; logoUrl = "https://vba.vn/wp-content/uploads/2023/01/hanoi-buffaloes-logo.png" },
    @{ name = "Danang Dragons"; coach = "HLV Tran Quoc Tuan"; logoUrl = "https://vba.vn/wp-content/uploads/2023/01/danang-dragons-logo.png" },
    @{ name = "Cantho Catfish"; coach = "HLV Le Van Hung"; logoUrl = "https://vba.vn/wp-content/uploads/2023/01/cantho-catfish-logo.png" },
    @{ name = "Nha Trang Dolphins"; coach = "HLV Truong Minh Duc"; logoUrl = "https://vba.vn/wp-content/uploads/2023/01/nhatrang-dolphins-logo.png" },
    @{ name = "Thang Long Warriors"; coach = "HLV Nguyen Hai Dang"; logoUrl = "https://vba.vn/wp-content/uploads/2023/01/thanglong-warriors-logo.png" },
    @{ name = "HCM City Wings"; coach = "HLV Le Hoang Anh"; logoUrl = "https://vba.vn/wp-content/uploads/2023/01/hcmc-wings-logo.png" },
    @{ name = "Vung Tau Waves"; coach = "HLV Pham Van Tung"; logoUrl = "https://vba.vn/wp-content/uploads/2023/01/vungtau-waves-logo.png" }
)

$teamIds = @{}
foreach ($team in $teams) {
    Write-Host "Creating team: $($team.name)"
    Invoke-Api -Method POST -Endpoint "/Teams/Create" -Body $team
    Start-Sleep -Milliseconds 500
}

# Get Team IDs
Start-Sleep -Seconds 2
$allTeams = Invoke-Api -Method GET -Endpoint "/api/TeamsApi"
foreach ($team in $allTeams.data) {
    $teamIds[$team.name] = $team.teamId
    Write-Host "Team: $($team.name) - ID: $($team.teamId)"
}

# 4. Create Players
Write-Host "`n4. Creating Players..."
$positions = @("Point Guard", "Shooting Guard", "Small Forward", "Power Forward", "Center")
$firstNames = @("Nguyen", "Tran", "Le", "Pham", "Hoang", "Huynh", "Vo", "Dang", "Bui", "Do")
$middleNames = @("Van", "Thi", "Minh", "Quoc", "Duc", "Hoang", "Hai", "Anh", "Tuan", "Tan")
$lastNames = @("Hung", "Long", "Nam", "Khoa", "Dung", "Thang", "Phong", "Tai", "Kien", "Dat")

foreach ($teamName in $teamIds.Keys) {
    $teamId = $teamIds[$teamName]
    Write-Host "Creating players for: $teamName"
    
    for ($i = 1; $i -le 15; $i++) {
        $position = $positions[($i - 1) % 5]
        $fullName = "$($firstNames | Get-Random) $($middleNames | Get-Random) $($lastNames | Get-Random)"
        
        $player = @{
            fullName = $fullName
            position = $position
            number = $i
            teamId = $teamId
            imageUrl = "https://via.placeholder.com/200x200?text=$i"
        }
        
        Invoke-Api -Method POST -Endpoint "/Players/Create" -Body $player | Out-Null
        Start-Sleep -Milliseconds 200
    }
}

# 5. Create Matches
Write-Host "`n5. Creating Matches..."
$teamNamesList = @($teamIds.Keys)
$startDate = Get-Date "2025-03-20"
$matchCount = 0
$videos = @(
    "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "https://www.youtube.com/watch?v=9bZkp7q19f0"
)

for ($i = 0; $i -lt $teamNamesList.Count; $i++) {
    for ($j = $i + 1; $j -lt $teamNamesList.Count; $j++) {
        $teamA = $teamNamesList[$i]
        $teamB = $teamNamesList[$j]
        $matchDate = $startDate.AddDays($matchCount * 2)
        
        $scoreA = $null
        $scoreB = $null
        $videoUrl = $null
        if ($matchDate -lt (Get-Date)) {
            $scoreA = Get-Random -Minimum 70 -Maximum 110
            $scoreB = Get-Random -Minimum 70 -Maximum 110
            $videoUrl = $videos | Get-Random
        }
        
        $match = @{
            teamA = $teamA
            teamAId = $teamIds[$teamA]
            teamB = $teamB
            teamBId = $teamIds[$teamB]
            scoreTeamA = $scoreA
            scoreTeamB = $scoreB
            round = [Math]::Floor($matchCount / 4) + 1
            groupName = "Vong Bang"
            matchDate = $matchDate.ToString("yyyy-MM-dd")
            matchTime = "19:00:00"
            location = if ($matchCount % 2 -eq 0) { "Nha thi dau Phu Tho, HCM" } else { "Cung the thao Trinh Hoai Duc, HN" }
            tournamentId = $tournamentId
            highlightsVideoUrl = $videoUrl
            videoDescription = if ($videoUrl) { "Highlights $teamA vs $teamB" } else { $null }
        }
        
        Write-Host "Match $($matchCount + 1): $teamA vs $teamB"
        Invoke-Api -Method POST -Endpoint "/Match/Create" -Body $match | Out-Null
        $matchCount++
        Start-Sleep -Milliseconds 300
    }
}

# 6. Verify Data
Write-Host "`n6. Verifying Data..."
$checkTournament = Invoke-Api -Method GET -Endpoint "/api/TournamentApi/$tournamentId"
$checkTeams = Invoke-Api -Method GET -Endpoint "/api/TeamsApi"
$checkMatches = Invoke-Api -Method GET -Endpoint "/api/MatchesApi/tournament/$tournamentId"

Write-Host "`n========================================"
Write-Host "SETUP COMPLETED!"
Write-Host "========================================"
Write-Host "Tournament: $($checkTournament.data.name)"
Write-Host "Teams: $($checkTeams.data.Count)"
Write-Host "Matches: $($checkMatches.data.Count)"
Write-Host "`nView at: http://localhost:8080/Tournament/Details/$tournamentId"
