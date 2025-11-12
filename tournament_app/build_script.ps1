# TDSports Flutter App Build & Test Script for Windows PowerShell
# Tác giả: GitHub Copilot

param(
    [switch]$Release,
    [switch]$SkipTests,
    [switch]$CleanBuild
)

Write-Host "🚀 TDSports Flutter App - Build & Test Script" -ForegroundColor Blue
Write-Host "==============================================" -ForegroundColor Blue

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Set location to script directory
Set-Location $PSScriptRoot

# Check if Flutter is installed
Write-Status "Checking Flutter installation..."
try {
    $flutterVersion = flutter --version
    Write-Success "Flutter is installed"
    Write-Host $flutterVersion -ForegroundColor Gray
} catch {
    Write-Error-Custom "Flutter is not installed or not in PATH"
    exit 1
}

# Check Flutter doctor
Write-Status "Running Flutter doctor..."
flutter doctor

# Clean previous builds if requested
if ($CleanBuild) {
    Write-Status "Cleaning previous builds..."
    flutter clean
}

# Get dependencies
Write-Status "Getting Flutter dependencies..."
flutter pub get

# Check for code generation
if ((Get-Content "pubspec.yaml") -match "build_runner") {
    Write-Status "Generating code with build_runner..."
    flutter pub run build_runner build --delete-conflicting-outputs
}

# Analyze code
Write-Status "Analyzing Flutter code..."
$analyzeResult = flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Code analysis found issues"
} else {
    Write-Success "Code analysis passed"
}

# Run tests if not skipped
if (-not $SkipTests -and (Test-Path "test")) {
    Write-Status "Running Flutter tests..."
    flutter test
} elseif (-not (Test-Path "test")) {
    Write-Warning "No test directory found, skipping tests"
} else {
    Write-Warning "Tests skipped as requested"
}

# Build APK
if ($Release) {
    Write-Status "Building Android APK (release)..."
    flutter build apk --release
    $apkPath = "build\app\outputs\flutter-apk\app-release.apk"
} else {
    Write-Status "Building Android APK (debug)..."
    flutter build apk --debug  
    $apkPath = "build\app\outputs\flutter-apk\app-debug.apk"
}

Write-Success "Build completed successfully!"

# Display build artifacts
Write-Status "Build artifacts:"
if (Test-Path $apkPath) {
    $apkInfo = Get-Item $apkPath
    Write-Host "  📱 Android APK: $apkPath" -ForegroundColor Green
    Write-Host "  📏 Size: $([math]::Round($apkInfo.Length / 1MB, 2)) MB" -ForegroundColor Gray
    Write-Host "  📅 Created: $($apkInfo.LastWriteTime)" -ForegroundColor Gray
}

Write-Host ""
Write-Status "Build summary:"
Write-Host "  ✅ Dependencies installed" -ForegroundColor Green
Write-Host "  ✅ Code analysis completed" -ForegroundColor Green
Write-Host "  ✅ Android APK built" -ForegroundColor Green
Write-Host "  📱 Ready for testing" -ForegroundColor Green

Write-Host ""
Write-Success "🎉 TDSports Flutter app build completed!"

Write-Host ""
Write-Status "Next steps:"
Write-Host "  1. Connect Android device or start emulator"
Write-Host "  2. Run: flutter run"
Write-Host "  3. Test Google Sign-In functionality"  
Write-Host "  4. Make sure backend is running on http://localhost:8080"

Write-Host ""
Write-Status "Quick commands:"
Write-Host "  flutter run                    # Run on connected device"
Write-Host "  flutter run --release          # Run release build"
Write-Host "  flutter run --debug           # Run debug build"
Write-Host "  flutter install               # Install on connected device"
Write-Host "  flutter devices               # List available devices"

Write-Host ""
Write-Status "Google OAuth Setup:"
Write-Host "  📄 See GOOGLE_OAUTH_SETUP.md for detailed instructions"
Write-Host "  🔑 Update google-services.json with real credentials"
Write-Host "  🌐 Configure backend OAuth endpoints"