function Remove-LocalBranches ([switch]$Force) {
  git branch |
    Where-Object { $_ -notmatch '(^\*)|(^. master$)' } |
    ForEach-Object { git branch $(if($Force) { '-D' } else { '-d' }) $_.Substring(2) }
}

function Add-MajorVersionTag {
  Param (
    [string]$Message = ''
  )
  $elements = GetLatestVersionElements
  $major = [int]::Parse($($elements[0]))
  $major++
  $NewTag = "v$major.0.0"
  CreateNewTag $NewTag $Message
  WriteSuccessMessage $($elements[3]) $NewTag $Message
}

function Add-MinorVersionTag {
  Param (
    [string]$Message = ''
  )
  $elements = GetLatestVersionElements
  $minor = [int]::Parse($($elements[1]))
  $minor++
  $NewTag = "v$($elements[0]).$minor.0"
  CreateNewTag $NewTag $Message
  WriteSuccessMessage $($elements[3]) $NewTag $Message
}

function Add-PatchVersionTag {
  Param (
    [string]$Message = ''
  )
  $elements = GetLatestVersionElements
  $patch = [int]::Parse($($elements[2]))
  $patch++
  $NewTag = "v$($elements[0]).$($elements[1]).$patch"
  CreateNewTag $NewTag $Message
  WriteSuccessMessage $($elements[3]) $NewTag $Message
}

function New-VersionTag {
  Param (
    [string]$Tag,
    [string]$Message = ''
  )

  if ($Tag -notmatch "v[0-9]+\.[0-9]+\.[0-9]+") {
    throw "$Tag is not a valid version number. Use the format 'v1.2.3'."
  }

  CreateNewTag $Tag $Message
  Write-Host "New tag created`: $Tag $Message" -ForegroundColor Cyan
}

function WriteSuccessMessage($OldTag, $NewTag, $Message) {
  Write-Host "Version Incremented`: $OldTag --> $NewTag $Message" -ForegroundColor Cyan
}

function CreateNewTag($NewTag, $Message) {
  if ($Message -eq '') { git tag -a $NewTag }
  else { git tag -a $NewTag -m $Message }
}

function GetLatestVersionElements {
  $lastTag = git for-each-ref refs/tags/v* --format="%(refname:short)" --sort=-v:refname --count=1
  if ($lastTag -eq $null) { throw "Couldn't find any previous version to increment!" }
  $lastTag.Substring(1).split('.') # return array of version numbers
  $lastTag # return the unsplit original
}

Export-ModuleMember *-*