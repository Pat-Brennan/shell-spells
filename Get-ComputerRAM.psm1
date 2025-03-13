
# $bytes = (Get-ComputerInfo).CsTotalPhysicalMemory
# write-host($bytes)

# $totalRam = [math]::Round($bytes / 1GB)
# Write-Host("TOTAL RAM: $totalRam")


function Get-ComputerRAM {
  [CmdletBinding()]
  param (
    [switch]$Gigabytes
  )

  $bytes = (Get-ComputerInfo).CsTotalPhysicalMemory

  if ($Gigabytes) {
    $RamGb = [math]::Round($bytes / 1GB)
    Write-Host("TOTAL RAM: $RamGb")
  }
  else {
    Write-Host("TOTAL BYTES: $bytes")
  }
}

