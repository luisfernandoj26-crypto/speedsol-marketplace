# Risk Scoring Skill

**When to use:** Whenever any agent classifies the severity of a finding. All agents MUST use this methodology to produce consistent, comparable severity ratings across the assessment.

## The 4-Dimension Model

Every finding receives a score in four dimensions. Each dimension scores 1–5. The final severity is derived from the composite.

### 1. Control Criticality (weight: 1.5x)

How important is the affected control to SOC 2 compliance?

| Score | Meaning |
|-------|---------|
| 5 | Key control — auditor will test this with certainty (e.g. MFA, encryption at rest, access review) |
| 4 | Significant control — high likelihood of being tested |
| 3 | Standard control — sampled by auditor |
| 2 | Supporting control — secondary evidence |
| 1 | Informational — good practice but not a control |

### 2. Exposure (weight: 1.5x)

What data or systems are affected?

| Score | Meaning |
|-------|---------|
| 5 | Customer data (PII, financial, health, auth credentials) |
| 4 | Internal confidential data (source code, infra secrets, employee data) |
| 3 | Internal operational data (logs, metrics, non-prod) |
| 2 | Public data handled incorrectly |
| 1 | Theoretical — no sensitive data involved |

### 3. Exploitability (weight: 1.0x)

How easily can this be exploited?

| Score | Meaning |
|-------|---------|
| 5 | Exploitable remotely without authentication |
| 4 | Exploitable remotely with standard user authentication |
| 3 | Requires privileged user access |
| 2 | Requires insider access + specific conditions |
| 1 | Requires physical access or theoretical-only |

### 4. Detectability (weight: 1.0x)

Would you notice if this were exploited? (Inverse — lower detection = higher risk)

| Score | Meaning |
|-------|---------|
| 5 | No monitoring in place — exploitation would be invisible |
| 4 | Partial monitoring — would likely miss this |
| 3 | Monitoring exists but alerts are noisy or delayed |
| 2 | Alerted within 1 hour |
| 1 | Alerted within 5 minutes with clear runbook |

## Composite Score Calculation

```
composite = (criticality × 1.5) + (exposure × 1.5) + exploitability + detectability
```

Max = 25. Min = 5.

## Severity Mapping

| Composite | Severity | SLA for remediation |
|-----------|----------|---------------------|
| 21–25 | **Critical** | 48 hours |
| 16–20 | **High** | 14 days |
| 11–15 | **Medium** | 60 days |
| 6–10 | **Low** | 180 days |
| 5 | **Informational** | Tracked, no SLA |

## Severity Overrides (automatic upgrades)

Certain conditions **automatically escalate** regardless of composite score:

- Live secret (API key, credential) found in public or shared code → **Critical**
- Unauthenticated remote code execution → **Critical**
- Production data accessible without authentication → **Critical**
- Any control failure during the assessment period with no compensating control → **at minimum High**
- CVE with public exploit AND reachability confirmed → **at minimum High**
- CVE in CISA KEV catalog AND reachability confirmed → **Critical**

## Severity Downgrades (require justification)

Severity may be downgraded **only** with documented compensating controls. The finding must record:

- Which compensating control applies
- Evidence the compensating control is operating
- Residual risk owner (named person)
- Review date

Never downgrade based solely on "we don't think this is exploitable."

## Output Format

Every finding's severity section must include:

```json
{
  "severity": "high",
  "risk_score": {
    "composite": 18.5,
    "criticality": 5,
    "exposure": 4,
    "exploitability": 3,
    "detectability": 3,
    "overrides_applied": [],
    "compensating_controls": []
  },
  "remediation_sla_days": 14,
  "remediation_deadline": "2026-05-06T00:00:00Z"
}
```

## Worked Example

**Finding:** Hardcoded AWS access key found in git history of a public repository.

- Criticality: 5 (CC6.1 — Key control, auditor will scan for secrets)
- Exposure: 5 (AWS key grants access to infrastructure holding customer data)
- Exploitability: 5 (Public repo, no auth needed to read)
- Detectability: 4 (No alerting on secret usage from unknown IPs)

Composite = (5×1.5) + (5×1.5) + 5 + 4 = 24 → **Critical**

Override: "Live secret in public code" also triggers Critical → confirmed.

SLA: 48 hours. Action: rotate immediately, audit all usage of the key during the exposure window.
