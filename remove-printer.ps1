[Parameter(Mandatory = $true)]
[string] $PrinterName = "PRINTER TO BE REMOVED HERE"

try {
  Remove-Printer -Name $PrinterName
  Write-Output "Printer '$PrinterName' removed from the local computer." -ForegroundColor Green
}
catch {
  Remove-Printer -Name $PrinterName -ErrorAction Stop
  Write-Error "Failed to remove '$PrinterName': $($_.Exception.Message)"
}

<#
.SYNOPSIS
    Removes a specified printer from the local or remote computer.
.DESCRIPTION
    This script removes a printer based on the provided printer name. It can operate on the local computer or a remote computer.
.PARAMETER ComputerName
    The name of the remote computer. If omitted, the script operates on the local computer.
.PARAMETER PrinterName
    The name of the printer to remove. This parameter is mandatory.
.EXAMPLE
    .\Remove-Printer.ps1 -PrinterName "HP LaserJet Pro"
    Removes the "HP LaserJet Pro" printer from the local computer.
.EXAMPLE
    .\Remove-Printer.ps1 -ComputerName "RemotePC" -PrinterName "Brother MFC-L2750DW"
    Removes the "Brother MFC-L2750DW" printer from the remote computer named "RemotePC".
#>

param (
  [string]$ComputerName,
  [Parameter(Mandatory = $true)]
  [string]$PrinterName
)

try {
  if ($ComputerName) {
    # Remote computer
    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
      Remove-Printer -Name $using:PrinterName -ErrorAction Stop
    }
    Write-Host "Printer '$PrinterName' removed from '$ComputerName'." -ForegroundColor Green
  }
  else {
    # Local computer
    Remove-Printer -Name $PrinterName -ErrorAction Stop
    Write-Host "Printer '$PrinterName' removed from the local computer." -ForegroundColor Green
  }
}
catch {
  Write-Error "Failed to remove printer '$PrinterName': $($_.Exception.Message)"
}