using System;

namespace WhatsNew
{
    public class ProgressInfo
    {
        public ProgressInfo(string currentOperation, int totalItems, int completedItems, string verboseOutput = "")
        {
            CurrentOperation = currentOperation;
            TotalItems = totalItems;
            CompletedItems = completedItems;
            VerboseOutput = verboseOutput;
        }

        public string CurrentOperation { get; set; }

        public int TotalItems { get; set; }

        public int CompletedItems { get; set; }

        public string VerboseOutput { get; set; }

        public int PercentComplete() => (int)Math.Truncate(CompletedItems / (double)TotalItems * 100);
    }
}
