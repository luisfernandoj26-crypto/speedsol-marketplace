---
description: Validate Git/PR workflow compliance — branch naming, commits, PR rules, deployment policy
allowed-tools: Bash
---

Apply the `workflow` skill to validate the following Git workflow state.

$ARGUMENTS

If the above is empty, run the following commands to get the current git state and analyze it:
- `git branch --show-current` — get current branch name
- `git log --oneline -10` — get last 10 commits
- `git status` — get uncommitted changes

Validate the current state against company workflow rules.

Before analyzing, check `memory/project-context.md` for known workflow decisions and approved deviations.

Output must follow the workflow skill format:
- 🔴 Violations
- 🟡 Risks
- 🟢 Recommendations
- 💻 Suggested Fix
- 📝 MEMORY UPDATE
