<#

.SYNOPSIS
    This script sets all active physical network adapters to use DHCP for IP and DNS configuration.
.DESCRIPTION
    The script retrieves all active physical network adapters and configures them to obtain their IP address and
    DNS server addresses automatically via DHCP. It also requests a new DHCP lease for all adapters.
.NOTES
  Specifically designed to be used in NinjaOne as a script to set static IPs back to DHCP. It will also request a new lease for all adapters.
  ! Made for a project to move network off of static IPs and onto DHCP.

#>

$ErrorActionPreference = "Continue"

$adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Virtual -eq $false }

if (-not $adapters) {
    Write-Error "No active physical network adapters found."
    exit 1
}

foreach ($adapter in $adapters) {
    try {

        Write-Host "Setting adapter '$($adapter.Name)' to DHCP..."
        Set-NetIPInterface -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -Dhcp Enabled -ErrorAction Stop
        Write-Host "Successfully set adapter '$($adapter.Name)' to DHCP."

        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
        Write-Host "Successfully reset DNS server addresses for adapter '$($adapter.Name)'."
    
      } catch {
        Write-Error "Failed to set adapter '$($adapter.Name)' to DHCP: $_"
    }
}

write-host "Requesting new dhcp lease for all adapters..."

ipconfig /renew * | Out-Null

write-host "DHCP configuration completed."
Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address, DNSServer | Format-Table -AutoSize