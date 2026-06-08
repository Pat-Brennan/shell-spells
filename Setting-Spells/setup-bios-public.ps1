

$NEW_BIOSPassword = $env:new_biospassword
$CURRENT_BIOSPassword = $env:current_biospassword

if([string]::IsNullOrEmpty($NEW_BIOSPassword)) {
    Write-Host "❗ Error: No new BIOS password provided. Exiting script."
    exit 1
}

#Installs Package Provider
if(-not(Get-PackageProvider -Name NuGet -ListAvailable -ErrorAction SilentlyContinue)) {
    Write-Output "🔄 Installing NuGet Package Provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

#Installs DellBIOSProvider Module
if(-not(Get-Module -ListAvailable -Name "DellBIOSProvider" -ErrorAction SilentlyContinue)) {
    Write-Output "🔄 Installing DellBIOSProvider module..."
    Install-Module -Name DellBIOSProvider -Force
}

Import-Module DellBIOSProvider

#Update BIOS Settings
try {

  Set-Location DellSMBIOS:\

  Write-output "⚙️ Applying BIOS settings..."

    $BIOSSettings = @{
    "DellSMBios:\Wireless\BluetoothDevice" = "Disabled"
    "DellSMBios:\Wireless\WirelessLan" = "Disabled"
    "DellSMBios:\PowerManagement\DeepSleepCtrl" = "Disabled"
    "DellSMBios:\PowerManagement\BlockSleep" = "Enabled"
    "DellSMBios:\PowerManagement\WakeOnLan" = "LanWlan"
    "DellSMBios:\PowerManagement\AutoOn" = "Everyday"
    "DellSMBios:\PowerManagement\AutoOnHr" = "7"
    "DellSMBios:\PowerManagement\AutoOnMn" = "0"
    "DellSMBios:\SystemConfiguration\InternalSpeaker" = "Disabled"
    "DellSMBios:\SystemConfiguration\Microphone" = "Enabled"
  }

  foreach ($setting in $BIOSSettings.GetEnumerator()) {
    try{
        if ([string]::IsNullOrEmpty($CURRENT_BIOSPassword)) {
            Set-Item -Path $setting.Key -Value $setting.Value -ErrorAction Stop
        } else {
            Set-Item -Path $setting.Key -Value $setting.Value -Password $CURRENT_BIOSPassword -ErrorAction Stop
        }
        Write-Output "✅ Set $($setting.Key) to $($setting.Value)"
    } catch {
        Write-Warning "⚠️ Failed to set $($setting.Key): $_"
    }
  }

  Write-Output "🔒 Configuring BIOS Password ..."
  if ($NEW_BIOSPassword -eq $CURRENT_BIOSPassword) {
    # The passwords match. Skip the change.
    Write-Output "✅ Target BIOS password already matches the current password. No changes needed."
  } elseif ([string]::IsNullOrEmpty($CURRENT_BIOSPassword)) {
    Set-Item -path "DellSMBIOS:\Security\AdminPassword" -Value $NEW_BIOSPassword
    Write-Output "✅ BIOS password set successfully."
  } else {
    Set-Item -path "DellSMBIOS:\Security\AdminPassword" -Value $NEW_BIOSPassword -Password $CURRENT_BIOSPassword -ErrorAction Stop
    Write-Output "✅ BIOS password updated successfully from Previous BIOS Password."
  }

  Write-Output "🎉 All BIOS settings applied successfully. System will now reboot to apply changes.
  "
  # Restart the computer to apply changes
  Start-Sleep -Seconds 5
  Restart-Computer -Force

} catch {

  Write-Error "❌ An error occurred during BIOS Setup. Error: $_"

}