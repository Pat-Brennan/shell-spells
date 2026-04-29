<#
  .SYNOPSIS
    Eliminates erronous popups that emerge when opening Adobe Acrobat

  .DESCRIPTION
    Built for better public PC management of Adobe Acrobat since Acrobat reader was deprecated
#>


# 1. Suppress Sign-in Prompt & Force Free Reader Mode
$LockdownPaths = @(
    "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockDown",
    "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown"
)

foreach ($Path in $LockdownPaths) {
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name "bIsSCReducedModeEnforcedEx" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $Path -Name "bAcroSuppressUpsell" -Value 1 -Type DWord -Force
}

# 2. Auto-Accept the EULA for All Users System-Wide
$ViewerPaths = @(
    "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\AdobeViewer",
    "HKLM:\SOFTWARE\WOW6432Node\Adobe\Adobe Acrobat\DC\AdobeViewer",
    "HKLM:\SOFTWARE\Adobe\Acrobat Reader\DC\AdobeViewer",
    "HKLM:\SOFTWARE\WOW6432Node\Adobe\Acrobat Reader\DC\AdobeViewer"
)

foreach ($Path in $ViewerPaths) {
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    # 1 = EULA is silently accepted
    Set-ItemProperty -Path $Path -Name "EULA" -Value 1 -Type DWord -Force
    
    # Caches acceptance for the browser plugin as well
    Set-ItemProperty -Path $Path -Name "EULAAcceptedForBrowser" -Value 1 -Type DWord -Force
}