$filePath = "Controllers\RulesController.cs"
$content = Get-Content $filePath -Raw
$newContent = $content -replace ',\s*ImageUrl\s*=\s*"[^"]*"', ''
Set-Content -Path $filePath -Value $newContent
Write-Host "ImageUrl properties removed from $filePath"
