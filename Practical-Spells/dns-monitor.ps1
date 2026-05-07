<#
.SYNOPSIS
    This script monitors DNS query activity on a Windows machine to detect potential abuse of library endpoints that may be generating excessive DNS requests.
.DESCRIPTION
    The script enables the DNS Operational Log temporarily, monitors for a specified duration (60 seconds), and counts the number of DNS queries sent (Event ID 3006). If the count exceeds a defined threshold (e.g., 500 queries), it triggers an alert. After monitoring, it disables the log to prevent unnecessary log growth.
.NOTES  
    - Requires administrative privileges to enable/disable the DNS Operational Log.
    - Designed for use in environments where library endpoints may be generating excessive DNS traffic, which can indicate abuse or misconfiguration.
    - Adjust the threshold and monitoring duration as needed based on typical network activity patterns.
#>

# 1. Enable the DNS Operational Log temporarily
wevtutil sl Microsoft-Windows-DNS-Client/Operational /e:true

Write-Output "ℹ️ DNS logging enabled. Monitoring network activity for 60 seconds..."
Start-Sleep -Seconds 60

# 2. Query the log for DNS queries sent (Event ID 3006) in the last minute
$startTime = (Get-Date).AddSeconds(-65) 
$dnsEvents = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-DNS-Client/Operational'; ID=3006; StartTime=$startTime} -ErrorAction SilentlyContinue

# 3. Disable the log to clean up and prevent log bloat
wevtutil sl Microsoft-Windows-DNS-Client/Operational /e:false

# 4. Tally the results
$eventCount = if ($dnsEvents) { $dnsEvents.Count } else { 0 }

# 5. Evaluate against a flood threshold (e.g., 500 requests a minute is highly suspect for a library endpoint)
if ($eventCount -gt 500) {
    Write-Output " ‼️ ALERT: High DNS activity detected! $eventCount queries sent in 60 seconds."
    exit 1
} else {
    Write-Output "✅ Traffic normal. Only $eventCount queries sent in the last 60 seconds."
    exit 0
}