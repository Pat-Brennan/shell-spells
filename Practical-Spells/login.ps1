$adminCredential = Get-Credential

$session = New-PSSession -Credential $adminCredential

Enter-PSSession $session