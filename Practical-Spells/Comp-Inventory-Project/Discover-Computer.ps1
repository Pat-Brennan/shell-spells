$rows = Import-Csv -Path D:\PowerShell\PART-II\Comp-Inventory-Project\HTLiveIPList.csv

foreach($row in $rows) {
    try {
        $output = @{
            IPAddress = $row.IP
            Name = $row.Name
            Type = $row.Type
            IsOnline = $false
            Error = $null
        }
        if (Test-Connection -ComputerName $row.IP -Count 1 -Quiet) {
            $output.IsOnline = $true
        }
        if($hostname = (Resolve-DnsName -Name $row.IP -ErrorAction Stop).Name) {
            $output.Name = $hostname
        }
    } catch {
        $output.error = $_.Exception.Message
    } finally {
        [PSCustomObject]$output
    }
}