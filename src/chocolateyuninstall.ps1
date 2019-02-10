$ErrorActionPreference = 'Stop'
$psModuleFolder = "$home\Documents\PowerShell\Modules\$env:ChocolateyPackageName"
Write-Debug "Removing: $psModuleFolder"
Remove-Item $psModuleFolder -Force -Recurse

$appDataFolder = "$env:LocalAppData\$env:ChocolateyPackageName"
$oldInstalls = Get-ChildItem -Path $appDataFolder -Directory | Sort-Object
foreach ($install in $oldInstalls) {
  try {
    Write-Debug "Removing: $($install.FullName)"
    Remove-Item $($install.FullName) -Force -Recurse
  } catch {
    Write-Warning "Unable to remove $($install.FullName). You will have to do this manually."
  }
}

if (-Not(Test-Path "$appDataFolder\*")) {
  Remove-Item $appDataFolder -Force -Recurse
}
