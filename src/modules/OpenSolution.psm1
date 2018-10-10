function Open-Solution() {
  param(
    [string]$RootDirectory = ''
  )
  $solutions = Get-ChildItem -Recurse -Path "$RootDirectory*.sln"
  if ($solutions.Count -eq 1) {
    & $solutions.FullName
  }
  elseif ($solutions.Count -eq 0) {
    write-host "I couldn't find any solution files here!"
  }
  elseif ($solutions.Count -gt 1) {
    write-host "I found more than solution. Which one do you want to open?"
    $solutions | ForEach-Object { write-host " - $($_.FullName)" }
  }
}

Set-Alias sln Open-Solution
Export-ModuleMember -Function * -Alias *