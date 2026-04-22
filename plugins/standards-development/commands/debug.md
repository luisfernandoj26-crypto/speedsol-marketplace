---
description: Analyze .NET errors — classifies, identifies root cause, provides corrected code
allowed-tools: Read, Grep
---

Apply the `debug` skill to analyze the following .NET error.

$ARGUMENTS

If the above is empty, ask the user: "Please paste the error message, stacktrace, or describe the unexpected behavior."

If a file path was included, read the relevant section of the file to understand the context of the error.

Before analyzing, check `memory/project-context.md` for similar error patterns that were already resolved.

Output must follow the debug skill format — ALL 4 sections mandatory:
- 🧨 Problem
- 🧠 Root Cause
- 🛠 Solution
- 💻 Corrected Code
- 📝 MEMORY UPDATE
