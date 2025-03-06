# Get all network adapters that support Wake-on-LAN
$NetworkAdapters = Get-NetAdapter | Where-Object { $_.WakeOnMagicPacket -ne $null }

if ($NetworkAdapters) {
  foreach ($Adapter in $NetworkAdapters) {
    Write-Host "Adapter Name: $($Adapter.Name)"
    Write-Host "  Wake on Magic Packet: $($Adapter.WakeOnMagicPacket)"
    Write-Host "  Wake on Pattern: $($Adapter.WakeOnPattern)"
    Write-Host "  Enabled: $($Adapter.Status -eq 'Up')"
    Write-Host "------------------------"
  }
}
else {
  Write-Host "No network adapters with Wake-on-LAN capabilities found."
}