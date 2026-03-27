
<#
.SYNOPSIS
    Silently uninstalls Mozilla Firefox from a Windows 11 system.
#>

$appName = "Mozilla Firefox"
$logPath = "C:\temp\Firefox_Uninstall_Log.txt"

# Basic logging function to keep track of the script's progress
Function Write-Log {
    Param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Write-Host $logEntry
    Out-File -FilePath $logPath -InputObject $logEntry -Append
}

# Ensure temp directory exists for the log
if (!(Test-Path "C:\temp")) { New-Item -ItemType Directory -Path "C:\temp" | Out-Null }

Write-Log "ℹ️ Starting uninstallation process for $appName..."

try {

    Write-Log "ℹ️ Checking for active Firefox processes..."

    get-process -Name "firefox" -ErrorAction SilentlyContinue | Stop-Process -Force

    Write-Log "☑️ Firefox processes stopped (if any were running)."

    Write-Log "🔍 Locating the uninstaller in the Registry..."
    
    $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $uninstallKeyWow64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

    $uninstallString = (Get-ChildItem $uninstallKey, $uninstallKeyWow64 -ErrorAction SilentlyContinue |
        Get-ItemProperty -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "*$appName*" } |
        Select-Object -ExpandProperty UninstallString -First 1)
    if ($uninstallString) {
        $cleanpath = $uninstallString.trim('"') # Remove any surrounding quotes
        Write-Log "☑️ Uninstall string found: $cleanpath"
    } else {
        Write-Log "❌ Uninstall string not found in Registry."
    }

    Write-Log "ℹ️ Executing the uninstaller..."

    if ($uninstallString) {
        Start-Process -FilePath $cleanpath -ArgumentList "/S" -Wait
        Write-Log "☑️ Uninstaller executed successfully."
    } else {
        Write-Log "❌ Cannot execute uninstaller because the uninstall string was not found."
    }

    Write-Log "ℹ️ Cleaning up leftover directories..."
    
$firefoxDirs = @(
        "$env:ProgramFiles\Mozilla Firefox",
        "${env:ProgramFiles(x86)}\Mozilla Firefox"
    )
    foreach ($dir in $firefoxDirs) {
        if (Test-Path $dir) {
            Remove-Item -Recurse -Force $dir
            Write-Log "☑️ Removed leftover directory: $dir"
        }
    }
    Write-Log "✅ Script completed successfully."
}
catch {
    Write-Log "❌ An error occurred: $($_.Exception.Message)"
}