$ErrorActionPreference = 'Stop'
$psModuleFolderBase = "$home\Documents\WindowsPowerShell\Modules"
$psModuleFolder = "$psModuleFolderBase\$env:ChocolateyPackageName"

if (Test-Path $psModuleFolder) {
  Remove-Item "$psModuleFolder" -Recurse -Force
  Write-Debug "Removed all previous data from module directory: '$psModuleFolder'"
}

Copy-Item -Path $env:ChocolateyPackageFolder -Container -Recurse -Filter "*.ps?1" -Destination $psModuleFolderBase
Write-Debug "Copied contents of '$env:ChocolateyPackageFolder' to '$psModuleFolder'"