using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using JetBrains.Annotations;

namespace WhatsNew
{
    [PublicAPI]
    [Cmdlet(VerbsData.Export, "PSScriptFunctionNames")]
    public class ExportPSScriptFunctionNamesCmdlet : PSCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public string ScriptFile { get; set; }

        protected override void ProcessRecord()
        {
            var scriptBlockAst = Parser.ParseFile(ScriptFile, out var tokens, out var errors);
            var functionDefinitions = scriptBlockAst.FindAll(a => a is FunctionDefinitionAst, true).Cast<FunctionDefinitionAst>();
            var names = functionDefinitions.Select(x => x.Name);

            WriteObject(names, true);
        }
    }
}