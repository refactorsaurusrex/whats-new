using System.Collections.Generic;
using System.Linq;

namespace WhatsNew
{
    internal static class Extensions
    {
        public static bool YamlFrontMatterToCodeFence(this List<string> markdownLines)
        {
            if (markdownLines.First() != "---")
                return false;

            var counter = 0;
            for (var i = 0; i < markdownLines.Count; i++)
            {
                if (markdownLines[i].StartsWith("---"))
                {
                    markdownLines[i] = markdownLines[i].Replace("---", "```");
                    if (++counter >= 2)
                        break;
                }
            }

            return true;
        }

        public static bool CodeFenceToYamlFrontMatter(this List<string> value)
        {
            if (value.First() != "```")
                return false;

            var counter = 0;
            for (var i = 0; i < value.Count; i++)
            {
                if (value[i].StartsWith("```"))
                {
                    value[i] = value[i].Replace("```", "---");
                    if (++counter >= 2)
                        break;
                }
            }

            return true;
        }
    }
}
