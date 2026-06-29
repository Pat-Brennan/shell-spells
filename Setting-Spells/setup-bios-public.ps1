<#

.SYNOPSIS
    This script configures BIOS settings on Dell systems using the DellBIOSProvider module.
.DESCRIPTION
    The script checks for the presence of the DellBIOSProvider module and installs it if necessary
    It then applies a set of predefined BIOS settings and configures the BIOS password based on the provided environment variables.
.PARAMETER new_biospassword
    The new BIOS password to be set. This parameter is necessary if there is no BIOS password currently set or if you want to change the existing BIOS password.
.PARAMETER current_biospassword
    The current BIOS password, if any.

#>

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

    $BIOSSettings = [ordered] @{
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

    if ([string]::IsNullOrEmpty($NEW_BIOSPassword)) {

      Write-Output "ℹ️ No new BIOS password provided. Keeping the current BIOS password unchanged."

    } elseif ($NEW_BIOSPassword -eq $CURRENT_BIOSPassword) {

    Write-Output "ℹ️ Target BIOS password already matches the current password. No changes needed."

  } elseif ([string]::IsNullOrEmpty($CURRENT_BIOSPassword)) {

    Set-Item -path "DellSMBIOS:\Security\AdminPassword" -Value $NEW_BIOSPassword -ErrorAction Stop
    Write-Output "✅ BIOS password set successfully."

  } else {

    Set-Item -path "DellSMBIOS:\Security\AdminPassword" -Value $NEW_BIOSPassword -Password $CURRENT_BIOSPassword -ErrorAction Stop
    Write-Output "✅ BIOS password updated successfully from Previous BIOS Password."

  }
  Write-Output "🎉 All BIOS settings applied successfully. System will reboot in one minute to apply changes.
  "
  # Restart the computer to apply changes
  shutdown.exe /r /t 60 /c "Rebooting to apply BIOS settings changes."

} catch {

  Write-Error "❌ An error occurred during BIOS Setup. Error: $_"

}