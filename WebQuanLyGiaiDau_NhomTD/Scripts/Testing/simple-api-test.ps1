# Simple API Test Script
# Test các API endpoints của hệ thống quản lý giải đấu

param(
    [string]$BaseUrl = "http://localhost:5194"
)

$tests = @()

function Test-Endpoint {
    param([string]$url, [string]$description)
    
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 10
        $status = "✅ PASS"
        $details = "Status: $($response.StatusCode)"
        
        if ($response.Content) {
            try {
                $json = $response.Content | ConvertFrom-Json
                if ($json.success) {
                    $details += " | Success: $($json.success)"
                    if ($json.count) { $details += " | Count: $($json.count)" }
                    if ($json.data -and $json.data.Count) { $details += " | Data Items: $($json.data.Count)" }
                }
            } catch {
                $details += " | Response: $($response.Content.Substring(0, [Math]::Min(50, $response.Content.Length)))..."
            }
        }
    } catch {
        $status = "❌ FAIL"
        $details = $_.Exception.Message
    }
    
    $global:tests += [PSCustomObject]@{
        Description = $description
        URL = $url
        Status = $status
        Details = $details
    }
    
    Write-Host "$status $description"
    Write-Host "    $details" -ForegroundColor Gray
    Write-Host
}

Write-Host "🚀 TESTING API ENDPOINTS" -ForegroundColor Cyan
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host

# Test basic connectivity
Test-Endpoint "$BaseUrl/ping" "Basic Connectivity"

# Test Sports API
Test-Endpoint "$BaseUrl/api/SportsApi" "Get All Sports"
Test-Endpoint "$BaseUrl/api/SportsApi/1" "Get Sport by ID (1)"

# Test Tournament API  
Test-Endpoint "$BaseUrl/api/TournamentApi" "Get All Tournaments"
Test-Endpoint "$BaseUrl/api/TournamentApi/1" "Get Tournament by ID (1)"
Test-Endpoint "$BaseUrl/api/TournamentApi/by-sport/1" "Get Tournaments by Sport ID (1)"

# Test Matches API
Test-Endpoint "$BaseUrl/api/MatchesApi" "Get All Matches"
Test-Endpoint "$BaseUrl/api/MatchesApi/1" "Get Match by ID (1)" 
Test-Endpoint "$BaseUrl/api/MatchesApi?page=1&pageSize=5" "Get Matches with Pagination"
Test-Endpoint "$BaseUrl/api/MatchesApi/tournament/1" "Get Matches by Tournament ID (1)"
Test-Endpoint "$BaseUrl/api/MatchesApi/live" "Get Live Matches"

# Test Teams API
Test-Endpoint "$BaseUrl/api/TeamsApi" "Get All Teams"
Test-Endpoint "$BaseUrl/api/TeamsApi/1" "Get Team by ID (1)"
Test-Endpoint "$BaseUrl/api/TeamsApi/1/players" "Get Team Players (Team ID: 1)"

# Test some error cases
Test-Endpoint "$BaseUrl/api/SportsApi/999" "Get Sport by Invalid ID (999) - Should be 404"
Test-Endpoint "$BaseUrl/api/TournamentApi/999" "Get Tournament by Invalid ID (999) - Should be 404"

# Summary
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "📊 TEST SUMMARY" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$totalTests = $tests.Count
$passedTests = ($tests | Where-Object { $_.Status -like "*PASS*" }).Count
$failedTests = $totalTests - $passedTests

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red
Write-Host "Success Rate: $([math]::Round(($passedTests / $totalTests) * 100, 1))%" -ForegroundColor Yellow

if ($failedTests -gt 0) {
    Write-Host "`n❌ FAILED TESTS:" -ForegroundColor Red
    $tests | Where-Object { $_.Status -like "*FAIL*" } | ForEach-Object {
        Write-Host "   • $($_.Description)" -ForegroundColor Red
        Write-Host "     $($_.Details)" -ForegroundColor Gray
    }
}

Write-Host "`n🎯 API Documentation available at: $BaseUrl/api-docs" -ForegroundColor Cyan
Write-Host "📖 Swagger JSON: $BaseUrl/swagger/v1/swagger.json" -ForegroundColor Cyan
