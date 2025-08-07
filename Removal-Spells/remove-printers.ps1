#Requires -RunAsAdministrator

# Define a list of printers to remove
$printersToRemove = @(
  "Send to OneNote 2016",
  "OneNote (Desktop)",
  "Microsoft Print to PDF",
  "Microsoft XPS Document Writer",
  "Fax"
)

# Loop through each printer in the list
foreach ($printer in $printersToRemove) {
  try {
    # Check if the printer exists before trying to remove it
    if (Get-Printer -Name $printer -ErrorAction SilentlyContinue) {
      Remove-Printer -Name $printer
      Write-Host "✅ Successfully removed printer: '$printer'"
    }
    else {
      Write-Host "ℹ️ Printer not found, skipping: '$printer'"
    }
  }
  catch {
    Write-Error "❌ Failed to remove printer '$printer': $($_.Exception.Message)"
  }
}