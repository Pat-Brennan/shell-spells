# Define the list of computers (names or IP addresses) to ping
$computers = @(
  # INSERT IPs HERE
)

# Use a ForEach loop to iterate through the list
$computers |  ForEach-Object -Parallel {
  $ping = Test-Connection -TargetName $_ -Count 1 -ErrorAction SilentlyContinue

  if ($ping.status -eq 'Success') {
    Write-Output "$_ is UP (Latency: $($ping.ResponseTime)ms)"
  }
  else {
    Write-Output "$_ is DOWN"
  }
} -ThrottleLimit 50
