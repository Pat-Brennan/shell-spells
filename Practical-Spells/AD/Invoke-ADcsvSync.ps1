$syncFieldMap = @{
  fname = 'GivenName'
  lname = 'surname'
  dept  = 'Department'
}

$fieldMatchIds = @{
  AD  = @('givenName', 'surName')
  CSV = @('fname', 'lname')
}

function get-AcmeEmployeeFromCsv {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateNotNullOrEmpty]
    [string]$CsvFilePath = 'D:\PowerShell\PART-II\AD\Employees.csv',

    # Parameter help description
    [Parameter(Mandatory)]
    [hashtable]
    $syncFieldMap,

    [Parameter(Mandatory)]
    [hashtable]
    $fieldMatchIds
  )
}

try {
  $properties = $syncFieldMap.GetEnumerator() | ForEach-Object {
    @{
      name       = $_.Value
      Expression = [scriptblock]::Create("`$_.$($_.Key)")
    }
  }
  $uniqueIdProperty = '"{0}{1}" -f'
  $uniqueIdProperty = $uniqueIdProperty += ($fieldMatchIds.CSV | 
    ForEach-Object { '$_.{0}' -f $_ }) -join ','
  $properties += @{
    Name       = 'UniqueID'
    Expression = [scriptblock]::Create($uniqueIdProperty)
  }
  Import-Csv -Path $CsvFilePath | Select-Object - Property $properties
}
catch {
  Write-Error -Message $_.Exception.Message
}

function Get-AcmeEmployeeFromAD {
  [CmdletBinding()]
  param()

  try {
    $uniqueIdProperty = '"{0}{1}" -f '
    $uniqueIdProperty += ($fieldMatchIds.AD | ForEach-Object { '$_.{0}' -f $_ }) -join ','

    $uniqueIdProperty = @{
      Name       = 'UniqueID'
      Expression = [scriptblock]::Create($uniqueIdProperty)
    }

    Get-ADUser -Filter * -Properties @($syncFieldMap.Values) | Select-Object *, $uniqueIdProperty

  }
  catch {
    Write-Error -Message $_.Exception.Message
  }
}

function Find-UserMatch {
  [OutputType()]
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [object[]]$ADUsers = (Get-AcmeEmployeeFromAD),

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [object]$CsvUsers = (Get-AcmeEmployeeFromCsv)
  )

  $ADUsers.foreach({
      $adUniqueID = $_.UniqueID
      if ($adUniqueID) {
        $output = @{
          CSVProperties    = 'NoMatch'
          ADSamAccountName = $_.samAccountName
        }
        if ($adUniqueID -in $CsvUsers.UniqueID) {
          $output.CSVProperties = ($CsvUsers.Where({ $_.UniqueID -eq $adUniqueID }))
        }
        [pscustomobject]$output
      }
    })
}

$positiveMatches = (Find-UserMatch).where({ $_.CSVProperties -ne 'NoMatch' })
foreach ($positiveMatch in $positiveMatches) {
  $setAdUserParams = @{
    Identify = $positiveMatch.ADSamAccountName
  }

  $positiveMatch.CSVProperties.foreach({
      $_.PSObject.Properties.foreach({
          $_.PSObject.Properties.where({
              $_.Name -ne 'UniqueID'
            }).foreach({
              $setAdUserParams[$_.Name] = $_.Value
            })
        })
    })
  Set-ADUser @setAdUserParams
}