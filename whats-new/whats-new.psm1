function Remove-LocalBranches ($Commit = 'HEAD', [switch]$Force) {
  git branch |
    ? { $_ -notmatch '(^\*)|(^. master$)' } |
    % { git branch $(if($Force) { '-D' } else { "-d" }) $_.Substring(2) }
}

function Add-MajorVersionTag() {
  Param(
    [switch]$AllBranches,
    [string]$Message = ''
  )
  $elements = GetLatestVersionElements $AllBranches
  $major = [int]::Parse($($elements[0]))
  $major++
  $newTag = "v$major.0.0"
  CreateNewTag $newTag $Message
  write-host "Version Bumped`: $($elements[3]) --> $newTag $message" -foregroundcolor cyan
}

function Add-MinorVersionTag() {
  Param(
    [switch]$AllBranches,
    [string]$Message = ''
  )
  $elements = GetLatestVersionElements $AllBranches
  $minor = [int]::Parse($($elements[1]))
  $minor++
  $newTag = "v$($elements[0]).$minor.0"
  CreateNewTag $newTag $Message
  write-host "Version Bumped`: $($elements[3]) --> $newTag $message" -foregroundcolor cyan
}

function Add-PatchVersionTag() {
  Param(
    [switch]$AllBranches,
    [string]$Message = ''
  )
  $elements = GetLatestVersionElements $AllBranches
  $patch = [int]::Parse($($elements[2]))
  $patch++
  $newTag = "v$($elements[0]).$($elements[1]).$patch"
  CreateNewTag $newTag $Message
  write-host "Version Bumped`: $($elements[3]) --> $newTag $message" -foregroundcolor cyan
}

function CreateNewTag($newTag, $message) {
  if ($message -eq '') { git tag -a $newTag }
  else { git tag -a $newTag -m $message }
}

function GetLatestVersionElements([switch]$AllBranches) {
  if ($AllBranches) {
    $lastTag = git for-each-ref refs/tags/v* --format="%(refname:short)" --sort=-v:refname --count=1
    $lastTag.Substring(1).split('.') # return array of version numbers
    $lastTag # return the unsplit original
  } else {
    $lastTag = git describe
    $index = $lastTag.indexOf('-')
    if ($index -lt 0) {
      $lastTag.Substring(1).split('.') # return array of version numbers
      $lastTag.Substring(1) # return the unsplit original
    } else {
      $lastTag.Substring(1, $index - 1).split('.') # return array of version numbers
      $lastTag.Substring(1, $index - 1) # return the unsplit original
    }
  }
}

export-modulemember *-*