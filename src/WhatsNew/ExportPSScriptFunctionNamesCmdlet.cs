using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using JetBrains.Annotations;

namespace WhatsNew
{
    /// <summary>
    /// <para type="synopsis">Extracts function names from a given PowerShell script.</para>
    /// <para type="description">Returns a list of all function names contained within a specified PowerShell script.</para>
    /// <para type="link" uri="https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#export-psscriptfunctionnames">Online help.</para>
    /// </summary>
    [PublicAPI]
    [Cmdlet(VerbsData.Export, "PSScriptFunctionNames")]
    public class ExportPSScriptFunctionNamesCmdlet : PSCmdlet
    {
        /// <summary>
        /// <para type="description">The PowerShell script file from which to extract all function names.</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public string ScriptFile { get; set; }

        /// <inheritdoc />
        protected override void ProcessRecord()
        {
            var scriptBlockAst = Parser.ParseFile(ScriptFile, out var tokens, out var errors);
            var functionDefinitions = scriptBlockAst.FindAll(a => a is FunctionDefinitionAst, true).Cast<FunctionDefinitionAst>();
            var names = functionDefinitions.Select(x => x.Name);

            WriteObject(names, true);
        }
    }
}