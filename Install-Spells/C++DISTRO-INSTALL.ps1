<#
.SYNOPSIS
    This script automates the installation of the Visual C++ Redistributable for Visual Studio 2017 (x64) on a Windows machine. 
    It downloads the installer from the official Microsoft URL and executes it silently, 
    ensuring that the necessary runtime components are installed without user intervention.  
.DESCRIPTION
    The script performs the following steps:
    1. Defines the direct download URL for the Visual C++ Redistributable and a temporary save location.
    2. Downloads the installer using Invoke-WebRequest.
    3. Executes the installer with silent installation arguments.
    4. Optionally cleans up the downloaded installer file after installation.
#>

$downloadUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
$tempPath = "$env:TEMP\vc_redist.x64.exe"

Try {
    Write-Output "🔄 Downloading Visual C++ Redistributable..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath

    Write-Output "✅ Download completed. Starting installation..."
    Start-Process -FilePath $tempPath -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow

    Write-Output "✅ Installation completed successfully."
} catch {
    Write-Error "❌ An error occurred during download or installation: $_"
} finally {
    if (Test-Path -Path $tempPath) {
        Remove-Item -Path $tempPath -Force
        Write-Output "🧹 Cleaned up temporary installer file."
    }
}