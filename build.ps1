param(
  [string]$Version = ''
)

$ErrorActionPreference = 'Stop'

if ($env:APPVEYOR_BUILD_VERSION) {
  $Version = [regex]::match($env:APPVEYOR_BUILD_VERSION,'[0-9]+\.[0-9]+\.[0-9]+').Groups[0].Value
} elseif ($Version -eq '') {
  throw "Missing version parameter"
}

if (Test-Path "$PSScriptRoot\publish") {
  Remove-Item -Path "$PSScriptRoot\publish" -Recurse -Force
}

$appName = "WhatsNew"
$publishOutputDir = "$PSScriptRoot\publish\$appName"
$proj = Get-ChildItem -Filter "$appName.csproj" -Recurse -Path $PSScriptRoot | Select-Object -First 1 -ExpandProperty FullName
dotnet publish $proj --output $publishOutputDir -c Release

if ($LASTEXITCODE -ne 0) {
  throw "Failed to publish application."
}

Remove-Item "$publishOutputDir\*.pdb"

Import-Module "$publishOutputDir\$appName.dll"
$moduleInfo = Get-Module WhatsNew
$cmdletNames = Export-BinaryCmdletNames -ModuleInfo $moduleInfo
$cmdletAliases = Export-BinaryCmdletAliases -ModuleInfo $moduleInfo

$scriptFiles = Get-ChildItem -Path "$PSScriptRoot\src\script-modules" -File
$scriptAliases = $scriptFiles | Select-Object -ExpandProperty FullName | Export-PSScriptAliases
$scriptFunctions = $scriptFiles | Select-Object -ExpandProperty FullName | Export-PSScriptFunctionNames

$modules = $scriptFiles | 
  Select-Object -ExpandProperty Name | 
  ForEach-Object { ".\script-modules\$_" }

$modules += ".\$appName.dll"
$manifestPath = "$publishOutputDir\$appName.psd1"

$newManifestArgs = @{
  Path = $manifestPath
}

$updateManifestArgs = @{
  Path = $manifestPath
  CopyRight = "(c) $((Get-Date).Year) Nick Spreitzer"
  Description = "Powershell functions for versioning a git repo with tags and more!"
  Guid = '861e5d28-8348-47d3-a2f6-cdd23e33bb55'
  Author = 'Nick Spreitzer'
  CompanyName = 'RAWR! Productions'
  ModuleVersion = $Version
  AliasesToExport = $cmdletAliases + $scriptAliases
  NestedModules = $modules
  CmdletsToExport = $cmdletNames
  FunctionsToExport = $scriptFunctions
  CompatiblePSEditions = @("Desktop","Core")
  HelpInfoUri = "https://github.com/refactorsaurusrex/whats-new/wiki"
  PowerShellVersion = "6.0"
  PrivateData = @{
    Tags = 'git','semver', 'markdown'
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

Install-Module platyPS
Import-Module platyPS
$docs = "$PSScriptRoot\docs"
try {
  git clone https://github.com/refactorsaurusrex/whats-new.wiki.git $docs
  Switch-CodeFenceToYamlFrontMatter -Path $docs -NoConfirm
  New-ExternalHelp -Path $docs -OutputPath $publishOutputDir
} finally {
  if (Test-Path $docs) {
    Remove-Item -Path $docs -Recurse -Force
  }
}