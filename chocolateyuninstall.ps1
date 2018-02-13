$p = [Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::Machine)
$p = $p.Replace(";$($env:ChocolateyPackageFolder)", "")
[Environment]::SetEnvironmentVariable("PSModulePath", $p, [System.EnvironmentVariableTarget]::Machine)