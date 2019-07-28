using System.Linq;
using System.Management.Automation;
using System.Reflection;
using JetBrains.Annotations;

namespace WhatsNew
{
    /// <summary>
    /// <para type="synopsis">Extracts cmdlet names from a given module.</para>
    /// <para type="description">Returns a list of all cmdlet names contained within a specified binary cmdlet module.</para>
    /// <para type="link" uri="https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#export-binarycmdletnames">Online help.</para>
    /// </summary>
    [PublicAPI]
    [Cmdlet(VerbsData.Export, "BinaryCmdletNames")]
    public class ExportBinaryCmdletNamesCmdlet : PSCmdlet
    {
        /// <summary>
        /// <para type="description">The PSModuleInfo from which to extract cmdlet names</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public PSModuleInfo ModuleInfo { get; set; }

        /// <inheritdoc />
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
