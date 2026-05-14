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

ninjarmm-cli set department $department