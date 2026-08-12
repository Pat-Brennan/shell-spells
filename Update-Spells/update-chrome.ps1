<# 
.SYNOPSIS
    This script updates Google Chrome on Windows systems, bypassing any administrator update blocks.
.DESCRIPTION
    The script checks for Google Update policies that may prevent Chrome from updating, 
    temporarily overrides them, and then runs the Google Update executable to update Chrome. 
    It also stops any running Chrome processes before initiating the update.
.NOTES
    This was created to be used in conjunction with NinjaOne for endpoint management and can be run as a scheduled task or manually by an administrator.
#>

Write-Host "ℹ️ Checking for administrator update blocks..."
$policyPath = "HKLM:\SOFTWARE\Policies\Google\Update"

# Temporarily allow updates if the policy key exists
if (Test-Path $policyPath) {
    Write-Host "ℹ️ Overriding Google Update policies for this session to allow manual updates..."
    
    # Override Global Update Policy
    Set-ItemProperty -Path $policyPath -Name "UpdateDefault" -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $policyPath -Name "DisableAutoUpdateChecksCheckboxValue" -Value 0 -Force -ErrorAction SilentlyContinue
    
    # Override Chrome-Specific Update Policy
    Set-ItemProperty -Path $policyPath -Name "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" -Value 1 -Force -ErrorAction SilentlyContinue
}

$googleUpdatePaths = @(
    "$env:ProgramFiles\Google\Update\GoogleUpdate.exe",
    "${env:ProgramFiles(x86)}\Google\Update\GoogleUpdate.exe",
    "$env:LOCALAPPDATA\Google\Update\GoogleUpdate.exe"
) | Where-Object { Test-Path $_ }

if (-not $googleUpdatePaths) {
    Write-Error "❗ GoogleUpdate.exe not found in any expected directories."
    exit 1
}

Write-Host "⚠️ Stopping existing Chrome processes..."
Get-Process -Name chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

foreach ($updateExe in $googleUpdatePaths) {
    Write-Host "🔁 Running updater: $updateExe"
    
    # Using the correct Chromium Updater argument to target the browser
    Start-Process -FilePath $updateExe -ArgumentList '--update-apps', '--system' -Wait -NoNewWindow -ErrorAction SilentlyContinue
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "ℹ️ Updater returned exit code $LASTEXITCODE for $updateExe"
    }
}

$taskNames = @(
    '\GoogleUpdateTaskMachineCore',
    '\GoogleUpdateTaskMachineUA',
    '\GoogleUpdateTaskUserCore',
    '\GoogleUpdateTaskUserUA',
    '\GoogleUpdaterTaskSystemWakes',
    '\GoogleUpdaterTaskSystem'
)

foreach ($task in $taskNames) {
    schtasks /query /tn $task 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Triggering scheduled task: $task"
        schtasks /run /tn $task | Out-Null
    }
}

Write-Host "✅ Google Chrome update process completed."