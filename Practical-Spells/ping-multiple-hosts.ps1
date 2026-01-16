# Define the list of computers (names or IP addresses) to ping
# Example list:
$computers = @("10.5.1.211",
  "10.5.1.212",
  "10.5.1.213",
  "10.5.1.214",
  "10.5.1.215",
  "10.5.1.216",
  "10.5.1.217",
  "10.5.1.218",
  "10.5.1.219",
  "10.5.1.220",
  "10.5.1.221",
  "10.5.1.222",
  "10.5.1.223",
  "10.5.1.224",
  "10.5.1.225",
  "10.5.1.226",
  "10.5.1.227",
  "10.5.1.228",
  "10.5.1.229",
  "10.5.1.230",
  "10.5.1.231",
  "10.5.1.232",
  "10.5.1.233",
  "10.5.1.234",
  "10.5.1.235",
  "10.5.1.236",
  "10.5.1.237",
  "10.5.1.238",
  "10.5.1.239",
  "10.5.1.240",
  "10.5.1.241",
  "10.5.1.242",
  "10.5.1.243",
  "10.5.1.244",
  "10.5.1.245",
  "10.5.1.246",
  "10.5.1.247",
  "10.5.1.248",
  "10.5.1.249",
  "10.5.1.250",
  "10.5.1.251",
  "10.5.1.252",
  "10.5.1.253",
  "10.5.1.254"

)

# Use a ForEach loop to iterate through the list
$results = foreach ($computer in $computers) {
  Write-Host "Pinging $computer..." -ForegroundColor Cyan
  # Use Test-Connection with Count 1 for a single ping packet
  # ErrorAction SilentlyContinue prevents the script from stopping if a host is unreachable
  $pingResult = Test-Connection -ComputerName $computer -Count 1 -ErrorAction SilentlyContinue

  if ($pingResult.Status -eq 'Success') {
    # If successful, create a custom object with details
    [PSCustomObject]@{
      ComputerName = $computer
      Status       = "Up (Reachable)"
      ResponseTime = $pingResult.Latency
      IPv4Address  = $pingResult.Address.IPAddressToString
    }
  }
  else {
    # If unsuccessful, create a custom object indicating failure
    [PSCustomObject]@{
      ComputerName = $computer
      Status       = "Down (Unreachable)"
      ResponseTime = "N/A"
      IPv4Address  = "N/A"
    }
  }
}

# Display the final results in a clean table format
Write-Host "`n--- Ping Results Summary ---`n" -ForegroundColor Green
$results | Format-Table -AutoSize
