#!/bin/bash

# TDSports Flutter App Build & Test Script
# Tác giả: GitHub Copilot

set -e # Exit on any error

echo "🚀 TDSports Flutter App - Build & Test Script"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
print_status "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

flutter --version
print_success "Flutter is installed"

# Navigate to Flutter project directory
cd "$(dirname "$0")"
print_status "Working directory: $(pwd)"

# Check Flutter doctor
print_status "Running Flutter doctor..."
flutter doctor

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Generate code (if needed)
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    print_status "Generating code with build_runner..."
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Analyze code
print_status "Analyzing Flutter code..."
flutter analyze

# Run tests (if test directory exists)
if [ -d "test" ]; then
    print_status "Running Flutter tests..."
    flutter test
else
    print_warning "No test directory found, skipping tests"
fi

# Build for Android (debug)
print_status "Building Android APK (debug)..."
flutter build apk --debug

# Build for Android (release) - commented out as it requires signing
# print_status "Building Android APK (release)..."
# flutter build apk --release

print_success "Build completed successfully!"

# Display build artifacts
print_status "Build artifacts:"
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    echo "  📱 Android Debug APK: build/app/outputs/flutter-apk/app-debug.apk"
    ls -lh build/app/outputs/flutter-apk/app-debug.apk
fi

print_status "Build summary:"
echo "  ✅ Dependencies installed"
echo "  ✅ Code analysis passed"
echo "  ✅ Android debug APK built"
echo "  📱 Ready for testing on emulator/device"

echo ""
print_success "🎉 TDSports Flutter app build completed!"
echo ""
print_status "Next steps:"
echo "  1. Connect Android device or start emulator"
echo "  2. Run: flutter run"
echo "  3. Test Google Sign-In functionality"
echo "  4. Make sure backend is running on http://localhost:8080"

print_status "Quick commands:"
echo "  flutter run                    # Run on connected device"
echo "  flutter run --release          # Run release build"
echo "  flutter run --debug           # Run debug build"
echo "  flutter install               # Install on connected device"