# Define the user's home directory.
# This makes the script more flexible, as it will work for any user.
$homeDirectory = Get-ChildItem -Path "Env:HOMEDRIVE" | Select-Object -ExpandProperty Value
$homePath = Get-ChildItem -Path "Env:HOMEPATH" | Select-Object -ExpandProperty Value
$userProfile = "$homeDirectory$homePath"

# Define the list of folders to clean.
# We're using the user profile path to ensure we target the correct folders.
$foldersToClean = @(
  "$userProfile\Documents",
  "$userProfile\Downloads",
  "$userProfile\Desktop",
  "$userProfile\Pictures",
  "$userProfile\Videos"
)

# Loop through each folder in our list.
foreach ($folder in $foldersToClean) {
  # Check if the folder exists to prevent errors.
  if (Test-Path -Path $folder) {
    Write-Host "Cleaning up folder: $folder"

    # Get all files and folders within the target folder.
    # -Recurse ensures that we get items in subfolders as well.
    # -Force is used to access hidden or system files/folders.
    $items = Get-ChildItem -Path $folder -Recurse -Force

    # Check if there are any items to delete before proceeding.
    if ($items.Count -gt 0) {
      # Delete all the items.
      # -Recurse deletes subfolders and their contents.
      # -Force handles read-only files.
      # -Confirm:$false prevents a confirmation prompt for each file.
      Remove-Item -Path $items.FullName -Recurse -Force -Confirm:$false
    }
    else {
      Write-Host "Folder is already empty."
    }
  }
  else {
    Write-Host "Folder not found: $folder"
  }
}

Write-Host "Cleanup complete!"