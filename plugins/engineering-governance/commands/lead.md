---
description: Orchestrated full analysis — automatically selects and combines review, security, architecture, debug, and workflow skills
allowed-tools: Read, Grep, Glob, Bash
---

Apply the `lead` skill to perform an orchestrated analysis.

$ARGUMENTS

If the above is empty:
1. Read `memory/project-context.md` for open issues
2. Run `git status` and `git log --oneline -5` for recent changes
3. Identify the most pressing areas needing analysis
4. Run the appropriate skill combination

Always begin by reading memory (`memory/project-context.md` and `memory/session.md`) before starting any analysis.

The lead skill will determine which combination of review, security, architecture, debug, and workflow skills to activate based on the input.

Output must follow the lead skill format:
- 📚 Context Loaded
- 🎯 Skills Activated
- [Full output per skill]
- 📋 Consolidated Summary
- 🎯 Top Priority Actions
- 📝 MEMORY UPDATE
