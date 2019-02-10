$ErrorActionPreference = 'Stop'
$appDataFolder = "$env:LocalAppData\$env:ChocolateyPackageName\$env:ChocolateyPackageVersion"
if (-Not (Test-Path $appDataFolder)) {
  New-Item $appDataFolder -ItemType Directory | Out-Null
}

Get-ChildItem -Path "$env:ChocolateyPackageFolder" -Exclude "*.choco*","*.nu*" | Copy-Item -Destination $appDataFolder -Container -Recurse
Write-Debug "Copied contents of '$env:ChocolateyPackageFolder' to '$appDataFolder'"

$psModuleFolder = "$home\Documents\PowerShell\Modules\$env:ChocolateyPackageName"

if (-Not (Test-Path $psModuleFolder)) {
  New-item $psModuleFolder -ItemType Directory | Out-Null
  Write-Debug "Created new module directory: '$psModuleFolder'"
} 

$originalManifest = Get-Item -Path "$env:ChocolateyPackageFolder\$env:ChocolateyPackageName.psd1"
Copy-Item -Path $originalManifest -Destination $psModuleFolder -Force
Write-Debug "Copied '$originalManifest' to '$psModuleFolder'"

$deployedManifestPath = "$psModuleFolder\$env:ChocolateyPackageName.psd1"
(Get-Content $deployedManifestPath).Replace('<APP_DATA>', $appDataFolder) | Set-Content $deployedManifestPath

$oldInstalls = Get-ChildItem -Path "$env:LocalAppData\$env:ChocolateyPackageName" -Directory | 
  Sort-Object -Descending -Property @{Expression={([Version]$_.Name)};} |
  Select-Object -Skip 2

if ($null -ne $oldInstalls) {
  $oldInstalls | ForEach-Object { Write-Debug "Attempting to remove old install: $_.FullName" }
  $oldInstalls | Remove-Item -Recurse -Force -ErrorAction Ignore
}