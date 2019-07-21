<#
.SYNOPSIS
  Deletes all local git branches in the current respository, other than master.
.DESCRIPTION
  Deletes all local git branches in the current respository, other than master. By default, unmerged branches
  are ignored. Use -Force to delete all non-master branches regardless of merge status.
.PARAMETER Force
  Deletes all braches regardless of merge status.
#>
function Remove-LocalBranches ([switch]$Force) {
  git branch |
    Where-Object { $_ -notmatch '(^\*)|(^. master$)' } |
    ForEach-Object { git branch $(if($Force) { '-D' } else { '-d' }) $_.Substring(2) }
}

Export-ModuleMember *-*