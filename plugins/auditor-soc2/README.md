# SOC 2 Readiness Agents

Sistema multi-agente para realizar una **auto-evaluación de controles alineada con SOC 2 Trust Service Criteria** sobre un producto SaaS, incluyendo auditoría de código fuente.

> ⚠️ **Aviso legal importante**
>
> Este sistema **no emite informes SOC 2**. Un informe SOC 2 oficial solo puede ser emitido por una firma independiente de contadores públicos (CPA) licenciada siguiendo AICPA AT-C 205. Este sistema produce un **"SOC 2 Readiness Report" / "Informe de Preparación SOC 2"** — una auto-evaluación interna comunicable a clientes bajo NDA.
>
> Nunca utilices términos como "SOC 2 Certified" o "SOC 2 Compliant" para referirte al output de este sistema. AICPA protege activamente su marca.

---

## Estructura

```
soc2-agents/
├── config/
│   ├── environment.template.yaml      # Configuración maestra parametrizable
│   └── controls.yaml                  # Catálogo de controles SOC 2 y tests
├── skills/
│   ├── risk-scoring.md                # Modelo de 4 dimensiones para severidad
│   ├── finding-schema.md              # Estructura canónica de un hallazgo
│   ├── evidence-handling.md           # Integridad, redacción de PII, retención
│   ├── control-testing.md             # Protocolo de ejecución de pruebas
│   └── pr-generation.md               # Workflow de 5 fases para remediation
├── agents/
│   ├── 00-compliance-orchestrator.md  # Coordina compliance agents, genera reporte
│   ├── 01-access-control-cc6.md       # CC6: MFA, passwords, SSH, provisioning, revocación
│   ├── 02-operations-cc7.md           # CC7: logging, monitoring, IR, RCA
│   ├── 03-change-management-cc8.md    # CC8: PR reviews, CI, deploy approvals
│   ├── 04-risk-vendor.md              # CC3, CC9: risk register, vendor management
│   ├── 05-availability-a1.md          # A1: backups, DR, SLO
│   ├── 06-confidentiality-c1.md       # C1: TLS, encryption at rest, classification
│   ├── 07-governance-cc1-cc2.md       # CC1, CC2: policies, training, acknowledgments
│   ├── 10-code-orchestrator.md        # Coordina code agents, despacha remediation
│   ├── 11-sast.md                     # SAST + triage contextual
│   ├── 12-secrets-crypto.md           # Secretos + review criptográfica
│   ├── 13-dependencies-license.md     # SCA + reachability + licencias
│   ├── 14-iac-config.md               # IaC, K8s, Dockerfiles, CI workflows, IAM
│   └── 15-remediation.md              # PR generator — quirúrgico, nunca mergea
├── templates/
│   ├── finding.schema.json            # Schema JSON para validar hallazgos
│   └── report-outline.md              # Plantilla del reporte final
└── README.md
```

---

## Arquitectura

```
                    ┌────────────────────────────┐
                    │ COMPLIANCE ORCHESTRATOR    │
                    │ (agente 00)                │
                    │ coordina + reporta         │
                    └──┬─────────────────────┬───┘
                       │                     │
         ┌─────────────┴──────┐     ┌───────┴──────────┐
         │ COMPLIANCE AGENTS  │     │ CODE AGENTS      │
         │ auditan controles  │     │ (via orchestrator│
         │ 01 Access Control  │     │  agente 10)      │
         │ 02 Operations      │     │                  │
         │ 03 Change Mgmt     │     │ 11 SAST          │
         │ 04 Risk & Vendor   │     │ 12 Secrets+Crypto│
         │ 05 Availability    │     │ 13 Dependencies  │
         │ 06 Confidentiality │     │ 14 IaC + Config  │
         │ 07 Governance      │     │                  │
         └────────────────────┘     └────────┬─────────┘
                                             │
                                    ┌────────▼─────────┐
                                    │ REMEDIATION      │
                                    │ (agente 15)      │
                                    │ abre PRs, nunca  │
                                    │ mergea           │
                                    └──────────────────┘
```

Toda la comunicación entre agentes es mediante **findings en JSON** conformes a `templates/finding.schema.json` y **evidencia almacenada** con hashes SHA-256.

---

## Cómo usar

### Paso 1 — Configurar el entorno

```bash
cp config/environment.template.yaml config/environment.yaml
# Editar environment.yaml con los valores reales de tu organización
```

Campos críticos a llenar:
- `organization.*` — razón social, producto en alcance, periodo
- `source_code.repositories[].local_path` — rutas absolutas a cada repo
- `git_platform.organization` y `api_token_env_var`
- `environments.qa.url`, `environments.staging.url`
- `cloud.aws.readonly_role_arn` (o equivalente para GCP/Azure)
- `identity_provider.*` — Okta/AzureAD/GWorkspace
- `observability.siem_*` — Datadog/Splunk/Elastic
- `issue_tracker.*` — Jira/Linear
- `evidence_store.bucket_or_path` — S3 con Object Lock recomendado

### Paso 2 — Ajustar el catálogo de controles

Editar `config/controls.yaml` para:
- Añadir tests específicos a tu stack
- Quitar controles fuera de alcance
- Ajustar `pass_criteria` a tus umbrales

### Paso 3 — Provisionar credenciales (variables de entorno)

```bash
export GITHUB_TOKEN=ghp_...          # token read-only
export OKTA_API_TOKEN=...            # read-only
export DATADOG_API_KEY=...
export DATADOG_APP_KEY=...
export AWS_PROFILE=soc2-readonly     # perfil con rol read-only asumido
export JIRA_API_TOKEN=...
# ... según tu stack
```

**Nunca commitees estos valores**. Los agentes solo leen el nombre de la variable, no el valor.

### Paso 4 — Ejecutar

El sistema se puede correr de varias formas — elige según tu runtime:

**Opción A: Claude Agent SDK / Claude Code**
```bash
# Con el cliente oficial
claude-code --system-prompt agents/00-compliance-orchestrator.md \
            --allowed-tools "file_read,bash,web_fetch" \
            --working-dir /workspace/soc2-agents
```

**Opción B: API de Anthropic + orquestador propio**
- Leer el prompt de un agente
- Reemplazar `{{VARIABLES}}` con los valores de `environment.yaml`
- Enviar al endpoint `/v1/messages`
- Proveer herramientas MCP (filesystem, github, bash)

**Opción C: LangGraph / CrewAI**
- Modelar cada agente como nodo
- El orchestrator es el grafo raíz
- Usar tools nativos de la librería

### Paso 5 — Revisar outputs

```
reports/
├── SOC2-Readiness-2026-06-30.md       # Reporte final
├── SOC2-Readiness-2026-06-30.pdf      # (si se configuró)
├── control-matrix-2026-06-30.csv      # Matriz tabular
└── trend-2026-06-30.json              # Comparación con periodos previos

findings/
└── {run_id}/
    ├── findings/*.json                # Hallazgos individuales
    └── test_results/*.json            # Resultado por cada test

evidence/
└── {run_id}/
    ├── manifest.json                  # Manifiesto firmado
    ├── manifest.sig                   # Firma GPG
    └── ...                            # Evidencia cruda (hasheada)
```

---

## Modos de ejecución

Configurable vía `policies.agent_execution_mode` en `environment.yaml`:

| Modo | Comportamiento |
|------|----------------|
| `read_only` | Solo detección. No PRs, no tickets, solo hallazgos. **Recomendado al inicio.** |
| `suggest` | Remediation Agent comenta sugerencias en archivos locales, no toca git. |
| `open_pr` | Remediation Agent abre PRs en modo Draft (severity crítico) o Ready (low/medium). |
| `auto_merge` | **NO recomendado.** Requiere salvaguardas adicionales en CI. |

---

## Despliegue recomendado

**Semana 1-2:** Configurar, ejecutar en `read_only`. Revisar falsos positivos, calibrar `pass_criteria`.
**Semana 3-4:** Agregar code agents, también en `read_only`. Usar findings para tickets manuales.
**Semana 5-6:** Pasar a `suggest`. Los ingenieros ven propuestas, deciden aplicar.
**Semana 7-8+:** Pasar a `open_pr` pero solo para severity `low`/`medium`. Nunca `critical` auto-PR.
**3 meses en adelante:** Evaluar métricas de calidad (merge rate, revert rate). Ajustar thresholds.

---

## Controles de seguridad del propio sistema

El sistema de agentes es también una superficie de ataque. Controles integrados:

1. **Agentes corren con credenciales read-only** excepto Remediation (que puede hacer push a branches propios de la bot).
2. **Remediation nunca mergea** — el humano aprueba.
3. **PROHIBITED_PATHS** previene modificación de CI, CODEOWNERS, policies.
4. **Límite de PRs por run** evita floods.
5. **Evidencia inmutable** con Object Lock — nadie (ni el agente) puede reescribir evidencia pasada.
6. **Bot de git tiene su propio usuario** — auditable, revocable.
7. **Rate limits** y **timeouts** previenen runaway agents.
8. **Prompts versionados en git** — cambios al prompt pasan por PR review.

---

## Métricas de calidad

Tracked over time por el orchestrator:

- **Merge rate de PRs del remediation agent** (target ≥ 70%)
- **First-pass approval rate** (target ≥ 50%)
- **Revert rate** (target ≤ 5%)
- **Falsos positivos** (target ≤ 20% después de triage)
- **Cobertura de controles** (% de tests ejecutados vs catálogo)
- **Tiempo a detección** y **tiempo a remediación** por severidad

Si estas métricas degradan, el orchestrator automáticamente restringe los modos más agresivos.

---

## Limitaciones conocidas

- **No reemplaza auditoría humana.** Ciertos controles (gestión del riesgo, tone-from-the-top) requieren juicio humano; los agentes los marcan como `manual_attestation`.
- **Reachability analysis es aproximada.** Para código con reflexión/dinámico, degradamos a "UNKNOWN" y tratamos como potencialmente alcanzable.
- **LLM hallucination risk.** Mitigación: los agentes DEBEN citar evidencia verificable; sin evidencia no hay finding.
- **Escalabilidad de triage.** Repos muy grandes pueden exceder el budget de tokens. Priorizar severity + paginar.
- **Cobertura de controles.** El catálogo actual cubre los controles de alto impacto. Completar según alcance de cada organización.

---

## Extensión

Para agregar un nuevo agente:

1. Crear `agents/NN-nombre.md` siguiendo la estructura (RUNTIME PARAMETERS, Skills, Tools, Workflow, Output).
2. Registrar en `agents/00-compliance-orchestrator.md` → `AGENTS_TO_INVOKE`.
3. Añadir los tests correspondientes a `config/controls.yaml` con `agent: tu_agente_id`.
4. Ejecutar y ajustar.

Para agregar un nuevo control/test:

1. Añadir entrada en `config/controls.yaml` bajo el control apropiado.
2. Asignar `agent:` al agente que lo ejecutará.
3. Definir `pass_criteria` como expresión evaluable.
4. Actualizar el agente responsable con el nuevo procedimiento (sección "Test Execution Procedures").

---

## Soporte y gobierno

- **Owner:** equipo de Seguridad / Compliance
- **Reviewers de prompts:** 2 personas del equipo, obligatorio peer review en cambios
- **Cadencia de ejecución:** semanal o diaria para controles continuos; trimestral para reporte completo
- **Retention de evidencia:** 7 años mínimo (ajustar por jurisdicción)

---

## Glosario corto

- **Agente**: un system prompt + configuración + herramientas, con un rol específico
- **Skill**: capacidad reutilizable compartida entre agentes (p.ej. "cómo puntuar riesgo")
- **Finding**: hallazgo de no conformidad, estructurado según el schema
- **Run**: una ejecución completa del orchestrator
- **Manifiesto**: registro firmado de todo lo que se hizo en un run
