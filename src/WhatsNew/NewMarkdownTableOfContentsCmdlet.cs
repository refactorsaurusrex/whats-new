using System;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;
using JetBrains.Annotations;
using Flurl;

namespace WhatsNew
{
    [PublicAPI]
    [Cmdlet(VerbsCommon.New, "MarkdownTableOfContents")]
    [OutputType(typeof(string))]
    public class NewMarkdownTableOfContentsCmdlet : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        public string Path { get; set; }

        [Parameter(Mandatory = true, Position = 1)]
        public string Filter { get; set; }

        [Parameter(Mandatory = true, Position = 2)]
        public string BaseUrl { get; set; }

        [Parameter(Position = 3)]
        [ValidateSet("Ordered", "Unordered", IgnoreCase = true)]
        public string ListType { get; set; } = "Unordered";

        protected override void ProcessRecord()
        {
            Path = GetUnresolvedProviderPathFromPSPath(Path);
            var builder = new StringBuilder();
            var dir = new DirectoryInfo(Path);
            var files = dir.GetFiles(Filter, SearchOption.AllDirectories);
            var listMarker = ListType == "Unordered" ? "-" : "1.";

            foreach (var file in files.OrderBy(f => f.Name))
            {
                var uri = BaseUrl.AppendPathSegment(System.IO.Path.GetFileNameWithoutExtension(file.FullName));
                builder.Append($"{listMarker} [{System.IO.Path.GetFileNameWithoutExtension(file.FullName)}]({uri}){Environment.NewLine}");
            }

            WriteObject(builder.ToString());
        }
    }
}
