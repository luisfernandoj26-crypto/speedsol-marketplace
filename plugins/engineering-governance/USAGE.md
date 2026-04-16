# Engineering Governance Plugin — Team Guide

## Quick Start (run once per developer)

```powershell
./plugins/engineering-governance/hooks/setup.ps1
```

---

## Available Commands

| Command | Purpose | Example |
|---|---|---|
| `/lead` | Orchestrated full analysis — auto-selects skills | `/lead src/Services/OrderService.cs` |
| `/review` | Code quality review | `/review src/Services/UserService.cs` |
| `/security` | Security audit | `/security src/Controllers/AuthController.cs` |
| `/architecture` | Architecture validation | `/architecture src/Services/` |
| `/workflow` | Git/PR compliance check | `/workflow feature/user-auth` |
| `/debug` | Error analysis with root cause | `/debug "NullReferenceException at OrderService.cs:47"` |
| `/optimize` | Compress last response | `/optimize` |

---

## Tips

- **Not sure which command to use?** → Use `/lead`. It reads memory and decides automatically.
- **`/debug` accepts full stacktraces** — paste the entire error output as the argument.
- **`/workflow` without args** → analyzes your current branch and last 10 commits automatically.
- **`/optimize` without args** → compresses the most recent response in the current session.
- **Memory grows over time** — the more your team uses the plugin, the more context accumulates in `memory/project-context.md`.
- **`/lead` with no args** → reads open issues from memory and determines what to analyze.

---

## Memory Files

### Shared Team Memory

| File | Purpose | In Git |
|---|---|---|
| `memory/project-context.md` | Accumulated project knowledge — tech debt, decisions, resolved issues | ✅ Yes — commit and share |
| `memory/team-log.md` | Audit trail of all analyses | ✅ Yes — commit and share |
| `memory/session.md` | Current session context — intermediate results | ❌ No — local only |

### Per-Agent Memory (`memory/agents/`)

Each agent has its own dedicated memory file that accumulates project-specific knowledge over time:

| File | Agent | What it learns |
|---|---|---|
| `memory/agents/lead.md` | Lead Orchestrator | Orchestration history, multi-skill patterns, escalation decisions |
| `memory/agents/review.md` | Code Review | Recurring code quality issues, approved patterns, resolved findings |
| `memory/agents/security.md` | Security Audit | Vulnerability patterns, resolved CVEs, approved auth implementations |
| `memory/agents/architecture.md` | Architecture | Layer violations, approved deviations, recurring design problems |
| `memory/agents/debug.md` | Debug | Error patterns per module, root causes, successful resolutions |
| `memory/agents/workflow.md` | Workflow | Branch/PR violations, recurring workflow problems, team habits |
| `memory/agents/optimize.md` | Optimize | Best compression techniques per content type |

**All per-agent files are committed to git** — shared across the entire team. ✅

#### Per-Agent Memory Structure

Each agent memory file has 5 sections:
- **Known Issues in This Codebase** — open problems the agent has identified (avoid re-reporting)
- **Resolved Issues (Do Not Re-report)** — closed issues (skip these when analyzing)
- **Approved Patterns (Do Not Flag)** — intentional implementations the team approved
- **Recurring Problems by Module** — issues seen more than once per file/module
- **Analysis History** — log of past analyses with outcomes

#### How Auto-Learning Works

After every session, when Claude includes a `### 🧠 AGENT LEARNING: <name>` section in its response, the `post-process.ps1` hook automatically:
1. Detects the section (e.g., `### 🧠 AGENT LEARNING: security`)
2. Classifies each line by prefix:
   - `- New known issue:` → **Known Issues** section
   - `- Recurring (seen again):` → **Known Issues** section (increments awareness)
   - `- Resolved:` → **Resolved Issues** section
   - `- Approved pattern:` → **Approved Patterns** section
   - `- History:` → **Analysis History** section
3. Appends each line with today's date into the correct section

No manual intervention needed — agents learn automatically with every use.

---

## Hook Behavior

| Hook | Fires when | What it does |
|---|---|---|
| `pre-process.ps1` | Before any `Write` or `Edit` on `.cs` files | Blocks hardcoded secrets from being written |
| `post-process.ps1` | After Claude stops responding | Extracts `📝 MEMORY UPDATE` → `project-context.md`; routes `🧠 AGENT LEARNING` sections → `memory/agents/<name>.md`; appends to `team-log.md` |
| `error-handler.ps1` | After failed Bash commands | Logs to `logs/claude-errors.log` with timestamp and developer |

---

## Skills Available

| Skill | Description |
|---|---|
| `review` | Senior .NET reviewer — quality, naming, logging, architecture compliance |
| `security` | Security auditor — OWASP, auth, SQL injection, secrets, Azure |
| `architecture` | Architecture validator — layer separation, DI, coupling, scalability |
| `optimize` | Token optimizer — compresses AI responses |
| `workflow` | DevOps enforcer — Git flow, PR compliance, deployments |
| `debug` | Error analyst — classification, root cause, fix with code |
| `lead` | Orchestrator — reads memory, activates the right skills, consolidates |

---

## Adding the Plugin to Claude Code

```bash
/plugin install engineering-governance
```

Or from the marketplace:

```bash
/plugin marketplace add luisfernandoj26-crypto/speedsol-marketplace
/plugin install engineering-governance
```

---

## Logs

All hook execution logs are stored locally (not committed to git):
- `logs/pre-process.log` — secret scan results
- `logs/claude-errors.log` — failed Bash commands
