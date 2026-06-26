<#
.SYNOPSIS
    This script uninstalls MyPC from the system.
    
.DESCRIPTION
    This script checks for the presence of the MyPC uninstaller and executes it silently. 
    It also handles errors gracefully and provides feedback to the user.
    !This script is assuming the uninstaller is already on the designated path on the machine.
#>

#Requires -RunAsAdministrator

$path = "C:\MyPC\User Deploy - 7.0.0.35\uninstall_clients.exe"

if (!(Test-Path $path)) {
    Write-Warning "⚠️ Uninstall executable not found at $path. Please check the path and try again."
    exit 1
}

Try {
    Write-Output "🔄 Uninstalling MyPC..."
    Start-Process -FilePath $path -ArgumentList "/S" -Wait -NoNewWindow
    Write-Output "✅ MyPC uninstalled successfully."
} Catch {
    Write-Warning "⚠️ Failed to uninstall MyPC: $_"
}

Write-output "ℹ️ Restarting the system to complete the uninstallation process..."
restart-computer -Force