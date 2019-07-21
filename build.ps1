param(
  [string]$Version = ''
)

$ErrorActionPreference = 'Stop'

if ($env:APPVEYOR_BUILD_VERSION) {
  $Version = $env:APPVEYOR_BUILD_VERSION
} elseif ($Version -eq '') {
  throw "Missing version parameter"
}

Get-ChildItem -Filter '*.nupkg' | Remove-Item 
Remove-Item -Path "$PSScriptRoot\publish" -Recurse -ErrorAction SilentlyContinue

$sln = Get-ChildItem -Filter '*.sln' -Recurse -Path $PSScriptRoot | Select-Object -First 1 -ExpandProperty FullName
dotnet publish $sln --output "$PSScriptRoot\publish" -c Release

if ($LASTEXITCODE -ne 0) {
  throw "Failed to publish application."
}

Get-ChildItem -Filter "WhatsNew.dll-Help.xml" -Recurse -File -Path "$PSScriptRoot\src" |
  Where-Object { $_.FullName -like "*bin\Release*" } | 
  Select-Object -First 1 | 
  Copy-Item -Destination "$PSScriptRoot\publish" -Force

Import-Module "$PSScriptRoot\publish\WhatsNew.dll"
$moduleInfo = Get-Module WhatsNew
$cmdletNames = Export-BinaryCmdletNames -ModuleInfo $moduleInfo
$cmdletAliases = Export-BinaryCmdletAliases -ModuleInfo $moduleInfo

$scriptFiles = Get-ChildItem -Path "$PSScriptRoot\src\script-modules" -File
$scriptAliases = $scriptFiles | Select-Object -ExpandProperty FullName | Export-PSScriptAliases
$scriptFunctions = $scriptFiles | Select-Object -ExpandProperty FullName | Export-PSScriptFunctionNames

$modules = $scriptFiles | 
  Select-Object -ExpandProperty Name | 
  ForEach-Object { "<APP_DATA>\script-modules\$_" }

$modules += "<APP_DATA>\WhatsNew.dll"
$manifestPath = "$PSScriptRoot\publish\whats-new.psd1"

$manifestArgs = @{
  Path = $manifestPath
  Guid = '861e5d28-8348-47d3-a2f6-cdd23e33bb55'
  Author = 'Nick Spreitzer'
  CompanyName = 'RAWR! Productions'
  ModuleVersion = $Version
  AliasesToExport = $cmdletAliases + $scriptAliases
  NestedModules = $modules
  CmdletsToExport = $cmdletNames
  FunctionsToExport = $scriptFunctions
}

New-ModuleManifest @manifestArgs
Import-Module "$PSScriptRoot\src\script-modules\RemoveModuleManifestComments.psm1" -Force
Remove-ModuleManifestComments $manifestPath -NoConfirm

Get-ChildItem -Path "$PSScriptRoot\src" -Filter "chocolatey*.ps1" | Copy-Item -Destination .\publish
New-item -ItemType Directory -Path "$PSScriptRoot\publish\script-modules\" | Out-Null
Get-ChildItem -Path "$PSScriptRoot\src\script-modules" -Filter "*.ps*1" | Copy-Item -Destination "$PSScriptRoot\publish\script-modules\"

choco pack "$PSScriptRoot\whats-new.nuspec" --version $Version