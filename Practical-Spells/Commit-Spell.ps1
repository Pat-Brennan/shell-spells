#? The CMDLET Solutions

# function Invoke-Commit-Spell {
#   [CmdletBinding()]
#   param (
#     [Parameter(Mandatory = $true, Position = 0)]
#     [string]$CommitMessage
#   )

#   begin {
#     # Initialization code (if needed)
#   }

#   process {
#     # Git add
#     try {
#       & git add .
#       if ($LASTEXITCODE -ne 0) {
#         throw "git add failed"
#       }
#     }
#     catch {
#       Write-Error $_
#       return # Exit the cmdlet with an error
#     }

#     # Git commit with the custom message
#     try {
#       & git commit -m "$CommitMessage"
#       if ($LASTEXITCODE -ne 0) {
#         throw "git commit failed"
#       }
#     }
#     catch {
#       Write-Error $_
#       return
#     }

#     # Git push
#     try {
#       & git push origin main
#       if ($LASTEXITCODE -ne 0) {
#         throw "git push failed"
#       }
#       Write-Host "Git push successful."
#     }
#     catch {
#       Write-Error $_
#       return
#     }

#     Write-Host "Git commands completed successfully."
#   }

#   end {
#     # Cleanup code (if needed)
#   }
# }

#? The Simple Solution

# Get the custom commit message from the user
$commitMessage = Read-Host "Enter your commit message"

# Git add
try {
  & git add .
  if ($LASTEXITCODE -ne 0) {
    throw "git add failed"
  }
}
catch {
  Write-Error $_
  exit 1 # Exit the script with an error code
}

# Git commit with the custom message
try {
  & git commit -m "$commitMessage"
  if ($LASTEXITCODE -ne 0) {
    throw "git commit failed"
  }
}
catch {
  Write-Error $_
  exit 1
}

# Git push
try {
  & git push origin main
  if ($LASTEXITCODE -ne 0) {
    throw "git push failed"
  }
  Write-Host "Git push successful."
}
catch {
  Write-Error $_
  exit 1
}

Write-Host "Git commands completed successfully."