<#
.SYNOPSIS
    This script disables the WiFi adapter in the BIOS on Dell Machines using the DellBIOSProvider PowerShell module.
.DESCRIPTION
    The script checks for the presence of the DellBIOSProvider module, installs it if not found, and then uses it to disable the WiFi adapter in the BIOS.
    The BIOS password is required to make changes to the BIOS settings.

.NOTES
    - THIS SCRIPT IS MEANT TO BE RUN IN NINJAONE
#>
$BIOSPassword = $env:BiosPassword

if([string]::IsNullOrEmpty($BiosPassword)) {
    Write-Host "❗ Error: No BIOS password provided. Exiting script."
    exit 1
}

if(-not(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Write-Output "🔄 Installing NuGet Package Provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

if(-not(Get-Module -ListAvailable -Name "DellBIOSProvider" -ErrorAction SilentlyContinue)) {
    Write-Output "🔄 Installing DellBIOSProvider module..."
    Install-Module -Name DellBIOSProvider -Force
}


Import-Module DellBIOSProvider

try {

  Set-Location DellSMBIOS:\
  Set-Item -Path "DellSMBIOS:\Wireless\WirelessLan" -Value "Disabled" -Password $BIOSPassword

  Write-Output "✅ WiFi disabled successfully."
  Restart-Computer -Force

} catch {

  Write-Error "❌ An error occurred: Please verify the BIOS password and try again. Error: $_"

}