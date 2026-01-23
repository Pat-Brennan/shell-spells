# POWERSHELL 7 REQUIRED FOR THIS SCRIPT

#HIGH SPEEED NETWORK MONITOR DASHBOARD

# Define the range
$subnet = "10.5.10"
$ips = 1..255 | ForEach-Object { "$subnet.$_" }
$columns = 4

while ($true) {
    # 1. Run the high-speed scan
    $results = $ips | ForEach-Object -Parallel {
        $ping = [System.Net.NetworkInformation.Ping]::new()
        try {
            $reply = $ping.Send($_, 500)
            if ($reply.Status -eq 'Success') {
                [PSCustomObject]@{ IP = $_; Status = "UP"; Color = "Green" }
            } else {
                [PSCustomObject]@{ IP = $_; Status = "DOWN"; Color = "Red" }
            }
        } catch {
            [PSCustomObject]@{ IP = $_; Status = "ERR"; Color = "Gray" }
        }
    } -ThrottleLimit 100

    # 2. Sort results numerically
    $sorted = $results | Sort-Object { [version]$_.IP }

    # 3. UI Header
    Clear-Host
    Write-Host "--- Network Dashboard ($subnet.1 - .255) ---" -ForegroundColor Yellow
    Write-Host "Updated: $(Get-Date -Format 'HH:mm:ss') | 4-Column View" -ForegroundColor Gray
    Write-Host ("=" * 85)

    # 4. Calculate rows for the columns
    # Formula: Total Items / Columns (Rounded up)
    $rowCount = [Math]::Ceiling($sorted.Count / $columns)

    for ($i = 0; $i -lt $rowCount; $i++) {
        for ($j = 0; $j -lt $columns; $j++) {
            $index = $i + ($j * $rowCount)
            if ($index -lt $sorted.Count) {
                $item = $sorted[$index]
                
                # Format: IP (padded to 15) [STATUS] (padded to 6) + spacing
                $ipString = $item.IP.PadRight(15)
                $statusString = "[$($item.Status)]".PadRight(8)
                
                Write-Host $ipString -NoNewline
                Write-Host $statusString -ForegroundColor $item.Color -NoNewline
                Write-Host " | " -NoNewline
            }
        }
        Write-Host "" # New line after each row
    }

    Write-Host ("=" * 85)
    Write-Host "Scanning... (Next refresh in 10s)"
    Start-Sleep -Seconds 10
}