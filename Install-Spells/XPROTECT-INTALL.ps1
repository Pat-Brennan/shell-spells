<#
.SYNOPSIS
    Installs Milestone XProtect Smart Client 2026 R1 silently.
.DESCRIPTION
    This script checks for the presence of the Milestone XProtect Smart Client installer at a specified path and runs it with silent installation arguments.
    It also checks the exit code to confirm if the installation was successful.

.NOTES
    ! requires the installer to be located at C:\Xprotect\Milestone XProtect Smart Client 2026 R1 Installer.exe
#>


$INSTALLERPATH = "C:\Xprotect\Milestone XProtect Smart Client 2026 R1 Installer.exe"

$ARGUMENTS = "--quiet"

Try {
  if(!(Test-Path $INSTALLERPATH)) {
    Write-Error "❌ Installer not found at path: $INSTALLERPATH"
    Exit 1
  } else {
    Write-Output "🔄 Starting installation of Milestone XProtect Smart Client 2026 R1..."
  }

$PROCESS = Start-Process -FilePath $INSTALLERPATH -ArgumentList $ARGUMENTS -Wait -PassThru

if($PROCESS.ExitCode -eq 0 -or $PROCESS.ExitCode -eq 3010) {
    Write-Output "✅ Milestone XProtect Smart Client 2026 R1 installed successfully."
  } else {
    Write-Error "❌ Installation failed with exit code: $($PROCESS.ExitCode)"
  } 
} Catch {
    Write-Error "❌ An error occurred during installation: $_"
}