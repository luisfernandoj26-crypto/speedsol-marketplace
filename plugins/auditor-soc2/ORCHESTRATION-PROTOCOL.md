# SOC 2 Audit Orchestration Protocol

**Purpose:** Define how all 15 agents coordinate, communicate, and produce consolidated output  
**Owner:** Agent 00 (Compliance) + Agent 10 (Code)  
**Last Updated:** 2026-04-22

---

## Executive Summary

```
User Request
    ↓
┌─────────────────────────────────────────────┐
│ Agent 00: Compliance Orchestrator           │
│ - Parses user request                       │
│ - Loads config + controls.yaml              │
│ - Determines scope (which compliance domains)
│ - Invokes Agents 01-07 in PARALLEL         │
│ - Waits for all to complete                │
│ - Consolidates findings                    │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Agents 01-07 (Parallel Execution)          │
│ 01: Access Control (CC6)                   │
│ 02: Operations (CC7)                       │
│ 03: Change Management (CC8)                │
│ 04: Risk & Vendor (CC3, CC9)               │
│ 05: Availability (A1)                      │
│ 06: Confidentiality (C1)                   │
│ 07: Governance (CC1-CC2)                   │
│                                            │
│ Each agent:                                │
│ - Reads control from Agent 00 message      │
│ - Executes tests for that domain           │
│ - Produces: findings.json, evidence/*, run_summary.json
│ - Reports back to Agent 00                 │
└─────────────────────────────────────────────┘
    ↓ (concurrent)
┌─────────────────────────────────────────────┐
│ Agent 10: Code Orchestrator                │
│ - Parses code findings request             │
│ - Determines scope (which code patterns)   │
│ - Invokes Agents 11-14 in PARALLEL        │
│ - Waits for all to complete                │
│ - Deduplicates findings                    │
│ - Prioritizes by severity + reachability   │
│ - Creates remediation backlog              │
│ - Invokes Agent 15 with prioritized list  │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Agents 11-14 (Parallel Execution)          │
│ 11: SAST                                   │
│ 12: Secrets & Crypto                       │
│ 13: Dependencies & License                 │
│ 14: IaC & Config                          │
│                                            │
│ Each agent:                                │
│ - Reads code analysis request              │
│ - Scans codebase for violations            │
│ - Classifies findings (confirmed/FP/etc)  │
│ - Produces: findings.json, evidence/*, run_summary.json
│ - Reports back to Agent 10                 │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Agent 15: Remediation                      │
│ - Receives prioritized backlog from 10     │
│ - For each low/medium finding:             │
│   - Generate fix code                      │
│   - Create regression test                 │
│   - Open GitHub PR                         │
│   - Log result (success/blocked)           │
│ - For high/critical:                       │
│   - Flag for manual review                 │
│ - Produces: PRs + remediation-log.json    │
└─────────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────────┐
│ Agent 00: Final Consolidation              │
│ - Reads all findings from 01-07            │
│ - Merges with code findings from 10        │
│ - Generates final report:                  │
│   - Consolidated findings by severity      │
│   - Risk matrix (probability × impact)     │
│   - Compliance % by area                   │
│   - Recommendations prioritized            │
│   - Management letter                      │
│   - Appendices (evidence refs)             │
│ - Saves to: /reports/{RUN_ID}/             │
└─────────────────────────────────────────────┘
    ↓
Output Files:
  /findings/{RUN_ID}/cc6/*.json
  /findings/{RUN_ID}/cc7/*.json
  ... (one per domain)
  /findings/{RUN_ID}/sast/*.json
  /findings/{RUN_ID}/secrets/*.json
  ... (one per code agent)
  /evidence/{RUN_ID}/**/*.json (with SHA-256 hashes)
  /reports/{RUN_ID}/consolidated-findings.json
  /reports/{RUN_ID}/quarterly-report.md
  /remediation/{RUN_ID}/pr-*.md
```

---

## 1. Agent 00: Compliance Orchestrator

### Responsibilities

```
PRIMARY:
  1. Parse audit request (scope, period, systems)
  2. Load configuration (controls.yaml, compliance-rules.md)
  3. Determine which compliance agents to invoke (01-07)
  4. Invoke agents in parallel with proper context
  5. Wait for all agents to report
  6. Consolidate findings
  7. Generate quarterly report

SECONDARY:
  - Coordinate with Agent 10 on scheduling
  - Receive code findings from Agent 10
  - Merge compliance + code findings
  - Ensure no duplicate findings across domains
  - Calculate overall compliance score
```

### Input (From User / Upstream System)

```json
{
  "request_type": "quarterly_audit",
  "run_id": "audit-2026-04-22-Q2",
  "period": {
    "start": "2026-04-01",
    "end": "2026-06-30"
  },
  "scope": {
    "systems": ["production", "staging"],
    "domains": ["all"],  // or specific: ["CC6", "CC7", "A1"]
    "code_analysis": true
  },
  "config": {
    "output_dir": "/results/audit-2026-04-22-Q2",
    "evidence_store": "s3://soc2-evidence/",
    "evidence_bucket": "soc2-evidence-{account}",
    "pii_redaction": true
  }
}
```

### Execution Flow

```
1. INITIALIZE
   ├─ Parse request.run_id → save to {OUTPUT_DIR}
   ├─ Load config/controls.yaml
   ├─ Load config/compliance-rules.md
   ├─ Load config/risk-assessment.md
   └─ Create {OUTPUT_DIR}/compliance-agents-status.json (for tracking)

2. INVOKE COMPLIANCE AGENTS (01-07) IN PARALLEL
   ├─ For each agent in [01, 02, 03, 04, 05, 06, 07]:
   │  ├─ Generate agent-specific message:
   │  │   {
   │  │     "agent_id": "01",
   │  │     "task": "audit_domain",
   │  │     "domain": "CC6",
   │  │     "controls": ["CC6.1", "CC6.2", ...],
   │  │     "run_id": "audit-2026-04-22-Q2",
   │  │     "output_dir": "/findings/cc6/",
   │  │     "evidence_store": "s3://...",
   │  │     "period": {start, end}
   │  │   }
   │  └─ Invoke agent (timeout: 300s per agent)
   │
   └─ Store responses in parallel queue

3. CONSOLIDATE COMPLIANCE FINDINGS
   ├─ Read all findings/{RUN_ID}/*/*.json files
   ├─ Merge into single consolidated-findings.json
   ├─ Deduplicate by (control, location, severity)
   ├─ Sort by severity (critical → high → medium → low)
   └─ Save to {OUTPUT_DIR}/consolidated-compliance-findings.json

4. WAIT FOR CODE FINDINGS (FROM AGENT 10)
   ├─ Poll /code-runs/{RUN_ID}/backlog.json (timeout: 600s)
   ├─ When available, merge with compliance findings
   └─ Update /reports/{RUN_ID}/all-findings.json

5. GENERATE QUARTERLY REPORT
   ├─ Create report structure:
   │   {
   │     "run_id": "audit-2026-04-22-Q2",
   │     "period": {start, end},
   │     "generated_at": "2026-06-30T17:00:00Z",
   │     "compliance_score": 87.5,
   │     "findings": {
   │       "critical": [{...}, ...],
   │       "high": [{...}, ...],
   │       "medium": [{...}, ...],
   │       "low": [{...}, ...]
   │     },
   │     "compliance_by_area": {
   │       "CC6": 92,
   │       "CC7": 85,
   │       ...
   │     },
   │     "risk_matrix": {matrix data},
   │     "recommendations": [{...}, ...],
   │     "evidence_references": {
   │       "finding_id_1": "evidence_id_abc123",
   │       ...
   │     }
   │   }
   │
   ├─ Generate management letter (markdown)
   ├─ Create appendices with evidence references
   └─ Save all to /reports/{RUN_ID}/

6. NOTIFY & ARCHIVE
   ├─ Log completion to memory
   ├─ Copy evidence to archive
   └─ Report success
```

### Output (To Users / Client)

```
/reports/{RUN_ID}/
├── consolidated-findings.json (master list of all findings)
├── quarterly-report.md (executive summary)
├── management-letter.md (detailed recommendations)
├── risk-analysis.json (probability × impact matrix)
├── compliance-by-area.json (% score per domain)
└── appendices/
    ├── evidence-references.json (finding ID → evidence ID mapping)
    └── control-mapping.json (finding → control mapping)
```

### Key Variables (From Environment)

```bash
ANTHROPIC_API_KEY              # Token for Agent SDK
GITHUB_TOKEN                   # For remediation PRs
AWS_ACCESS_KEY_ID             # S3 evidence store
AWS_SECRET_ACCESS_KEY         # S3 evidence store
AWS_REGION                     # us-east-1 recommended
S3_EVIDENCE_BUCKET            # soc2-evidence-{account}
EVIDENCE_STORE_PATH           # s3://bucket/
OUTPUT_BASE_DIR               # /results/ or /auditoria/
PII_REDACTION_ENABLED         # true/false
```

---

## 2. Agent 10: Code Orchestrator

### Responsibilities

```
PRIMARY:
  1. Parse code analysis request
  2. Determine scope (which code patterns to scan)
  3. Invoke code agents in parallel (11-14)
  4. Wait for all agents to report
  5. Deduplicate findings (SAST + Secrets + Deps + IaC)
  6. Prioritize by severity + reachability
  7. Create remediation backlog + plan
  8. Invoke Agent 15 (Remediation) with prioritized list

SECONDARY:
  - Coordinate with Agent 00 on timing
  - Report progress to Agent 00
  - Handle failures gracefully (escalate to manual review)
  - Track remediation status
```

### Input (From Agent 00 / Upstream System)

```json
{
  "request_type": "code_analysis",
  "run_id": "audit-2026-04-22-Q2",
  "scope": {
    "repositories": ["main-app", "backend-api"],
    "languages": ["python", "typescript", "go"],
    "agents": [11, 12, 13, 14],  // SAST, Secrets, Deps, IaC
    "remediation_mode": "open_pr"  // detect_only | suggest | open_pr | auto_merge
  },
  "config": {
    "output_dir": "/code-runs/{RUN_ID}/",
    "evidence_store": "s3://soc2-evidence/",
    "min_precision": 0.90,  // Reject findings with low precision
    "remediation_enabled": true
  }
}
```

### Execution Flow

```
1. INITIALIZE
   ├─ Parse run_id
   ├─ Create /code-runs/{RUN_ID}/ directory
   ├─ Create status-tracking.json
   └─ Load code policies from config/

2. INVOKE CODE AGENTS (11-14) IN PARALLEL
   ├─ For each agent in [11, 12, 13, 14]:
   │  ├─ Generate agent-specific message:
   │  │   {
   │  │     "agent_id": "12",
   │  │     "task": "scan_codebase",
   │  │     "pattern_type": "secrets",
   │  │     "run_id": "audit-2026-04-22-Q2",
   │  │     "output_dir": "/findings/secrets/",
   │  │     "repositories": ["main-app", "backend-api"],
   │  │     "min_precision": 0.90
   │  │   }
   │  └─ Invoke agent (timeout: 600s per agent)
   │
   └─ Store responses in parallel queue

3. CONSOLIDATE CODE FINDINGS
   ├─ Read all findings/sast/*.json, findings/secrets/*.json, etc.
   ├─ Merge into single consolidated-code-findings.json
   ├─ DEDUPLICATE:
   │  ├─ Same file + line + type → keep highest severity, collapse duplicates
   │  ├─ Similar locations (within 5 lines) → investigate, possibly merge
   │  └─ Track deduplication in metadata
   ├─ FILTER by min_precision (default: 0.90)
   │  ├─ Remove false positives
   │  ├─ Keep confirmed_vulnerable + context_dependent
   │  └─ Log rejected findings
   └─ Save to /code-runs/{RUN_ID}/consolidated-code-findings.json

4. PRIORITIZE & CREATE BACKLOG
   ├─ For each finding, calculate priority score:
   │   priority = severity × reachability × exposure
   │   where:
   │     severity: [1=low, 2=medium, 3=high, 4=critical]
   │     reachability: [1=unreachable, 2=dev-only, 3=prod-accessible, 4=externally-exposed]
   │     exposure: [1=internal, 2=partner, 3=public]
   │
   ├─ Sort by priority (descending)
   ├─ Group by severity for SLA tracking:
   │   - Critical: 24h SLA
   │   - High: 7-day SLA
   │   - Medium: 30-day SLA
   │   - Low: next sprint
   │
   └─ Save backlog to /code-runs/{RUN_ID}/backlog.json:
       {
         "total_findings": 45,
         "by_severity": {
           "critical": 3,
           "high": 8,
           "medium": 18,
           "low": 16
         },
         "findings": [
           {
             "id": "FINDING-001",
             "agent_id": 12,
             "type": "hardcoded_secret",
             "severity": "critical",
             "location": "src/config.py:42",
             "priority_score": 48,
             "sla_deadline": "2026-04-23T14:30:00Z",
             "remediation_effort": "low"
           },
           ...
         ]
       }

5. CREATE REMEDIATION PLAN
   ├─ For each finding, determine:
   │   ├─ Fix complexity: low/medium/high
   │   ├─ Regression test needed: yes/no
   │   ├─ Manual review required: yes/no
   │   ├─ Estimated effort (hours)
   │   └─ Owner team
   │
   └─ Save plan to /code-runs/{RUN_ID}/remediation-plan.json:
       {
         "total_estimated_hours": 24,
         "by_complexity": {
           "low": {count: 20, hours: 2},
           "medium": {count: 15, hours: 15},
           "high": {count: 10, hours: 40}
         },
         "timeline": {
           "week_1": ["FINDING-001", "FINDING-002"],
           "week_2": ["FINDING-003", ...],
           ...
         }
       }

6. INVOKE REMEDIATION AGENT (15)
   ├─ Generate message:
   │   {
   │     "agent_id": "15",
   │     "task": "remediate",
   │     "backlog": /code-runs/{RUN_ID}/backlog.json,
   │     "remediation_mode": "open_pr",
   │     "run_id": "audit-2026-04-22-Q2",
   │     "output_dir": "/remediation/{RUN_ID}/"
   │   }
   │
   └─ Invoke Agent 15 (timeout: 1200s - allow time for PR creation)

7. TRACK REMEDIATION STATUS
   ├─ Poll /remediation/{RUN_ID}/remediation-log.json
   ├─ Update status for each finding:
   │   - pr_opened: yes/no
   │   - pr_number: "123" (if yes)
   │   - blocked_reason: "..." (if no)
   │   - escalation_required: yes/no
   │
   └─ Save final status to /code-runs/{RUN_ID}/final-status.json

8. REPORT TO AGENT 00
   ├─ Create summary message:
   │   {
   │     "status": "complete",
   │     "findings": 45,
   │     "prs_opened": 20,
   │     "escalations": 5,
   │     "remediation_backlog": "/code-runs/{RUN_ID}/backlog.json"
   │   }
   │
   └─ Notify Agent 00 to proceed with final consolidation
```

### Output (To Agent 00 / Users)

```
/code-runs/{RUN_ID}/
├── consolidated-code-findings.json (all code findings merged)
├── backlog.json (prioritized list for remediation)
├── remediation-plan.json (timeline + effort estimates)
└── final-status.json (PR results + escalations)

/remediation/{RUN_ID}/
├── pr-001-fix-secret.md (before/after, tests, commit message)
├── pr-002-fix-sql-injection.md
├── remediation-log.json (success/blocked results)
└── escalations.json (findings requiring manual review)
```

---

## 3. Inter-Agent Communication Protocol

### Message Format (Standard for All Agents)

```json
{
  "orchestrator_id": "00",  // or "10"
  "target_agent_id": "01",
  "task_id": "task-abc123",
  "run_id": "audit-2026-04-22-Q2",
  "timestamp": "2026-04-22T14:30:00Z",
  
  "instructions": {
    "action": "audit_domain",
    "domain": "CC6",
    "controls": ["CC6.1", "CC6.2", "CC6.3"],
    "scope": {
      "systems": ["production"],
      "period": {
        "start": "2026-04-01",
        "end": "2026-06-30"
      }
    }
  },
  
  "context": {
    "output_dir": "/findings/cc6/",
    "evidence_store": "s3://soc2-evidence/audit-2026-04-22-Q2/01/",
    "pii_redaction": true,
    "config": {
      "compliance_rules_file": "config/compliance-rules.md",
      "controls_file": "config/controls.yaml",
      "risk_assessment_file": "config/risk-assessment.md"
    }
  },
  
  "expected_outputs": {
    "findings_json": "{output_dir}/findings.json",
    "run_summary_json": "{output_dir}/run_summary.json",
    "evidence_directory": "{evidence_store}"
  },
  
  "timeout": 300,
  "retry_policy": "exponential_backoff"
}
```

### Response Format (Standard from All Agents)

```json
{
  "agent_id": "01",
  "orchestrator_id": "00",
  "task_id": "task-abc123",
  "run_id": "audit-2026-04-22-Q2",
  "timestamp": "2026-04-22T14:35:42Z",
  
  "status": "success",  // or "failed" or "partial"
  "duration_seconds": 342,
  
  "results": {
    "tests_executed": 15,
    "findings_count": {
      "critical": 0,
      "high": 2,
      "medium": 3,
      "low": 1
    },
    "evidence_artifacts": {
      "count": 12,
      "total_size_bytes": 102400,
      "hashes": ["sha256:abc123", ...]
    },
    "continuity_checks": {
      "type_ii_eligible": true,
      "first_detection": "2026-04-01T08:00:00Z",
      "recurring": true,
      "last_verification": "2026-06-30T17:00:00Z"
    }
  },
  
  "output_files": {
    "findings_json": "/findings/cc6/findings.json",
    "run_summary_json": "/findings/cc6/run_summary.json",
    "evidence_directory": "s3://soc2-evidence/audit-2026-04-22-Q2/01/"
  },
  
  "errors": [],  // If status is "failed" or "partial"
  "warnings": []
}
```

---

## 4. Timing & Orchestration Rules

### Parallel vs Sequential

```
PARALLEL (All agents simultaneously):
├─ Compliance Agents 01-07 (start together, wait for all)
├─ Code Agents 11-14 (start together, wait for all)
└─ Max concurrent: 14 agents

SEQUENTIAL (One after another):
├─ Compliance orchestration (01-07) → wait → consolidate → report
├─ Code orchestration (11-14) → wait → consolidate → remediate
└─ Final consolidation (Agent 00)

WAIT STRATEGY:
├─ Each orchestrator waits for ALL agents to complete
├─ Timeout per agent: 300s for compliance, 600s for code
├─ If any agent times out: mark as failed, continue without it
├─ Report which agents failed in final output
```

### Error Handling

```
If Agent 01-07 fails:
  ├─ Log error to evidence_store
  ├─ Mark control as "exception" (not pass/fail)
  ├─ Include exception reason in findings
  └─ Continue with other agents (resilient execution)

If Agent 11-14 fails:
  ├─ Log error to evidence_store
  ├─ Mark finding class as "unchecked"
  ├─ Escalate to manual review
  └─ Continue with other agents

If Agent 15 (Remediation) fails:
  ├─ Log error to remediation-log.json
  ├─ Flag finding as "remediation_failed"
  ├─ Escalate to human team
  └─ Continue with remaining findings
```

---

## 5. Shared State & Environment Variables

### Shared Variables (All Agents Access)

```bash
# Run identity
RUN_ID=audit-2026-04-22-Q2
PERIOD_START=2026-04-01
PERIOD_END=2026-06-30

# Storage paths
OUTPUT_BASE_DIR=/results/
FINDINGS_DIR=/findings/{RUN_ID}/
EVIDENCE_STORE=s3://soc2-evidence/
S3_BUCKET=soc2-evidence-{account}
EVIDENCE_PATH=s3://soc2-evidence/{RUN_ID}/{agent_id}/

# Configuration files (all agents load same files)
CONTROLS_FILE=config/controls.yaml
COMPLIANCE_RULES_FILE=config/compliance-rules.md
RISK_ASSESSMENT_FILE=config/risk-assessment.md

# Feature flags
PII_REDACTION_ENABLED=true
TYPE_II_EVIDENCE_MODE=continuous
EVIDENCE_HASH_ALGORITHM=sha256
EVIDENCE_RETENTION_DAYS=90

# Credentials (from environment, never hardcoded)
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
GITHUB_TOKEN=${GITHUB_TOKEN}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_REGION=us-east-1
```

### Shared State Files (Written & Read by All)

```
{OUTPUT_BASE_DIR}/{RUN_ID}/
├── execution-status.json
│   {
│     "run_id": "...",
│     "started_at": "...",
│     "agents_completed": ["01", "02"],
│     "agents_pending": ["03", "04", ...],
│     "agents_failed": [],
│     "stage": "compliance_agents_running"
│   }
│
├── consolidated-findings.json (written by Agent 00)
│   {
│     "total": 45,
│     "critical": 3,
│     "high": 10,
│     "findings": [...]
│   }
│
└── evidence-index.json (manifest of all evidence)
    {
      "run_id": "...",
      "evidence_items": [
        {
          "id": "evidence-abc123",
          "agent_id": "01",
          "test_id": "CC6.1",
          "hash": "sha256:...",
          "location": "s3://..."
        }
      ]
    }
```

---

## 6. Execution Checklist for Orchestrators

### Before Starting Agents

- [ ] Validate run_id format
- [ ] Create output directories
- [ ] Load all configuration files
- [ ] Validate period dates
- [ ] Check S3 bucket access
- [ ] Verify API tokens are set
- [ ] Create execution-status.json

### While Agents Are Running

- [ ] Poll agent responses every 10 seconds
- [ ] Update execution-status.json with progress
- [ ] Log any warnings/errors
- [ ] Prepare for timeout handling

### After All Agents Complete

- [ ] Verify all required files exist
- [ ] Consolidate findings
- [ ] Calculate compliance scores
- [ ] Generate reports
- [ ] Archive evidence
- [ ] Notify stakeholders
- [ ] Clean up temporary files

### Error Recovery

- [ ] If agent times out: mark as failed, continue
- [ ] If output file missing: request re-execution
- [ ] If evidence corrupted: escalate + manual review
- [ ] If PII detected in output: quarantine file

---

## 7. Key Success Factors

1. **Clarity of Responsibility**
   - Agent 00: orchestrate compliance (01-07)
   - Agent 10: orchestrate code (11-14)
   - Each specialized agent (01-07, 11-14): execute tests for domain
   - Agent 15: fix findings from Agent 10

2. **Communication Protocol**
   - Standard message format (above)
   - Standard response format (above)
   - Clear expected outputs
   - Timeout handling

3. **Resilience**
   - Parallel execution maximizes throughput
   - Agent failure doesn't stop others
   - All evidence stored immutably
   - Detailed error logs for debugging

4. **Auditability**
   - Every action logged with timestamp
   - Evidence chain of custody maintained
   - PII redaction documented
   - All findings traceable to original source

5. **Type II Quality**
   - Continuous evidence capture (not point-in-time)
   - Continuity tracking built into findings
   - Exception handling for failures mid-period
   - Management letter documents control operation

---

**This protocol ensures all 15 agents work as a unified auditing system, not isolated agents.**
