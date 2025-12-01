$launcherPath = ".\LauncherApp\bin\Debug\net9.0-windows\TDSportsLauncher.exe"
if (Test-Path $launcherPath) {
    Start-Process $launcherPath
} else {
    Write-Host "Building Launcher..."
    dotnet build LauncherApp/TDSportsLauncher.csproj
    if ($?) {
        Start-Process $launcherPath
    } else {
        Write-Error "Build failed."
    }
}
