<#
.SYNOPSIS
    Checks the SSL certificate expiration for a list of URLs.
.DESCRIPTION
    This script connects to each specified URL on port 443, retrieves the SSL certificate, and
    checks how many days are remaining until the certificate expires. It will warn if the certificate is set to expire within 30 days.
.PARAMETER Urls
    An array of URLs to check. You can include the protocol (https://) or just the domain name. The script will handle both cases.
.EXAMPLE
    .\SSL-checker.ps1 -Urls "camdencountylibrary.org", "www.camdencountylibrary.org", "google.com", "github.com"
    This will check the SSL certificates for the specified domains and output the expiration status.
.NOTES
    - This script uses the TcpClient and SslStream classes to directly connect to the server and retrieve the SSL certificate, which provides more accurate results and better error handling compared to using WebRequest.
    - Make sure to run this script in an environment that has access to the specified URLs and that the necessary .NET libraries are available.
    - The script ignores certificate validation errors to allow checking of expired or otherwise invalid certificates, but it will still report the expiration status based on the certificate information retrieved.
#>

param (
    [string[]]$Urls = @(
        "camdencountylibrary.org",
        "www.camdencountylibrary.org",
        "google.com",
        "github.com"
    )
)

foreach ($url in $Urls) {
    try {
        # Strip https:// if it was included so TcpClient just gets the raw hostname
        $domain = $url -replace "^https?://", "" -replace "/.*$", ""
        
        # Connect directly to port 443
        $tcpClient = New-Object Net.Sockets.TcpClient($domain, 443)
        $tcpStream = $tcpClient.GetStream()
        
        # Create the SSL stream and force it to ignore validation errors inline
        $sslStream = New-Object Net.Security.SslStream($tcpStream, $false, { $true })
        
        # Authenticate the client and explicitly force TLS 1.2
        $sslStream.AuthenticateAsClient($domain, $null, [System.Security.Authentication.SslProtocols]::Tls12, $false)
        
        # Grab the certificate
        $certificate = New-Object Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)
        
        $expirationDate = [DateTime]::Parse($certificate.GetExpirationDateString())
        $daysRemaining = ($expirationDate - (Get-Date)).Days

        if ($daysRemaining -le 30) {
            Write-Host "Warning: SSL certificate for $domain expires in $daysRemaining days. ($expirationDate)" -ForegroundColor Yellow
        } else {
            Write-Host "SSL certificate for $domain is valid and expires in $daysRemaining days. ($expirationDate)" -ForegroundColor Green
        }

        # Clean up
        $sslStream.Dispose()
        $tcpClient.Dispose()

    } catch {
        # This will now give you a much more accurate inner exception if it fails
        Write-Host "Error checking SSL certificate for $url : $($_.Exception.InnerException.Message -f $_)" -ForegroundColor Red
    }
}




<#! 
    Below utilizes the older WebRequest method which is more likely to run into issues
    with modern TLS requirements and may not give as detailed error messages for certificate issues.
    The newer TcpClient + SslStream approach is more robust for checking SSL certificates directly.
#>

# param (
#     [string[]]$Urls = @(
#         "https://www.camdencountylibrary.org",
#         "https://camdencountylibrary.org",
#         "https://google.com",
#         "https://github.com"
#     )
# )

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# # Tell .NET to ignore certificate trust errors so we can actually inspect invalid certs
# [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# foreach ($url in $Urls) {
#     try {
#         $request = [System.Net.WebRequest]::Create($url)
#         $request.Method = "HEAD"
#         $response = $request.GetResponse()
        
#         $certificate = $request.ServicePoint.Certificate
        
#         if ($certificate) {
#             $expirationDate = [DateTime]::Parse($certificate.GetExpirationDateString())
#             $daysRemaining = ($expirationDate - (Get-Date)).Days

#             if ($daysRemaining -le 30) {
#                 Write-Host "Warning: SSL certificate for $url expires in $daysRemaining days." -ForegroundColor Yellow
#             } else {
#                 Write-Host "SSL certificate for $url is valid and expires in $daysRemaining days." -ForegroundColor Green
#             }
#         } else {
#             Write-Host "No certificate returned for $url" -ForegroundColor Red
#         }

#         # Always close the response to free up the connection
#         $response.Close()

#     } catch {
#         # Fixed the string interpolation so you can see the actual error
#         Write-Host "Error checking SSL certificate for $url : $_" -ForegroundColor Red
#     }
# }