$p = [Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
if ($p.Contains($($env:ChocolateyPackageFolder))) { return }
$p += ";$($env:ChocolateyPackageFolder)"
[Environment]::SetEnvironmentVariable("PSModulePath", $p, [System.EnvironmentVariableTarget]::Machine)