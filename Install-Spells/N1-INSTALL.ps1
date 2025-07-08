Set-ExecutionPolicy RemoteSigned -Force
 
Install-Module OSD -Force
 
Import-Module OSD -Force
 
New-OSDCloudTemplate
 
New-OSDCloudWorkspace -WorkspacePath C:\OSDCloud
 
New-OSDCloudUSB
 
Edit-OSDCloudwinPE -workspacepath C:\OSDCloud -CloudDriver * -WebPSScript https://github.com/Pat-Brennan/shell-spells/blob/main/Install-Spells/N1-INSTALL.ps1 -Verbose
 
New-OSDCloudISO
 
Update-OSDCloudUSB