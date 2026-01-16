# Define the list of computers (names or IP addresses) to ping
$computers = @(
  #INSERT IPs HERE
)

# Use a ForEach loop to iterate through the list
$results = foreach ($computer in $computers) {
  Write-Host "Pinging $computer..." -ForegroundColor Cyan
  # Use Test-Connection with Count 1 for a single ping packet
  # ErrorAction SilentlyContinue prevents the script from stopping if a host is unreachable
  $pingResult = Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue

  if ($pingResult.Status -eq 'Success') {
    [PSCustomObject]@{
      ComputerName = $computer
      Status       = "Up (Reachable)"
      ResponseTime = $pingResult.Latency
      IPv4Address  = $pingResult.Address.IPAddressToString
    }
  }
  else {
    [PSCustomObject]@{
      ComputerName = $computer
      Status       = "Down (Unreachable)"
      ResponseTime = "N/A"
      IPv4Address  = "N/A"
    }
  }
}

Write-Host "`n--- Ping Results Summary ---`n" -ForegroundColor Green
$results | Format-Table -AutoSize
