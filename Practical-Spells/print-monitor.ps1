Write-Host "Monitoring ALL print queues..." -ForegroundColor Cyan
$OpenQueues = @{}

while ($true) {
    # Get all printers installed on the system
    $Printers = Get-Printer

    foreach ($Printer in $Printers) {
        $Name = $Printer.Name
        # Check if there are active jobs for this specific printer
        $Jobs = Get-PrintJob -PrinterName $Name -ErrorAction SilentlyContinue

        if ($Jobs -and -not $OpenQueues[$Name]) {
            Write-Host "Active job found on: $Name. Opening queue..." -ForegroundColor Green

            $Jobs | Suspend-Printjob -ErrorAction SilentlyContinue

            Start-Process "rundll32.exe" -ArgumentList "printui.dll,PrintUIEntry /o /n `"$Name`""

            Start-Sleep -Seconds 10

            $Jobs | Resume-Printjob -ErrorAction SilentlyContinue

            # Mark this printer as "Window Open" so it doesn't spam more windows
            $OpenQueues[$Name] = $true
        }
        elseif (-not $Jobs -and $OpenQueues[$Name]) {
            # Reset the tracker once the queue is empty
            Write-Host "Job cleared for: $Name." -ForegroundColor Yellow
            $OpenQueues[$Name] = $false
        }
    }

    # Reduced sleep to 0.5 seconds to catch fast-processing Ricoh jobs
    Start-Sleep -Milliseconds 500
}









# Write-Host "Monitoring ALL print queues..." -ForegroundColor Cyan
# $OpenQueues = @{}

# while ($true) {
#     # Get all printers installed on the system
#     $Printers = Get-Printer

#     foreach ($Printer in $Printers) {
#         $Name = $Printer.Name
#         # Check if there are active jobs for this specific printer
#         $Jobs = Get-PrintJob -PrinterName $Name -ErrorAction SilentlyContinue

#         if ($Jobs -and -not $OpenQueues[$Name]) {
#             Write-Host "Active job found on: $Name. Opening queue..." -ForegroundColor Green

#             $shell = New-Object -ComObject Shell.Application
#             $shell.ShellExecute("microsoft.devicesandprinters.registration:///Printers/PrintQueue?printername=$Name")

#             # Mark this printer as "Window Open" so it doesn't spam more windows
#             $OpenQueues[$Name] = $true
#         }
#         elseif (-not $Jobs -and $OpenQueues[$Name]) {
#             # Reset the tracker once the queue is empty
#             Write-Host "Job cleared for: $Name." -ForegroundColor Yellow
#             $OpenQueues[$Name] = $false
#         }
#     }

#     Start-Sleep -Seconds 1
# }



# $printerName = "RICOH IM C2500 PCL 6" 

# $encodedName = [uri]::EscapeDataString($printerName)

# Write-Host "Monitoring print queue for: $printerName..." -ForegroundColor Cyan

# while ($true) {
#     # Check for any active print jobs on the specified printer
#     $printJobs = Get-PrintJob -PrinterName $printerName -ErrorAction SilentlyContinue

#     if ($printJobs) {
#         Write-Host "Print job detected! Opening queue..." -ForegroundColor Green
        
#         $shell = New-Object -ComObject Shell.Application
#         $shell.ShellExecute("microsoft.devicesandprinters.registration:///Printers/PrintQueue?printername=$printerName")
        
#         # Wait for the job to clear before checking again to avoid opening multiple windows
#         while (Get-PrintJob -PrinterName $printerName -ErrorAction SilentlyContinue) {
#             Start-Sleep -Seconds 5
#         }
#         Write-Host "Job completed. Resuming monitor..." -ForegroundColor Yellow
#     }

#     # Wait 2 seconds between checks to save CPU
#     Start-Sleep -Seconds 1
# }



# $printerName = "RICOH IM C2500 PCL 6"
# $encodedName = [uri]::EscapeDataString($printerName)

# # Create a query to watch for "Creation" events in the Print Job class
# $query = "SELECT * FROM __InstanceCreationEvent WITHIN 1 WHERE TargetInstance ISA 'Win32_PrintJob' AND TargetInstance.Name LIKE '%$printerName%'"

# Write-Host "Waiting for print jobs on $printerName..." -ForegroundColor Cyan

# # This block waits for the event to trigger
# while ($true) {
#     try {
#         # This command pauses the script until a job is detected
#         $jobEvent = Wait-Event -SourceIdentifier "PrintJobWatcher" -ErrorAction SilentlyContinue
        
#         if ($null -eq $jobEvent) {
#             # Register the watcher if it's not already running
#             Register-WmiEvent -Query $query -SourceIdentifier "PrintJobWatcher"
#             Continue
#         }

#         Write-Host "Print job detected! Opening queue..." -ForegroundColor Green
        
#         # Open the queue
#         $shell = New-Object -ComObject Shell.Application
#         $shell.ShellExecute("microsoft.devicesandprinters.registration:///Printers/PrintQueue?printername=$encodedName")

#         # Remove the event so it can be re-registered for the next job
#         Unregister-Event -SourceIdentifier "PrintJobWatcher"
#     }
#     catch {
#         # Fallback to ensure the watcher stays active
#         Register-WmiEvent -Query $query -SourceIdentifier "PrintJobWatcher"
#     }
# }