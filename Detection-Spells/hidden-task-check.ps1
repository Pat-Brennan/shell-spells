# 1. Check Standard Registry Persistence (HKLM and HKCU)
Write-Output "🗝️ === REGISTRY RUN KEYS === 🗝️"

$registryPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)

foreach ($path in $registryPaths) {
    if (Test-Path $path) {
        Write-Output "ℹ️ `nChecking: $path"
        Get-ItemProperty $path -ErrorAction SilentlyContinue | 
        Select-Object -Property * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider | 
        Format-List
    }
}

Write-Output "🔁 `n=== SUSPICIOUS SCHEDULED TASKS === 🔁"
# Filters for tasks launching command shells, scripting engines, or running from user profiles
Get-ScheduledTask | Where-Object { 
    $_.Actions.Execute -match "powershell|cmd|mshta|cscript|wscript|\\AppData\\|\\Temp\\" 
} | Select-Object TaskName, State, 
    @{Name="Execute";Expression={$_.Actions.Execute}}, 
    @{Name="Arguments";Expression={$_.Actions.Arguments}} | 
    Format-Table -AutoSize

Write-Output "🔁 `n=== WMI EVENT CONSUMERS === 🔁"
Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer -ErrorAction SilentlyContinue | 
Select-Object Name, CommandLineTemplate, ExecutablePath | 
Format-List