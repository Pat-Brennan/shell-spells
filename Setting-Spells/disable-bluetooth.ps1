
Install-Module -Name DellBIOSProvider -Force

Import-Module DellBIOSProvider

Set-Location DellSMBIOS:\

Set-Item -Path "DellSMBIOS:\Wireless\BluetoothDevice" -Value "Disabled" -Password (Get-Credential -Message "Enter the password for the BIOS settings")