Write-Host "Bootstrapping melos..." -ForegroundColor Cyan
melos bootstrap
Write-Host "Running code generation for all packages..." -ForegroundColor Cyan
melos run gen
Write-Host "Done." -ForegroundColor Green
