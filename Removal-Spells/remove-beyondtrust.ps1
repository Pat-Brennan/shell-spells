$appName = "*Privileged Remote Access Jump Client*"

# Search the 64-bit and 32-bit registry hives for the exact app in your screenshot
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$installedApps = Get-ItemProperty $registryPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $appName }

if ($installedApps) {
    foreach ($app in $installedApps) {
        Write-Output "Preparing to uninstall: $($app.DisplayName)"
        
        $uninstallString = $app.UninstallString
        
        # Check if it was deployed via MSI
        if ($uninstallString -match "msiexec") {
            $guid = $app.PSChildName
            Write-Output "Running MSI silent uninstall..."
            Start-Process "msiexec.exe" -ArgumentList "/x $guid /qn /norestart" -Wait -NoNewWindow
            Write-Output "Uninstallation triggered."
        }
        # Otherwise, handle the standard EXE installer (bomgar-pec.exe)
        elseif ($uninstallString -match "bomgar-pec.exe") {
            # Extract the raw file path by stripping quotes and the standard -uninstall flag
            $exePath = $uninstallString -replace '"', '' -replace ' -uninstall.*', ''
            
            if (Test-Path $exePath) {
                Write-Output "Running EXE silent uninstall..."
                # Append the 'silent' parameter to the BeyondTrust uninstaller
                Start-Process -FilePath $exePath -ArgumentList "-uninstall silent" -Wait -NoNewWindow
                Write-Output "Uninstallation triggered."
            } else {
                Write-Warning "Executable not found at expected path: $exePath"
            }
        }
        else {
            Write-Warning "Unrecognized uninstall string format: $uninstallString"
        }
    }
} else {
    Write-Output "No installation found matching '$appName'."
}