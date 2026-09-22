# ==============================================================================
# Script Name: Tattoo-EndpointFromNinja.ps1
# Description: Tattoo registry keys using NinjaOne Form Environment Variables
# ==============================================================================

# Define the target registry path
$registryPath = "HKLM:\SOFTWARE\CCLS-IT\EndpointInfo"

# 1. Pull environment variables injected by NinjaOne script parameters
$assetTag       = $env:assetTag
$department     = $env:department
$supportTier    = $env:supportTier
$techUsername   = $env:NINJA_EXECUTING_USER  # Automatically populated by NinjaOne engine if available
$dateTattooed   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# Fallback defaults if optional fields are left blank by the technician
if ([string]::IsNullOrWhiteSpace($department))  { $department  = "Unassigned" }
if ([string]::IsNullOrWhiteSpace($supportTier)) { $supportTier = "Tier 1" }

# Ensure mandatory Asset Tag is present
if ([string]::IsNullOrWhiteSpace($assetTag)) {
    Write-Error "CRITICAL: Asset Tag script variable missing or empty. Tattoo aborted."
    exit 1
}

try {
    # 2. Ensure registry path exists
    if (-not (Test-Path -Path $registryPath)) {
        Write-Host "Creating new registry path at: $registryPath"
        New-Item -Path $registryPath -Force | Out-Null
    }

    Write-Host "Applying registry tattoo..."

    # 3. Write parameters to the registry
    Set-ItemProperty -Path $registryPath -Name "AssetTag"       -Value $assetTag       -Type String
    Set-ItemProperty -Path $registryPath -Name "Department"     -Value $department     -Type String
    Set-ItemProperty -Path $registryPath -Name "SupportTier"    -Value $supportTier    -Type String
    Set-ItemProperty -Path $registryPath -Name "LastTattooed"   -Value $dateTattooed   -Type String

    if (-not [string]::IsNullOrWhiteSpace($techUsername)) {
        Set-ItemProperty -Path $registryPath -Name "TattooedBy" -Value $techUsername   -Type String
    }

    Write-Host "Successfully tattooed endpoint!"

    # 4. Display output for NinjaOne Activity / Execution Log
    Write-Host "--- Updated Registry Tattoo ---"
    Get-ItemProperty -Path $registryPath | Select-Object AssetTag, Department, SupportTier, LastTattooed | Format-List

} catch {
    Write-Error "Error updating registry: $_"
    exit 1
}