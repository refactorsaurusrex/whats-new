using System;
using System.IO;
using System.Management.Automation;
using JetBrains.Annotations;
using System.Linq;

namespace WhatsNew
{
    [PublicAPI]
    [Cmdlet(VerbsCommon.Switch, "YamlFrontMatterToCodeFence", ConfirmImpact = ConfirmImpact.High)]
    public class SwitchYamlFrontMatterToCodeFenceCmdlet : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 0)]
        [ValidateNotNullOrEmpty]
        public string Path { get; set; }

        [Parameter]
        public SwitchParameter NoConfirm { get; set; }

        protected override void ProcessRecord()
        {
            Path = GetUnresolvedProviderPathFromPSPath(Path);

            if (File.Exists(Path))
            {
                var warning = $"You're about to convert the yaml front matter in the following file to a code fence.{Environment.NewLine}{Path}";
                if (!NoConfirm && !ShouldContinue("Do you want to continue?", warning)) return;

                var lines = File.ReadAllLines(Path).ToList();
                if (lines.YamlFrontMatterToCodeFence())
                    File.WriteAllLines(Path, lines);
            }
            else if (Directory.Exists(Path))
            {
                var warning = $"You're about to convert the yaml front matter to a code fence in all markdown files in the following directory.{Environment.NewLine}{Path}";
                if (!NoConfirm && !ShouldContinue("Do you want to continue?", warning)) return;

                foreach (var file in Directory.GetFiles(Path, "*.md", SearchOption.AllDirectories))
                {
                    var lines = File.ReadAllLines(file).ToList();
                    if (lines.YamlFrontMatterToCodeFence())
                        File.WriteAllLines(file, lines);
                }
            }
            else
            {
                throw new PSArgumentException("The specified path does not exist.");
            }
        }
    }
}
