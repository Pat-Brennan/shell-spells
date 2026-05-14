<#
.SYNOPSIS
  This scripts utilizes NinjaOne to organize different to PCs into their specific departments. It adds a custom field called "Department" to each PC's inventory in NinjaOne, allowing for better categorization and management of devices based on their assigned department.
.DESCRIPTION
  The script retrieves a list of all PCs, and updates each PC's inventory with a new custom field "Department". The value for this field can be set based on the department the PC belongs to (e.g., IT, HR, Finance). This helps in organizing and managing devices more efficiently within NinjaOne.
.NOTES
  - The script can be customized to set the "Department" field based on specific criteria (e.g., IP address, hostname patterns, etc.).
  - Ensure that the custom field "department" is created in NinjaOne before running the script to avoid errors.
  - This script is intended for use in environments where device management and organization are crucial for operational efficiency.
#>

$ComputerName = $env:COMPUTERNAME

switch -Wildcard ($ComputerName) {
    "VA*" { $department = "ADMIN"; break }
    "VB*" { $department = "BUSINESS"; break }
    "VH*" { $department = "HR"; break }
    "VI*" { $department = "IT"; break }
    "VL*" { $department = "LVCC"; break }
    "VM*" { $department = "MAINTENANCE"; break }
    "VP*" { $department = "PR"; break }
    "VR*" { $department = "ADULT SERVICES"; break }
    "VS*" { $department = "CIRC"; break }

    # Specific patterns that begin with VT
    "VT1F-CIRC*" { $department = "CIRC"; break }
    "VT2F-AS*" { $department = "ADULT SERVICES"; break }
    "VT2F-ASO*" { $department = "ADULT SERVICES"; break }
    "VT2F-REFD*" { $department = "ADULT SERVICES"; break }
    "VT2F-REFO*" { $department = "ADULT SERVICES"; break }
    "VT3F-BOM*" { $department = "MAINTENANCE"; break }
    "VT3F-IT*" { $department = "IT"; break }
    "VT3F-MGR*" { $department = "ADMIN"; break }

    # VT Catch all moved to bottom to prevent it from catching other VT patterns
    "VT*" { $department = "TECH SERVICES"; break }
    "VY*" { $department = "YOUTH SERVICES"; break }

  Default { $department = "UNKNOWN" }
}

$DeptMappings = @{
    "MAINTENANCE" = "0d01be9e-bfec-4f8d-9f63-1bca0d960878"
    "BUSINESS" = "1315b2f1-9a1c-47bd-b2a7-552d7d78d2af"
    "ADULT SERVICES" = "1c866dd6-5c29-4a02-bf25-6389830edacd"
    "SECURITY" = "1ca7cc4e-8fad-4072-a4b8-92bd784805c7"
    "HR" = "2dacdae7-8ffc-48a5-9422-2c7f6de03084"
    "CIRC" = "75686bc9-2d5c-4726-8fc8-dc582f534af1"
    "YOUTH SERVICES" = "77753a94-5f21-4d63-a473-3c1da7b7ad6e"
    "ADMIN" = "7be0e4ec-f8f1-4ecb-b309-64548b26e7d9"
    "LVCC" = "ad7596f5-9eb0-4265-a219-aa3ce82e849a"
    "PR" = "b53d9fe9-658a-4427-a864-d12c44583efa"
    "TECH SERVICES" = "e85269e9-1582-42d7-a377-2c206cb8b7ea"
    "IT" = "e880e47d-c65c-4e31-a17b-c67a1adfb412"
}

$TargetUUID = $DeptMappings[$department]

if($TargetUUID) {
    Set-NinjaProperty Department $TargetUUID
    Write-Host "✅ Department '$department' mapped to UUID '$TargetUUID' and set successfully."
} else {
    Write-Error " ❗ERROR: Department '$department' does not have a corresponding UUID mapping. Could not set the Department field for this PC."
}



# Acceptable values: 
# 0d01be9e-bfec-4f8d-9f63-1bca0d960878, #? MAINTENANCE
# 1315b2f1-9a1c-47bd-b2a7-552d7d78d2af, #? BUSINESS
# 1c866dd6-5c29-4a02-bf25-6389830edacd, #? ADULT SERVICES
# 1ca7cc4e-8fad-4072-a4b8-92bd784805c7,#? SECURITY
# 2dacdae7-8ffc-48a5-9422-2c7f6de03084,#? HR
# 75686bc9-2d5c-4726-8fc8-dc582f534af1, #? CIRC
# 77753a94-5f21-4d63-a473-3c1da7b7ad6e, #? YOUTH SERVICES
# 7be0e4ec-f8f1-4ecb-b309-64548b26e7d9, #? ADMIN
# ad7596f5-9eb0-4265-a219-aa3ce82e849a, #? LVCC
# b53d9fe9-658a-4427-a864-d12c44583efa, #? PR
# e85269e9-1582-42d7-a377-2c206cb8b7ea, #? TECH SERVICES
# e880e47d-c65c-4e31-a17b-c67a1adfb412 #? IT
