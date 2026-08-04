Write-output "ℹ️ Restarting Windows Defender UI..."

$SecHealthPackage = Get-AppxPackage -AllUsers -Name "*SecHealthUI*"

if ($SecHealthPackage) {
  $ManifestPath = Join-Path -Path $SecHealthPackage.InstallLocation -ChildPath "AppxManifest.xml"

  Write-output "ℹ️ Found Manifest Path at: $ManifestPath"

    try{
      add-appxpackage -register $ManifestPath -DisableDevelopmentMode -erroraction Stop
      Write-output "✅ Successfully restarted Windows Defender UI."
    } 
    catch {
      Write-output "❌ Failed to restart Windows Defender UI."
    }
    else {
      Write-output "❌ Windows Defender UI package not found."
  }
}