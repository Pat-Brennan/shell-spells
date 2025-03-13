function Send-WakeOnLan {
  param(
    [string]$MacAddress,
    [string]$IpAddress = "255.255.255.0",
    [int]$Port = 7
  )

  # Validate MAC address format
  if ($MacAddress -notmatch "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$") {
    Write-Error "Invalid MAC address format. Use format like 'XX:XX:XX:XX:XX:XX'."
    return
  }

  # Convert MAC address to byte array
  $MacBytes = $MacAddress -split "[:-]" | ForEach-Object { [byte]"0x$_" }

  # Create magic packet
  $MagicPacket = (, 0xFF * 6) + ($MacBytes * 16)

  # Create UDP client
  $UdpClient = New-Object System.Net.Sockets.UdpClient
  try {
    # Send magic packet
    $UdpClient.Send($MagicPacket, $MagicPacket.Length, $IpAddress, $Port)
    Write-Host "Magic packet sent to '$MacAddress' at '${IpAddress}:$Port'"
  }
  catch {
    Write-Error "Failed to send magic packet: $_"
  }
  finally {
    $UdpClient.Close()
  }
}

# Example usage:
$MacAddress = "30:d0:42:fd:cd:50" # Replace with your PC's MAC address
Send-WakeOnLan -MacAddress $MacAddress