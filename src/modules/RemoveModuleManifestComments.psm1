function Remove-ModuleManifestComments {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)][string]$ManifestPath,
    [switch]$NoConfirm
  )

  $originalManifestContent = Get-Content $ManifestPath
  $cleanManifest = @()
  
  $originalManifestContent | ForEach-Object { 
    if ($_ -match "(?(?=.*#)(.*(?=#))|(.*))" -and -not [string]::IsNullOrWhiteSpace($Matches[0])) { 
      $cleanManifest += $Matches[0]
    } 
  }
  
  for ($i = 1; $i -le $cleanManifest.Length - 2; $i++) {
    if ($cleanManifest[$i][0] -ne "`t") {
      $cleanManifest[$i] = "`t$($cleanManifest[$i])"
    }
  }
  
  $query = "This action will overwrite the existing module manifest file. (And make it look nicer in the process.) Continue?"
  if ($NoConfirm -or $PSCmdlet.ShouldContinue($query, "*****Warning*****")) {
    Set-Content -Path $ManifestPath -Value $cleanManifest
  }
}

Export-ModuleMember *-*