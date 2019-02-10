using System.Linq;
using System.Management.Automation;
using System.Reflection;
using JetBrains.Annotations;

namespace WhatsNew
{
    [PublicAPI]
    [Cmdlet(VerbsData.Export, "BinaryCmdletNames")]
    public class ExportBinaryCmdletNamesCmdlet : PSCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public PSModuleInfo ModuleInfo { get; set; }

        protected override void ProcessRecord()
        {
            if (ModuleInfo.ModuleType != ModuleType.Binary)
            {
                var ex = new PSInvalidOperationException("This cmdlet can only be executed on binary modules.");
                WriteError(ex.ErrorRecord);
                return;
            }

            var cmdletsToExport = ModuleInfo.ImplementingAssembly
                .GetExportedTypes()
                .Select(x => x.GetCustomAttribute<CmdletAttribute>())
                .Where(x => x != null)
                .Select(x => $"{x.VerbName}-{x.NounName}")
                .ToList();

            WriteObject(cmdletsToExport, true);
        }
    }
}
