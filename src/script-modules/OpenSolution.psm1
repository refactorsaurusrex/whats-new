<#
.SYNOPSIS
  Opens a `.sln` file in the default editor.
.DESCRIPTION
  Recursively searches for the first `.sln` file and opens it using the default application, usually Visual Studio. 
.PARAMETER RootDirectory
  The directory to search. Defaults to the current directory. 
.LINK
  https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#open-solution
#>
function Open-Solution {
  [Alias('sln')]
  param (
    [string]$RootDirectory = $PWD
  )

  $solutions = Get-ChildItem -Recurse -Path $RootDirectory -Filter "*.sln"
  if ($solutions.Count -eq 1) {
    Invoke-Item $solutions.FullName
  }
  elseif ($solutions.Count -eq 0) {
    Write-Host "I couldn't find any solution files here!" -ForegroundColor Red
  }
  elseif ($solutions.Count -gt 1) {
    Write-Host "I found more than 1 solution. Which one do you want to open?" -ForegroundColor Yellow
    $solutions | Format-Table @{ Label="Solutions"; Expression={" --> $_"} }
  }
}

Export-ModuleMember -Function * -Alias *