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
  Set-Item -Path "DellSMBIOS:\Wireless\BluetoothDevice" -Value "Disabled" -Password $BIOSPassword

  Write-Output "✅ Bluetooth Disabled Successfully."

  # Restart the computer to apply changes
  Restart-Computer -Force

} catch {

  Write-Error "❌ An error occurred: Please verify the BIOS password and try again. Error: $_"

}