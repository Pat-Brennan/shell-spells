$AppName = "*McAfee Security Scan*"

Write-Host "ℹ️ Searching for the 'McAfee Security Scan ' app package..."

$AppPackage = Get-AppxPackage -Name $AppName -AllUsers

if ($AppPackage) {
  Write-Host "ℹ️ Found: $($AppPackage.Name). Attempting to remove it for all users..."
  try {
    Remove-AppxPackage -Package $AppPackage.PackageFullName -AllUsers -ErrorAction Stop
    Write-Host "✅ '$($AppPackage.Name)' has been successfully removed." -ForegroundColor Green
  }
  catch {
    Write-Host "❌ An error occurred during removal: $_" -ForegroundColor Red
  }
}
else {
  Write-Host "⚠️ The 'Mcafee Security Scan' app package was not found on this system." -ForegroundColor Yellow
}

Write-Host "🛠️ Script completed!"