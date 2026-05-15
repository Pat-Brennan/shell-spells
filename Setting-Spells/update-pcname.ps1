<#
.SYNOPSIS
The goal of this script is to update the NAME of the pc it is being applied too

.DESCRIPTION
The script retrieves the computer name of the PC it is being applied to, updates it to what is entered into the prompt

.NOTES
- THIS SCRIPT IS MEANT TO BE RUN IN NINJAONE
#>


$TARGETNAME = $env:NewHostName

if([string]::IsNullOrEmpty($TARGETNAME)) {
    Write-Host "❗ Error: No new hostname provided. Exiting script."
    exit 1
}

if($TARGETNAME -eq $env:COMPUTERNAME) {
    Write-Host "⚠️ The current computer name is already '$TARGETNAME'. No changes needed."
    exit 0
}

try {
    Rename-Computer -NewName $TARGETNAME -Force -ErrorAction Stop
    Write-Host "✅ Computer name successfully updated to '$TARGETNAME'. A restart may be required for the change to take effect."
    Restart-Computer -Force
} catch {
    Write-Error "❗ Error: Failed to update computer name. $_"
}