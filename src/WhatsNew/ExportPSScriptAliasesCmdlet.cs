using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using JetBrains.Annotations;

namespace WhatsNew
{
    [PublicAPI]
    [Cmdlet(VerbsData.Export, "PSScriptAliases")]
    [OutputType(typeof(string[]))]
    public class ExportPSScriptAliasesCmdlet : PSCmdlet
    {
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public string ScriptFile { get; set; }

        protected override void ProcessRecord()
        {
            var scriptBlockAst = Parser.ParseFile(ScriptFile, out _, out _);
            var attributes = scriptBlockAst.FindAll(a => a is AttributeAst, true).Cast<AttributeAst>();
            var aliases = attributes
                .SelectMany(x => x.PositionalArguments)
                .Select(x => x as StringConstantExpressionAst)
                .Where(x => x != null)
                .Select(x => x.Value);

            WriteObject(aliases, true);
        }
    }
}