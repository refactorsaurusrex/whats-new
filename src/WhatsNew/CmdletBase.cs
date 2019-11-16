using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text;

namespace WhatsNew
{
    public class CmdletBase : PSCmdlet
    {
        private readonly Random _random = new Random();

        protected void ShowProgress(ProgressRecord progressRecord, ProgressReporter progressReporter)
        {
            foreach (var progressInfo in progressReporter.GetConsumingEnumerable())
            {
                progressRecord.CurrentOperation = progressInfo.CurrentOperation;
                progressRecord.StatusDescription = $"Completed {progressInfo.CompletedItems} of {progressInfo.TotalItems} items";
                progressRecord.PercentComplete = progressInfo.PercentComplete();
                WriteProgress(progressRecord);

                if (!string.IsNullOrEmpty(progressInfo.VerboseOutput))
                    WriteVerbose(progressInfo.VerboseOutput);
            }
        }

        protected void HideProgress(ProgressRecord progressRecord)
        {
            progressRecord.RecordType = ProgressRecordType.Completed;
            WriteProgress(progressRecord);
        }

        protected ProgressRecord CreateProgressRecord(string activity, string statusDescription) => new ProgressRecord(_random.Next(), activity, statusDescription);
    }
}
