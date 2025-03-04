# Uninstall the new Microsoft Outlook app for the current user
# Get-AppxPackage | Where-Object {$_.Name -like '*OutlookForWindows*'} | Remove-AppxPackage -ErrorAction Continue

# Uninstall the new Microsoft Outlook app for all users (requires admin privileges)
Get-AppxPackage -AllUsers | 
Where-Object {$_.Name -like '*OutlookForWindows*'} | 
Remove-AppxPackage -AllUsers -ErrorAction Continue