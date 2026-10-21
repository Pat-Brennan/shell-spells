# ==============================================================================
# Script: Auto-Provision Staff Folders (NinjaOne / Local File Server)
# Target OS: Windows Server 2012 R2+
# ==============================================================================

# 1. Automatic RSAT Check & Installation (Required for Server 2012 R2 member servers)
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Output "ActiveDirectory module not found. Installing RSAT-AD-PowerShell..."
    Install-WindowsFeature RSAT-AD-PowerShell | Out-Null
}
Import-Module ActiveDirectory

# 2. Environment Configuration
# Local disk path on the File Server hosting the S: Drive
$BasePath = "E:\S_Drive\Staff Folders" 

# Base search root capturing IT, MGR, and Staff sub-OUs
$SearchBaseOU = "OU=Accounts,OU=Camden365,DC=camden,DC=lib,DC=nj,DC=us"
$DomainNetBIOS = "CAMDEN"

# 3. Retrieve all enabled user accounts recursively across sub-OUs
$Users = Get-ADUser -SearchBase $SearchBaseOU -SearchScope Subtree -Filter {Enabled -eq $true} -Properties SamAccountName

Write-Output "Found $($Users.Count) active accounts under $SearchBaseOU"

# 4. Process each account and provision missing directories
foreach ($User in $Users) {
    $SamName    = $User.SamAccountName
    $FolderPath = Join-Path -Path $BasePath -ChildPath $SamName
    $DomainUser = "$DomainNetBIOS\$SamName"

    # Only execute if the folder does not already exist
    if (-not (Test-Path -Path $FolderPath)) {
        Write-Output "Creating directory for $SamName at: $FolderPath"
        New-Item -Path $FolderPath -ItemType Directory -Force | Out-Null

        # Retrieve default ACL
        $Acl = Get-Acl -Path $FolderPath

        # Disable inheritance from root, but preserve local SYSTEM / Administrator rights
        $Acl.SetAccessRuleProtection($true, $true)

        # Define explicit Modify rule: Applies to "This folder, subfolders and files"
        $Permission  = "Modify"
        $Inherit     = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
        $Propagation = [System.Security.AccessControl.PropagationFlags]::None
        $AccessType  = [System.Security.AccessControl.AccessControlType]::Allow

        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $DomainUser, 
            $Permission, 
            $Inherit, 
            $Propagation, 
            $AccessType
        )

        # Apply rule and write back to folder
        $Acl.AddAccessRule($AccessRule)
        Set-Acl -Path $FolderPath -AclObject $Acl

        Write-Output "Successfully set permissions for $DomainUser"
        Write-Output "Successfully set permissions for $DomainUser"
        Write-Output "Successfully set permissions for $DomainUser"
        Write-Output "Successfully set permissions for $DomainUser"
    }
}