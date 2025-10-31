# Script để build và cài đặt TDSports với icon mới

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   BUILD & INSTALL TDSPORTS" -ForegroundColor Cyan
Write-Host "   Icon: LOGO.jpg | App Name: TDSports" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Chuyển đến thư mục project
Set-Location -Path "D:\WebQuanLyGiaiDau_NhomTD\tournament_app"

# Bước 1: Clean
Write-Host "[1/4] Cleaning previous build..." -ForegroundColor Yellow
flutter clean
Write-Host "✓ Clean completed!" -ForegroundColor Green
Write-Host ""

# Bước 2: Get dependencies
Write-Host "[2/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "✓ Dependencies ready!" -ForegroundColor Green
Write-Host ""

# Bước 3: Kiểm tra thiết bị
Write-Host "[3/4] Checking connected devices..." -ForegroundColor Yellow
flutter devices
Write-Host ""

# Bước 4: Build và cài đặt
Write-Host "[4/4] Building and installing app..." -ForegroundColor Yellow
Write-Host "⚠️  Please make sure your phone is connected via USB" -ForegroundColor Magenta
Write-Host "⚠️  USB Debugging must be enabled" -ForegroundColor Magenta
Write-Host ""

$choice = Read-Host "Continue with installation? (Y/N)"

if ($choice -eq "Y" -or $choice -eq "y") {
    Write-Host ""
    Write-Host "Building in RELEASE mode for best icon display..." -ForegroundColor Cyan
    flutter run --release
    
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "   ✓ INSTALLATION COMPLETED!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Check your phone:" -ForegroundColor Yellow
    Write-Host "  1. App name should be: TDSports" -ForegroundColor White
    Write-Host "  2. App icon should be: LOGO.jpg" -ForegroundColor White
    Write-Host "  3. Splash screen shows: TDSports logo" -ForegroundColor White
    Write-Host ""
    Write-Host "If icon doesn't update:" -ForegroundColor Cyan
    Write-Host "  - Uninstall old app first" -ForegroundColor White
    Write-Host "  - Run this script again" -ForegroundColor White
    Write-Host "  - Restart your phone if needed" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Installation cancelled." -ForegroundColor Red
    Write-Host ""
    Write-Host "To install manually, run:" -ForegroundColor Yellow
    Write-Host "  flutter run --release" -ForegroundColor White
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
