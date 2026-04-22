---
description: Full .NET code quality review — quality, naming, logging, architecture compliance
allowed-tools: Read, Grep, Glob
---

Apply the `review` skill to analyze the following .NET code.

$ARGUMENTS

If the above is empty, ask the user: "Please provide a file path (e.g., `src/Services/UserService.cs`) or paste the code to review."

If a file path was provided, read the file before analyzing.

Before analyzing, check `memory/project-context.md` for existing known issues on this file to avoid re-reporting resolved items.

Output must follow the review skill format:
- 🔴 Issues
- 🟡 Risks
- 🟢 Improvements
- 💻 Suggested Fix (if needed)
- 📝 MEMORY UPDATE
