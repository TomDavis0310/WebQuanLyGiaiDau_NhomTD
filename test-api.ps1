# Test API Endpoints Script
# Đảm bảo ứng dụng đang chạy tại http://localhost:5194

Write-Host "🚀 TESTING API ENDPOINTS" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green

$baseUrl = "http://localhost:5194/api"

# Test 1: Sports API
Write-Host "`n📋 1. Testing Sports API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/sports" -Method GET
    Write-Host "✅ Sports API: SUCCESS" -ForegroundColor Green
    Write-Host "Found $($response.Count) sports:" -ForegroundColor Cyan
    foreach ($sport in $response) {
        Write-Host "  - $($sport.name) (ID: $($sport.id), Tournaments: $($sport.tournamentCount))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Sports API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Tournaments API
Write-Host "`n🏆 2. Testing Tournaments API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/tournaments" -Method GET
    Write-Host "✅ Tournaments API: SUCCESS" -ForegroundColor Green
    Write-Host "Found $($response.Count) tournaments:" -ForegroundColor Cyan
    foreach ($tournament in $response) {
        Write-Host "  - $($tournament.name) (Sport: $($tournament.sportsName))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Tournaments API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Teams API
Write-Host "`n👥 3. Testing Teams API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/teams" -Method GET
    Write-Host "✅ Teams API: SUCCESS" -ForegroundColor Green
    Write-Host "Found $($response.Count) teams:" -ForegroundColor Cyan
    foreach ($team in $response) {
        Write-Host "  - $($team.name) (Coach: $($team.coach), Players: $($team.playerCount))" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Teams API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Matches API
Write-Host "`n⚽ 4. Testing Matches API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/matches?page=1&pageSize=5" -Method GET
    Write-Host "✅ Matches API: SUCCESS" -ForegroundColor Green
    Write-Host "Found matches (showing first 5):" -ForegroundColor Cyan
    foreach ($match in $response.matches) {
        $status = if ($match.scoreTeamA -ne $null) { "$($match.scoreTeamA) - $($match.scoreTeamB)" } else { "Chưa diễn ra" }
        Write-Host "  - $($match.teamA) vs $($match.teamB) | $status" -ForegroundColor White
    }
} catch {
    Write-Host "❌ Matches API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Specific Sport Detail
Write-Host "`n🏀 5. Testing Sport Detail API (Basketball)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/sports/1" -Method GET
    Write-Host "✅ Sport Detail API: SUCCESS" -ForegroundColor Green
    Write-Host "Sport: $($response.name)" -ForegroundColor Cyan
    Write-Host "Tournaments in this sport: $($response.tournaments.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Sport Detail API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Live Matches
Write-Host "`n🔴 6. Testing Live Matches API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/matches/live" -Method GET
    Write-Host "✅ Live Matches API: SUCCESS" -ForegroundColor Green
    if ($response.Count -eq 0) {
        Write-Host "No live matches currently" -ForegroundColor Gray
    } else {
        Write-Host "Live matches: $($response.Count)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Live Matches API: FAILED - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 API TESTING COMPLETED!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host "You can also test these APIs manually at: http://localhost:5194/api-docs" -ForegroundColor Cyan
