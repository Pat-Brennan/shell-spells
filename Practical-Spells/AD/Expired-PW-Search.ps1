$today = Get-Date
$30DaysAgo = $today.AddDays(-30)
Get-AdUser -Filter "Enabled -eq 'True' -and passwordlastset -lt '$30DaysAgo'"