[![Build status](https://ci.appveyor.com/api/projects/status/rsvlu24m8jdxdbql?svg=true)](https://ci.appveyor.com/project/refactorsaurusrex/whats-new)

# What's New?!

![whats-new](/whats-new.png) 

Powershell functions for versioning a git repo with tags and more!

# Features

## Semantically Versioned Git Tags

Easily add [semantically versioned](https://semver.org/) tags to your git commits with the following functions:

- `Add-MajorVersionTag`: Create a new tag with the *major* version incremented.
- `Add-MinorVersionTag`: Create a new tag with the *minor* version incremented.
- `Add-PatchVersionTag`: Create a new tag with the *patch* version incremented.
- `New-VersionTag`: Create a new tag with an *arbitrary* version number.

The *Major*, *Minor*, and *Patch* functions will find the most recent semantically versioned tag and use it as the basis for the incremention operation, following SemVer numbering rules. 

## Delete Old Local Git Branches

Delete all local branches in a git repo except for master. Useful for those moments when you realize you have an enormous number of obsolete branches that are ready for the big -D.

`Remove-LocalBranches`

By default, this will only remove merged branches. Use `-Force` to delete both [merged and unmerged branches](https://git-scm.com/docs/git-branch#git-branch--d).

# Installation

1. [Install Chocolatey](https://chocolatey.org/install#installing-chocolatey).
1. Run: `choco install whats-new`

## Pre-Release Versions

The Chocolatey moderation queue is *slooooooooooooooooooooow*. If you want to install the latest pre-release version, run this:

`choco install whats-new -s https://ci.appveyor.com/nuget/whats-new-teneg79dr9y7`

Chocolatey package page is [here](https://chocolatey.org/packages/whats-new).

# Contributions & Bug Reports

[Read the guidelines here.](/CONTRIBUTING.MD) 
