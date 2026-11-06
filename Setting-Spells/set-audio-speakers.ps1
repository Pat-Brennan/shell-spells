<#
Sets the audio speakers on the system.
#>

Begin {

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

    if (-not (Get-Module -ListAvailable -Name AudioDeviceCmdlets)) {
        Install-Module -Name AudioDeviceCmdlets -Scope CurrentUser -Force
    }

    Import-Module -Name AudioDeviceCmdlets
}

Process {
    Try {
        $speakers = Get-AudioDevice -List | Where-Object { $_.Name -match "Speakers" -and $_.Type -eq "Playback" }
        
        if ($speakers) {
            $targetSpeaker = $speakers | Select-Object -First 1
            Set-AudioDevice -ID $targetSpeaker.ID
            Write-Host "Successfully set default audio device to: $($targetSpeaker.Name)"
        } else {
            Write-Warning "No speakers found on the system."
        } 
    }
    Catch {
        Write-Error "An error occurred while setting the audio speakers: $_"
    } 
}