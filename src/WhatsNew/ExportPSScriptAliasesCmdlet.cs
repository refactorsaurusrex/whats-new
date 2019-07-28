﻿using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using JetBrains.Annotations;

namespace WhatsNew
{
    /// <summary>
    /// <para type="synopsis">Extracts aliases from a given PowerShell script.</para>
    /// <para type="description">Returns a list of all aliases contained within a specified PowerShell script.</para>
    /// <para type="link" uri="https://github.com/refactorsaurusrex/whats-new/wiki/Cmdlet-and-Function-Overview#export-psscriptaliases">Online help.</para>
    /// </summary>
    [PublicAPI]
    [Cmdlet(VerbsData.Export, "PSScriptAliases")]
    public class ExportPSScriptAliasesCmdlet : PSCmdlet
    {
        /// <summary>
        /// <para type="description">The PowerShell script file from which to extract all function names.</para>
        /// </summary>
        [Parameter(ValueFromPipeline = true, Mandatory = true)]
        public string ScriptFile { get; set; }

        /// <inheritdoc />
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