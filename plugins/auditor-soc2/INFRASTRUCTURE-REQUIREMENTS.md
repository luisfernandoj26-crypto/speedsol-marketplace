# Infrastructure Requirements for auditor-soc2

**Status:** Implementation planning  
**Priority:** Critical path items  
**Timeline:** 2 weeks (MVP) + 4 weeks (full production)

---

## 1. Runtime Environment (Week 1)

### Decision: Orchestration Framework

| Option | Pros | Cons | Recommendation |
|--------|------|------|-----------------|
| **Claude Agent SDK** | Native Anthropic, simple mental model, MCPs built-in | Newer, less battle-tested | ✅ **RECOMMENDED** |
| **LangGraph** | Mature, graph-based composition, great for DAGs | Heavier framework, more setup | Alternative |
| **CrewAI** | Agent-first design, role-based | Abstraction overhead | Consider for team training |

**Chosen:** Claude Agent SDK

### Requirements

```yaml
Agent SDK Setup:
  api_key: ${ANTHROPIC_API_KEY}
  model: claude-3-5-sonnet-20241022
  max_tokens: 8192
  timeout: 300s
  
MCPs Required:
  - Filesystem MCP
    purpose: read project code for analysis
    permissions: read-only
    
  - GitHub MCP
    purpose: create/update PRs (Remediation agent)
    permissions: write on PR
    credentials: ${GITHUB_TOKEN}
    
  - S3 MCP (or Postgres MCP)
    purpose: evidence store backend
    permissions: read-write
    credentials: ${AWS_ACCESS_KEY} or ${DB_CONNECTION_STRING}
    
  - Secrets MCP
    purpose: retrieve secrets for tests (not hardcode)
    permissions: read-only
    credentials: managed by platform
    
Environment Variables (in .env, never git):
  ANTHROPIC_API_KEY=sk-ant-...
  GITHUB_TOKEN=ghp_...
  AWS_ACCESS_KEY_ID=AKIA...
  AWS_SECRET_ACCESS_KEY=...
  AWS_REGION=us-east-1
  DATABASE_URL=postgresql://...
```

### Orchestration Script Template

```python
#!/usr/bin/env python3
"""
SOC 2 Audit Orchestrator
Runs compliance + code agents in parallel, consolidates findings
"""
import asyncio
from anthropic import AsyncAnthropic
from datetime import datetime

client = AsyncAnthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))

async def run_audit():
    run_id = f"audit-{datetime.now().isoformat()}"
    
    # Parallel execution of compliance agents (01-07)
    compliance_tasks = [
        run_agent(agent_id=f"0{i}", run_id=run_id) 
        for i in range(1, 8)
    ]
    
    # Parallel execution of code agents (11-14)
    code_tasks = [
        run_agent(agent_id=f"1{i}", run_id=run_id) 
        for i in range(1, 5)
    ]
    
    # Wait for all to complete
    compliance_results = await asyncio.gather(*compliance_tasks)
    code_results = await asyncio.gather(*code_tasks)
    
    # Consolidate with Agent 00 and Agent 10
    consolidated = await consolidate_findings(
        compliance_results, code_results, run_id
    )
    
    return consolidated
```

---

## 2. Evidence Store (Week 1)

### Decision: Backend Selection

#### Option A: S3 Object Lock (RECOMMENDED)

```yaml
Implementation:
  storage: AWS S3
  
bucket_config:
  name: "soc2-evidence-{account-id}"
  versioning: enabled
  object_lock:
    enabled: true
    default_retention:
      mode: COMPLIANCE  # Cannot be overridden or deleted
      days: 90
  encryption:
    algorithm: AES-256 (default)
    kms_key_id: ${KMS_KEY}  # Customer-managed KMS
  
access_control:
  block_public_access: true
  bucket_policy: |
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {"Service": "lambda.amazonaws.com"},
          "Action": ["s3:GetObject", "s3:PutObject"],
          "Resource": "arn:aws:s3:::soc2-evidence/*",
          "Condition": {
            "StringEquals": {"aws:RequestedRegion": "us-east-1"}
          }
        }
      ]
    }

Cost Estimate:
  - Standard: $0.023/GB/month
  - Object Lock: +$0.10/GB/month
  - Typical 1TB evidence: ~$13/month
```

#### Option B: Postgres + Append-Only Triggers

```sql
-- Evidence table (immutable)
CREATE TABLE evidence (
  id UUID PRIMARY KEY,
  run_id VARCHAR(50),
  agent_id VARCHAR(10),
  test_id VARCHAR(100),
  content JSONB,
  hash VARCHAR(64),  -- SHA-256
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Prevent updates/deletes on old records (>24h)
CREATE TRIGGER prevent_evidence_modification
BEFORE UPDATE OR DELETE ON evidence
FOR EACH ROW
WHEN (OLD.created_at < NOW() - INTERVAL '24 hours')
EXECUTE FUNCTION raise_immutability_error();

-- Audit log (append-only)
CREATE TABLE evidence_audit_log (
  id BIGSERIAL PRIMARY KEY,
  evidence_id UUID REFERENCES evidence(id),
  action VARCHAR(10),  -- INSERT, UPDATE, DELETE
  timestamp TIMESTAMP DEFAULT NOW(),
  user_id VARCHAR(50),
  reason TEXT
);

CREATE RULE log_evidence_changes AS ON INSERT TO evidence
DO ALSO INSERT INTO evidence_audit_log (evidence_id, action, user_id)
VALUES (NEW.id, 'INSERT', CURRENT_USER);
```

#### Option C: Both (Redundancy)

```yaml
Architecture:
  primary: S3 Object Lock (live, immediate access)
  secondary: Postgres (backup, queryable archive)
  sync: Lambda function on S3 PutObject → Postgres insert
  
Failover:
  if S3 unavailable: write to Postgres + retry S3
  if Postgres unavailable: write to S3 + queue for later sync
```

**RECOMMENDATION:** S3 Object Lock (simplest, meets immutability requirement)

### Evidence Path Schema

```
s3://soc2-evidence-{account}/
├── {RUN_ID}/
│   ├── 00/  (Orchestrator)
│   ├── 01/  (Access Control)
│   │   ├── CC6.1-mfa-policy/
│   │   │   └── evidence-20260422-001.json {hash: SHA256}
│   │   └── CC6.2-access-review/
│   │       └── evidence-20260422-002.json
│   ├── 12/  (Secrets & Crypto)
│   │   └── SECRET-DETECTION/
│   │       └── evidence-20260422-003.json
│   └── manifest.json  (signed, lists all evidence)
```

### Manifest Signing

```json
{
  "run_id": "audit-2026-04-22T143000Z",
  "timestamp": "2026-04-22T14:30:00Z",
  "evidence": [
    {
      "id": "evidence-20260422-001",
      "hash": "sha256:abc123...",
      "agent_id": "01",
      "test_id": "CC6.1-mfa-policy",
      "size_bytes": 2048
    }
  ],
  "manifest_hash": "sha256:def456...",
  "signature": "RSA-SHA256:xyz789...",
  "signer_key_id": "arn:aws:kms:us-east-1:123456789:key/12345678-1234-1234-1234-123456789012"
}
```

### Read API

```python
# Retrieve evidence by ID
GET /evidence/{evidence_id}
Response:
{
  "id": "evidence-20260422-001",
  "content": { ... },
  "hash": "sha256:abc123...",
  "signature": "RSA-SHA256:...",
  "created_at": "2026-04-22T14:30:00Z"
}

# Verify evidence integrity
GET /evidence/{evidence_id}/verify
Response:
{
  "valid": true,
  "calculated_hash": "sha256:abc123...",
  "stored_hash": "sha256:abc123...",
  "signature_valid": true
}
```

---

## 3. PII Redaction System (Week 1)

### Decision: Redaction Engine

| Tool | Detection | Performance | Maintenance | Recommendation |
|------|-----------|-------------|-------------|-----------------|
| **Microsoft Presidio** | Entity recognition (NER) | Fast | Active community | ✅ **RECOMMENDED** |
| **Custom Regex** | Pattern matching | Very fast | High overhead | Simple patterns only |
| **AWS Comprehend** | ML-based + patterns | Slow (API) | AWS-managed | Consider for scale |

**Chosen:** Microsoft Presidio

### Presidio Integration

```python
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine

analyzer = AnalyzerEngine()
anonymizer = AnonymizerEngine()

def redact_evidence(text: str) -> str:
    """Redact PII before evidence touches disk"""
    results = analyzer.analyze(
        text=text,
        language="en",
        entities=[
            "PERSON",
            "EMAIL_ADDRESS",
            "PHONE_NUMBER",
            "CREDIT_CARD",
            "CRYPTO",
            "IBAN",
            "IP_ADDRESS",
            "SSN",
            "AWS_KEY",  # Custom entity
        ]
    )
    
    redacted = anonymizer.anonymize(
        text=text,
        analyzer_results=results,
        operators={
            "PERSON": OperatorConfig(
                "replace", params={"new_value": "[PERSON]"}
            ),
            "EMAIL_ADDRESS": OperatorConfig(
                "replace", params={"new_value": "[EMAIL]"}
            ),
            "AWS_KEY": OperatorConfig(
                "mask", params={
                    "type": "mask",
                    "masking_char": "*",
                    "chars_to_mask": 20,
                    "from_end": True
                }
            ),
        }
    )
    
    return redacted.text

# Usage in agent
evidence_raw = read_sensitive_file(path)
evidence_redacted = redact_evidence(evidence_raw)
store_to_evidence_backend(evidence_redacted)  # Now safe
```

### Redaction Patterns

```yaml
patterns:
  - id: SSN
    regex: '\d{3}-\d{2}-\d{4}'
    replacement: '[SSN]'
    
  - id: API_KEY
    regex: '(AKIA|sk-|ghp_|pat_)[A-Za-z0-9_]{20,}'
    replacement: '[API_KEY_***]'
    
  - id: AWS_SECRET
    regex: 'aws_secret_access_key\s*=\s*([A-Za-z0-9/+=]{40})'
    replacement: 'aws_secret_access_key=[REDACTED]'
    
  - id: DATABASE_PASSWORD
    regex: 'password\s*[:=]\s*[''"]([^''\"]+)[''"]'
    replacement: 'password="[REDACTED]"'
    
  - id: JWT_TOKEN
    regex: 'eyJhbGciOi[A-Za-z0-9_-]*\.eyJsu[A-Za-z0-9_-]*\.'
    replacement: '[JWT_TOKEN]'

redaction_log:
  file: /logs/redaction-audit.log
  format: |
    {
      "timestamp": "2026-04-22T14:30:00Z",
      "evidence_id": "...",
      "patterns_matched": ["SSN", "API_KEY"],
      "items_redacted": 3,
      "redacted_by": "agent_12"
    }
```

### Timing: Capture-Time Redaction (Critical)

```
Flow:
  1. Agent reads sensitive file
  2. IMMEDIATELY redact (before any disk write)
  3. Store redacted version to evidence store
  4. Original never persists locally
  
Incorrect Flow (DO NOT DO):
  1. Agent reads file
  2. Stores to disk
  3. Later redacts
  4. Risk: PII already exposed
```

---

## 4. Control Catalog Expansion (Week 2-3)

### Current Coverage

```yaml
Implemented:
  CC6: Access Control ✅
  CC7: Operations ✅
  CC8: Change Management ✅
  A1: Availability ✅
  C1: Confidentiality ✅
  CC1-CC2: Governance ✅
  CC3, CC9: Risk & Vendor ✅
  
Missing:
  CC2.2: Responsibility for objectives
  CC2.3: Competence of people
  CC3.1: Authorization policies
  CC3.3: Segregation of duties
  CC4.x: Monitoring Activities (entire series)
  CC5.x: Control Activities (entire series)
  CC6.4: Access control over information assets
  CC6.5: Removal of access rights
  CC7.5: Incident detection and notification
  CC9.1: Change control
  A1.1: Availability of systems
  A1.3: Incident processing
  
Optional (if Privacy/PI):
  P1.x: Personal data collection and usage (~15 tests)
  P2.x: Retention and deletion (~10 tests)
  I1.x: Integrity of systems (~12 tests)
```

### Test Template

```yaml
test:
  id: "CC4.1-evidence-retention"
  control: "CC4.1"
  domain: "Monitoring Activities"
  
  name: "Evidence and Log Retention"
  description: |
    Verify that logs of system activity and changes to key
    configurations are retained for a minimum of 90 days
    
  procedure: |
    1. Identify log aggregation systems (CloudTrail, ELK, etc.)
    2. Check retention policy for each system
    3. Verify retention >= 90 days
    4. Test log accessibility (retrieve random entry from 60 days ago)
    5. Verify immutability (can logs be modified/deleted?)
    
  expected_result: |
    - All log systems have retention policy >= 90 days
    - Logs immutable (write-once, read-many)
    - Log retrieval works for historical periods
    
  failure_modes:
    - Retention < 90 days
    - Logs can be deleted/modified
    - Log API unavailable
    - No centralized logging
    
  evidence_points:
    - CloudTrail bucket policy (S3 Object Lock enabled)
    - ELK retention policy configuration
    - Log access test results
    - Audit of log modifications (should be none)
    
  remediation: |
    1. Configure log retention policy to 90+ days
    2. Enable Object Lock on log buckets
    3. Test retrieval at 90-day boundary
```

---

## 5. Custom Semgrep Rules (Week 2-3)

### Rule Mapping to Controls

```yaml
soc2-cc6.1-endpoint-without-audit-log:
  pattern-either:
    - patterns:
        - pattern: |
            @app.route(...)
            def $FUNC(...):
              ...
        - pattern-not: |
            @app.route(...)
            def $FUNC(...):
              ...
              audit_log.record(...)
              ...
  message: "Endpoint without audit logging violates CC6.1"
  languages: [python]
  severity: ERROR
  metadata:
    control: CC6.1
    description: "User activity not logged"
    fix: "Add audit_log.record() to endpoint"

soc2-c1.1-unencrypted-data-at-rest:
  pattern-either:
    - patterns:
        - pattern: "boto3.resource('s3').Bucket(...).put_object(...)"
        - pattern-not-inside: "ServerSideEncryption='AES256'"
  message: "S3 bucket write without encryption violates C1.1"
  languages: [python]
  severity: ERROR
  metadata:
    control: C1.1
    description: "Data stored unencrypted"
    fix: "Add ServerSideEncryption='AES256' parameter"

soc2-cc8.1-no-change-approval:
  pattern-either:
    - patterns:
        - pattern: "git push origin main"
        - pattern-not-inside: "PR approved with minimum 2 reviews"
  message: "Direct push to main violates CC8.1"
  languages: [bash, github-actions]
  severity: ERROR
  metadata:
    control: CC8.1
    description: "Change not approved"
    fix: "Use PR workflow with branch protection"
```

### Validation

```bash
# Test rule against vulnerable repos
semgrep -r soc2-rules/ OWASP/juice-shop/ --json > results.json

# Validate findings
python validate_findings.py \
  --rules soc2-rules/ \
  --repo OWASP/juice-shop/ \
  --expected-findings 150+ \
  --min-precision 0.90
```

---

## 6. Implementation Checklist

### Week 1 (Infrastructure Foundation)

- [ ] Set up S3 bucket with Object Lock
  - [ ] Enable versioning
  - [ ] Configure 90-day retention
  - [ ] Set up KMS encryption
  - [ ] Test manifest signing
  
- [ ] Install Claude Agent SDK
  - [ ] Configure Anthropic API key
  - [ ] Install MCPs (Filesystem, GitHub, S3)
  - [ ] Test basic agent invocation
  
- [ ] Deploy Presidio PII redaction
  - [ ] Install presidio library
  - [ ] Configure custom entities
  - [ ] Test redaction patterns
  - [ ] Set up audit logging

### Week 2 (Agent Integration)

- [ ] Agent 12 (Secrets & Crypto) end-to-end test
  - [ ] Run against OWASP Juice Shop
  - [ ] Measure recall/precision
  - [ ] Generate findings JSON
  - [ ] Verify evidence storage
  - [ ] Validate PII redaction
  
- [ ] Expand control catalog
  - [ ] Add missing CC tests
  - [ ] Implement test procedures
  - [ ] Define evidence requirements

### Week 3 (Scaling)

- [ ] Deploy remaining agents (01-07, 10-11, 13-15)
- [ ] Set up CI/CD pipeline
- [ ] Configure dashboard
- [ ] Test parallel execution

### Week 4+ (Operations)

- [ ] Legal review of disclaimer
- [ ] Report branding and PDF generation
- [ ] Human process definition
- [ ] Client readiness testing

---

**Status:** Ready for implementation after runtime/evidence backend decision.
