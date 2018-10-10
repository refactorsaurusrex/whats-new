param(
  [string]$Version = ''
)

$ErrorActionPreference = 'Stop'

if ($env:APPVEYOR_BUILD_VERSION) {
  $Version = $env:APPVEYOR_BUILD_VERSION
} elseif ($Version -eq '') {
  throw "Missing version parameter"
}

$manifestPath = "$PSScriptRoot\src\whats-new.psd1"
$guid = '861e5d28-8348-47d3-a2f6-cdd23e33bb55'
$modules = Get-ChildItem -Path "$PSScriptRoot\src\modules" -File | 
  Select-Object -ExpandProperty Name | 
  ForEach-Object { ".\modules\$_" }

$manifestArgs = @{
  Path = $manifestPath
  Guid = $guid
  Author = 'Nick Spreitzer'
  CompanyName = 'RAWR! Productions'
  ModuleVersion = $Version
  FunctionsToExport = @('*')
  AliasesToExport = @('*')
  NestedModules = $modules
}

New-ModuleManifest @manifestArgs
$originalManifestContent = Get-Content $manifestPath
$cleanManifest = @()

$originalManifestContent | ForEach-Object { 
  if ($_ -match "(?(?=.*#)(.*(?=#))|(.*))" -and -not [string]::IsNullOrWhiteSpace($Matches[0])) { 
    $cleanManifest += $Matches[0]
  } 
}

for ($i = 1; $i -le $cleanManifest.Length - 2; $i++) {
  $cleanManifest[$i] = "`t$($cleanManifest[$i])"
}

Set-Content -Path $manifestPath -Value $cleanManifest
choco pack .\src\whats-new.nuspec --version $Version