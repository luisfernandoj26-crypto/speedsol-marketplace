# Entregables de cada agente y pendientes del proyecto

> Análisis del estado del sistema SOC 2 Readiness Agents: qué produce cada
> agente, qué falta fuera de ejecutarlos, y qué priorizar primero.

---

## Parte 1: Qué entrega cada agente

Todos los agentes escriben tres tipos de artefactos: **findings** (JSON
estructurado), **evidencia** (archivos con hash SHA-256) y un
**run_summary.json** con métricas de su corrida. Lo específico de cada uno:

### Agentes de compliance (00–07)

| Agente | Entregable principal | Dónde lo escribe |
|---|---|---|
| **00 Compliance Orchestrator** | Reporte trimestral consolidado + carta de gestión + apéndices | `{OUTPUT_DIR}/reports/{RUN_ID}/` |
| **01 Access Control (CC6)** | Findings de MFA faltante, cuentas sin rotación, provisioning tardío, accesos no revocados, access reviews no realizados | `{FINDINGS_DIR}/cc6/` |
| **02 Operations (CC7)** | Findings de fuentes de log caídas, retención insuficiente, alertas no configuradas, IR plan no probado, incidentes sin RCA | `{FINDINGS_DIR}/cc7/` |
| **03 Change Management (CC8)** | Findings de PRs sin peer review, CI que no corre tests, deploys a prod sin aprobación, push directos a `main`, cambios mayores sin análisis de riesgo | `{FINDINGS_DIR}/cc8/` |
| **04 Risk & Vendor** | Findings de vendors críticos sin SOC 2, DPAs faltantes, risk register desactualizado, sub-procesadores no mapeados | `{FINDINGS_DIR}/cc3-cc9/` |
| **05 Availability (A1)** | Findings de backups no probados, DR drill atrasado, SLO incumplido, capacity planning ausente | `{FINDINGS_DIR}/a1/` |
| **06 Confidentiality (C1)** | Findings de datos sin clasificar, buckets sin cifrado en reposo, TLS < 1.2, retención no enforced, deletion requests sin evidencia | `{FINDINGS_DIR}/c1/` |
| **07 Governance (CC1-CC2)** | Findings de políticas desactualizadas, code of conduct no firmado, training de seguridad atrasado, org chart inconsistente | `{FINDINGS_DIR}/cc1-cc2/` |

Cada uno además produce para cada test que ejecuta:

- **Resultado del test** (`pass` / `fail` / `exception` / `not_applicable`)
  con evidencia que respalda la conclusión
- **Registro de continuidad** — evidencia capturada periódicamente durante
  el período de assessment (esto es lo que da calidad Type II)
- **Log de excepciones** — casos donde el test no pudo ejecutarse (tool
  caído, permisos insuficientes, ambigüedad)

### Agentes de código (10–15)

| Agente | Entregable principal | Dónde lo escribe |
|---|---|---|
| **10 Code Orchestrator** | Backlog priorizado de findings deduplicados, plan de remediación | `{OUTPUT_DIR}/code-runs/{RUN_ID}/backlog.json` |
| **11 SAST** | Findings clasificados (`confirmed_vulnerable`/`false_positive`/`context_dependent`/`already_mitigated`) con flujo de datos, CWE, snippet, sugerencia de fix sin aplicar | `{FINDINGS_DIR}/sast/` |
| **12 Secrets & Crypto** | Findings de secretos (con estado `live`/`revoked`/`unknown`), uso de algoritmos débiles, JWT mal configurados, bad randomness | `{FINDINGS_DIR}/secrets/` |
| **13 Dependencies & License** | SBOM (CycloneDX), CVEs priorizados por EPSS+KEV+reachability, licencias copyleft en prod, dependencias abandonadas, typosquatting | `{FINDINGS_DIR}/deps/` + `{EVIDENCE_STORE}/sboms/` |
| **14 IaC & Config** | Findings de Terraform/K8s/Dockerfiles/GHA/IAM con severity ajustada por contexto (recurso protegido, alcance del permiso) | `{FINDINGS_DIR}/iac/` |
| **15 Remediation** | **Pull Requests en GitHub** con fix + regression test + metadata de compliance + evidencia antes/después. Log de PRs abiertos, escalaciones y findings que no pudo remediar. | Git (PRs) + `{OUTPUT_DIR}/remediation/{RUN_ID}/` |

El Remediation Agent es el único que produce un entregable **externo al
filesystem local**: PRs reales en tu repo. Los demás producen archivos que
el orchestrator consume.

### Flujo de datos entre agentes

```
Compliance Agents (01-07)  ──┐
                             ├──► Findings JSON ──► Compliance Orchestrator (00) ──► Reporte trimestral
Code Detection (11-14)     ──┤                                     ▲
                             │                                     │
                             └──► Code Orchestrator (10) ──► Remediation (15) ──► PRs + evidencia remediación
```

---

## Parte 2: Qué falta fuera de ejecutar los agentes

Aquí hay dos tipos de "pendiente": lo que **falta para que el sistema
funcione** y lo que **falta para que el sistema sea útil a escala**. Los
separo.

### Pendientes críticos para que el sistema corra

**1. Infraestructura de ejecución (runtime).** Los prompts no se ejecutan
solos. Necesitas:

- Un orquestador real: Claude Agent SDK, LangGraph, CrewAI, o un runner
  casero con la Messages API. Recomendación: Agent SDK por simplicidad si
  no tienes preferencia fuerte.
- MCPs configurados: GitHub MCP (para el Remediation agent), Filesystem
  MCP (lectura de código), Postgres o S3 MCP (evidence store).
- Variables de entorno y secretos (API tokens de GitHub, credenciales
  cloud read-only, token de Anthropic) gestionados fuera del prompt. Los
  prompts referencian `{ENV_VAR}`; algo tiene que resolverlos.

**2. Evidence store implementado.** El diseño asume que existe; no está
construido. Decisiones pendientes:

- Backend: S3 con Object Lock (recomendado, cumple retención inmutable)
  vs Postgres con triggers append-only vs ambos.
- Esquema de paths: `s3://evidence/{RUN_ID}/{agent}/{test_id}/{evidence_id}.json`.
- Servicio de manifest signing (firma el manifest al cierre de cada run).
- API de lectura para el reporte (recuperar evidencia por ID, verificar hash).

**3. Sistema de redacción de PII.** Mencionado como requerimiento en
`skills/evidence-handling.md` pero no implementado. Necesitas una librería
o servicio que aplique los patrones de redacción **antes** de que la
evidencia toque el disco. Opciones: Microsoft Presidio, regex engine
casero, o AWS Comprehend. La redacción al capturar no es negociable
(sección 4.7 de `_context.md`).

**4. Catálogo completo de controles en `controls.yaml`.** Tiene tests
representativos pero no cubre todo el TSC. Faltan: CC2.2, CC2.3, CC3.1,
CC3.3, toda la serie CC4.x (Monitoring Activities), toda CC5.x (Control
Activities), CC6.4, CC6.5, CC7.5, CC9.1, A1.1, A1.3. Si agregas Privacy
o Processing Integrity, son ~30 tests más cada uno.

**5. Reglas Semgrep custom mapeadas a controles.** Semgrep con los
rulesets públicos encuentra vulnerabilidades, pero no sabe qué significa
CC6.1 para tu código. Necesitas reglas como:

```yaml
# Ejemplo: detectar endpoints sensibles sin logging de acceso (evidencia para CC6.1)
- id: soc2-cc6.1-endpoint-without-audit-log
  pattern: |
    @app.route($PATH)
    def $FUNC(...):
      ...
  pattern-not: |
    @app.route($PATH)
    def $FUNC(...):
      ...
      audit_log.record(...)
      ...
```

Sin esto, el SAST agent encuentra cosas genéricas pero no produce
evidencia específica para los controles del reporte.

### Pendientes para uso real y confiable

**6. Harness de testing con repos vulnerables conocidos.** Antes de
apuntar los agentes a tu código real, necesitas validar que encuentran lo
que deberían y no generan ruido. Repos sugeridos: OWASP Juice Shop,
NodeGoat, DVWA, Damn Vulnerable Cloud Application (DVCA) para IaC.
Métricas a medir:

- Recall: ¿encuentra las vulnerabilidades plantadas?
- Precision: ¿qué porcentaje de findings son verdaderos positivos?
- Calidad del triage del SAST agent (¿filtra FPs correctamente?)
- Calidad de los PRs del Remediation agent (¿un humano los aprobaría?)

Sin este paso vas a ciegas. Y si los agentes tienen baja precision en
repos conocidos, la van a tener peor en el tuyo.

**7. Pipeline CI/CD que invoca el sistema.** Los agentes deberían correr
automáticamente:

- Code agents: diariamente o por PR (detección continua)
- Compliance agents: semanalmente (operacional) + trimestralmente (para
  el reporte)
- Remediation agent: bajo demanda del Code Orchestrator

GitHub Actions, Jenkins, Argo Workflows, o Temporal. La elección depende
de tu stack.

**8. Dashboard operacional.** Lo que se genera son JSONs. Alguien tiene
que revisarlos. Mínimo: una vista web con findings abiertos por severity,
PRs pendientes de review humano, tests de control fallando, y tendencias.
Opciones: Grafana + Postgres, Metabase apuntando al evidence store, o
algo custom.

**9. Proceso humano alrededor del sistema.** Esto es lo que **más** se
olvida en implementaciones de este tipo:

- ¿Quién revisa los PRs que abre el Remediation agent? SLA de review.
- ¿Quién aprueba las excepciones cuando un test falla pero hay control
  compensatorio? Workflow de accepted_risk.
- ¿Quién firma el reporte trimestral antes de enviarlo a clientes? Esto
  es crítico — un reporte sin firma ejecutiva vale poco frente a un
  cliente enterprise.
- ¿Qué pasa cuando un test falla en período de assessment? Por definición
  Type II requiere que los controles operen continuamente; un failure
  mid-period tiene que documentarse con remediación.

**10. Plan de rollout progresivo del Remediation agent.** Está diseñado
con modos (`detect_only` / `suggest` / `open_pr` / `auto_merge`). Falta la
política de transición:

- Semana 1–4: `detect_only`
- Semana 5–8: `suggest` (comenta en PRs existentes)
- Semana 9+: `open_pr` solo para severity baja/media
- Severity crítica: **nunca** automático, siempre pairing humano-agente

### Pendientes para que el output sea comercialmente creíble

**11. Branding y forma final del reporte.** `templates/report-outline.md`
es estructura, no presentación. Necesitas:

- Diseño visual (PDF con tu logo, tipografía corporativa)
- Generador: Pandoc, Typst, o WeasyPrint según preferencia
- Portada con datos del assessment period, scope, versión
- Tabla de contenidos automática y paginación
- Apéndices con evidencia referenciada por ID (cliente puede auditarla
  bajo NDA)

**12. Disclaimer legal revisado por abogado.** El que generé es defensivo
y razonable, pero no lo escribió un abogado. Antes de mandar un reporte a
un cliente, un abogado colombiano con experiencia en tech (mejor si
conoce AICPA) debe revisarlo. Costo bajo, riesgo alto si se omite.

**13. NDA estándar para compartir el reporte.** El reporte contiene
detalle de tus controles y potencialmente findings abiertos. Debe
entregarse bajo NDA. Plantilla legal.

**14. Proceso de actualización del reporte.** Un cliente puede pedir el
último reporte 6 meses después del cierre del período. ¿Regeneras? ¿Das
el del último trimestre cerrado? Definir política.

---

## Parte 3: Lo que yo priorizaría primero

Si tuviera que elegir qué construir en las próximas 2–3 semanas antes de
cualquier otra cosa, sería esto, en este orden:

**Semana 1: infraestructura mínima viable.** Evidence store en S3 con
Object Lock + redacción de PII con Presidio + Claude Agent SDK como
runner. Sin esto, nada más corre.

**Semana 2: un solo agente end-to-end.** Elige el más valioso (sugerencia:
Secrets & Crypto, porque el ROI es inmediato y los failures son obvios).
Hazlo correr contra un repo de prueba hasta que el ciclo completo
funcione: detección → evidencia → finding → (si aplica) PR. Esto valida
el diseño completo con una superficie pequeña.

**Semana 3: harness de testing.** Apunta ese agente a OWASP Juice Shop o
equivalente. Mide precision/recall. Itera el prompt hasta que los números
sean aceptables.

Si esas tres semanas salen bien, los otros agentes son réplica del patrón
con cambios específicos. Si salen mal, descubres los problemas de diseño
temprano, antes de haber invertido en los 13 restantes.

---

## Resumen ejecutivo en 5 líneas

- Cada agente produce findings JSON + evidencia con SHA-256 + run_summary;
  el único que escribe fuera del filesystem es Remediation (PRs en GitHub).
- Faltan 14 cosas para que el sistema sea operativo y comercialmente
  creíble, agrupadas en 3 categorías: crítico para correr, necesario para
  uso confiable, necesario para entregar a clientes.
- Lo más subestimado: evidence store (PII + integridad + retención) y
  proceso humano (revisión de PRs, firma del reporte, SLA de excepciones).
- Primer hito de 2–3 semanas: infra mínima → un agente end-to-end →
  harness de testing contra repos vulnerables conocidos.
- Decisión abierta: elegir stack de runtime (Agent SDK / LangGraph /
  CrewAI) y backend de evidence store (S3 Object Lock / Postgres / ambos).
