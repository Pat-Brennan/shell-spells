<#
.SYNOPSIS
    This script disables the WiFi adapter in the BIOS on Dell Machines using the DellBIOSProvider PowerShell module.
.DESCRIPTION
    The script checks for the presence of the DellBIOSProvider module, installs it if not found, and then uses it to disable the WiFi adapter in the BIOS.
    The BIOS password is required to make changes to the BIOS settings.

.NOTES
    - THIS SCRIPT IS MEANT TO BE RUN IN NINJAONE
#>
$BiosPassword = $env:BiosPassword

if([string]::IsNullOrEmpty($BiosPassword)) {
    Write-Host "❗ Error: No BIOS password provided. Exiting script."
    exit 1
}

if(-not(Get-Module -ListAvailable -Name "DellBIOSProvider" -ErrorAction SilentlyContinue)) {
    Write-Output "🔄 Installing DellBIOSProvider module..."
    Install-Module -Name DellBIOSProvider -Force -ApplicationLicense -Scope AllUsers
}

Import-Module DellBIOSProvider

try {

  Set-Location DellSMBIOS:\
  Set-Item -Path "DellSMBIOS:\Wireless\WirelessLan" -Value "Disabled" -Password $BIOSPassword

  Write-Output "✅ WiFi disabled successfully."

} catch {

  Write-Error "❌ An error occurred: Please verify the BIOS password and try again. Error: $_"

}