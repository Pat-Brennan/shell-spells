<#
.SYNOPSIS
    This script is designed to uninstall Milestone XProtect Smart Client from a Windows system.
.DESCRIPTION
    The script searches the Windows registry for installed applications that match the name "Milestone XProtect Smart Client". 
    If found, it retrieves the uninstall string and executes the uninstallation process using msiexec. 
    The script handles both 32-bit and 64-bit registry paths.
#>


$APPNAME = "*Milestone XProtect Smart Client*"

$registryPaths = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$INSTALLEDAPPS = Get-ItemProperty -Path $registryPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like $APPNAME }

if ($INSTALLEDAPPS) {
    foreach ($app in $INSTALLEDAPPS) {
        Write-Output "✅ Found target application: $($app.DisplayName)"

        if ($app.UninstallString -match "{[A-F0-9\-]+}") {
            $msiGuid = $matches[0]
            Write-Output "ℹ️ Uninstalling $($app.DisplayName) using MSI GUID: $msiGuid"

            $uninstallArgs = "/x $msiGuid /quiet /norestart"
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $uninstallArgs -Wait -PassThru
            
            if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
                Write-Output "✅ $($app.DisplayName) has been uninstalled successfully."
            } else {
                Write-Output "❌Uninstallation failed with exit code: $($process.ExitCode)"
            }
        } else {
            Write-Output "⚠️ Uninstall string not found for $($app.DisplayName)."
        }
    }
} else {
    Write-Output "❗No target application found matching: $APPNAME"
}