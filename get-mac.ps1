  # This script runs on a 'Helper' device (one that is already ON).
  # It finds all devices in the same Location, pulls their MAC from the custom field, and sends the wake packet.

  # 1. Define the custom field name used in Ninja
  $FieldName = "Target_MAC_Address"

  # 2. Get all devices in the current Location (via Ninja's internal data)
  # Note: In a real automation, you can use Ninja-Property-Get if running 1-to-1, 
  # but for a "Master" wake, we pull from the organization inventory.

  Write-Host "Searching for offline devices in this location..."

  # Fetching list of MACs (This logic assumes you've synced MACs to the Custom Field)
  # Use NinjaOne's internal CLI to get sibling device properties
  $DeviceList = ninjarmm-cli get-group-devices # or specific location filter

  foreach ($Device in $DeviceList) {
    $Mac = $Device.CustomFields.$FieldName
    $Status = $Device.Status

    if ($Status -eq "OFFLINE" -and $Mac) {
      Write-Host "Sending Magic Packet to: $($Device.Name) ($Mac)"
          
      $MacByteArray = $Mac -split "[:-]" | ForEach-Object { [Byte] "0x$_" }
      [Byte[]] $MagicPacket = (, 0xFF * 6) + ($MacByteArray * 16)
      $UdpClient = New-Object System.Net.Sockets.UdpClient
      $UdpClient.Connect(([System.Net.IPAddress]::Broadcast), 9)
      $UdpClient.Send($MagicPacket, $MagicPacket.Length)
      $UdpClient.Close()
    }
  }


  Get-AD