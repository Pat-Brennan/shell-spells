<#
.SYNOPSIS
    This script uninstalls specific Microsoft 365 language packs using a direct execution method.

.DESCRIPTION
    The script finds the exact uninstall command for each program in the Windows Registry and executes it
    directly using cmd.exe. This method is highly reliable, especially for Click-to-Run installers and when
    running under management tools like NinjaRMM.

.NOTES
    Author: Gemini
    Date: 2024-07-03
    Requires: Run this script with Administrator privileges. The script includes a check for this.
#>

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
  "Microsoft 365 - pt-br"
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
            Write-Host "  Successfully executed uninstall for '$programName'. Exit Code: 0 (Success)" -ForegroundColor Green
          }
          else {
            # A non-zero exit code indicates a potential problem with the uninstaller itself.
            Write-Warning "  The uninstaller for '$programName' finished with Exit Code: $($process.ExitCode). This may indicate an issue."
          }
        }
        catch {
          # This catches errors if Start-Process itself fails.
          Write-Error "  A PowerShell error occurred while trying to launch the uninstaller for '$programName'."
          Write-Error $_
        }
      }
      else {
        Write-Warning "  Found program, but it has no UninstallString in the registry."
      }
    }
  }

  if (-not $packageFound) {
    Write-Host "  Could not find '$programName' in the registry. It may already be uninstalled." -ForegroundColor Yellow
  }
  Write-Host "--------------------------------------------------------------------"
}

Write-Host "Script finished. Please refresh 'Apps & features' to confirm removal." -ForegroundColor Cyan
