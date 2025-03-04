# Check if the system meets the minimum requirements for Windows 11
function Check-Windows11Requirements {
  # Check CPU (Simplified - requires more robust logic for all CPUs)
  $CPU = Get-WmiObject Win32_Processor | Select-Object -ExpandProperty Name
  if ($CPU -notmatch "Intel|AMD") {
    # Basic check - improve this!
    Write-Warning "CPU Check: Cannot definitively determine Windows 11 compatibility for $($CPU).  Manual verification recommended."
  }
  else {
    Write-Host "CPU Check: $($CPU) - Proceed with caution.  Manual verification recommended for full compatibility."
  }


  # Check RAM
  $RAM = (Get-WmiObject Win32_OperatingSystem | Select-Object -ExpandProperty TotalVisibleMemorySize) / 1GB
  if ($RAM -lt 4) {
    Write-Error "RAM Check: Insufficient RAM. Windows 11 requires at least 4GB.  Currently: $($RAM)GB"
    return $false
  }
  else {
    Write-Host "RAM Check: $($RAM)GB - OK"
  }

  # Check Disk Space (Simplified - needs improvement for edge cases)
  $DiskSpace = (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq "C:\" } | Select-Object -ExpandProperty Free) / 1GB
  if ($DiskSpace -lt 64) {
    Write-Error "Disk Space Check: Insufficient disk space. Windows 11 requires at least 64GB. Currently: $($DiskSpace)GB free."
    return $false
  }
  else {
    Write-Host "Disk Space Check: $($DiskSpace)GB free - OK"
  }

  # Check Secure Boot (This needs more advanced checks)
  Write-Warning "Secure Boot Check: Cannot reliably check Secure Boot status via PowerShell. Manual verification is REQUIRED in BIOS/UEFI settings."

  # Check TPM 2.0 (This needs more advanced checks)
  Write-Warning "TPM 2.0 Check: Cannot reliably check TPM 2.0 status via PowerShell. Manual verification is REQUIRED in BIOS/UEFI settings and potentially via tpm.msc"

  return $true # Assume success if basic checks pass, but warn about manual checks
}


# Check for existing upgrade files (Optional -  adjust path if needed)
$UpgradeFiles = Get-ChildItem -Path "C:\Windows11Upgrade" -File -ErrorAction SilentlyContinue

if ($UpgradeFiles) {
  Write-Host "Existing Windows 11 upgrade files found.  Consider removing them and downloading a fresh copy if you have issues."
  # You could add logic here to remove the existing files if needed
}

# Download the Windows 11 Installation Assistant (This is the most reliable way)
$DownloadURL = "https://go.microsoft.com/fwlink/?linkid=2171764"  # Official link - may change over time

try {
  Write-Host "Downloading Windows 11 Installation Assistant..."
  Invoke-WebRequest -Uri $DownloadURL -OutFile "C:\Windows11Upgrade\Windows11InstallationAssistant.exe" -UseBasicParsing # Create folder

  if (!(Test-Path "C:\Windows11Upgrade")) {
    New-Item -ItemType Directory -Path "C:\Windows11Upgrade" | Out-Null
  }

}
catch {
  Write-Error "Failed to download the Installation Assistant: $($_.Exception.Message)"
  return
}

# Run the Installation Assistant
Write-Host "Launching the Windows 11 Installation Assistant..."
try {
  Start-Process -FilePath "C:\Windows11Upgrade\Windows11InstallationAssistant.exe" -Wait  # -Wait is important!
}
catch {
  Write-Error "Failed to start the Installation Assistant: $($_.Exception.Message)"
  return
}

Write-Host "Windows 11 upgrade process started.  Follow the on-screen instructions."

# Important Notes:
# - This script provides a basic framework.  Real-world upgrades can encounter various issues.
# - The CPU, Secure Boot, and TPM checks are simplified and require manual verification.
# - Always back up your data before performing a major upgrade.
# - Microsoft's official Windows 11 Installation Assistant is the recommended method, so this script focuses on that.
# - This script does NOT handle driver updates.  You may need to update drivers after the upgrade.
# - The download link might change in the future; update the $DownloadURL variable if needed.
# - Error handling and logging could be significantly improved for a production-ready script.
# - The -Wait parameter is used to ensure the script waits for the Installation Assistant to complete (or fail) before continuing. This is crucial.