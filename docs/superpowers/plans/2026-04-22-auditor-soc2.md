# `auditor-soc2` Implementation Plan

**Goal:** Implementar plugin auditor-soc2 como solución avanzada de auditoría SOC 2, análisis de cumplimiento y generación de reportes.

**Architecture:** Agente `auditor` principal que analiza TODOS los archivos del proyecto, evalúa cumplimiento SOC 2, valida controles, analiza riesgos y genera informe detallado a `/auditoria/YYYY-MM-DD-informe.md`.

**Tech Stack:** Markdown, Claude Agents, análisis estático de código, generación de reportes.

---

## Mapeo de Archivos

**Crear:**
- `plugins/auditor-soc2/config/soc2-controls.md` — Framework de controles SOC 2
- `plugins/auditor-soc2/config/compliance-rules.md` — Reglas de cumplimiento
- `plugins/auditor-soc2/config/risk-assessment.md` — Matriz de riesgos

**Modificar:**
- `plugins/auditor-soc2/agents/auditor.md` — Agente principal de auditoría
- `plugins/auditor-soc2/commands/audit.md` — Comando `/audit-soc2`

---

### Task 1: Crear `config/soc2-controls.md`

**Files:** Create: `plugins/auditor-soc2/config/soc2-controls.md`

- [ ] **Step 1:** Crear archivo con controles SOC 2

```markdown
# SOC 2 Controls Framework

## CC (Common Criteria)

### CC6 - Logical and Physical Access Controls
- Access management policies
- Authentication mechanisms
- Authorization controls
- Network perimeter controls
- Segregation of duties

### CC7 - System Monitoring
- Monitoring and logging
- Intrusion detection
- Incident response procedures

### CC8 - Incident Management
- Incident identification and response
- Root cause analysis
- Preventive measures

### CC9 - Change Management
- Change approval process
- Configuration management
- Version control

## A1 (Availability)
- System availability monitoring
- Backup and recovery procedures
- Disaster recovery testing

## C1 (Confidentiality)
- Encryption in transit and at rest
- Data classification
- Access restrictions

## I1 (Integrity)
- Data validation
- Change tracking
- Integrity verification

## P1 (Privacy)
- Personal data handling
- Privacy policies
- Data retention
```

- [ ] **Step 2:** Commit

```bash
git add plugins/auditor-soc2/config/soc2-controls.md
git commit -m "config: add soc2 controls framework"
```

---

### Task 2: Crear `config/compliance-rules.md`

**Files:** Create: `plugins/auditor-soc2/config/compliance-rules.md`

- [ ] **Step 1:** Crear archivo con reglas de cumplimiento

```markdown
# Compliance Rules

## Code Security
- No hardcoded secrets (critical)
- Input validation on endpoints (critical)
- Parameterized queries (critical)
- Authentication on protected endpoints (high)
- Error messages non-exposing (high)

## Infrastructure
- HTTPS only (critical)
- Encryption at rest (high)
- Firewall rules (high)
- Access logging (high)

## Data Management
- Data classification (high)
- Retention policies (high)
- Backup procedures (high)
- Encryption keys rotation (medium)

## Change Management
- Git history (high)
- Code review process (high)
- Testing automation (high)
- Deployment process (high)

## Monitoring
- Logging enabled (high)
- Log retention (medium)
- Alert configuration (medium)
- Health checks (medium)

## Documentation
- Security policies (high)
- Incident procedures (high)
- Disaster recovery plan (high)
- Change log (high)
```

- [ ] **Step 2:** Commit

```bash
git add plugins/auditor-soc2/config/compliance-rules.md
git commit -m "config: add compliance rules for auditing"
```

---

### Task 3: Crear `config/risk-assessment.md`

**Files:** Create: `plugins/auditor-soc2/config/risk-assessment.md`

- [ ] **Step 1:** Crear archivo con matriz de riesgos

```markdown
# Risk Assessment Matrix

## Severity Levels

### Critical (Immediate Action Required)
- Exploitable security vulnerabilities
- Unauthorized data access
- System unavailability
- Data loss risk

### High (Fix Before Release)
- Missing authentication/authorization
- Weak encryption
- No logging on sensitive operations
- Missing backups

### Medium (Should Be Fixed)
- Code quality issues
- Incomplete documentation
- Manual processes that could be automated
- Outdated dependencies

### Low (Best Practice Improvements)
- Code style inconsistencies
- Minor performance issues
- Documentation clarity
- Logging improvements

## Risk Calculation

Risk = Probability × Impact

### Probability Scores
- High (3): Easily exploitable, multiple vectors
- Medium (2): Requires specific conditions
- Low (1): Difficult to exploit

### Impact Scores
- High (3): Critical system/data impact
- Medium (2): Significant operational impact
- Low (1): Minor impact

## Remediation Timeline

- Critical: 24 hours
- High: 1 week
- Medium: 30 days
- Low: Next sprint
```

- [ ] **Step 2:** Commit

```bash
git add plugins/auditor-soc2/config/risk-assessment.md
git commit -m "config: add risk assessment matrix"
```

---

### Task 4: Crear agente `auditor.md`

**Files:** Create/Modify: `plugins/auditor-soc2/agents/auditor.md`

- [ ] **Step 1:** Crear/reescribir agente auditor

```markdown
# Agent: Auditor (SOC 2)

## System Prompt

You are a senior SOC 2 auditor at Speed Solutions. Your role is to analyze entire projects for compliance, security, and operational controls.

**Scope:** All files in project directory. Security controls, infrastructure, data management, change management, monitoring, documentation.

**Tools:** Read, Grep, Bash (analysis only, NO modifications)

## Core Responsibilities

1. **Comprehensive Analysis**
   - Scan ALL files (code, config, docs, infrastructure)
   - Check for security vulnerabilities
   - Validate authentication/authorization
   - Verify encryption practices
   - Review logging and monitoring
   - Assess change management procedures

2. **Compliance Evaluation**
   - Match findings against SOC 2 controls (config/soc2-controls.md)
   - Check compliance rules (config/compliance-rules.md)
   - Evaluate risk levels (config/risk-assessment.md)

3. **Report Generation**
   - Hallazgos (Findings) — grouped by severity
   - Riesgos (Risks) — business impact assessment
   - Recomendaciones (Recommendations) — actionable fixes
   - Próximos Pasos (Next Steps) — remediation timeline

4. **Report Persistence**
   - Generate filename: `/auditoria/YYYY-MM-DD-informe.md`
   - Create `/auditoria/` if doesn't exist
   - Save complete report with all sections
   - Timestamp and metadata

## Output Format

```markdown
# Informe de Auditoría SOC 2
Fecha: [YYYY-MM-DD]
Nivel de Cumplimiento: [%]

## 🔴 HALLAZGOS CRÍTICOS
[List with location, impact, fix]

## 🟠 HALLAZGOS ALTOS
[List with location, impact, fix]

## 🟡 HALLAZGOS MEDIOS
[List with location, impact, fix]

## 🟢 HALLAZGOS BAJOS
[List with location, impact, fix]

## 📊 ANÁLISIS DE RIESGOS
[Risk matrix: probability × impact]

## ✅ CUMPLIMIENTO POR ÁREA
- Code Security: [%]
- Infrastructure: [%]
- Data Management: [%]
- Change Management: [%]
- Monitoring: [%]
- Documentation: [%]

## 💡 RECOMENDACIONES
[Prioritized list with remediation timeline]

## 📅 PRÓXIMOS PASOS
[Timeline for fixes and re-audit]
```

## Constraints

- Do NOT modify ANY code
- Do NOT execute code (analysis only)
- Be explicit and factual
- Provide evidence locations (file:line)
- Include remediation guidance
- Assume code will be fixed separately
```

- [ ] **Step 2:** Commit

```bash
git add plugins/auditor-soc2/agents/auditor.md
git commit -m "feat: create auditor agent for soc2 compliance"
```

---

### Task 5: Crear comando `audit.md`

**Files:** Create: `plugins/auditor-soc2/commands/audit.md`

- [ ] **Step 1:** Crear comando /audit-soc2

```markdown
# Command: /audit-soc2

## Purpose

Execute a comprehensive SOC 2 compliance audit of the entire project. Generates a detailed report with findings, risks, and recommendations.

## How It Works

1. Scans ALL project files
2. Evaluates against SOC 2 controls framework
3. Checks compliance rules
4. Assesses risks (probability × impact)
5. Generates detailed report
6. Saves to `/auditoria/YYYY-MM-DD-informe.md`

## Usage

```
/audit-soc2
```

## Output

Complete audit report saved to `/auditoria/` with:
- Critical, High, Medium, Low findings
- Risk assessment matrix
- Compliance percentage by area
- Actionable recommendations
- Remediation timeline

## After Audit

1. Review findings in generated report
2. Use other plugins to fix issues
3. Run `/audit-soc2` again to re-evaluate
4. Track remediation progress

## Frequency

- Initial: Before first release
- Periodic: Quarterly or after major changes
- Post-Fix: After addressing high/critical findings
```

- [ ] **Step 2:** Commit

```bash
git add plugins/auditor-soc2/commands/audit.md
git commit -m "docs: add audit-soc2 command documentation"
```

---

### Task 6: Verificar estructura del plugin

**Files:** Check: `plugins/auditor-soc2/`

- [ ] **Step 1:** Verificar y ajustar structure

```bash
ls -la plugins/auditor-soc2/
cat plugins/auditor-soc2/.claude-plugin/plugin.json
```

- [ ] **Step 2:** Verificar que marketplace.json incluye auditor-soc2

```bash
grep "auditor-soc2" .claude-plugin/marketplace.json
```

Expected: Entrada con `"name": "auditor-soc2"` y `"source": "./plugins/auditor-soc2"`

- [ ] **Step 3:** Commit final

```bash
git add -A
git commit -m "chore: finalize auditor-soc2 plugin structure"
```

---

## Plan Summary

✅ **Archivos creados:** 5 (3 configs + 1 agent + 1 command)  
✅ **Funcionalidad:** Auditoría SOC 2 completa, análisis de cumplimiento, generación de reportes  
✅ **Output:** Reportes guardados en `/auditoria/YYYY-MM-DD-informe.md`  
✅ **Integración:** Plugin registrado en marketplace.json  

