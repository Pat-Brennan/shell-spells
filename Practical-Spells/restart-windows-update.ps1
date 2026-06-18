
Write-Output "ℹ️ Initializing windows update restart..."

Set-Service -name "usosvc" -StartupType Automatic

$services = @("bits", "wuauserv", "cryptSvc", "msiserver", "UsoSvc")

foreach ($service in $services) {
    try {
        Write-Output "ℹ️ Stopping $service service..."
        Stop-Service -Name $service -Force -ErrorAction Stop
        Write-Output "✅ $service service stopped successfully."
    } catch {
        Write-Output "‼️ An error occurred while stopping $service service: $_"
    }
}

foreach ($service in $services) {
    try {
        Write-Output "🔁 Restarting $service service..."
        Start-Service -Name $service -ErrorAction Stop
        Write-Output "✅ $service service started successfully."
    } catch {
        Write-Output "‼️ An error occurred while starting $service service: $_"
    }
  }

Write-Output "✅ Windows Update services restart completed."