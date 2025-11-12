# API Testing Script for Tournament Management System
# Author: Assistant
# Date: $(Get-Date -Format "yyyy-MM-dd")

param(
    [string]$BaseUrl = "http://localhost:5194",
    [switch]$Verbose = $false
)

# Colors for console output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

# Function to make HTTP requests and display results
function Test-ApiEndpoint {
    param(
        [string]$Url,
        [string]$Method = "GET",
        [string]$Description,
        [hashtable]$Headers = @{},
        [string]$Body = $null
    )
    
    Write-Host "`n=== $Description ===" -ForegroundColor $InfoColor
    Write-Host "Endpoint: $Method $Url" -ForegroundColor Gray
    
    try {
        $requestParams = @{
            Uri = $Url
            Method = $Method
            ContentType = "application/json"
            UseBasicParsing = $true
        }
        
        if ($Headers.Count -gt 0) {
            $requestParams.Headers = $Headers
        }
        
        if ($Body) {
            $requestParams.Body = $Body
        }
        
        $response = Invoke-WebRequest @requestParams
        
        Write-Host "Status: $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor $SuccessColor
        
        if ($response.Content) {
            try {
                $jsonResponse = $response.Content | ConvertFrom-Json
                
                if ($Verbose) {
                    Write-Host "Response:" -ForegroundColor Gray
                    Write-Host ($jsonResponse | ConvertTo-Json -Depth 3) -ForegroundColor Gray
                } else {
                    # Display summary information
                    if ($jsonResponse.success) {
                        Write-Host "Success: $($jsonResponse.success)" -ForegroundColor $SuccessColor
                        if ($jsonResponse.message) {
                            Write-Host "Message: $($jsonResponse.message)" -ForegroundColor Gray
                        }
                        if ($jsonResponse.count) {
                            Write-Host "Count: $($jsonResponse.count)" -ForegroundColor Gray
                        }
                        if ($jsonResponse.data -and $jsonResponse.data.Count) {
                            Write-Host "Data Count: $($jsonResponse.data.Count)" -ForegroundColor Gray
                        }
                        if ($jsonResponse.pagination) {
                            Write-Host "Pagination: Page $($jsonResponse.pagination.currentPage) of $($jsonResponse.pagination.totalPages) (Total: $($jsonResponse.pagination.totalRecords))" -ForegroundColor Gray
                        }
                    } else {
                        Write-Host "Success: $($jsonResponse.success)" -ForegroundColor $WarningColor
                        if ($jsonResponse.message) {
                            Write-Host "Message: $($jsonResponse.message)" -ForegroundColor $WarningColor
                        }
                    }
                }
            } catch {
                Write-Host "Response (Raw): $($response.Content)" -ForegroundColor Gray
            }
        }
        
        return $true
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor $ErrorColor
        if ($_.Exception.Response) {
            Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor $ErrorColor
        }
        return $false
    }
}

# Test summary variables
$totalTests = 0
$successfulTests = 0

Write-Host "================================" -ForegroundColor $InfoColor
Write-Host "API ENDPOINT TESTING STARTED" -ForegroundColor $InfoColor
Write-Host "Base URL: $BaseUrl" -ForegroundColor $InfoColor
Write-Host "Verbose Mode: $Verbose" -ForegroundColor $InfoColor
Write-Host "================================" -ForegroundColor $InfoColor

# Test basic connectivity
Write-Host "`n### TESTING BASIC CONNECTIVITY ###" -ForegroundColor $InfoColor
$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/ping" -Description "Basic connectivity test") {
    $successfulTests++
}

# Test Sports API Endpoints
Write-Host "`n### TESTING SPORTS API ###" -ForegroundColor $InfoColor

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/SportsApi" -Description "Get all sports") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/SportsApi/1" -Description "Get sport by ID (ID: 1)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/SportsApi/999" -Description "Get sport by invalid ID (ID: 999) - Should return 404") {
    $successfulTests++
}

# Test Tournament API Endpoints
Write-Host "`n### TESTING TOURNAMENT API ###" -ForegroundColor $InfoColor

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TournamentApi" -Description "Get all tournaments") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TournamentApi/1" -Description "Get tournament by ID (ID: 1)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TournamentApi/999" -Description "Get tournament by invalid ID (ID: 999) - Should return 404") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TournamentApi/by-sport/1" -Description "Get tournaments by sport (Sport ID: 1)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TournamentApi/by-sport/999" -Description "Get tournaments by invalid sport (Sport ID: 999)") {
    $successfulTests++
}

# Test Matches API Endpoints
Write-Host "`n### TESTING MATCHES API ###" -ForegroundColor $InfoColor

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi" -Description "Get all matches (default pagination)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi?page=1&pageSize=5" -Description "Get matches with pagination (Page 1, Size 5)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi?search=Saigon" -Description "Search matches by team name 'Saigon'") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi?search=NonExistentTeam" -Description "Search matches by non-existent team") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi/1" -Description "Get match by ID (ID: 1)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi/999" -Description "Get match by invalid ID (ID: 999) - Should return 404") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi/tournament/1" -Description "Get matches by tournament (Tournament ID: 1)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi/tournament/999" -Description "Get matches by invalid tournament (Tournament ID: 999) - Should return 404") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi/live" -Description "Get live matches") {
    $successfulTests++
}

# Test Teams API Endpoints
Write-Host "`n### TESTING TEAMS API ###" -ForegroundColor $InfoColor

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TeamsApi" -Description "Get all teams") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TeamsApi?search=Saigon" -Description "Search teams by name 'Saigon'") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TeamsApi?search=NonExistentTeam" -Description "Search teams by non-existent name") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TeamsApi/1" -Description "Get team by ID (ID: 1)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TeamsApi/999" -Description "Get team by invalid ID (ID: 999) - Should return 404") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TeamsApi/1/players" -Description "Get players of team (Team ID: 1)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/TeamsApi/999/players" -Description "Get players of invalid team (Team ID: 999) - Should return 404") {
    $successfulTests++
}

# Test Swagger/API Documentation
Write-Host "`n### TESTING API DOCUMENTATION ###" -ForegroundColor $InfoColor

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/swagger/v1/swagger.json" -Description "Get Swagger JSON documentation") {
    $successfulTests++
}

# Test additional endpoints with different parameters
Write-Host "`n### TESTING ADVANCED SCENARIOS ###" -ForegroundColor $InfoColor

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi?page=2&pageSize=20" -Description "Get matches with large page size") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi?page=0&pageSize=5" -Description "Get matches with invalid page (0)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi?page=1&pageSize=0" -Description "Get matches with invalid page size (0)") {
    $successfulTests++
}

$totalTests++
if (Test-ApiEndpoint -Url "$BaseUrl/api/MatchesApi?page=1&pageSize=1000" -Description "Get matches with very large page size") {
    $successfulTests++
}

# Summary
Write-Host "`n================================" -ForegroundColor $InfoColor
Write-Host "API TESTING COMPLETED" -ForegroundColor $InfoColor
Write-Host "================================" -ForegroundColor $InfoColor
Write-Host "Total Tests: $totalTests" -ForegroundColor $InfoColor
Write-Host "Successful: $successfulTests" -ForegroundColor $SuccessColor
Write-Host "Failed: $($totalTests - $successfulTests)" -ForegroundColor $ErrorColor
Write-Host "Success Rate: $([math]::Round(($successfulTests / $totalTests) * 100, 2))%" -ForegroundColor $InfoColor

if ($successfulTests -eq $totalTests) {
    Write-Host "`n🎉 All API endpoints are working correctly!" -ForegroundColor $SuccessColor
} elseif ($successfulTests -gt ($totalTests * 0.8)) {
    Write-Host "`n✅ Most API endpoints are working correctly!" -ForegroundColor $SuccessColor
} else {
    Write-Host "`n⚠️  Several API endpoints have issues that need attention." -ForegroundColor $WarningColor
}

Write-Host "`n=== TESTING NOTES ===" -ForegroundColor $InfoColor
Write-Host "• Use -Verbose flag to see full JSON responses" -ForegroundColor Gray
Write-Host "• Some 404 errors are expected for invalid IDs" -ForegroundColor Gray
Write-Host "• Live matches endpoint may return empty results if no matches today" -ForegroundColor Gray
Write-Host "• Search endpoints may return empty results if no data matches" -ForegroundColor Gray
