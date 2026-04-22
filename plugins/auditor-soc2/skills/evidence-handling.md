# Evidence Handling Skill

**When to use:** Every time an agent captures evidence that will support a finding or a control test result. Evidence integrity is the backbone of the Type II-style report — if evidence is questionable, the entire report is.

## Principles

1. **Integrity first.** Every piece of evidence has a SHA-256 hash recorded at capture time.
2. **Tamper-evident storage.** Evidence store uses immutable storage (S3 Object Lock in compliance mode, or git with signed commits).
3. **Timestamp authority.** Use a trusted time source (NTP-synced system clock is acceptable for internal reports; for higher assurance, use RFC 3161 timestamps).
4. **Redact PII at capture, not at report time.** Never store raw PII in evidence.
5. **Provenance chain.** Every evidence item records: who/what captured it, what tool, what version, what parameters.
6. **Retain on a schedule.** Default 7 years or per `evidence_store.retention_years` in the environment config.

## Evidence Capture Workflow

```
1. Execute deterministic tool or API call
2. Capture raw output to temporary buffer
3. Apply PII redaction (see rules below)
4. Compute sha256 of redacted output
5. Write to evidence store with canonical path
6. Create manifest entry
7. Append to run manifest
8. (Optional) GPG-sign the manifest
```

## PII Redaction Rules

Before storing any evidence that may contain operational data, run redaction. This is non-negotiable.

| Pattern | Example | Replacement |
|---------|---------|-------------|
| Email | `user@example.com` | `<EMAIL:hash8>` |
| Phone (E.164) | `+573001234567` | `<PHONE:hash8>` |
| National ID (Colombia CC, US SSN, etc.) | `123-45-6789` | `<NATIONAL_ID:hash8>` |
| Credit card | `4111 1111 1111 1111` | `<CC:redacted>` |
| API keys / tokens | `ghp_xxx`, `sk-xxx`, `AKIA...` | `<TOKEN:type>` |
| IP addresses (when identifying users) | `192.168.1.5` | `<IP:hash8>` |
| JWTs | `eyJ...` | `<JWT:redacted>` |
| Private keys | `-----BEGIN PRIVATE KEY-----` | `<PRIVATE_KEY:redacted>` |

`hash8` = first 8 chars of sha256(value + per-run salt). This lets an analyst correlate the same user across logs without exposing PII.

**Exception:** When the evidence itself IS that a secret was leaked, store the FACT that it leaked plus a hash, but NEVER the actual secret value. E.g.:
```json
{
  "finding": "Live AWS access key exposed in repo",
  "key_prefix": "AKIAIOSFOD",  
  "key_full_sha256": "...",
  "validated_live": true,
  "provider_confirmation_ref": "..."
}
```

## Evidence Types & Capture Methods

### API Responses
```json
{
  "type": "api_response",
  "tool": "okta_sdk",
  "tool_version": "2.8.1",
  "endpoint": "/api/v1/users?filter=credentials.provider.type eq \"PASSWORD\"",
  "method": "GET",
  "captured_at": "2026-04-22T14:23:11Z",
  "response_sha256": "...",
  "response_status": 200,
  "response_body_ref": "raw/okta_users_20260422.json.gz",
  "redaction_applied": true,
  "agent_run_id": "..."
}
```

### Command Output
```json
{
  "type": "command_output",
  "tool": "semgrep",
  "tool_version": "1.85.0",
  "command": "semgrep --config=p/owasp-top-ten --json src/",
  "captured_at": "...",
  "exit_code": 0,
  "stdout_sha256": "...",
  "stderr_sha256": "...",
  "stdout_ref": "raw/semgrep_scan_20260422.json.gz",
  "agent_run_id": "..."
}
```

### Configuration Snapshots
```json
{
  "type": "config_snapshot",
  "source": "github::branch_protection::acme/main-app::main",
  "captured_at": "...",
  "content_sha256": "...",
  "content_ref": "raw/bp_main_20260422.json",
  "capture_method": "api_call"
}
```

### Screenshots (for manual evidence)
Only when no API-based capture is possible.
```json
{
  "type": "screenshot",
  "captured_at": "...",
  "captured_by": "agent | human_operator",
  "image_sha256": "...",
  "image_ref": "raw/screenshot_abc.png",
  "description": "Admin panel showing MFA required setting enabled"
}
```

## Manifest Format

Every agent run writes a manifest to `{evidence_store}/{run_id}/manifest.json`:

```json
{
  "manifest_version": "1.0",
  "run_id": "...",
  "agent": "access_control_agent",
  "started_at": "...",
  "completed_at": "...",
  "environment_config_sha256": "...",
  "controls_catalog_sha256": "...",
  "tests_executed": [
    {
      "test_id": "CC6.1-T01",
      "status": "pass | fail | error",
      "evidence_refs": ["findings/..../evidence/..."],
      "finding_ids": ["..."]
    }
  ],
  "evidence_count": 42,
  "total_size_bytes": 15728640,
  "signed_by": "agent_key_fingerprint",
  "signature": "base64 GPG signature"
}
```

## Integrity Verification

At any later point, anyone should be able to verify a finding:

```
1. Read finding.json
2. Fetch evidence from evidence.raw_output_ref
3. Compute sha256
4. Compare to evidence.raw_output_sha256
5. If mismatch → evidence tampered or lost
```

The reporter agent MUST run this verification before including findings in the final report.

## Retention Lifecycle

| Phase | Duration | Action |
|-------|----------|--------|
| Hot | Current period | Full evidence, fast access |
| Warm | Past 12 months | Full evidence, may be archived |
| Cold | 12 months – 7 years | Compressed archive, monthly digests |
| Purge | > 7 years | Secure deletion with deletion certificate |

Never purge evidence still referenced by an **open** finding, regardless of age.

## Failure Modes to Avoid

- **Screenshot without hash.** Any image without a sha256 is not evidence; it's decoration.
- **"Logged in manually and checked."** If a human eyeballed something, capture the screenshot + describe what was checked. Otherwise it's unverifiable.
- **Mutable references.** Never reference a cloud resource state by "current" — always by captured_at + snapshot.
- **Missing tool versions.** A finding from `semgrep 1.0` with ruleset X is different from `semgrep 2.0` with ruleset X'. Record the version.
- **Redacting too late.** If raw PII ever hits disk, redaction after the fact is not enough. Redact before writing.
