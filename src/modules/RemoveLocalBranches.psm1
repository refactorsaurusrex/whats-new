function Remove-LocalBranches ([switch]$Force) {
  git branch |
    Where-Object { $_ -notmatch '(^\*)|(^. master$)' } |
    ForEach-Object { git branch $(if($Force) { '-D' } else { '-d' }) $_.Substring(2) }
}

Export-ModuleMember *-*