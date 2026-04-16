# Design Spec: engineering-governance Plugin — Production Rebuild

**Date:** 2026-04-16  
**Author:** Luis Fernando Jaramillo / Speed Solutions S.A.S  
**Status:** Approved  
**Scope:** Full rebuild of the `plugins/engineering-governance` plugin for multi-developer production use

---

## 1. Context & Problem Statement

The current `engineering-governance` plugin has the following critical defects that prevent it from working in production:

| Component | Defect |
|---|---|
| `skills/review/SKILL.md` | No frontmatter — Claude Code does not recognize it as a skill |
| All skills | Reference policy files (`rules.md`, etc.) in text but never embed their content — Claude never sees the policies |
| All commands | No valid Claude Code slash command format — they are plain text descriptions, not executable prompts |
| Hooks (`pre-process`, `post-process`, `error-handler`) | Pure markdown — never execute. Claude Code requires real shell scripts configured in `settings.json` |
| Agents | Loose role descriptions with no invocation mechanism |
| Missing `/workflow` command | Workflow skill exists but has no command |
| Missing `/debug` command | `error-policy.md` exists but has no skill or command |
| Missing `/lead` command | Orchestrator agent has no entry command |
| No agent memory | Every analysis starts from zero — no shared knowledge between sessions or developers |

---

## 2. Goals

- Every skill must be recognized by Claude Code and contain all policy content inline
- Every command must be a functional Claude Code slash command prompt
- Hooks must execute real PowerShell scripts on the correct Claude Code lifecycle events
- Agents must be complete subagent system prompts
- A 3-layer memory system must persist findings across sessions and across team members
- The full plugin must be activatable with a single `setup.ps1` run per developer

---

## 3. Skills (7 total)

### 3.1 Policy embedding rule
All skills must inline the content of relevant policy files directly into the prompt. The section "APPLY COMPANY POLICIES → filename" pattern is replaced by the actual policy text. This is mandatory because Claude Code skills are standalone prompts — they cannot import external files at runtime.

### 3.2 Skills to rebuild

| Skill | Key change |
|---|---|
| `skills/review/SKILL.md` | Add frontmatter (`name: review`, `description: ...`) + inline `quality-policy.md` + `rules.md` + `architecture-policy.md` + memory protocol |
| `skills/architecture/SKILL.md` | Inline `architecture-policy.md` + `rules.md` + `quality-policy.md` + memory protocol |
| `skills/security/SKILL.md` | Inline `security-policy.md` + `error-policy.md` + `rules.md` + memory protocol |
| `skills/optimize/SKILL.md` | Inline `tokens.md` + `rules.md` + memory protocol |
| `skills/workflow/SKILL.md` | Inline `workflow-policy.md` + `rules.md` + `security-policy.md` + memory protocol |

### 3.3 New skills

**`skills/debug/SKILL.md`**
- `name: debug`, `description: .NET error analysis with root cause and fix`
- Based entirely on `error-policy.md`
- Receives: error description or stacktrace via `$ARGUMENTS`
- Classifies: Syntax / Logic / Security / Performance / Integration
- Identifies: affected layer (Controller / Service / Repository / External)
- Outputs: root cause + concrete fix + corrected code snippet
- Memory protocol: records resolved error patterns to `memory/project-context.md`

**`skills/lead/SKILL.md`**
- `name: lead`, `description: Orchestrator — auto-selects and combines relevant agents`
- Reads `memory/project-context.md` and `memory/session.md` before analyzing
- Evaluates input type and decides which combination of skills to activate
- Dispatches sub-analyses and consolidates into a single structured output
- Writes comprehensive findings to `memory/session.md` and summary to `memory/project-context.md`

### 3.4 Memory protocol (all skills)

Every skill prompt ends with:

```
## 🧠 MEMORY PROTOCOL

BEFORE analyzing:
1. If memory/project-context.md exists, read it — do NOT re-report already resolved issues
2. If memory/session.md exists, check if this file was already analyzed this session

AFTER analyzing, append to your output:
### 📝 MEMORY UPDATE
- New findings to persist: [list]
- Decisions to record: [list]  
- Issues resolved (mark as closed): [list]
```

---

## 4. Commands (7 total)

### 4.1 Command format

All commands use valid Claude Code slash command format:

```markdown
---
description: "Short description for /help"
allowed-tools: Tool1, Tool2
---

[Full self-contained prompt that invokes the correct skill]

$ARGUMENTS

[Fallback: if no $ARGUMENTS provided, read the active file or ask for minimum context]
```

### 4.2 Commands to rebuild

| Command | allowed-tools | Behavior |
|---|---|---|
| `/review` | Read, Grep, Glob | Invokes `review` skill. With args: analyzes specified path. Without args: asks user to provide a file path or paste code |
| `/security` | Read, Grep, Glob | Invokes `security` skill. With args: analyzes specified path. Without args: asks user to provide a file path |
| `/architecture` | Read, Glob | Invokes `architecture` skill. With args: analyzes specified path or module. Without args: asks user to specify a module or layer to validate |
| `/optimize` | Read | Invokes `optimize` skill. With args: compresses specified content. Without args: compresses the most recent Claude response in context |
| `/workflow` | Bash | Invokes `workflow` skill. With args: validates specified branch name. Without args: runs `git branch --show-current` and validates current branch |

### 4.3 New commands

**`/debug`**
- `allowed-tools: Read, Grep`
- Invokes `debug` skill
- Accepts: stacktrace paste, error description, or file path
- Without args: asks user for error description
- Output: classified error + root cause + fix + code

**`/lead`**
- `allowed-tools: Read, Grep, Glob, Bash`
- Invokes `lead` skill (orchestrator)
- Reads memory before starting
- Evaluates what type of analysis is needed
- Runs appropriate combination of sub-analyses
- Single consolidated output with all findings
- Without args: analyzes current project context broadly

---

## 5. Hooks (real implementation)

### 5.1 Claude Code hook events used

| Hook | Event | Matcher |
|---|---|---|
| `pre-process` | `PreToolUse` | `Write\|Edit` |
| `post-process` | `Stop` | `.*` |
| `error-handler` | `PostToolUse` | `Bash` (on error) |

### 5.2 Hook scripts

**`hooks/scripts/pre-process.ps1`**
- Reads `memory/project-context.md` and validates it exists (creates empty if not)
- Scans code about to be written for hardcoded secrets (regex: `password\s*=\s*"`, `api_key\s*=\s*"`, connection strings)
- Validates `.cs` file namespace conventions (PascalCase)
- Exit code 1 blocks the operation; exit code 0 allows it
- Logs validation result to `logs/pre-process.log`

**`hooks/scripts/post-process.ps1`**
- After Claude stops responding, checks if output contains `📝 MEMORY UPDATE` section
- If found: extracts and appends to `memory/project-context.md`
- Appends one line to `memory/team-log.md`: `TIMESTAMP | $env:USERNAME | COMMAND | FILE | SUMMARY`
- Does not block — informational only

**`hooks/scripts/error-handler.ps1`**
- Fires after a Bash tool call that returned non-zero exit code
- Captures stderr, timestamps it, appends to `logs/claude-errors.log`
- Format: `TIMESTAMP | $env:USERNAME | FAILED_COMMAND | ERROR_SUMMARY`

### 5.3 Distributed setup

```
hooks/
├── scripts/
│   ├── pre-process.ps1
│   ├── post-process.ps1
│   └── error-handler.ps1
├── settings-merge.json    ← ready-to-merge hook configuration fragment
└── setup.ps1              ← one-time setup script per developer
```

**`setup.ps1` behavior:**
1. Detects `.claude/settings.json` (creates if missing)
2. Merges `settings-merge.json` into existing settings (preserves other keys)
3. Creates `memory/` directory and initializes empty files if not present
4. Creates `logs/` directory
5. Adds `memory/session.md` and `logs/` to `.gitignore`
6. Prints confirmation with list of registered hooks

Each developer runs once:
```powershell
./plugins/engineering-governance/hooks/setup.ps1
```

---

## 6. Agents (5 total — rewritten as subagent system prompts)

All agents are rewritten as complete system prompts that can be dispatched via Claude Code's `Agent` tool.

| Agent | Tools | Core responsibility |
|---|---|---|
| `lead.md` | Read, Grep, Glob, Bash | Reads memory → evaluates input → decides which agents to activate → consolidates output |
| `review.md` | Read, Grep, Glob | Full .NET code review: structure, bad practices, DRY, naming, layer compliance |
| `security.md` | Read, Grep | Security audit: input validation, auth/authz, SQL injection, secrets, Azure security |
| `architecture.md` | Read, Glob | System design validation: layer separation, DI, coupling, scalability, God classes |
| `optimize.md` | Read | Token optimizer: minimal output, no verbosity, result only |

Each agent prompt embeds:
- Its specific role and restrictions ("Does NOT do" sections)
- Relevant policy rules inline
- Strict output format
- Memory protocol (read before / write after)

---

## 7. Memory System (3 layers)

### 7.1 Files

| File | Persistence | In git | Purpose |
|---|---|---|---|
| `memory/project-context.md` | Permanent | Yes | Accumulated project knowledge: tech debt, decisions, resolved issues |
| `memory/session.md` | Session | No (`.gitignore`) | Current session context: analyzed files, intermediate results |
| `memory/team-log.md` | Permanent | Yes | Audit trail: who ran what, on what file, what was found |

### 7.2 Memory flow

```
Command invoked
    ↓
pre-process hook: reads project-context.md → validates input
    ↓
Skill/Agent reads: project-context.md + session.md (avoids re-reporting)
    ↓
Analysis runs with full historical context
    ↓
Output includes "📝 MEMORY UPDATE" section
    ↓
post-process hook: extracts MEMORY UPDATE → appends to project-context.md
post-process hook: appends one line to team-log.md
```

### 7.3 project-context.md structure

```markdown
# Project Memory — [Project Name]

## Known Tech Debt
- [file]: [issue] | Added: DATE | Status: open/resolved

## Architecture Decisions
- [decision] | Date: DATE | Reason: [why]

## Security — Resolved Issues
- [file]: [issue] | Fixed: DATE | By: developer

## Approved Deviations
- [file]: [pattern that looks wrong but is intentional] | Reason: [why]
```

---

## 8. New files summary

| File | Purpose |
|---|---|
| `skills/debug/SKILL.md` | New debug skill |
| `skills/lead/SKILL.md` | New orchestrator skill |
| `commands/workflow.md` | New /workflow command |
| `commands/debug.md` | New /debug command |
| `commands/lead.md` | New /lead command |
| `hooks/scripts/pre-process.ps1` | Real pre-process hook |
| `hooks/scripts/post-process.ps1` | Real post-process hook |
| `hooks/scripts/error-handler.ps1` | Real error handler hook |
| `hooks/settings-merge.json` | Distributable hook config |
| `hooks/setup.ps1` | One-time setup per developer |
| `memory/project-context.md` | Persistent project memory |
| `memory/session.md` | Session memory (gitignored) |
| `memory/team-log.md` | Team audit log |
| `logs/` | Hook execution logs (gitignored) |
| `USAGE.md` | Team cheat sheet |
| `.gitignore` | Ignores session.md and logs/ |

---

## 9. Out of scope

- External tool integrations (GitHub CLI, Azure CLI) — future v2.0
- `/report` command for weekly summaries — future v2.0
- Cross-platform bash scripts (Linux/Mac) — current focus is Windows/PowerShell for Speed Solutions team

---

## 10. Success criteria

- [ ] All 7 skills recognized by Claude Code (valid frontmatter)
- [ ] All 7 commands produce structured output when invoked
- [ ] `setup.ps1` runs without errors and registers all 3 hooks
- [ ] `pre-process.ps1` blocks a write containing a hardcoded password
- [ ] `post-process.ps1` appends to `team-log.md` after a command
- [ ] `memory/project-context.md` grows across sessions
- [ ] `/lead` invokes multiple sub-analyses and consolidates them
- [ ] `USAGE.md` covers all commands with examples
