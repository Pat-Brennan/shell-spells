#requires -RunAsAdministrator

function Disable-FastStartup {

  $registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
  $propertyName = "HiberbootEnabled"

  try {

    if (Test-Path $registryPath) {
      $currentValue = (Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue).$propertyName

      if ($currentValue -eq 0) {
        Write-Host "✅ Windows Fast Startup is already disabled." -ForegroundColor Green
      }
      else {
        Write-Host "ℹ️ Disabling Windows Fast Startup..."
        Set-ItemProperty -Path $registryPath -Name $propertyName -Value 0 -Force
        Write-Host "✅ Successfully disabled Windows Fast Startup." -ForegroundColor Green

      }
    }
    else {
      Write-Error "⚠️ The required registry path was not found: $registryPath"
    }
  }
  catch {
    Write-Error "⚠️ An error occurred while trying to disable Fast Startup."
    Write-Error $_.Exception.Message
  }
}

# --- Main script execution ---

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Warning "ℹ️ This script requires administrative privileges. Attempting to relaunch as Administrator..."
  Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
  exit
}

# Call the function
Disable-FastStartup

# Restart the PC
Write-Host "❗ A restart is required for the changes to take effect." -ForegroundColor Yellow
Write-Host "ℹ️ The Computer will restart in 10 seconds/ Press Ctrl+C to Cancel." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Restart-Computer -Force

Write-Host "🛠️ Script Complete!"
