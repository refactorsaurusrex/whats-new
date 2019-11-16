using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using JetBrains.Annotations;
using Flurl.Http;

namespace WhatsNew
{
    [PublicAPI]
    [Cmdlet(VerbsCommon.Get, "MicrosoftDesktopWallpaper")]
    public class GetMicrosoftDesktopWallpaperCmdlet : CmdletBase
    {
        private readonly Dictionary<string, string> _categories = new Dictionary<string, string>
        {
            { "Animals", "https://support.microsoft.com/en-us/help/18673/animal-wallpapers" },
            { "Automotive", "https://support.microsoft.com/en-us/help/18823/automotive-wallpapers" },
            { "Branded", "https://support.microsoft.com/en-us/help/18829/branded-wallpapers" },
            { "Community", "https://support.microsoft.com/en-us/help/18830/from-the-community-wallpapers" },
            { "Featured", "https://support.microsoft.com/en-us/help/17780/featured-wallpapers" },
            { "Games", "https://support.microsoft.com/en-us/help/18824/games-wallpaper" },
            { "HolidaysAndSeasons", "https://support.microsoft.com/en-us/help/18825/holiday-seasons-wallpaper" },
            { "IllustrativeArt", "https://support.microsoft.com/en-us/help/18818/art-illustrative-wallpapers" },
            { "NaturalWonders", "https://support.microsoft.com/en-us/help/18826/natural-wonders-wallpaper" },
            { "Panoramic", "https://support.microsoft.com/en-us/help/18831/panoramic-wallpapers" },
            { "PlacesAndLandscapes", "https://support.microsoft.com/en-us/help/18827/places-landscapes-wallpaper" },
            { "PlantsAndFlowers", "https://support.microsoft.com/en-us/help/18828/plants-flowers-wallpaper" },
            { "PhotographicArt", "https://support.microsoft.com/en-us/help/18822/art-photographic-wallpapers" }
        };

        [Parameter(Mandatory = true)]
        public string OutDirectory { get; set; }

        [Parameter(Mandatory = true)]
        [ValidateSet("Animals", "Automotive", "Branded", "Community", "Featured", "Games", "HolidaysAndSeasons", "IllustrativeArt", "NaturalWonders", "Panoramic", "PlacesAndLandscapes", "PlantsAndFlowers", "PhotographicArt")]
        public string[] Categories { get; set; }

        protected override void ProcessRecord()
        {
            
            var counter = 1;

            foreach (var category in Categories)
            {
                var record = CreateProgressRecord($"Downloading '{category}' images [Category {counter++} of {Categories.Length}]", "Waiting...");

                try
                {
                    var reporter = new ProgressReporter();
                    var task = DownloadImages(category, reporter);
                    ShowProgress(record, reporter);
                    task.Wait();
                }
                finally
                {
                    HideProgress(record);
                }
            }
        }

        private async Task DownloadImages(string category, ProgressReporter reporter)
        {
            var html = await _categories[category].GetStringAsync();
            const string regex = @"https:\/\/kbdevstorage1\.blob\.core\.windows\.net\/asset-blobs\/[0-9A-Za-z_]+";
            var urls = Regex.Matches(html, regex).Cast<Match>().Select(x => x.Value).Distinct().ToList();
            var counter = 1;

            foreach (var url in urls)
            {
                string fileName;
                string path;
                do
                {
                    fileName = $"{Guid.NewGuid().ToString().Split('-')[4]}.jpg";
                    path = Path.Combine(OutDirectory, fileName);
                } while (File.Exists(path));

                reporter.UpdateProgress(url, urls.Count, counter++);
                var result = await url.DownloadFileAsync(OutDirectory, fileName);
            }

            reporter.CompleteAdding();
        }
    }
}
