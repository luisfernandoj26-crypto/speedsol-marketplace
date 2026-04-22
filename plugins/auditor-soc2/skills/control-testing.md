# Control Testing Skill

**When to use:** By compliance agents (CC6/CC7/CC8, Availability, Confidentiality, Risk/Vendor, Governance) when executing the tests defined in `controls.yaml` against live systems.

## Core Contract

Every test execution produces exactly one **test result object** regardless of outcome. A run that cannot execute (tool failed, credentials expired, API down) produces a result with `status: "error"` — never silently skipped.

## Test Result Schema

```json
{
  "test_id": "CC6.1-T01",
  "control_id": "CC6.1",
  "test_name": "MFA enforced on all production access",
  "agent": "access_control_agent",
  "run_id": "uuid",
  "executed_at": "ISO 8601 UTC",
  "method": "automated | manual_attestation | hybrid",
  "status": "pass | fail | error | not_applicable",
  "pass_criteria": "expression from controls.yaml",
  "actual_result": "computed value",
  "evidence_refs": ["array of evidence store paths"],
  "findings_generated": ["array of finding_ids"],
  "duration_ms": 1234,
  "tool_used": "name + version",
  "notes": "free text"
}
```

## Execution Steps per Test

```
1. Load test definition from controls.yaml
2. Verify prerequisites (credentials, tool availability, target reachability)
3. If prerequisites fail → status: "error", explain, do not proceed
4. Execute the data-gathering step (API call, command, query)
5. Capture evidence (see evidence-handling.md)
6. Evaluate pass_criteria expression against gathered data
7. If pass → write test result with status: "pass" and move on
8. If fail → write test result AND generate finding (see finding-schema.md)
9. Always write the test result, even on pass (evidence of operation)
```

## Failure Modes and Handling

### Tool or API unreachable
- Status: `error`
- Notes: exact error message
- DO NOT assume pass
- Retry: up to 3 times with exponential backoff
- If still failing, escalate to orchestrator

### Credentials invalid or expired
- Status: `error`
- Notes: "Credentials to {{system}} invalid or expired"
- DO NOT attempt to refresh credentials automatically
- Generate a finding against CC6.1 (access management) because stale credentials in the automation is itself a finding

### Ambiguous result
If the data returned cannot be cleanly evaluated against `pass_criteria`:
- Status: `error`
- Notes: explain ambiguity
- Request human attestation via issue tracker
- Do NOT guess

### Missing data source
If the `evidence_source` does not exist (e.g. no risk register maintained at all):
- Status: `fail`
- Generate a **critical-adjacent finding** — the absence of the source is itself a control failure
- Do NOT mark as `not_applicable` — that requires explicit scope decision

### Not applicable
Only valid when:
- The test references a TSC category that is out of scope for this assessment, OR
- The technology stack does not have the feature (e.g. "container scanning" when you run on VMs)

`not_applicable` always requires a `notes` field explaining why.

## Manual Attestation Tests

For `method: manual_attestation`, the agent cannot produce a pass directly. Workflow:

1. Check for an existing attestation evidence file in a known path (e.g. `{{evidence_store}}/attestations/{{test_id}}.json`).
2. If exists and is signed and dated within validity window → use it.
3. If missing or expired → generate a **task in the issue tracker** for the designated owner, status: `error`, notes: "Awaiting human attestation".
4. Never self-attest.

Attestation evidence format:
```json
{
  "test_id": "CC6.3-T01",
  "attested_at": "...",
  "attested_by": "human name",
  "attested_by_role": "...",
  "attestation": "I confirm the Q1 2026 access review was completed on 2026-03-28 covering all production systems. Evidence attached.",
  "supporting_evidence_refs": ["..."],
  "signature": "cryptographic signature or e-sign ID",
  "valid_until": "..."
}
```

## Hybrid Tests

Some tests have both automated and manual components. Example: CC9.2-T01 (critical vendors have SOC 2).

- Automated part: check the vendor register for list of critical vendors, check each vendor's attestation file exists and is not expired.
- Manual part: confirm the vendor list itself is complete and up to date (requires human).

For hybrid tests:
1. Execute automated part first.
2. If automated fails → status: `fail`, generate finding.
3. If automated passes → check for most recent human validation of the list. If > 90 days old → status: `error`, request attestation.

## Pass Criteria Expression Evaluation

The `pass_criteria` field uses a restricted expression syntax. Supported:

- Comparisons: `==`, `!=`, `<`, `<=`, `>`, `>=`
- Boolean: `AND`, `OR`, `NOT`
- Field access: `field_name`, `field.nested`
- Set operations: `in`, `not in`
- Numeric: `+`, `-`, `*`, `/`
- String: `matches` (regex), `contains`

Do NOT use `eval()` or dynamic code execution. Use a safe expression parser or explicit conditionals in the agent logic.

Example:
```yaml
pass_criteria: "count == 0"
# evaluated against: { "count": 3 } → fail
```

## Evidence Capture Per Test

Every test generates evidence even on pass (to demonstrate the control operated). Evidence required per test method:

| Method | Evidence required |
|--------|-------------------|
| automated | Raw tool/API output, timestamp, command/query used |
| manual_attestation | Signed attestation + supporting docs |
| hybrid | Both of the above |

For `pass` results, evidence supports the "controls operated during period" claim. Do not skip.

## Tests That Span Time Windows

Some tests look at activity during a period (e.g. CC8.1-T04: "No direct pushes in last 90 days"). For these:

1. `assessment_period_start` and `assessment_period_end` come from environment config.
2. Query must respect these boundaries.
3. Evidence must show the exact date range queried.
4. If the agent has been running continuously, use aggregated data from prior runs rather than re-query full history each time (for performance).

## Idempotency

Running the same test twice in the same minute must produce the same result if the underlying system state hasn't changed. Evidence timestamps will differ, but:
- Test result `status` must match
- Finding `dedup_key` must match (no duplicate findings)
- Evidence `sha256` may differ (timestamps embedded) — that's expected

## Orchestrator Integration

After executing all tests, the agent returns a **run summary** to the orchestrator:

```json
{
  "agent": "access_control_agent",
  "run_id": "...",
  "tests_planned": 12,
  "tests_executed": 12,
  "tests_passed": 9,
  "tests_failed": 2,
  "tests_errored": 1,
  "tests_not_applicable": 0,
  "findings_generated_new": 2,
  "findings_generated_recurrence": 0,
  "evidence_items_written": 27,
  "run_duration_ms": 142000,
  "manifest_ref": "{{evidence_store}}/{{run_id}}/manifest.json"
}
```
