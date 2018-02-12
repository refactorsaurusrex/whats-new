$ErrorActionPreference = 'Stop'
choco pack .\whats-new\whats-new.nuspec --version $env:APPVEYOR_BUILD_VERSION