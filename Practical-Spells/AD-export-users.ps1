<#
  .SYNOPSIS
    Exports all active users from a specific OU in Active Directory to a CSV file.
  .DESCRIPTION
    This script retrieves all enabled users with an email address from the specified Organizational Unit (OU) 
    in Active Directory and exports their first name, last name, and email address to a CSV file. 
    The output file is saved in the C:\temp directory with a timestamp in the filename.
  
#>

$TargetOU = "OU=Accounts,OU=Camden365,DC=camden,DC=lib,DC=nj,DC=us"

Get-ADUser -Filter 'Enabled -eq "true" -and EmailAddress -like "*"' -SearchBase $TargetOU -Properties EmailAddress | 
Select-Object GivenName, Surname, EmailAddress | 
Select-Object @{Name="FirstName";Expression={$_.GivenName}},
              @{Name="LastName";Expression={$_.Surname}},
              @{Name="Email";Expression={$_.EmailAddress}} |
Export-Csv "C:\temp\Active-Users_$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation -Encoding UTF8