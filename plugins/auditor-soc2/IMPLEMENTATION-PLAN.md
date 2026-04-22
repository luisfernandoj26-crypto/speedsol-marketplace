# auditor-soc2 Implementation Plan

**Based on:** agent-deliverables-and-pending-work.md  
**Phase:** MVP → Production (5 phases, 16 sprints)  
**Owner:** Engineering team + DevOps + Legal  

---

## Phase 1: Infrastructure Minimal Viable (Week 1)

### 1.1 Runtime: Claude Agent SDK Setup

**Task:** Configure Agent SDK with MCPs and environment

```bash
# 1. Install dependencies
pip install anthropic

# 2. Configure .env
cat > .env << EOF
ANTHROPIC_API_KEY=sk-ant-...
GITHUB_TOKEN=ghp_...
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
S3_EVIDENCE_BUCKET=soc2-evidence-{account}
EOF

# 3. Create orchestrator script
cat > run_audit.py << 'EOF'
import asyncio
from anthropic import AsyncAnthropic

async def main():
    client = AsyncAnthropic()
    # Agent invocation logic here
    pass

if __name__ == "__main__":
    asyncio.run(main())
EOF

# 4. Test basic agent
python run_audit.py --test --agent 12 --input "secrets test"
```

**Deliverable:** Working Agent SDK with GitHub + S3 MCPs connected

---

### 1.2 Evidence Store: S3 Object Lock Setup

**Task:** Create immutable evidence storage with Object Lock

```bash
# 1. Create S3 bucket with Object Lock
aws s3api create-bucket \
  --bucket soc2-evidence-$(aws sts get-caller-identity --query Account --output text) \
  --region us-east-1

# 2. Enable Object Lock
aws s3api put-object-lock-configuration \
  --bucket soc2-evidence-{account} \
  --object-lock-configuration '{
    "ObjectLockEnabled": "Enabled",
    "Rule": {
      "DefaultRetention": {
        "Mode": "COMPLIANCE",
        "Days": 90
      }
    }
  }'

# 3. Enable versioning
aws s3api put-bucket-versioning \
  --bucket soc2-evidence-{account} \
  --versioning-configuration Status=Enabled

# 4. Enable encryption
aws s3api put-bucket-encryption \
  --bucket soc2-evidence-{account} \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "aws:kms",
        "KMSMasterKeyID": "arn:aws:kms:us-east-1:123456789:key/..."
      }
    }]
  }'

# 5. Test
aws s3api put-object \
  --bucket soc2-evidence-{account} \
  --key "test-run/evidence-001.json" \
  --body test.json \
  --object-lock-mode COMPLIANCE \
  --object-lock-retain-until-date 2026-07-22T00:00:00Z
```

**Deliverable:** S3 bucket operational with Object Lock, KMS encryption, versioning

---

### 1.3 PII Redaction: Presidio Integration

**Task:** Set up automated PII redaction before evidence storage

```bash
# 1. Install Presidio
pip install presidio-analyzer presidio-anonymizer

# 2. Create redaction module
cat > redaction.py << 'EOF'
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine

def redact_evidence(text: str) -> tuple[str, dict]:
    """
    Redact PII from evidence. Returns redacted text + log of what was redacted.
    """
    analyzer = AnalyzerEngine()
    anonymizer = AnonymizerEngine()
    
    results = analyzer.analyze(text=text, language="en")
    redacted = anonymizer.anonymize(text=text, analyzer_results=results)
    
    audit_log = {
        "patterns_detected": [r.entity_type for r in results],
        "items_redacted": len(results),
        "timestamp": datetime.now().isoformat()
    }
    
    return redacted.text, audit_log

# Usage in agent
evidence_raw = read_file(path)
evidence_clean, audit = redact_evidence(evidence_raw)
store_evidence(evidence_clean)
log_redaction(audit)
EOF

# 3. Test redaction
python -c "
from redaction import redact_evidence
text = 'User john@example.com with SSN 123-45-6789 accessed system'
clean, log = redact_evidence(text)
print(f'Original: {text}')
print(f'Redacted: {clean}')
print(f'Log: {log}')
"
```

**Deliverable:** Presidio configured, redaction working, audit logging operational

---

## Phase 2: E2E Validation (Week 2)

### 2.1 Agent 12 (Secrets & Crypto) - Complete Cycle

**Task:** One agent from detection → findings → evidence → validation

```bash
# 1. Configure Agent 12 (Secrets & Crypto)
# File: plugins/auditor-soc2/agents/12-secrets-crypto.md
# Update with:
#   - Prompt for secret detection
#   - Integration with evidence store
#   - Findings JSON schema
#   - PII redaction steps

# 2. Test against vulnerable repo
git clone https://github.com/OWASP/juice-shop.git test-repo

# 3. Run Agent 12
python run_audit.py \
  --agent 12 \
  --repo test-repo \
  --run-id test-2026-04-22

# 4. Validate outputs
ls -la findings/secrets/
ls -la evidence/test-2026-04-22/12/

# 5. Check findings JSON format
jq . findings/secrets/findings.json | head -50

# 6. Verify SHA-256 hashes
find evidence/ -name "*.json" -exec sha256sum {} \;

# 7. Measure metrics
python analyze_findings.py \
  --repo juice-shop \
  --findings findings/secrets/findings.json \
  --metrics recall precision false_positive_rate
```

**Expected Output:**
```
✅ Agent 12 detects 90%+ of planted secrets in Juice Shop
✅ Findings JSON valid and complete
✅ Evidence stored with SHA-256 hashes
✅ PII redaction working (no real emails/tokens in findings)
✅ run_summary.json generated with metrics
```

**Deliverable:** Agent 12 operational end-to-end

---

### 2.2 Testing Harness

**Task:** Validate agents against known-vulnerable repositories

```bash
# 1. Clone test repositories
git clone https://github.com/OWASP/juice-shop.git
git clone https://github.com/OWASP/NodeGoat.git
git clone https://github.com/digininja/DVWA.git
git clone https://github.com/ermetic/DVCA.git

# 2. Create test suite
cat > test_harness.py << 'EOF'
import subprocess
import json

test_cases = [
    {
        "agent": 12,
        "repo": "juice-shop",
        "expected_minimum_findings": 50,
        "metrics": {
            "recall": 0.90,
            "precision": 0.95,
            "false_positive_rate": 0.05
        }
    },
    {
        "agent": 11,
        "repo": "NodeGoat",
        "expected_minimum_findings": 20,
        "metrics": {
            "recall": 0.85,
            "precision": 0.90
        }
    }
]

for test in test_cases:
    result = subprocess.run([
        "python", "run_audit.py",
        "--agent", str(test["agent"]),
        "--repo", test["repo"]
    ], capture_output=True)
    
    findings = json.loads(result.stdout)
    passed = validate_findings(findings, test["metrics"])
    print(f"Agent {test['agent']} on {test['repo']}: {'PASS' if passed else 'FAIL'}")
EOF

# 3. Run test harness
python test_harness.py
```

**Deliverable:** Test harness validates agent quality (precision >90%, recall >85%)

---

## Phase 3: Operational System (Weeks 3-4)

### 3.1 Complete Control Catalog

**Task:** Expand from 6 domains to full TSC coverage

```yaml
Current (6 domains):
  - CC6: Access Control
  - CC7: Operations
  - CC8: Change Management
  - A1: Availability
  - C1: Confidentiality
  - CC1-CC2: Governance

Add Missing (9 domains):
  - CC2.2-CC2.3: Responsibilities & competence
  - CC3.1, CC3.3: Authorization & segregation
  - CC4.x: Monitoring Activities (5 criteria)
  - CC5.x: Control Activities (5 criteria)
  - CC6.4-CC6.5: Access over assets & removal
  - CC7.5: Incident detection
  - CC9.1: Change control

Implementation:
  1. For each missing control: create agents/XX-{control-name}.md
  2. Define test procedures (what to check)
  3. List evidence requirements
  4. Map to compliance rules
  5. Test against real systems
  6. Validate findings format
```

**Deliverable:** agents/ contains 00-15 with full TSC coverage

---

### 3.2 CI/CD Pipeline

**Task:** Automate agent execution with GitHub Actions

```yaml
# File: .github/workflows/soc2-audit.yml
name: SOC 2 Compliance Audit

on:
  schedule:
    - cron: "0 9 * * *"  # Daily at 9 AM
  workflow_dispatch:

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run compliance agents
        run: |
          python run_audit.py \
            --agents 01-07 \
            --parallel \
            --output findings/
      
      - name: Run code agents
        run: |
          python run_audit.py \
            --agents 10-15 \
            --parallel \
            --output findings/
      
      - name: Consolidate findings (Agent 00)
        run: |
          python run_audit.py \
            --agent 00 \
            --input findings/ \
            --output reports/
      
      - name: Upload to S3
        run: |
          aws s3 sync reports/ \
            s3://soc2-evidence/$(date +%Y-%m-%d)/reports/
      
      - name: Notify on critical findings
        if: failure()
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: '⚠️ Critical findings detected in SOC 2 audit'
            })

  remediate:
    needs: audit
    runs-on: ubuntu-latest
    if: success()
    steps:
      - name: Trigger Remediation Agent
        run: |
          python run_audit.py \
            --agent 15 \
            --mode open_pr \
            --severity low,medium
```

**Deliverable:** CI/CD runs daily, agents execute in parallel, findings consolidated

---

### 3.3 Operational Dashboard

**Task:** Visualize findings and compliance trends

```bash
# 1. Deploy Grafana + Postgres
docker-compose up -d grafana postgres

# 2. Create Postgres schema
psql << EOF
CREATE TABLE findings (
  id UUID PRIMARY KEY,
  run_id VARCHAR(50),
  agent_id VARCHAR(10),
  control VARCHAR(50),
  severity VARCHAR(20),  -- critical/high/medium/low
  status VARCHAR(20),    -- open/in-progress/closed
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

CREATE TABLE compliance_score (
  id SERIAL PRIMARY KEY,
  run_id VARCHAR(50),
  control VARCHAR(50),
  passed INT,
  failed INT,
  score DECIMAL(5,2),
  timestamp TIMESTAMP
);
EOF

# 3. Create Grafana dashboard
# Query 1: Findings by severity (pie chart)
# Query 2: Compliance trend (line chart)
# Query 3: Open findings by agent (bar chart)
# Query 4: SLA tracking (green/yellow/red)
```

**Deliverable:** Dashboard shows findings, trends, SLA status

---

## Phase 4: Commercial Credibility (Weeks 4-5)

### 4.1 Legal & Disclaimers

**Task:** Get legal review, create standard NDA

```markdown
# Disclaimer (Template)

This SOC 2 audit report ("Report") is prepared by Speed Solutions S.A.S. based on
audit procedures performed during the assessment period {DATES}.

**Scope Limitations:**
- Report covers {SYSTEMS} only
- Third-party services assessed by reference to provider SOC 2 reports
- Point-in-time assessment, not continuous monitoring guarantee

**Non-Reliance:**
This report is provided for {CLIENT} internal use only. Speed Solutions makes
no warranty regarding the completeness or accuracy of this assessment.

**Use Restrictions:**
Recipients may not distribute this report without written consent. Any public
reference to this report must be pre-approved by Speed Solutions.

**Limitation of Liability:**
In no event shall Speed Solutions be liable for damages exceeding the fees
paid for this engagement ($X).
```

**Deliverable:** Disclaimer reviewed by Colombian lawyer with AICPA experience

---

### 4.2 Report Branding

**Task:** Generate professional PDF reports

```bash
# 1. Install Typst (PDF generator)
curl --proto '=https' --tlsv1.2 -sSLf https://taas.typst.sh/install.sh | sh

# 2. Create report template
cat > report_template.typ << 'EOF'
#let report(
  title: "",
  date: "",
  findings: (),
) = {
  
  // Cover page
  page(
    align(center + horizon, {
      image("logo.png", width: 100pt)
      v(2em)
      text(size: 28pt, weight: "bold")[SOC 2 Type II Audit Report]
      v(1em)
      text(size: 14pt)[Assessment Period: #date]
    })
  )
  
  // Table of contents
  outline()
  
  // Findings by severity
  heading("Critical Findings")
  for finding in findings.filter(s => s.severity == "critical") {
    [- #finding.title: #finding.description]
  }
  
  // Compliance scores
  table(
    columns: (1fr, 1fr),
    align: left,
    [Control], [Compliance %],
    ...
  )
}
EOF

# 3. Generate report
typst compile report.typ report.pdf
```

**Deliverable:** Professional PDF reports with logo, typography, pagination

---

### 4.3 Remediation Rollout Strategy

**Task:** Define progressive automation of fixes

```yaml
Week 1-4: detect_only
  - Agent 15 runs
  - Identifies findings
  - Creates issues in tracking system
  - Does NOT open PRs
  - Review: manual triage of all findings

Week 5-8: suggest
  - Agent 15 comments on existing PRs
  - Suggests fixes without pushing
  - Example: "This endpoint missing audit log (CC6.1)"
  - Review: developers incorporate into their work

Week 9+: open_pr (low/medium only)
  - Agent 15 creates PRs for low/medium severity
  - Includes regression tests
  - Includes before/after evidence
  - Review: standard code review process
  - Critical: NEVER automatic

Critical (always):
  - Agent 15 flags for manual review
  - Security team + developer pair-program fix
  - Proof of concept testing required
  - Executive approval for deploy
```

**Deliverable:** Remediation policy documented, progressive rollout ready

---

## Phase 5: Scale & Productization (Weeks 6+)

### 5.1 All Agents (01-15)

**Task:** Deploy remaining agents with their specific procedures

```bash
# For each agent 01-07:
for agent_id in 01 02 03 04 05 06 07; do
  echo "Deploying Agent $agent_id..."
  # Copy template → agents/{agent_id}-{domain}.md
  # Customize test procedures
  # Validate findings format
  # Test against real system
  python run_audit.py --agent $agent_id --test
done

# For each agent 10-14:
for agent_id in 10 11 13 14; do
  echo "Deploying Agent $agent_id..."
  # Similar deployment
done
```

**Deliverable:** All 15 agents operational

---

### 5.2 Report Automation

**Task:** Quarterly reports generated automatically

```bash
# 1. Create scheduled job
aws events put-rule \
  --name soc2-quarterly-report \
  --schedule-expression "cron(0 9 ? 1/3 MON *)"  # Every 3 months, Monday 9 AM

# 2. Deploy consolidation logic
# Agent 00 reads all findings from quarter
# Generates executive summary
# Compiles PDF report
# Sends to stakeholders

# 3. Archive previous reports
aws s3 sync reports/ s3://soc2-archive/
```

**Deliverable:** Quarterly reports fully automated, archived

---

## Success Criteria by Phase

| Phase | Metric | Target | Status |
|-------|--------|--------|--------|
| **1** | Evidence store operational, PII redaction working | ✅ | Pending |
| **2** | Agent 12 finds 90%+ real secrets, precision >95% | ✅ | Pending |
| **3** | Pipeline daily without errors, dashboard live | ✅ | Pending |
| **4** | PDF report generated without manual work | ✅ | Pending |
| **5** | 100% automated, zero manual toil | ✅ | Pending |

---

## Resource Allocation

| Role | Week 1 | Week 2 | Week 3 | Week 4 | Week 5-8 | Week 9-10 |
|------|--------|--------|--------|--------|----------|-----------|
| **DevOps** | AWS setup, S3, KMS | Testing infra | CI/CD | Dashboard | Monitoring | Scaling |
| **Backend** | Agent SDK, Presidio | Integration | Agents 01-07 | Report gen | Remaining | Optimization |
| **QA** | Harness setup | Agent 12 testing | Full suite | Legal docs | UAT | Certification |
| **Legal** | Disclaimer draft | Review | Finalize | Signature | - | - |

**Total:** ~16 sprints (4 people × 4 weeks intensive)

---

## Blockers & Dependencies

```
┌──────────────────┐
│ Runtime Decision │ (Agent SDK / LangGraph / CrewAI)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Evidence Backend │ (S3 / Postgres / Both)
└────────┬─────────┘
         │
         ├─→ Infrastructure Week 1 ─→ Agent 12 Testing Week 2
         │
         ├─→ Control Catalog ─→ Test Harness ─→ CI/CD Pipeline
         │
         └─→ Legal Review ─→ Report Branding ─→ Client Ready
```

---

## Next Steps

**Immediately (This Week):**
1. [ ] Approve runtime environment (Agent SDK recommended)
2. [ ] Approve evidence backend (S3 Object Lock recommended)
3. [ ] Allocate resources (DevOps, Backend, QA, Legal)
4. [ ] Create implementation tickets

**Week 1:**
1. [ ] Set up S3 bucket with Object Lock
2. [ ] Deploy Claude Agent SDK
3. [ ] Install and configure Presidio
4. [ ] Test integration end-to-end

**Week 2:**
1. [ ] Deploy Agent 12 (Secrets & Crypto)
2. [ ] Run against Juice Shop
3. [ ] Validate recall/precision metrics
4. [ ] Create testing harness

---

**Document Status:** Ready for stakeholder review and approval

**Approval Required By:** [DATE]  
**Implementation Start:** [DATE]  
**MVP Completion:** 4 weeks after start  
**Production Ready:** 8-10 weeks after start
