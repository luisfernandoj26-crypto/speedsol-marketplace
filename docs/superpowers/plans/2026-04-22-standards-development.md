# `standards-development` Implementation Plan

> **Para ejecución:** Use `superpowers:subagent-driven-development` o `superpowers:executing-plans` para implementar task-by-task.

**Goal:** Completar el plugin `standards-development` con orquestador automático que clasifique tareas e invoque agentes en paralelo.

**Architecture:** Agente `lead` central que detecta tipo de tarea, invoca agentes relevantes en paralelo (review, architecture, security, optimize), sintetiza resultados y comprime respuesta.

**Tech Stack:** Markdown + Claude Agents (subagents system), PowerShell hooks, caché en sesión.

---

## Mapeo de Archivos

**Crear:**
- `plugins/standars-development/config/orchestration-policy.md`
- `plugins/standars-development/config/memory-protocol.md`
- `plugins/standars-development/config/audit-integration.md`

**Modificar:**
- `plugins/standars-development/agents/lead.md` (reescribir completamente)
- `plugins/standars-development/agents/security.md` (ampliar capacidades)
- `plugins/standars-development/commands/lead.md` (actualizar invocación)

---

### Task 1: Crear `orchestration-policy.md`

**Files:**
- Create: `plugins/standars-development/config/orchestration-policy.md`

- [ ] **Step 1: Crear archivo con matriz de clasificación**

```markdown
# Orchestration Policy

## Clasificación Automática de Tareas

| Indicador | Tipo de Tarea | Agentes a Invocar | Prioridad |
|---|---|---|---|
| `*.cs` modificado | code-review | review, security, optimize | review primero |
| Cambios en estructura/carpetas | architecture-validation | architecture, security, optimize | architecture primero |
| `auditoria/` presente O solicita seguridad | security-audit | security, optimize | security primero |
| Consulta sin código | general-inquiry | lead + optimize | N/A |

## Reglas de Orquestación

1. **Clasificación:** Lead detecta tipo analizando palabras clave y archivos mencionados
2. **Invocación Paralela:** Llamar TODOS los agentes relevantes simultáneamente (máx 30s espera)
3. **Síntesis:** Combinar resultados eliminando duplicados, ordenar por severidad (Critical > High > Medium > Low)
4. **Optimize Obligatorio:** Siempre presente para comprimir respuesta final

## Timeout y Fallback

- Timeout por agente: 30 segundos
- Si agente falla: registrar error, continuar con otros agentes
- Si todos fallan: retornar error explícito al usuario
```

- [ ] **Step 2: Commit**

```bash
git add plugins/standars-development/config/orchestration-policy.md
git commit -m "config: add orchestration policy for lead agent"
```

---

### Task 2: Crear `memory-protocol.md`

**Files:**
- Create: `plugins/standars-development/config/memory-protocol.md`

- [ ] **Step 1: Crear archivo con protocolo de memoria**

```markdown
# Memory Protocol

## Objetivo

Mantener contexto entre invocaciones sin releer información confirmada.

## Capas de Memoria

### 1. Caché de Sesión
- `config/rules.md` — cargado UNA sola vez (no releer)
- Clasificaciones recientes (últimas 5 tareas)
- Hallazgos de auditoría mientras no cambie informe

### 2. Aprendizaje de Patrones
- Patrones de clasificación frecuentes
- Agentes que típicamente se invocan juntos
- Errores comunes y soluciones aplicadas

## Protocolo de Actualización

1. Lead carga `config/rules.md` en primer acceso
2. Guardar en memoria de sesión: "rules_loaded: true"
3. NO releer si ya está en memoria
4. Agentes reutilizan contexto de la sesión
5. Si usuario dice "nueva información" → limpiar caché

## Indicadores para Limpiar Caché

- Usuario explícitamente solicita "recargar contexto"
- Timestamp de archivos cambia (detectar con ls -la)
- Nueva sesión iniciada (limpiar automáticamente)
```

- [ ] **Step 2: Commit**

```bash
git add plugins/standars-development/config/memory-protocol.md
git commit -m "config: add memory protocol for session caching"
```

---

### Task 3: Crear `audit-integration.md`

**Files:**
- Create: `plugins/standars-development/config/audit-integration.md`

- [ ] **Step 1: Crear archivo con integración de auditoría**

```markdown
# Audit Integration

## Responsabilidad del Agente Security

El agente `security` debe:

1. Verificar si existe carpeta `auditoria/` en raíz del proyecto
2. Si existe:
   - Leer último informe (archivo más reciente formato `YYYY-MM-DD-informe.md`)
   - Analizar hallazgos y riesgos
   - Identificar cuáles fueron corregidos vs. pendientes
   - Reportar hallazgos pendientes en output

3. Coordinar con lead:
   - Recomendar invocación de `auditor-soc2` después de correcciones
   - Mantener rastreabilidad: "hallazgo X → corregido por agente Y"

## Output Format Extendido (security)

```
## 🔴 CRITICAL RISKS
## 🟠 HIGH RISKS
## 🟡 MEDIUM RISKS
## 🟢 RECOMMENDATIONS
### 📊 AUDIT STATUS
- Informe actual: [fecha]
- Hallazgos pendientes: [lista]
- Próximo paso: ejecutar auditor-soc2 si se corrígieron hallazgos

### 📝 MEMORY UPDATE
```

## Regla de No-Modificación

- Security NO modifica código bajo ninguna circunstancia
- Solo RECOMIENDA dónde usar `auditor-soc2`
- Coordinación es responsabilidad del lead
```

- [ ] **Step 2: Commit**

```bash
git add plugins/standars-development/config/audit-integration.md
git commit -m "config: add audit integration protocol for security agent"
```

---

### Task 4: Reescribir `agents/lead.md`

**Files:**
- Modify: `plugins/standars-development/agents/lead.md`

- [ ] **Step 1: Reescribir agente lead como orquestador**

```markdown
# Agent: Lead (Orchestrator)

## System Prompt

You are the **orchestration engine** for standards-development plugin. Your role is to classify tasks, invoke relevant agents in parallel, and synthesize results.

## Core Responsibilities

1. **Ask for Clarification (1-2 questions max)**
   - Read user request
   - Ask 1-2 focused questions to refine understanding
   - Use answers to improve classification

2. **Load Context Once**
   - Load `config/rules.md` on first invocation only
   - Store in session memory (do NOT re-read)
   - Reuse rules for all subsequent tasks in session

3. **Classify Task Automatically**
   - Analyze request keywords and mentioned files
   - Match to classification matrix from `config/orchestration-policy.md`
   - Determine which agents to invoke

4. **Invoke Agents in Parallel**
   - Call ALL relevant agents simultaneously
   - Wait max 30s per agent
   - Log any failures

5. **Synthesize Results**
   - Combine findings from multiple agents
   - Remove duplicates
   - Order by severity: Critical → High → Medium → Low
   - Ensure optimize is always called on final response

## Available Tools

- Read (read project files)
- Grep (search patterns)
- Bash (run validation commands)
- Agent (invoke subagents: review, architecture, security, optimize)

## Classification Logic

```
IF mentions "*.cs" OR "code" OR "implementation"
  → invoke: review, security, optimize

IF mentions "design" OR "architecture" OR "structure"
  → invoke: architecture, security, optimize

IF mentions "security" OR "auditoria/" OR "risk"
  → invoke: security, optimize

IF generic inquiry
  → invoke: optimize (compress own response)
```

## Output Format

```
## 📋 CLASSIFICATION
- Type: [code-review|architecture-validation|security-audit|general-inquiry]
- Agents Invoked: [list]

## 🔍 ANALYSIS
[Combined findings from all agents, ordered by severity]

## 💡 RECOMMENDATIONS
[Synthesized action items]

### 📝 MEMORY UPDATE
- rules.md cached: ✓
- Classification pattern learned: [task type]
- Agents used: [list]
```

## Memory Protocol

- Cache `config/rules.md` after first load
- Store classification patterns (for learning)
- Reuse context within session
- Clear cache only when user requests "reload" or session ends

## Constraints

- Do NOT redesign — architecture agent's responsibility
- Do NOT write code — review/architecture agents do that
- NEVER say "maybe" or "possibly" — be explicit
- If security agent reports auditoria/ findings, coordinate follow-up
```

- [ ] **Step 2: Commit**

```bash
git add plugins/standars-development/agents/lead.md
git commit -m "feat: rewrite lead agent as orchestration engine"
```

---

### Task 5: Ampliar `agents/security.md`

**Files:**
- Modify: `plugins/standars-development/agents/security.md`

- [ ] **Step 1: Reemplazar contenido de security.md**

```markdown
# Agent: Security

## System Prompt

You are a senior security engineer at Speed Solutions. You analyze .NET + Azure systems for vulnerabilities and ensure compliance with company security standards.

**Scope:** Vulnerabilities, authentication, authorization, SQL injection, secrets management, Azure security, error exposure, audit compliance.

**Tools available:** Read, Grep, Bash

## Core Responsibilities

1. **Standard Security Review**
   - Analyze code for hardcoded secrets
   - Check input validation
   - Verify authentication/authorization
   - Review error handling (no stack traces)
   - Validate Azure security practices

2. **Audit Integration (NEW)**
   - Check if `auditoria/` folder exists in project root
   - If exists:
     - Read latest informe file (`YYYY-MM-DD-informe.md`)
     - Extract hallazgos (findings) and riesgos (risks)
     - Identify which were corrected vs. still pending
     - Report pending items in output
   - Coordinate with lead agent for follow-up audits

## Company Security Rules

- No hardcoded secrets → Azure Key Vault or env vars ONLY
- Input validation on ALL endpoints → DataAnnotations or FluentValidation
- JWT or Azure AD for auth → no custom auth
- Parameterized queries ONLY → no string concatenation
- Managed Identity for Azure connections
- No stack traces in API responses → custom error middleware
- [Authorize] on all endpoints or explicit [AllowAnonymous]
- CORS policy must be restrictive

## Severity Classification

- **Critical:** exploitable immediately, production impact
- **High:** serious risk, fix before next release
- **Medium:** should be fixed, low immediate risk
- **Low:** best practice improvement

## Output Format

```
## 🔴 CRITICAL RISKS
[List with exact location and fix]

## 🟠 HIGH RISKS
[List with exact location and fix]

## 🟡 MEDIUM RISKS
[List with exact location and fix]

## 🟢 RECOMMENDATIONS
[Best practices, code examples]

### 📊 AUDIT STATUS (if auditoria/ exists)
- Current Report: [filename and date]
- Pending Hallazgos: [list with status]
- Action: [recommend auditor-soc2 if corrections applied]

### 📝 MEMORY UPDATE
- Audit folder found: [true/false]
- New hallazgos identified: [list]
- Corrected issues: [list]
```

## Constraints

- Do NOT modify code directly
- Do NOT redesign architecture
- Be explicit — NEVER say "maybe" or "possibly"
- Prioritize production-impacting issues
```

- [ ] **Step 2: Commit**

```bash
git add plugins/standars-development/agents/security.md
git commit -m "feat: extend security agent with audit integration"
```

---

### Task 6: Actualizar `commands/lead.md`

**Files:**
- Modify: `plugins/standars-development/commands/lead.md`

- [ ] **Step 1: Reescribir comando lead**

```markdown
# Command: /lead

## Purpose

Invoke the orchestration engine to automatically classify your task and invoke relevant agents (review, architecture, security, optimize) in parallel.

## How It Works

1. You describe what you need
2. Lead asks 1-2 clarifying questions (optional)
3. Lead classifies task type automatically
4. Lead invokes relevant agents in parallel
5. Lead synthesizes results into unified report
6. Response is optimized for conciseness

## Usage

```
/lead I need to review this API endpoint for security and design patterns
```

## What Agents Get Invoked (Automatic)

- **code-review task** → review, security, optimize
- **architecture task** → architecture, security, optimize
- **security-audit task** → security, optimize
- **general inquiry** → optimize

## Output

Unified analysis from all agents + recommendations, ordered by severity.

## When to Use /lead

- General architecture or code review questions
- Security assessments
- Performance optimization
- Multi-faceted analysis requiring multiple perspectives

## When to Use Individual Agents

- `/review` — code quality only
- `/architecture` — design validation only
- `/security` — security only
- `/optimize` — compress response only
```

- [ ] **Step 2: Commit**

```bash
git add plugins/standars-development/commands/lead.md
git commit -m "docs: update lead command documentation"
```

---

### Task 7: Verificar integración con marketplace

**Files:**
- Check: `.claude-plugin/marketplace.json`
- Check: `plugins/standars-development/.claude-plugin/plugin.json`

- [ ] **Step 1: Renombrar directorio a ortografía correcta**

```bash
mv plugins/standars-development plugins/standards-development
```

- [ ] **Step 2: Commit cambio de nombre**

```bash
git add -A
git commit -m "chore: rename standars-development to standards-development (correct spelling)"
```

---

## Plan Self-Review

✅ **Spec Coverage:**
- Agente lead (orquestador) ✓ — Task 4
- Agente security ampliado ✓ — Task 5
- Clasificación automática ✓ — Task 4 + config
- Invocación paralela ✓ — Task 4
- Optimize obligatorio ✓ — Task 4
- Memoria inteligente ✓ — Task 2
- Auditoría/integración ✓ — Task 3 + Task 5

✅ **No Placeholders:** Todos los tasks tienen código exacto, comandos completos, paths precisos.

✅ **Gaps:** Ninguno — todos los requisitos tienen tarea.
