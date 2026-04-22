# auditor-soc2 Plugin - Architecture & Deliverables

**Based on:** agent-deliverables-and-pending-work.md  
**Last Updated:** 2026-04-22

---

## System Architecture

### Agent Portfolio (15 Agents Total)

#### Compliance Agents (00-07)

```
Compliance Orchestrator (00)
├── Agent 01: Access Control (CC6)
│   └── Findings: MFA, account rotation, provisioning, revocation, access reviews
│       Output: {FINDINGS_DIR}/cc6/
│
├── Agent 02: Operations (CC7)
│   └── Findings: log sources, retention, alerts, IR plan, RCA
│       Output: {FINDINGS_DIR}/cc7/
│
├── Agent 03: Change Management (CC8)
│   └── Findings: peer review, CI/tests, prod approvals, direct pushes, risk analysis
│       Output: {FINDINGS_DIR}/cc8/
│
├── Agent 04: Risk & Vendor (CC3, CC9)
│   └── Findings: vendor SOC 2, DPAs, risk register, sub-processors
│       Output: {FINDINGS_DIR}/cc3-cc9/
│
├── Agent 05: Availability (A1)
│   └── Findings: backups, DR drill, SLO, capacity planning
│       Output: {FINDINGS_DIR}/a1/
│
├── Agent 06: Confidentiality (C1)
│   └── Findings: data classification, encryption at rest, TLS, retention, deletion
│       Output: {FINDINGS_DIR}/c1/
│
└── Agent 07: Governance (CC1-CC2)
    └── Findings: policies, code of conduct, training, org chart
        Output: {FINDINGS_DIR}/cc1-cc2/
```

#### Code Detection Agents (10-15)

```
Code Orchestrator (10)
├── Agent 11: SAST
│   └── Findings: confirmed_vulnerable / false_positive / context_dependent / already_mitigated
│       With: dataflow, CWE, snippet, fix suggestion (no apply)
│       Output: {FINDINGS_DIR}/sast/
│
├── Agent 12: Secrets & Crypto
│   └── Findings: secrets (live/revoked/unknown), weak algorithms, bad JWT, bad randomness
│       Output: {FINDINGS_DIR}/secrets/
│
├── Agent 13: Dependencies & License
│   └── SBOM (CycloneDX), CVEs (EPSS+KEV+reachability), copyleft licenses, abandoned, typosquatting
│       Output: {FINDINGS_DIR}/deps/ + {EVIDENCE_STORE}/sboms/
│
├── Agent 14: IaC & Config
│   └── Findings: Terraform, K8s, Dockerfiles, GHA, IAM (severity adjusted by context)
│       Output: {FINDINGS_DIR}/iac/
│
└── Agent 15: Remediation
    └── **GitHub PRs**: fix + regression test + compliance metadata + before/after evidence
        Log of: opened PRs, escalations, non-remediable findings
        Output: Git (PRs) + {OUTPUT_DIR}/remediation/{RUN_ID}/
```

### Agent Deliverables (Standard Format)

All agents produce **three artifact types per run:**

#### 1. Findings JSON (Structured)

```json
{
  "agent_id": "12",
  "agent_name": "Secrets & Crypto",
  "run_id": "2026-04-22-001",
  "timestamp": "2026-04-22T14:30:00Z",
  "findings": [
    {
      "id": "SECRET-001",
      "type": "hardcoded_secret",
      "severity": "critical",
      "location": "src/config.ts:42",
      "finding": "AWS API key found in code",
      "state": "live",
      "impact": "Unauthorized AWS access",
      "recommendation": "Revoke key, use environment variables",
      "evidence_id": "SHA256-abc123..."
    }
  ],
  "summary": {
    "total": 5,
    "critical": 2,
    "high": 2,
    "medium": 1,
    "low": 0
  }
}
```

#### 2. Evidence (With SHA-256 Hash)

```
{EVIDENCE_STORE}/{RUN_ID}/{AGENT_ID}/{TEST_ID}/{EVIDENCE_ID}.json
└── Contains: raw data, logs, screenshots, configs (PII redacted)
    Hash: SHA256 for integrity verification
```

#### 3. Run Summary

```json
{
  "run_id": "2026-04-22-001",
  "agent_id": "12",
  "duration_seconds": 342,
  "tests_executed": 15,
  "test_results": {
    "pass": 8,
    "fail": 4,
    "exception": 2,
    "not_applicable": 1
  },
  "findings_count": 5,
  "evidence_captured": 12,
  "exceptions_logged": 2,
  "continuity_checks": "continuous (Type II quality)"
}
```

### Data Flow Between Agents

```
┌─────────────────────────────────────────────────────────────┐
│                    Run Coordinator                          │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌──────────┐         ┌──────────┐
   │  Agent  │          │  Agent   │         │  Agent   │
   │ 01-07   │          │ 10, 11-14│         │   15     │
   │Compliance│         │  Code    │         │Remediation│
   └────┬────┘          └────┬─────┘         └────┬─────┘
        │                    │                    │
        │ Findings JSON      │ Findings JSON      │ PRs +
        │ Evidence           │ Evidence           │ Evidence
        │ run_summary.json   │ run_summary.json   │ Logs
        │                    │                    │
        └────────────┬───────┴─────────┬──────────┘
                     │                 │
                     ▼                 ▼
         ┌──────────────────┐  ┌──────────────────┐
         │  Agent 00        │  │  Agent 10        │
         │  Compliance      │  │  Code            │
         │  Orchestrator    │  │  Orchestrator    │
         │ (consolidates)   │  │ (deduplicates)   │
         └────────┬─────────┘  └────────┬─────────┘
                  │                     │
                  │ Consolidated        │ Backlog
                  │ Findings            │ + Plan
                  │                     │
                  └─────────┬───────────┘
                            │
                            ▼
            ┌─────────────────────────────┐
            │   Final Report (Quarterly)  │
            │ {OUTPUT_DIR}/reports/       │
            │ - Consolidated findings     │
            │ - Risk matrix               │
            │ - Recommendations           │
            │ - Management letter         │
            │ - Appendices (evidence)     │
            └─────────────────────────────┘
```

---

## Output Directory Structure

```
{OUTPUT_DIR}/
├── reports/{RUN_ID}/
│   ├── consolidated-findings.json (merged 01-07 + 10-14)
│   ├── quarterly-report.md
│   ├── management-letter.md
│   └── appendices/
│       └── evidence-references.json (by finding ID)
│
├── code-runs/{RUN_ID}/
│   ├── backlog.json (Agent 10: deduplicated, prioritized)
│   ├── remediation-plan.json (Agent 10: timeline, owner, effort)
│   └── pr-log.json (Agent 15: opened, merged, escalated)
│
├── remediation/{RUN_ID}/
│   ├── pr-001-fix-secret.md (before/after, regression tests)
│   ├── pr-002-fix-sql-injection.md
│   └── escalations.json (findings that require manual review)
│
└── findings/{RUN_ID}/
    ├── cc1-cc2/ (Agent 07 output)
    ├── cc3-cc9/ (Agent 04 output)
    ├── cc6/ (Agent 01 output)
    ├── cc7/ (Agent 02 output)
    ├── cc8/ (Agent 03 output)
    ├── a1/ (Agent 05 output)
    ├── c1/ (Agent 06 output)
    ├── sast/ (Agent 11 output)
    ├── secrets/ (Agent 12 output)
    ├── deps/ (Agent 13 output)
    └── iac/ (Agent 14 output)
```

---

## Test Execution Model

Each compliance/code agent executes **multiple tests per domain** with:

### Test Result Format

```json
{
  "test_id": "CC6.1-mfa-policy",
  "test_name": "MFA Required for Privileged Access",
  "control": "CC6.1",
  "result": "fail",
  "evidence": {
    "file": "path/to/config.yaml",
    "line": 42,
    "finding": "MFA not enforced in IAM policy"
  },
  "hash": "SHA256-...",
  "continuity": {
    "first_seen": "2026-01-01",
    "recurring": true,
    "last_verified": "2026-04-22"
  }
}
```

### Continuity Tracking (Type II Quality)

- Agents capture evidence **periodically** during assessment period
- Not just at end of period (this is what gives "Type II" quality)
- `continuity` field tracks first detection, recurrence, last verification
- Allows auditor to claim control operated continuously

### Exception Handling

```json
{
  "test_id": "CC6.2-access-review",
  "result": "exception",
  "reason": "IAM API unreachable",
  "severity": "high",
  "resolution": "Retry after API recovery",
  "logged": "2026-04-22T14:30:00Z"
}
```

---

## Pending Implementation (14 Critical Items)

### Infrastructure Layer (Weeks 1-2)

- [ ] **1. Runtime Environment**
  - Orchestrator: Claude Agent SDK (recommended) vs LangGraph vs CrewAI
  - MCPs: GitHub, Filesystem, S3/Postgres, Secrets
  - Environment variables: API tokens, cloud credentials

- [ ] **2. Evidence Store**
  - Decision: S3 Object Lock (recommended) vs Postgres + both
  - Schema: `s3://evidence/{RUN_ID}/{agent}/{test_id}/{evidence_id}.json`
  - Manifest signing on run closure
  - Read API: retrieve evidence by ID, verify hash

- [ ] **3. PII Redaction System**
  - Library: Microsoft Presidio (recommended) vs regex vs AWS Comprehend
  - Patterns: SSN, email, API keys, tokens, credit cards
  - Timing: **BEFORE** evidence touches disk (non-negotiable)
  - Audit logs: track what was redacted

### Control Coverage (Weeks 2-3)

- [ ] **4. Complete Control Catalog**
  - Current: representative tests
  - Missing: CC2.2, CC2.3, CC3.1, CC3.3, CC4.x (Monitoring), CC5.x (Activities), CC6.4, CC6.5, CC7.5, CC9.1, A1.1, A1.3
  - Privacy/PI: ~30 additional tests each
  - Format: 1 test per sub-requirement, clear execution evidence

- [ ] **5. Custom Semgrep Rules**
  - Objective: Map code vulnerabilities to SOC 2 controls
  - Example: `@app.route()` without `audit_log.record()` → CC6.1 evidence
  - Scope: 5-10 rules per code agent (11-14)
  - Validation: test against vulnerable repos

### Operations Stack (Weeks 3-4)

- [ ] **6. Testing Harness**
  - Repos: OWASP Juice Shop, NodeGoat, DVWA, DVCA (IaC)
  - Metrics: recall (finds planted vulns?), precision (% true positives), triage quality, PR quality
  - Benchmark: precision >90% before prod

- [ ] **7. CI/CD Pipeline**
  - Trigger: daily (code agents) + weekly (compliance) + quarterly (report)
  - Platform: GitHub Actions (recommended) vs Jenkins vs Argo vs Temporal
  - Components: secret rotation, failure notifications, audit logs

- [ ] **8. Operational Dashboard**
  - Stack: Grafana + Postgres (recommended) vs Metabase vs custom
  - Views: findings by severity, pending PRs, failing tests, trends, SLA tracking
  - Data source: evidence store JSON + run_summary.json

### Human Process (Weeks 4-5)

- [ ] **9. Human Process Definition**
  - PR review SLA: How long to approve/reject Remediation PRs?
  - Exception workflow: Who approves when test fails but control is compensatory?
  - Executive signature: Who signs report before sending to client?
  - Mid-period failure handling: How to document test failure during Type II assessment?
  - RACI matrix: Roles and responsibilities for audit

- [ ] **10. Remediation Rollout Strategy**
  - Modes: `detect_only` → `suggest` → `open_pr` → `auto_merge` (never for critical)
  - Timeline:
    - Week 1-4: detect_only
    - Week 5-8: suggest (comments on existing PRs)
    - Week 9+: open_pr (low/medium severity only)
    - Critical: **NEVER** automatic, always human-agent pairing

### Commercial Credibility (Weeks 4-5)

- [ ] **11. Report Branding & Design**
  - Format: PDF with corporate logo, fonts, styles
  - Generator: Pandoc vs Typst (recommended) vs WeasyPrint
  - Components: cover (assessment period, scope, version), TOC, pagination, headers/footers
  - Appendices: evidence referenced by ID (client can audit under NDA)

- [ ] **12. Legal Compliance**
  - Disclaimer: reviewed by Colombian lawyer with AICPA experience
  - Standard for: compliance limits, non-reliance, etc.
  - Cost: low, risk if skipped: high

- [ ] **13. NDA & Confidentiality**
  - Standard NDA: for sharing detailed report
  - Protects: control details, open findings
  - Template: legal review required

- [ ] **14. Report Update Policy**
  - Scenario: Client requests report 6 months after period close
  - Decision: Regenerate? Provide last closed period? Archive version?
  - Policy: Define and communicate upfront

---

## Success Metrics by Phase

| Phase | Metric | Target |
|-------|--------|--------|
| **1 (Runtime)** | Evidence store operational, PII redacted, agents can log | ✅ |
| **2 (E2E)** | Agent 12 finds 90%+ real secrets in Juice Shop, precision >95% | ✅ |
| **3 (Operations)** | Pipeline daily without errors, dashboard complete | ✅ |
| **4 (Commercial)** | PDF report generated without manual work, process documented | ✅ |
| **5 (Scale)** | System 100% automated, zero manual toil | ✅ |

---

## Resource Estimate

| Component | Effort | Timeline | Owner |
|-----------|--------|----------|-------|
| Evidence Store | 2 sprints | Week 1-2 | DevOps |
| PII + Runtime | 1 sprint | Week 1 | Backend/Security |
| Agent 12 E2E | 2 sprints | Week 2-3 | AI/ML |
| Harness + Testing | 1.5 sprints | Week 3 | QA/Security |
| CI/CD + Dashboard | 2 sprints | Week 3-4 | DevOps |
| Legal + Branding | 1 sprint | Week 4 | Legal/Product |
| Agents 01-07, 10-14 | 4 sprints | Week 5-8 | AI/ML Team (2-3) |
| Productization | 2 sprints | Week 9-10 | DevOps/Product |

**Total:** ~16 sprints (4 people × 4 weeks) or 8 sprints (8 people × 4 weeks)

---

## Decision Gates (Go/No-Go)

| Decision | Options | Recommendation | Deadline |
|----------|---------|-----------------|----------|
| Runtime | Agent SDK / LangGraph / CrewAI | Agent SDK | Week 1 |
| Evidence Backend | S3 / Postgres / Both | S3 Object Lock | Week 1 |
| PII Tool | Presidio / Custom / AWS Comprehend | Presidio | Week 1 |
| PDF Generator | Pandoc / Typst / WeasyPrint | Typst | Week 4 |
| Dashboard | Grafana / Metabase / Custom | Grafana + Postgres | Week 3 |
| CI/CD | GitHub Actions / Jenkins / Argo / Temporal | GitHub Actions | Week 3 |

---

## Current Status vs. Implementation

| Component | Defined | Implemented | Infrastructure | Operational |
|-----------|---------|-------------|-----------------|------------|
| Agents 00-07 (Compliance) | ✅ | 🟡 Prompts only | ❌ | ❌ |
| Agents 10-15 (Code) | ✅ | 🟡 Prompts only | ❌ | ❌ |
| Findings JSON schema | ✅ | ✅ | ❌ | ❌ |
| Evidence store design | ✅ | ❌ | ⏳ Pending | ❌ |
| PII redaction | ✅ (Design) | ❌ | ⏳ Pending | ❌ |
| Runtime | ✅ (Spec) | ❌ | ⏳ Pending | ❌ |
| Output directories | ✅ | ✅ | 🟡 Manual | 🟡 |
| Control catalog | 🟡 (Partial) | 🟡 (Partial) | ❌ | ❌ |
| CI/CD pipeline | ✅ (Spec) | ❌ | ⏳ Pending | ❌ |
| Dashboard | ✅ (Spec) | ❌ | ⏳ Pending | ❌ |
| Report branding | ✅ (Spec) | ❌ | ⏳ Pending | ❌ |
| Legal/NDA | ✅ (Spec) | 🟡 Draft | ⏳ Pending | ❌ |

**Legend:** ✅ Complete, 🟡 Partial, ❌ Missing, ⏳ Blocked on infrastructure

---

**Next Immediate Action:** Decide on runtime environment and evidence store backend.
