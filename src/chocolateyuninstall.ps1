$ErrorActionPreference = 'Stop'
$psModuleFolder = "$home\Documents\WindowsPowerShell\Modules\$env:ChocolateyPackageName"

if (Test-Path $psModuleFolder) {
  Remove-Item "$psModuleFolder" -Recurse -Force
  Write-Debug "Removed all previous data from module directory: '$psModuleFolder'"
} 