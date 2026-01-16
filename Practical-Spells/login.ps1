#Running these commands can get you into automation
$adminCredential = Get-Credential

$session = New-PSSession -Credential $adminCredential

Enter-PSSession $session