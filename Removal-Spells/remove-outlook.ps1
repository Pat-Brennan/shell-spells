
$AppName = "*Microsoft.OutlookForWindows*"

Write-Host "ℹ️ Searching for the 'New Outlook for Windows' app package..."

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
  Write-Host "⚠️ The 'New Outlook for Windows' app package was not found on this system." -ForegroundColor Yellow
}

Write-Host " 🛠️ Script completed!"