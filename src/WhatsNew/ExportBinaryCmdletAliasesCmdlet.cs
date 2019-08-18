using System.Linq;
using System.Management.Automation;
using System.Reflection;
using JetBrains.Annotations;

namespace WhatsNew
{
    [PublicAPI]
    [Cmdlet(VerbsData.Export, "BinaryCmdletAliases")]
    public class ExportBinaryCmdletAliasesCmdlet : PSCmdlet
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

            var aliasesToExport = ModuleInfo.ImplementingAssembly
                .GetExportedTypes()
                .Select(x => x.GetCustomAttribute<AliasAttribute>())
                .Where(x => x != null)
                .SelectMany(x => x.AliasNames)
                .ToList();

            WriteObject(aliasesToExport, true);
        }
    }
}