# Finding Schema Skill

**When to use:** Every time any agent produces a finding, it must conform exactly to this schema. The orchestrator and reporter agents depend on this structure to aggregate, deduplicate, and include findings in the final report.

## Canonical JSON Schema

```json
{
  "finding_id": "string — unique, format: {AGENT}-{YYYYMMDD}-{NNNN}",
  "schema_version": "1.0",
  "created_at": "ISO 8601 UTC timestamp",
  "created_by_agent": "string — agent identifier",
  "run_id": "string — uuid of the agent run",

  "control_mapping": {
    "primary_control": "string — e.g. CC6.1",
    "test_id": "string — e.g. CC6.1-T02",
    "secondary_controls": ["array of control IDs"],
    "tsc_category": "security | availability | confidentiality | processing_integrity | privacy"
  },

  "classification": {
    "title": "string — short human title, max 120 chars",
    "category": "sast | secret | dependency | iac_config | access | logging | change_mgmt | crypto | vendor | availability | governance",
    "subcategory": "string — e.g. 'sql_injection', 'weak_hash', 'missing_mfa'",
    "cwe": "string — e.g. 'CWE-89' if applicable",
    "owasp_top10": "string — e.g. 'A03:2021' if applicable",
    "cve": "string — if applicable"
  },

  "status": "open | in_progress | remediated | accepted_risk | false_positive | compensating_control",

  "severity": "critical | high | medium | low | informational",
  "risk_score": {
    "composite": "number",
    "criticality": "number 1-5",
    "exposure": "number 1-5",
    "exploitability": "number 1-5",
    "detectability": "number 1-5",
    "overrides_applied": ["array of override reasons"],
    "compensating_controls": ["array of compensating control refs"]
  },

  "description": {
    "summary": "string — 1-2 sentences, what is wrong",
    "technical_detail": "string — what the agent observed",
    "impact_if_exploited": "string — consequences in business terms"
  },

  "location": {
    "type": "code | infrastructure | configuration | policy | process",
    "repository": "string — repo name if applicable",
    "file_path": "string — relative path if applicable",
    "line_start": "number | null",
    "line_end": "number | null",
    "commit_sha": "string — if applicable",
    "resource_id": "string — cloud resource ARN/ID if applicable",
    "url": "string — if applicable"
  },

  "evidence": {
    "raw_output_ref": "string — path in evidence store",
    "raw_output_sha256": "string — hash for integrity",
    "redacted": "boolean — true if PII was redacted",
    "reproducer": "string — command or steps to reproduce",
    "screenshots": ["array of evidence store refs"],
    "related_logs": ["array of log query refs"]
  },

  "remediation": {
    "recommendation_summary": "string",
    "recommendation_detail": "string",
    "suggested_fix_available": "boolean",
    "fix_complexity": "trivial | small | medium | large | architectural",
    "estimated_effort_hours": "number",
    "owner": "string — team or individual",
    "deadline": "ISO 8601 date",
    "linked_pr": "string — URL if remediation PR exists",
    "linked_ticket": "string — issue tracker URL"
  },

  "lifecycle": {
    "first_detected": "ISO 8601 timestamp",
    "last_observed": "ISO 8601 timestamp",
    "observation_count": "number",
    "resolved_at": "ISO 8601 timestamp | null",
    "resolution_evidence_ref": "string | null",
    "resolution_verified_by_agent": "boolean"
  },

  "audit_trail": [
    {
      "timestamp": "ISO 8601",
      "actor": "string",
      "action": "string",
      "notes": "string"
    }
  ]
}
```

## Required Fields by Finding Type

All findings MUST populate:
- `finding_id`, `schema_version`, `created_at`, `created_by_agent`, `run_id`
- `control_mapping.primary_control`, `control_mapping.test_id`
- `classification.title`, `classification.category`
- `status`, `severity`, `risk_score` (full breakdown)
- `description.summary`, `description.impact_if_exploited`
- `evidence.raw_output_ref`, `evidence.raw_output_sha256`
- `remediation.recommendation_summary`
- `lifecycle.first_detected`, `lifecycle.last_observed`

## Deduplication Key

To prevent duplicate findings across runs, each finding gets a stable `dedup_key`:

```
dedup_key = sha256(
  control_mapping.primary_control +
  classification.subcategory +
  location.file_path (if present) +
  location.resource_id (if present) +
  location.line_start (if present, normalized to nearest function)
)
```

When the same `dedup_key` appears in a new run:
- Do NOT create a new finding
- Update `lifecycle.last_observed` and increment `observation_count`
- If severity changed, record in `audit_trail`

## Status Transitions

Valid state machine:

```
open ─────────┬──> in_progress ──> remediated
              │
              ├──> accepted_risk (with compensating_control ref)
              │
              ├──> compensating_control (mitigated by other control)
              │
              └──> false_positive (with reasoning in audit_trail)
```

Never delete a finding. Mark it `false_positive` with justification, or `remediated`. Historical trail matters for the audit.

## Filesystem Layout for Evidence

```
{evidence_store_root}/
├── {run_id}/
│   ├── manifest.json                 # list of all evidence in run, signed
│   ├── findings/
│   │   ├── {finding_id}.json         # the finding itself
│   │   └── {finding_id}.evidence/    # evidence folder
│   │       ├── raw_output.json
│   │       ├── screenshot.png
│   │       └── reproducer.sh
│   └── agent_logs/
│       └── {agent}.log
```

## Quality Gates

Before writing a finding, self-check:

1. Is the `title` specific enough that someone reading it in 6 months will understand without opening the details? Bad: "SQL issue". Good: "User-controlled input concatenated into SQL query in `orders.getByCustomer`".
2. Is the `location` precise enough to act on? Bad: "somewhere in the auth module". Good: "src/auth/session.ts:142–158".
3. Does `impact_if_exploited` describe **business** impact, not just technical? Bad: "attacker could read data". Good: "attacker with any authenticated account could read other customers' order history, violating CC6.7".
4. Is the `recommendation` actionable? Bad: "improve security". Good: "replace string concatenation with parameterized query using `prisma.orders.findMany({ where: { customerId } })`".
5. Is `evidence` verifiable? A reader must be able to independently confirm.
