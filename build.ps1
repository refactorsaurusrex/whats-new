param(
  [string]$Version = ''
)

$ErrorActionPreference = 'Stop'

if ($env:APPVEYOR_BUILD_VERSION) {
  $Version = $env:APPVEYOR_BUILD_VERSION
} elseif ($Version -eq '') {
  throw "Missing version parameter"
}

$publishOutputDir = "$PSScriptRoot\publish\WhatsNew"

Get-ChildItem -Filter '*.nupkg' | Remove-Item 
Remove-Item -Path $publishOutputDir -Recurse -ErrorAction SilentlyContinue

$sln = Get-ChildItem -Filter '*.sln' -Recurse -Path $PSScriptRoot | Select-Object -First 1 -ExpandProperty FullName
dotnet publish $sln --output $publishOutputDir -c Release

if ($LASTEXITCODE -ne 0) {
  throw "Failed to publish application."
}

Get-ChildItem -Filter "WhatsNew.dll-Help.xml" -Recurse -File -Path "$PSScriptRoot\src" |
  Where-Object { $_.FullName -like "*bin\Release*" } | 
  Select-Object -First 1 | 
  Copy-Item -Destination $publishOutputDir -Force

Remove-Item "$publishOutputDir\*.pdb"

Import-Module "$publishOutputDir\WhatsNew.dll"
$moduleInfo = Get-Module WhatsNew
$cmdletNames = Export-BinaryCmdletNames -ModuleInfo $moduleInfo
$cmdletAliases = Export-BinaryCmdletAliases -ModuleInfo $moduleInfo

$scriptFiles = Get-ChildItem -Path "$PSScriptRoot\src\script-modules" -File
$scriptAliases = $scriptFiles | Select-Object -ExpandProperty FullName | Export-PSScriptAliases
$scriptFunctions = $scriptFiles | Select-Object -ExpandProperty FullName | Export-PSScriptFunctionNames

$modules = $scriptFiles | 
  Select-Object -ExpandProperty Name | 
  ForEach-Object { ".\script-modules\$_" }

$modules += ".\WhatsNew.dll"
$manifestPath = "$publishOutputDir\WhatsNew.psd1"

$newManifestArgs = @{
  Path = $manifestPath
  Description = "Powershell functions for versioning a git repo with tags and more!"
  Guid = '861e5d28-8348-47d3-a2f6-cdd23e33bb55'
  Author = 'Nick Spreitzer'
  CompanyName = 'RAWR! Productions'
  ModuleVersion = $Version
  AliasesToExport = $cmdletAliases + $scriptAliases
  NestedModules = $modules
  CmdletsToExport = $cmdletNames
  FunctionsToExport = $scriptFunctions
}

$updateManifestArgs = @{
  Path = $manifestPath
  PrivateData = @{
    Tags = 'git','semver'
    LicenseUri = 'https://github.com/refactorsaurusrex/whats-new/blob/master/LICENSE.md'
    ProjectUri = 'https://github.com/refactorsaurusrex/whats-new'
  }
}

New-ModuleManifest @newManifestArgs
Update-ModuleManifest @updateManifestArgs
Import-Module "$PSScriptRoot\src\script-modules\RemoveModuleManifestComments.psm1" -Force
Remove-ModuleManifestComments $manifestPath -NoConfirm

New-item -ItemType Directory -Path "$publishOutputDir\script-modules\" | Out-Null
Get-ChildItem -Path "$PSScriptRoot\src\script-modules" -Filter "*.ps*1" | Copy-Item -Destination "$publishOutputDir\script-modules\"