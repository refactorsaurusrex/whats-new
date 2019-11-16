function Get-MicrosoftDesktopWallpaper {
  param (
    [Parameter(Mandatory = $true)][string]$OutDirectory,
    [Parameter(Mandatory = $true)][ValidateSet(
      'Animals', 
      'Automotive', 
      'Branded', 
      'Community', 
      'Featured', 
      'Games', 
      'HolidaysAndSeasons', 
      'IllustrativeArt', 
      'NaturalWonders', 
      'Panoramic',
      'PlacesAndLandscapes', 
      'PlantsAndFlowers', 
      'PhotographicArt'
    )]
    [string]$Category
  )

  $categories = @{
    'Animals' = 'https://support.microsoft.com/en-us/help/18673/animal-wallpapers'
    'Automotive' = 'https://support.microsoft.com/en-us/help/18823/automotive-wallpapers'
    'Branded' = 'https://support.microsoft.com/en-us/help/18829/branded-wallpapers'
    'Community' = 'https://support.microsoft.com/en-us/help/18830/from-the-community-wallpapers'
    'Featured' = 'https://support.microsoft.com/en-us/help/17780/featured-wallpapers'
    'Games' = 'https://support.microsoft.com/en-us/help/18824/games-wallpaper'
    'HolidaysAndSeasons' = 'https://support.microsoft.com/en-us/help/18825/holiday-seasons-wallpaper'
    'IllustrativeArt' = 'https://support.microsoft.com/en-us/help/18818/art-illustrative-wallpapers'
    'NaturalWonders' = 'https://support.microsoft.com/en-us/help/18826/natural-wonders-wallpaper'
    'Panoramic' = 'https://support.microsoft.com/en-us/help/18831/panoramic-wallpapers'
    'PlacesAndLandscapes' = 'https://support.microsoft.com/en-us/help/18827/places-landscapes-wallpaper'
    'PlantsAndFlowers' = 'https://support.microsoft.com/en-us/help/18828/plants-flowers-wallpaper'
    'PhotographicArt' = 'https://support.microsoft.com/en-us/help/18822/art-photographic-wallpapers'
  }
  
  $html = Invoke-WebRequest -Uri $categories[$Category] | Select-Object -ExpandProperty RawContent
  $regex = 'https:\/\/kbdevstorage1\.blob\.core\.windows\.net\/asset-blobs\/[0-9A-Za-z_]+'
  $uris = @(Select-String -InputObject $html -Pattern $regex -AllMatches | 
    ForEach-Object matches | 
    ForEach-Object value | 
    Get-Unique)
  # ForEach-Object { Invoke-WebRequest -uri $_ -OutFile "$OutDirectory\$counter.jpg" }
  
  # Write-Output $uris

  $counter = 0
  foreach ($uri in $uris) {
    $path = Join-Path -Path $OutDirectory -ChildPath "$counter.jpg"
    # Write-Host $path
    while (Test-Path $path) {
      # Write-Host $path
      $path = Join-Path -Path $OutDirectory -ChildPath "$((++$counter)).jpg"
    }
    Write-Host $path
    Invoke-WebRequest -uri $uri -OutFile $path
  }
}

Export-ModuleMember -Function * -Alias *