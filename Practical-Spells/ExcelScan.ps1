$excelSheets = Get-ExcelsheetInfo -Path .\Processes.xlsx

Foreach ($sheet in $excelSheets) {
  $workSheetName = $sheet.Name
  $sheetRows = Import-Excel -Path .\Processes.xlsx -WorkSheetName $workSheetName
  $sheetRows | Select-Object -Property *, @{'Name' = 'Worksheet'; 'Expression' = { $workSheetName } }
}