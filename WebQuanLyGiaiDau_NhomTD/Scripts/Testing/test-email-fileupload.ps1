# Test Email và File Upload Services API
# PowerShell script để test các API endpoints

Write-Host "=== TESTING EMAIL và FILE UPLOAD SERVICES ===" -ForegroundColor Green

# Base URL của ứng dụng
$baseUrl = "https://localhost:7095"
$apiUrl = "$baseUrl/api"

# Function để test API với error handling
function Test-API {
    param(
        [string]$endpoint,
        [string]$method = "GET",
        [hashtable]$headers = @{},
        [string]$body = $null
    )
    
    try {
        $params = @{
            Uri = $endpoint
            Method = $method
            Headers = $headers
            ContentType = "application/json"
        }
        
        if ($body) {
            $params.Body = $body
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "✅ SUCCESS: $endpoint" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "❌ FAILED: $endpoint" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
        return $null
    }
}

Write-Host "`n1. Testing Health Check..." -ForegroundColor Cyan
Test-API "$baseUrl/health"

Write-Host "`n2. Testing Email Service Health..." -ForegroundColor Cyan
Test-API "$apiUrl/email/health"

Write-Host "`n3. Testing File Upload Service Health..." -ForegroundColor Cyan
Test-API "$apiUrl/fileupload/health"

Write-Host "`n4. Testing Email Templates..." -ForegroundColor Cyan
Test-API "$apiUrl/email/templates"

Write-Host "`n5. Testing File Upload Info..." -ForegroundColor Cyan
Test-API "$apiUrl/fileupload/info"

# Test send email với template
Write-Host "`n6. Testing Send Email with Template..." -ForegroundColor Cyan
$emailTestData = @{
    templateName = "TOURNAMENT_REGISTRATION_CONFIRMATION"
    to = "test@example.com"
    subject = "Test Tournament Registration"
    variables = @{
        UserName = "Test User"
        TournamentName = "Test Tournament 2024"
        RegistrationDate = (Get-Date).ToString("dd/MM/yyyy")
    }
} | ConvertTo-Json

Test-API "$apiUrl/email/send-template" -method "POST" -body $emailTestData

Write-Host "`n=== TEST COMPLETED ===" -ForegroundColor Green
Write-Host "Kiểm tra console output để xem chi tiết..." -ForegroundColor Yellow