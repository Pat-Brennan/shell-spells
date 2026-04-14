<#
.SYNOPSIS
  Clears the Sophos Cache and Persist states
.DESCRIPTION
  This script stops the Sophos services, clears the cache, and restarts the services.
.NOTES
  ! ENSURE TAMPER PROTECTION IS DISABLED BEFORE RUNNING THIS SCRIPT 
#>

$ErrorActionPreference = "Stop"

$CACHE_PATH = "C:\ProgramData\Sophos\Management Communications System\Endpoint\Cache"
$PERSIST_PATH = "C:\ProgramData\Sophos\Management Communications System\Endpoint\Persist"
$AGENT_SERVICE = "Sophos MCS Agent"
$CLIENT_SERVICE = "Sophos MCS Client"

try {
  write-output "ℹ️ Stopping Sophos Services ..."
  Stop-Service -Name $AGENT_SERVICE, $CLIENT_SERVICE -Force

  start-sleep -Seconds 3

  write-output "ℹ️ Clearing Sophos Cache ..."
  if(Test-Path -Path $CACHE_PATH) {
    Remove-Item -Path "$CACHE_PATH\*" -Force -Recurse
  } else {
    Write-Output "⚠️ Cache Path Not Found, Skipping...: $CACHE_PATH"
  }

  if(Test-Path -Path $PERSIST_PATH) {
    Remove-Item -Path "$PERSIST_PATH\*.xml" -Force -Recurse
  } else {
    Write-Output "⚠️ Persist Path Not Found, Skipping...: $PERSIST_PATH"
  }

  write-output "✅ Sophos Cache Cleared. Restarting Services ..."
  Start-Service -Name $AGENT_SERVICE, $CLIENT_SERVICE -Force

  $AGENT_STATUS = (Get-Service -Name $AGENT_SERVICE).Status
  $CLIENT_STATUS = (Get-Service -Name $CLIENT_SERVICE).Status

  if($AGENT_STATUS -eq "Running" -and $CLIENT_STATUS -eq "Running") {
    Write-Output "✅ Services restarted successfully."
    exit 0
  } else {
    Write-Output "⚠️ One or more services failed to restart. Please check the service status."
    exit 1
  }

}
catch {
  Write-Error "❌ An error occurred: $_"
  Write-Error "⚠️ Please ensure you have the necessary permissions and that tamper protection is disabled."
  exit 1
}
finally {
  Write-Output "✅ Done."
}