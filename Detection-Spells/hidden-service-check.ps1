Write-Output "👁️ HIDDEN SERVICES (Registry vs SCM Mismatch)"

$regServices = (Get-ChildItem -Path "HKLM:\SYSTEM\CurrentControlSet\Services").PSChildName


$scmServices = (Get-Service).Name

$hiddenServices = Compare-Object -ReferenceObject $regServices -DifferenceObject $scmServices | 
    Where-Object { $_.SideIndicator -eq "<=" } | 
    Select-Object -ExpandProperty InputObject

foreach ($service in $hiddenServices) {
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$service"
    $imagePath = (Get-ItemProperty -Path $regPath -Name "ImagePath" -ErrorAction SilentlyContinue).ImagePath
    
    [PSCustomObject]@{
        ServiceName = $service
        ImagePath   = $imagePath
        Status      = "Hidden from SCM"
    }
}

Write-Output "👁️ SUSPICIOUS SERVICE PATHS"

# Query WMI for any services running from temporary or user profile directories
Get-CimInstance Win32_Service | 
    Where-Object { $_.PathName -match "\\AppData\\|\\Temp\\|\\Users\\" } | 
    Select-Object Name, DisplayName, PathName, State | 
    Format-Table -AutoSize