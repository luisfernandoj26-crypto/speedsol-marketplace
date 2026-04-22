# Auditor-SOC2 Implementation Roadmap

> Plan de implementación basado en agent-deliverables-and-pending-work.md
> Status: 2026-04-22

---

## Fase 1: Infraestructura Crítica (Semana 1)

### 1.1 Evidence Store Implementation
- **Decisión:** S3 Object Lock (recomendado para retención inmutable)
- **Schema:** `s3://evidence/{RUN_ID}/{agent}/{test_id}/{evidence_id}.json`
- **Componentes:**
  - [ ] Bucket S3 configurado con Object Lock habilitado
  - [ ] Policy de retención mínima 90 días
  - [ ] Encriptación AES-256 en reposo
  - [ ] Versionamiento habilitado
  - [ ] Servicio de manifest signing (firma al cierre de run)
  - [ ] API de lectura para recuperar evidencia por ID
  - [ ] Verificación de integridad SHA-256

**Alternativa:** Postgres con triggers append-only + ambos para redundancia

---

### 1.2 Sistema de Redacción de PII
- **Selección:** Microsoft Presidio (recomendado) o regex engine casero
- **Timing:** Antes de que la evidencia toque el disco
- **Implementación:**
  - [ ] Librería Presidio integrada en evidence capture
  - [ ] Patrones de redacción definidos (SSN, email, API keys, tokens)
  - [ ] Logs de redacción para auditoría
  - [ ] Validación que PII no llega al evidence store

---

### 1.3 Runtime de Ejecución (Orquestador)
- **Selección recomendada:** Claude Agent SDK
- **Componentes:**
  - [ ] Agent SDK configurado con API token de Anthropic
  - [ ] MCPs instalados:
    - [ ] Filesystem MCP (lectura de código)
    - [ ] GitHub MCP (para Remediation agent)
    - [ ] S3/Postgres MCP (evidence store)
  - [ ] Variables de entorno centralizadas (no hardcoded)
  - [ ] Sistema de secrets management
  - [ ] Logging centralizado de ejecuciones

**Alternativas:** LangGraph, CrewAI, runner casero con Messages API

---

## Fase 2: Validación End-to-End (Semana 2)

### 2.1 Un Agente Completo
- **Selección:** Agent 12 - Secrets & Crypto (ROI inmediato, failures obvios)
- **Objetivo:** Ciclo completo: detección → evidencia → finding → PR
- **Entregables:**
  - [ ] Prompt del agente refinado con ejemplos reales
  - [ ] Integration con evidence store
  - [ ] Producción de findings JSON estructurados
  - [ ] Tests contra repo vulnerado conocido
  - [ ] Generación de PR con fix cuando aplica

---

### 2.2 Harness de Testing
- **Repos de prueba:**
  - [ ] OWASP Juice Shop (general vulnerabilities)
  - [ ] NodeGoat (Node.js vulnerabilities)
  - [ ] DVWA (PHP vulnerabilities)
  - [ ] DVCA (IaC vulnerabilities)

- **Métricas a medir:**
  - [ ] Recall: ¿encuentra las vulnerabilidades plantadas?
  - [ ] Precision: ¿qué % de findings son verdaderos positivos?
  - [ ] Triage quality (Agent 11-14): ¿filtra FPs correctamente?
  - [ ] Quality de PRs (Agent 15): ¿un humano los aprobaría?

---

## Fase 3: Sistema Operacional Completo (Semana 3-4)

### 3.1 Catálogo Completo de Controles
- **Estado actual:** Tests representativos
- **Pendientes:** CC2.2, CC2.3, CC3.1, CC3.3, CC4.x, CC5.x, CC6.4, CC6.5, CC7.5, CC9.1, A1.1, A1.3
- **Adicionales (si Privacy/PI):** ~30 tests más por cada uno

**Implementación:**
- [ ] Expandir `controls.yaml` con cobertura completa TSC
- [ ] Un test por sub-requisito de control
- [ ] Evidencia clara de cómo ejecutar y validar
- [ ] Mappeo de cada test a requisito exacto del TSC

---

### 3.2 Reglas Semgrep Custom
- **Objetivo:** Mapear vulnerabilidades de código a controles SOC 2
- **Ejemplo:** Detectar endpoints sin audit logging (evidencia para CC6.1)
- **Implementación:**
  - [ ] 5-10 reglas custom por agente de código (11-14)
  - [ ] Cada regla mappea a control específico
  - [ ] Incluir ejemplos de código vulnerable/seguro
  - [ ] Validar contra harness de testing

---

### 3.3 Pipeline CI/CD
- **Triggers:**
  - [ ] Code agents: daily + on PR
  - [ ] Compliance agents: weekly (operacional) + quarterly (reporte)
  - [ ] Remediation: on-demand de Code Orchestrator

- **Stack:** GitHub Actions (recomendado), Jenkins, Argo, o Temporal
- **Componentes:**
  - [ ] Workflow definitions
  - [ ] Secret rotation automation
  - [ ] Failure notifications
  - [ ] Audit log de runs

---

### 3.4 Dashboard Operacional
- **Mínimo requerido:**
  - [ ] Vista de findings abiertos por severity
  - [ ] PRs pendientes de review humano
  - [ ] Tests de control fallando
  - [ ] Tendencias (mejora/degradación)
  - [ ] SLA tracking

- **Opciones:** Grafana + Postgres, Metabase, custom React app
- **Data source:** Evidence store JSON + run_summary.json

---

## Fase 4: Credibilidad Comercial (Semana 4-5)

### 4.1 Proceso Humano (CRÍTICO)
- [ ] **SLA de review:** ¿Cuánto tarda en revisar un PR que abre Remediation?
- [ ] **Workflow de excepciones:** ¿Quién aprueba cuando test falla pero hay control compensatorio?
- [ ] **Firma ejecutiva:** ¿Quién firma el reporte antes de enviarlo a cliente?
- [ ] **Handling de failures mid-period:** ¿Cómo documentar si un test falla durante assessment Type II?
- [ ] **Roles y responsabilidades:** RACI matrix para auditoría

---

### 4.2 Rollout Progresivo del Remediation Agent
- **Modos:** `detect_only` → `suggest` → `open_pr` → `auto_merge` (never for critical)
- **Timeline:**
  - [ ] Semana 1-4: `detect_only` (solo detecta, no abre PR)
  - [ ] Semana 5-8: `suggest` (comenta en PRs existentes)
  - [ ] Semana 9+: `open_pr` solo para severidad baja/media
  - [ ] Crítica: nunca automático, siempre pairing humano-agente

---

### 4.3 Branding y Forma Final del Reporte
- [ ] Diseño visual (PDF con logo corporativo)
- [ ] Tipografía corporativa y estilos
- [ ] Generador de PDF: Pandoc, Typst, o WeasyPrint
- [ ] Portada: assessment period, scope, versión
- [ ] Tabla de contenidos automática
- [ ] Paginación y headers/footers
- [ ] Apéndices con evidencia referenciada por ID (bajo NDA)

---

### 4.4 Compliance Legal
- [ ] **Disclaimer legal:** Revisado por abogado colombiano con experiencia AICPA
- [ ] **NDA estándar:** Para compartir el reporte
- [ ] **Política de actualización:** ¿Cómo manejar requests de reporte 6 meses después?
- [ ] **Insurance & indemnification:** ¿Tienes errors & omissions insurance?

---

## Fase 5: Escala y Productización (Semana 6+)

### 5.1 Todos los Agentes (01-07 y 10-15)
Una vez validado el patrón con Secrets & Crypto:
- [ ] Agents 01-07: Compliance orchestration
- [ ] Agents 10-14: Code detection
- [ ] Agent 15: Remediation completo
- [ ] Agent 00: Consolidación de reportes

---

### 5.2 Automatización de Reportes
- [ ] Generación trimestral automática
- [ ] Distribución a stakeholders
- [ ] Versionamiento y archivado
- [ ] Change tracking (comparación trimestral)

---

### 5.3 Integraciones Externas (Opcional)
- [ ] Slack/Teams notificaciones de findings críticos
- [ ] Jira/Linear integration para tracking de remediación
- [ ] Webhook para sistemas de inventario (asset management)
- [ ] Export a formatos estándar (Defect Dojo, OpenVAS, etc.)

---

## Decisiones Pendientes (No-go/Go Gates)

| Decisión | Opciones | Recomendación | Fecha Límite |
|----------|----------|---------------|--------------|
| Runtime | Agent SDK / LangGraph / CrewAI | Agent SDK | Antes Semana 1 |
| Evidence Backend | S3 Object Lock / Postgres / Ambos | S3 (single source of truth) | Antes Semana 1 |
| PII Redaction | Presidio / Custom Regex / AWS Comprehend | Presidio | Antes Semana 1 |
| PDF Generator | Pandoc / Typst / WeasyPrint | Typst (modern, Rust-based) | Antes Semana 4 |
| Dashboard | Grafana / Metabase / Custom | Grafana + Postgres (open source) | Antes Semana 3 |
| CI/CD Platform | GitHub Actions / Jenkins / Argo / Temporal | GitHub Actions (integrado) | Antes Semana 3 |

---

## Métricas de Éxito

### Por Fase
- **Fase 1:** Evidence store operativo, PII redacted, agents pueden loguear
- **Fase 2:** Agent 12 encuentra 90%+ de secretos reales en Juice Shop, precision >95%
- **Fase 3:** Pipeline CI/CD ejecuta diariamente sin errores, dashboard completo
- **Fase 4:** Reporte PDF generado sin intervención manual, proceso humano documentado
- **Fase 5:** Sistema corre 100% automatizado, 0 manual toil

### Comerciales
- Reporte trimestral listo en <2 horas de compute
- 0 findings falsos positivos sin re-review
- NPS cliente >8/10 en credibilidad de reporte
- Compliance score tracking (mejora trimestral esperada >5%)

---

## Riesgos Mitigación

| Riesgo | Mitigation |
|--------|-----------|
| Evidence store pierde data | S3 Object Lock (inmutable por x días) + Postgres backup diario |
| PII leak en reports | Redacción en capture time, nunca en disk. Auditar logs de redacción. |
| Agentes generan ruido (FPs altos) | Harness testing antes de prod. Threshold de precision >90%. |
| Reportes rechazados por cliente (legal) | Disclaimer revisado por abogado. Insurance. |
| Remediation agent rompe cosas | Rollout progresivo (detect → suggest → PR). Nunca crítica automática. |
| Compliance drift entre runs | Evidence store es single source. Manifest signing. Change tracking. |

---

## Budget/Resources Estimado

| Item | Effort | Timeline | Owner |
|------|--------|----------|-------|
| Evidence Store | 2 sprints | Semana 1-2 | DevOps / Platform |
| PII + Runtime | 1 sprint | Semana 1 | Backend / Security |
| Agent 12 E2E | 2 sprints | Semana 2-3 | AI/ML Engineer |
| Harness + Testing | 1.5 sprints | Semana 3 | QA / Security |
| CI/CD + Dashboard | 2 sprints | Semana 3-4 | DevOps |
| Legal + Branding | 1 sprint | Semana 4 | Legal / Product |
| Agents 01-07, 10-14 | 4 sprints | Semana 5-8 | AI/ML Team (2-3) |
| Productización | 2 sprints | Semana 9-10 | DevOps / Product |

**Total:** ~16 sprints (4 personas, 4 semanas) o 8 sprints (8 personas, 4 semanas)

---

## Siguientes Pasos Inmediatos (Esta Semana)

1. [ ] Reúnete con DevOps/Platform para decidir Evidence Store (S3 vs Postgres)
2. [ ] Obtén cotización de Presidio vs custom regex (tiempo de dev)
3. [ ] Evalúa Agent SDK vs LangGraph en un pequeño prototype
4. [ ] Crea tickets Jira/Linear para Fase 1 con dependencias
5. [ ] Agenda kick-off con legal (disclaimer + NDA)
6. [ ] Clona OWASP Juice Shop para harness de testing

---

**Documento Propietario — Speed Solutions S.A.S.**  
*Última actualización: 2026-04-22*
