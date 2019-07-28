<# 
.SYNOPSIS
  Adds a new major version tag to the current git repository.
.DESCRIPTION
  Finds the most recent semantic version tag in the current git repository, increments the major version, and creates
  a new tag based on this new version. 
.PARAMETER Message
  The message to associate with the new tag.
.PARAMETER CurrentBranchOnly
  Restricts the search for prior version tags to the current branch. By default all branches are searched.
.LINK
  https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#add-majorversiontag
#>
function Add-MajorVersionTag {
  Param (
    [Parameter(Mandatory = $true, Position = 0)][string]$Message,
    [switch]$CurrentBranchOnly
  )
  $elements = GetLatestVersionElements -CurrentBranchOnly:$CurrentBranchOnly
  $major = [int]::Parse($($elements[0]))
  $major++
  $NewTag = "v$major.0.0"
  git tag -a $NewTag -m $Message 
  WriteSuccessMessage $($elements[3]) $NewTag $Message
}

<# 
.SYNOPSIS
  Adds a new minor version tag to the current git repository.
.DESCRIPTION
  Finds the most recent semantic version tag in the current git repository, increments the minor version, and creates
  a new tag based on this new version. 
.PARAMETER Message
  The message to associate with the new tag.
.PARAMETER CurrentBranchOnly
  Restricts the search for prior version tags to the current branch. By default all branches are searched.
.LINK
  https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#add-minorversiontag
#>
function Add-MinorVersionTag {
  Param (
    [Parameter(Mandatory = $true, Position = 0)][string]$Message,
    [switch]$CurrentBranchOnly
  )
  $elements = GetLatestVersionElements -CurrentBranchOnly:$CurrentBranchOnly
  $minor = [int]::Parse($($elements[1]))
  $minor++
  $NewTag = "v$($elements[0]).$minor.0"
  git tag -a $NewTag -m $Message 
  WriteSuccessMessage $($elements[3]) $NewTag $Message
}

<# 
.SYNOPSIS
  Adds a new patch version tag to the current git repository.
.DESCRIPTION
  Finds the most recent semantic version tag in the current git repository, increments the patch version, and creates
  a new tag based on this new version. 
.PARAMETER Message
  The message to associate with the new tag.
.PARAMETER CurrentBranchOnly
  Restricts the search for prior version tags to the current branch. By default all branches are searched.
.LINK
  https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#add-patchversiontag
#>
function Add-PatchVersionTag {
  Param (
    [Parameter(Mandatory = $true, Position = 0)][string]$Message,
    [switch]$CurrentBranchOnly
  )
  $elements = GetLatestVersionElements -CurrentBranchOnly:$CurrentBranchOnly
  $patch = [int]::Parse($($elements[2]))
  $patch++
  $NewTag = "v$($elements[0]).$($elements[1]).$patch"
  git tag -a $NewTag -m $Message 
  WriteSuccessMessage $($elements[3]) $NewTag $Message
}

<# 
.SYNOPSIS
  Adds a new semantic version tag to the current git repository.
.DESCRIPTION
  Creates a new semantic version tag to the current git respository based on the provided version string.
.PARAMETER Tag
  The new semantic version tag to apply. Must be in the format 'v0.0.0'.
.PARAMETER Message
  The message to associate with the new tag.
.LINK
  https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#new-versiontag
#>
function New-VersionTag {
  Param (
    [Parameter(Mandatory = $true, Position = 0)][string]$Tag,
    [Parameter(Mandatory = $true, Position = 1)][string]$Message
  )

  if ($Tag -notmatch "v[0-9]+\.[0-9]+\.[0-9]+") {
    throw "$Tag is not a valid version number. Use the format 'v1.2.3'."
  }

  git tag -a $NewTag -m $Message 
  Write-Host "New tag created`: $Tag $Message" -ForegroundColor Cyan
}

function WriteSuccessMessage {
  param(
    [Parameter(Mandatory = $true, Position = 0)][string]$OldTag,
    [Parameter(Mandatory = $true, Position = 1)][string]$NewTag,
    [Parameter(Mandatory = $true, Position = 2)][string]$Message
  )
  Write-Host "Version Incremented`: $OldTag --> $NewTag $Message" -ForegroundColor Cyan
}

function GetLatestVersionElements {
  param (
    [switch]$CurrentBranchOnly
  )

  if ($CurrentBranchOnly) {
    $lastTag = git describe
    $index = $lastTag.indexOf('-')
    if ($index -lt 0) {
      $lastTag.Substring(1).split('.') # return array of version numbers
      $lastTag.Substring(1) # return the unsplit original
    } else {
      $lastTag.Substring(1, $index - 1).split('.') # return array of version numbers
      $lastTag.Substring(1, $index - 1) # return the unsplit original
    }
  } else {
    $lastTag = git for-each-ref refs/tags/v* --format="%(refname:short)" --sort=-v:refname --count=1
    if ($null -eq $lastTag) { throw "Couldn't find any previous version to increment!" }
    $lastTag.Substring(1).split('.') # return array of version numbers
    $lastTag # return the unsplit original
  }
}

Export-ModuleMember *-*