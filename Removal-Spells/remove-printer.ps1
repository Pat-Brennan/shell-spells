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