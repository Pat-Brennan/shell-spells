# --- Administrator Check ---
# This block checks if the script is running with elevated (Administrator) privileges.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires Administrator privileges to uninstall software."
    Write-Warning "Please right-click the script file and select 'Run as Administrator'."
    # Pause the script to allow the user to read the message before the window closes.
    if ($host.Name -eq "ConsoleHost") {
        Read-Host "Press Enter to exit"
    }
    exit
}

# --- Script Configuration ---

# An array containing the exact display names of the programs to uninstall.
$programsToUninstall = @(
    "Microsoft 365 - en-us",
    "Microsoft 365 - es-es",
    "Microsoft 365 - fr-fr",
    "Microsoft 365 - pt-br",
    "Microsoft OneNote - en-us",
    "Microsoft OneNote - es-es",
    "Microsoft OneNote - fr-fr",
    "Microsoft OneNote - pt-br",
    "Microsoft 365 Apps for enterprise - en-us"
)

# Registry paths where information about installed programs is stored.
$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

# --- Main Logic ---

Write-Host "Starting the direct execution uninstallation script for Microsoft 365 language packs." -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------"

# Loop through each program name from our list
foreach ($programName in $programsToUninstall) {
    Write-Host "Processing: '$programName'..."
    $packageFound = $false

    # Get all installed programs from the registry paths
    Get-ItemProperty $registryPaths | ForEach-Object {
        # Check if the program's DisplayName matches the one we want to uninstall
        if ($_.DisplayName -eq $programName) {
            $packageFound = $true
            Write-Host "  Found '$($_.DisplayName)' in the registry." -ForegroundColor White
            
            # Check if an uninstall string exists
            if ($_.UninstallString) {
                $uninstallString = $_.UninstallString
                Write-Host "  Uninstall command found: $uninstallString"
                
                try {
                    # Execute the command directly using cmd.exe /c. This is a very reliable method.
                    # We use -Wait to ensure PowerShell waits for the uninstaller to finish.
                    # We use -NoNewWindow to keep it running in the background.
                    Write-Host "  Executing command... Please wait, this may take a moment." -ForegroundColor Yellow
                    $process = Start-Process cmd -ArgumentList "/c `"$uninstallString`"" -Wait -PassThru -NoNewWindow
                    
                    # Check the exit code of the completed process. 0 usually means success.
                    if ($process.ExitCode -eq 0) {
                        Write-Host "  ✅ Successfully executed uninstall for '$programName'. Exit Code: 0 (Success)" -ForegroundColor Green
                    } else {
                        # A non-zero exit code indicates a potential problem with the uninstaller itself.
                        Write-Warning " ℹ️ The uninstaller for '$programName' finished with Exit Code: $($process.ExitCode). This may indicate an issue."
                    }
                }
                catch {
                    # This catches errors if Start-Process itself fails.
                    Write-Error " ❌ A PowerShell error occurred while trying to launch the uninstaller for '$programName'."
                    Write-Error $_
                }
            } else {
                Write-Warning " ℹ️ Found program, but it has no UninstallString in the registry."
            }
        }
    }

    if (-not $packageFound) {
        Write-Host " ⚠️ Could not find '$programName' in the registry. It may already be uninstalled." -ForegroundColor Yellow
    }
    Write-Host "--------------------------------------------------------------------"
}

# --- License and Registry Cleanup ---
Write-Host "Starting lingering Office 365 license cleanup..." -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------------"

# 1. Clear Identity Registry Key
$identityKey = "HKCU:\Software\Microsoft\Office\16.0\Common\Identity"
if (Test-Path $identityKey) {
    Write-Host "Clearing Office Identity registry keys..."
    Remove-Item -Path $identityKey -Recurse -Force
    Write-Host "  ✅ Identity keys cleared." -ForegroundColor Green
}

# 2. Find ospp.vbs
$osppPath = $null
$pathsToTest = @(
    "C:\Program Files\Microsoft Office\Office16\ospp.vbs",
    "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"
)

foreach ($path in $pathsToTest) {
    if (Test-Path $path) {
        $osppPath = $path
        break
    }
}

if ($osppPath) {
    Write-Host "Found ospp.vbs at: $osppPath"
    Write-Host "Checking for lingering Office 365 licenses..."
    
    # Run dstatus and capture output (//nologo suppresses the Microsoft copyright banner)
    $dstatusOutput = cscript.exe //nologo "`"$osppPath`"" /dstatus
    
    $isO365License = $false
    foreach ($line in $dstatusOutput) {
        # Check if the current block belongs to an O365 license
        if ($line -match "LICENSE NAME:.*O365" -or $line -match "LICENSE DESCRIPTION:.*Subscription") {
            $isO365License = $true
        }
        
        # If we are in an O365 block and find the product key, remove it
        if ($isO365License -and $line -match "Last 5 characters of installed product key: (.{5})") {
            $key = $matches[1]
            Write-Host "  Found lingering O365 key: $key. Uninstalling..." -ForegroundColor Yellow
            
            # Uninstall the key
            $unpkeyOutput = cscript.exe //nologo "`"$osppPath`"" /unpkey:$key
            
            if ($unpkeyOutput -match "Product key uninstall successful") {
                Write-Host "  ✅ Successfully uninstalled product key: $key" -ForegroundColor Green
            } else {
                Write-Warning " ⚠️ Failed to uninstall product key: $key"
            }
            
            # Reset flag for the next block
            $isO365License = $false
        }
        
        # Reset flag if we hit a visual separator (indicating a new license block)
        if ($line -match "---------------------------------------") {
            $isO365License = $false
        }
    }
} else {
    Write-Warning " ⚠️ Could not locate ospp.vbs. Skipping license cleanup."
}

Write-Host "--------------------------------------------------------------------"
Write-Host "Script finished. Office 365 removal and license cleanup complete." -ForegroundColor Cyan