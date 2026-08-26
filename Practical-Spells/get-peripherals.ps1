

$targetClasses = @(
  'Monitor',
  'Keyboard',
  'Mouse',
  'Printer',
  'Scanner',
  'Webcam',
  'USB',
  'AudioEndpoint',
  'HIDClass',
  'Image'
)

$activeDevices = Get-PnpDevice -PresentOnly | Where-Object { $_.Class -in $targetClasses }

$deviceList = foreach ($device in $activeDevices) {
    "- [$($device.Class)] $($device.FriendlyName)"
}

$finalOutput = $deviceList -join "`n"

Write-Host "Currently connected peripherals:" -ForegroundColor Cyan
Write-Host $finalOutput -ForegroundColor Green