# PR Generation Skill

**When to use:** Only by the Remediation Agent, whenever producing a code change that fixes a finding. This skill defines the bar for every PR created by an agent — it must be indistinguishable in quality from a PR written by a senior engineer.

## The Five-Phase Workflow

### Phase 1 — UNDERSTAND (read-only)

Before writing any code, fully understand the context.

Required actions:
1. Read the full file containing the finding, plus the files it imports and is imported by.
2. Run `grep` for all callers of the function being modified. Read each.
3. Check test coverage for the affected lines. Run the tests.
4. `git log -p` on the file for the last 5 commits — understand the history.
5. Search the repo for prior fixes of the same CWE/subcategory to match style.
6. Read relevant documentation (README, ARCHITECTURE.md, contributing guide).

Output a written **Context Brief** (internal to the agent, attached to the PR as a comment):
- What the code does today
- How the vulnerability is reachable
- Who calls the affected function
- What tests exist
- What prior fixes look like
- Whether a similar pattern exists elsewhere in the codebase (if yes — flag as separate finding)

**Do not proceed to Phase 2 if any of the following are true:**
- You cannot determine all callers (dynamic dispatch you can't resolve)
- Tests are missing for the affected path AND you cannot reasonably add them
- The file has been touched in the last 24 hours by an active PR (merge conflict risk)
- The fix would cross architectural boundaries (e.g. change a public API contract)

In those cases, output a finding with `remediation.suggested_fix_available: false` and `fix_complexity: "architectural"` and stop.

### Phase 2 — PLAN

Write a short written plan. Required sections:

1. **Root cause statement.** One sentence, technical and precise.
2. **Fix options considered.** List 1–3 alternatives with trade-offs. Always consider:
   - Minimal surgical fix
   - Fix + defense-in-depth
   - Fix + refactor (usually reject unless required)
3. **Chosen approach and justification.**
4. **Files to modify** (with line ranges).
5. **Tests to add** (explicit — regression test that fails without the fix).
6. **Breaking change analysis.** If yes → STOP and escalate to human.
7. **Rollback plan** if the fix causes issues post-deploy.

### Phase 3 — IMPLEMENT

Branch naming: `sec/{{control_id}}/{{finding_id}}-{{short-slug}}`
Example: `sec/CC6.1/SAST-20260422-0042-sanitize-order-query`

Commit message format:
```
sec({{area}}): {{concise description}}

Fixes {{CWE-XXX}}: {{longer description}}

- What changed: {{1-2 bullets}}
- Why: {{reference to finding}}
- Tests: {{what tests were added/modified}}

Finding-ID: {{finding_id}}
Control: {{control_id}}
Evidence-Before: {{evidence ref}}
Severity: {{severity}}
Co-Authored-By: {{human reviewer placeholder}}
```

Implementation rules:
- **Smallest possible diff.** No tangential refactors. No style changes. No comment additions unless directly relevant.
- **No new dependencies** unless absolutely required. If added, justify in PR body and verify license compatibility.
- **Match the codebase style.** Run the repo's linter and formatter before committing.
- **Never disable or weaken tests.** If a test needs changes, explain why in the PR body.
- **Never weaken type signatures.** Tighten if possible.
- **Never introduce TODO / FIXME** as part of a fix. Either fix it or explicitly scope it out.

### Phase 4 — VERIFY

Required verifications, in order:

1. **Lint / format.** Must pass with zero warnings.
2. **Type check.** Must pass.
3. **Unit tests.** All must pass, including the new regression test.
4. **Integration tests** (if scoped). Must pass.
5. **Re-run the detecting scanner.** The finding must no longer appear.
6. **Re-run related scanners.** No new findings introduced.
7. **Coverage check.** Modified lines must have test coverage ≥ 80% (or repo threshold, whichever higher).
8. **Diff review.** Read your own diff. Ask: does every line serve the fix?

If any verification fails:
- Iterate up to 3 times
- If still failing, convert PR to Draft and add a comment explaining what you tried

### Phase 5 — HANDOFF

PR Title: `sec({{area}}): {{finding.title}} [{{severity}}]`

PR Body template:
```markdown
## Summary

Fixes finding `{{finding_id}}` ({{severity}}, {{control_id}}).

{{one-paragraph summary of the vulnerability and fix}}

## Root Cause

{{technical explanation}}

## Fix

{{what the change does, in plain language}}

## Alternatives Considered

{{brief mention of other options and why this was chosen}}

## Testing

- [x] Added regression test: `{{test_name}}` — fails without fix, passes with fix
- [x] Existing tests pass: `{{count}} tests`
- [x] SAST rescan: no longer flagged
- [x] Coverage of modified lines: {{pct}}%

## Breaking Changes

{{none | list them}}

## Rollback Plan

{{how to revert if needed}}

## Compliance Metadata

- Finding ID: `{{finding_id}}`
- Control: `{{control_id}}`
- CWE: `{{cwe}}`
- Severity: `{{severity}}`
- Evidence before fix: `{{evidence_ref}}`
- Evidence after fix: `{{evidence_ref_after}}`

## Reviewer Checklist

- [ ] Root cause matches fix
- [ ] Regression test actually fails without fix (reviewer verified locally)
- [ ] No unrelated changes in diff
- [ ] No secrets added
- [ ] No telemetry or logging additions that could contain PII

---
*This PR was authored by the Remediation Agent. Human review is required before merge.*
```

Required labels: `security`, `soc2-remediation`, `severity:{{level}}`, `control:{{id}}`

Required reviewers: pull from CODEOWNERS for the changed paths. If none, fall back to the security team.

PR draft status rules:
- **Draft** if: any verification was skipped, severity is critical, fix complexity is medium+, or agent confidence <90%.
- **Ready for review** only if all verifications passed AND severity is low/medium AND fix is trivial/small.

## Never Do

- Never force-push to a protected branch.
- Never merge your own PR.
- Never add the agent itself as a CODEOWNER.
- Never modify CI configuration as part of a security fix (separate PR).
- Never touch secrets, keys, or credentials files — escalate to human.
- Never batch unrelated findings into one PR. One finding = one PR (rare exception: identical fix in multiple files from the same root cause, documented as such).
- Never use "I" or first person in PR descriptions. Write as the codebase's conventions dictate.

## Escalation Triggers

Stop and create a ticket (not a PR) when:
- Fix requires cross-team coordination
- Fix requires database migration
- Fix requires customer communication (behavior change)
- Fix requires rotation of secrets
- Fix requires dependency that doesn't exist in the ecosystem
- The "bug" is actually a design decision that needs product/security review

Ticket format in issue tracker:
```
Title: [SEC] {{finding.title}}
Body:
  Finding: {{finding_id}}
  Severity: {{severity}}
  Why human: {{reason for escalation}}
  Recommended next steps: {{list}}
  Compensating controls in place: {{list}}
  Proposed deadline: {{date}}
```
