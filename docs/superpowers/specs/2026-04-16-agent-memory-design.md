# Design Spec: Per-Agent Memory & Project-Specific Learning

**Date:** 2026-04-16
**Status:** Approved
**Scope:** Add dedicated memory files per agent so each accumulates project-specific knowledge independently

---

## 1. Problem

The current memory system (`project-context.md`, `team-log.md`, `session.md`) is shared across all agents. There is no way for the `review` agent to know it has seen `UserService.cs` 3 times with the same issue, or for the `security` agent to know that a given vulnerability was already fixed last week. All agents write to the same pool, which causes:

- Repeated reporting of resolved issues
- No per-agent view of recurring problems by module
- No way to accumulate project-specific approved patterns per agent

---

## 2. Solution

Give each agent its own dedicated memory file. Each agent reads its file before analyzing and writes new learnings after.

---

## 3. New Files

```
memory/agents/
├── review.md
├── security.md
├── architecture.md
├── debug.md
├── workflow.md
└── lead.md
```

Each file is committed to git and shared across the team (like `project-context.md`).

---

## 4. Per-Agent Memory File Structure

```markdown
# Agent Memory: [agent-name]

## Known Issues in This Codebase
<!-- [file]: [issue type] | First seen: DATE | Times: N | Status: open/resolved -->

## Resolved Issues (Do Not Re-report)
<!-- [file]: [issue] | Resolved: DATE | By: developer -->

## Approved Patterns (Do Not Flag)
<!-- [pattern]: [reason it's intentional] | Confirmed: DATE -->

## Recurring Problems by Module
<!-- [module]: [issue type] | Frequency: high/medium/low -->

## Analysis History
<!-- DATE: analyzed [file] → [key finding in one line] -->
```

---

## 5. Agent Behavior

### Before analysis
1. Read `memory/agents/<self>.md`
2. Skip issues in "Resolved Issues"
3. Do not flag patterns in "Approved Patterns"
4. Elevate priority of issues already in "Known Issues" (recurring = more critical)
5. Also read `memory/project-context.md` as before

### After analysis
Output a labeled section:

```
### 🧠 AGENT LEARNING: review
- New known issue: src/Controllers/OrderController.cs → business logic in controller | Status: open
- Recurring (seen again): src/Services/UserService.cs → missing ILogger | Times: 2
- Resolved: src/Repositories/ProductRepo.cs → SQL injection | Date: 2026-04-16
- Approved pattern: Dapper instead of EF Core in Reports module | Confirmed: 2026-04-16
```

The agent name embedded in the tag (`review`, `security`, etc.) allows the hook to route automatically.

---

## 6. hook: `post-process.ps1` update

In addition to extracting `### 📝 MEMORY UPDATE`, the hook now also:

1. Scans for `### 🧠 AGENT LEARNING: <name>` sections
2. Routes content to `memory/agents/<name>.md`
3. Classifies each line by prefix and appends to the correct section (always append — never modify existing lines):
   - `New known issue:` → `## Known Issues in This Codebase`
   - `Recurring (seen again):` → `## Known Issues in This Codebase` (agent reads duplicates and understands recurrence)
   - `Resolved:` → `## Resolved Issues`
   - `Approved pattern:` → `## Approved Patterns`
   - Everything else → `## Analysis History`

---

## 7. `setup.ps1` update

On first run (or re-run), initialize `memory/agents/` with all 6 files if they don't exist.

---

## 8. Files changed

| File | Change |
|---|---|
| `memory/agents/review.md` | CREATE |
| `memory/agents/security.md` | CREATE |
| `memory/agents/architecture.md` | CREATE |
| `memory/agents/debug.md` | CREATE |
| `memory/agents/workflow.md` | CREATE |
| `memory/agents/lead.md` | CREATE |
| `skills/review/SKILL.md` | Add per-agent memory read/write to MEMORY PROTOCOL |
| `skills/security/SKILL.md` | Add per-agent memory read/write to MEMORY PROTOCOL |
| `skills/architecture/SKILL.md` | Add per-agent memory read/write to MEMORY PROTOCOL |
| `skills/debug/SKILL.md` | Add per-agent memory read/write to MEMORY PROTOCOL |
| `skills/workflow/SKILL.md` | Add per-agent memory read/write to MEMORY PROTOCOL |
| `skills/optimize/SKILL.md` | Add per-agent memory read/write to MEMORY PROTOCOL |
| `skills/lead/SKILL.md` | Add per-agent memory read/write to MEMORY PROTOCOL |
| `hooks/scripts/post-process.ps1` | Extract + route `🧠 AGENT LEARNING` sections |
| `hooks/setup.ps1` | Initialize `memory/agents/` directory and files |
| `USAGE.md` | Document per-agent memory |

---

## 9. Success criteria

- [ ] All 6 `memory/agents/*.md` files created and initialized
- [ ] All 7 skills read `memory/agents/<self>.md` before analysis
- [ ] All 7 skills output `### 🧠 AGENT LEARNING: <self>` section
- [ ] `post-process.ps1` routes AGENT LEARNING to correct agent file
- [ ] `setup.ps1` initializes agent memory on first run
- [ ] After running `/review` twice on the same file, the second run notes "Recurring"
