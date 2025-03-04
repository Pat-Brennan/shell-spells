Get-Process |
Select-Object -Property *, @{Name = 'Timestamp'; Expression = { Get-Date -Format 'MMdd-yy hh:mm:ss' } } |
Export-Excel .\Processes.xlsx -WorksheetName 'ProcessesOverTime'