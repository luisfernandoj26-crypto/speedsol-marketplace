# _context.md — Contexto del proyecto SOC 2 Readiness Agents

> **Lee este documento completo antes de hacer cualquier cambio al sistema.**
> Aquí están las decisiones, restricciones y convenciones que no están escritas
> en ningún otro archivo pero que determinan qué es aceptable y qué no.
>
> Si una instrucción del usuario parece contradecir algo aquí, **pregunta antes
> de proceder** — este documento encapsula decisiones conscientes tomadas tras
> analizar alternativas.

---

## 1. Qué es este proyecto

Un **sistema multi-agente para realizar auto-evaluación de controles de seguridad
alineada con SOC 2 Trust Service Criteria** sobre un producto SaaS. Tiene dos
capacidades integradas:

1. **Auditoría de controles operacionales** (agentes 00–07): revisa IdP,
   cloud, logs, change management, vendors, backups, cifrado, políticas.
2. **Auditoría de código fuente** con remediación asistida (agentes 10–15):
   SAST, secretos/crypto, dependencias, IaC, y un agente de remediación que
   abre Pull Requests con fixes.

El output final es un **informe trimestral** ("SOC 2 Readiness Assessment")
que el usuario entrega a sus clientes como evidencia de postura de seguridad.

---

## 2. Quién es el usuario y qué quiere lograr

- **Ubicación**: Bogotá, Colombia.
- **Producto**: SaaS B2B (detalles específicos no divulgados en las
  conversaciones; cuando sean relevantes, preguntar).
- **Audiencia del deliverable**: clientes enterprise que piden artefactos de
  assurance durante sus procesos de vendor security review.
- **Decisión de negocio consciente**: NO va a contratar una firma CPA para un
  SOC 2 oficial (al menos en la fase actual). El sistema genera un sustituto
  comunicable bajo NDA, no un reemplazo legal.
- **Métrica de éxito**: que el reporte reduzca fricción en ciclos comerciales
  con clientes enterprise. La métrica NO es "cantidad de findings" ni
  "cantidad de PRs generados".

---

## 3. Restricción legal AICPA — NO CRUZAR

Esta es la única línea roja **inviolable** del proyecto.

**Qué dice la AICPA**: Solo firmas de contadores públicos (CPA) licenciadas,
siguiendo el estándar AT-C 205, pueden emitir informes SOC 2. "SOC 2" es una
marca registrada protegida activamente.

**Consecuencia directa**: este sistema **nunca** produce un "SOC 2 report".
Produce una auto-evaluación que usa los TSC como marco de referencia.

### Lenguaje permitido

- "SOC 2 Readiness Assessment"
- "SOC 2-Aligned Security Report"
- "Internal Controls Report based on AICPA Trust Service Criteria"
- "Auto-evaluación de controles alineada con SOC 2"
- "Informe de preparación SOC 2"

### Lenguaje prohibido (en código, prompts, reportes, emails a clientes, marketing)

- "SOC 2 Certified" ❌
- "SOC 2 Compliant" ❌
- "SOC 2 Audit" ❌ (sin aclarar que es interno)
- "SOC 2 Report" sin calificador ❌
- Cualquier cosa que sugiera equivalencia con un informe emitido por CPA ❌

### Qué hacer si el usuario pide esto

Si el usuario pide "llámalo SOC 2 Compliant en el reporte" o equivalente,
**no lo hagas**. Explica la restricción y ofrece alternativas. Esto protege
al usuario de riesgo legal aunque él mismo lo pida. Es la única vez que
está bien contradecir una instrucción directa.

---

## 4. Decisiones arquitectónicas con su justificación

Cada decisión aquí fue tomada tras evaluar alternativas. No las revises sin
entender el trade-off.

### 4.1 Dos sistemas de agentes separados (compliance + code)

- **Alternativa descartada**: un mega-agente que hace todo.
- **Por qué separados**: los agentes de compliance necesitan permisos de
  lectura amplios sobre sistemas operacionales (IdP, cloud, SIEM). Los de
  código necesitan permisos de escritura sobre git. Mezclar superficies de
  ataque aumenta el blast radius de un compromiso del agente.

### 4.2 Detección y remediación separadas dentro del subsistema de código

- **Alternativa descartada**: un agente que escanea y arregla en el mismo flujo.
- **Por qué separadas**: detección necesita **alto recall y read-only**.
  Remediación necesita **precisión quirúrgica y acceso write**. Mezclarlas
  produce fixes de baja calidad (agente apurado que parcha sin entender).
  Además, la separación permite que múltiples agentes de detección alimenten
  a un único Remediation Agent que deduplica y prioriza.

### 4.3 Claude como capa de triage sobre herramientas deterministas

- **Alternativa descartada**: pedirle a Claude "analiza el repo buscando vulnerabilidades".
- **Por qué triage**: los LLMs alucinan, omiten, y producen resultados
  inconsistentes entre corridas cuando se usan como scanners primarios.
  Semgrep, gitleaks, osv-scanner, checkov son deterministas, rápidos y tienen
  catálogos de reglas auditados. Claude añade valor donde las herramientas
  son débiles: **contexto** (¿es alcanzable este sink desde input externo?),
  **triage de false positives** (¿hay sanitización upstream que la herramienta
  no vio?), **priorización** (¿este CVE está en una función realmente
  invocada?), y **redacción de remediaciones coherentes con el estilo del codebase**.

### 4.4 Remediation Agent con workflow de 5 fases

- **Alternativa descartada**: flujo simple leer→parchar→PR.
- **Por qué 5 fases** (UNDERSTAND / PLAN / IMPLEMENT / VERIFY / HANDOFF):
  cada fase tiene un gate explícito. UNDERSTAND fuerza a leer callers y tests
  antes de tocar nada. PLAN fuerza a explicitar trade-offs. IMPLEMENT obliga
  a agregar regression test. VERIFY exige re-ejecutar el scanner. HANDOFF
  exige PR en draft si hay cualquier duda. Los gates previenen el modo de
  falla típico donde el agente "arregla" superficialmente algo que no entiende.

### 4.5 El Remediation Agent NUNCA mergea PRs

- **Alternativa descartada**: auto-merge para fixes triviales/de baja severidad.
- **Por qué nunca**: el merge es el único punto irreversible en el pipeline.
  Un agente con capacidad de merge se vuelve un vector de ataque: si un
  atacante compromete el prompt o el contexto del agente, puede introducir
  código malicioso en `main`. Mantener el merge humano preserva el "four
  eyes principle" exigido por CC8.
- **Aplicable incluso después de meses de data de calidad**: esta no es una
  restricción temporal. Es permanente.

### 4.6 Modelo de scoring de riesgo de 4 dimensiones

- **Alternativa descartada**: CVSS solo, o modelo simple de 3 dimensiones.
- **Por qué 4 dimensiones** (Criticality 1.5x, Exposure 1.5x, Exploitability 1x, Detectability 1x):
  CVSS solo es genérico y no toma en cuenta tu contexto. Un CVE 9.8 en una
  librería que no usas no es crítico para ti. Exposure y Criticality tienen
  peso 1.5x porque "¿está expuesto a internet?" y "¿toca datos sensibles?"
  son las dos preguntas que más mueven la aguja en impacto real. Exploitability
  y Detectability ajustan pero no dominan.

### 4.7 Evidencia con SHA-256, redacción de PII al capturar, retención 7 años

- **Alternativa descartada**: logs en texto plano, redacción post-hoc.
- **Por qué al capturar**: si capturas con PII y redactas después, tienes PII
  en reposo en ventanas de tiempo variables. GDPR, ley 1581 (Colombia),
  CCPA — todas tratan "tener PII" como el evento crítico, no "mostrar PII".
  Redactar al capturar significa que el evidence store **nunca** contiene PII.
- **Por qué SHA-256 en todo**: el reporte cita evidencia. Un cliente sofisticado
  puede pedir verificar que la evidencia no fue modificada después de capturada.
  Hashes + S3 Object Lock le dan integridad criptográfica.
- **Por qué 7 años**: período estándar de retención para evidencia de
  auditoría bajo varios marcos (SOX, HIPAA). Más barato sobreajustar que
  subajustar.

### 4.8 RUNTIME PARAMETERS al inicio de cada prompt de agente

- **Alternativa descartada**: paths hardcodeados, o solo variables de entorno.
- **Por qué en el prompt**: el prompt es auditable. Un reviewer o auditor
  puede ver literalmente qué paths/credenciales/políticas se le pasaron al
  agente en una corrida específica. Env vars se pierden. Hardcoded no es
  reutilizable entre orgs.
- **environment.template.yaml como fuente de verdad**: previene drift. Cada
  agente hereda un subconjunto de ese archivo. Si cambias un path ahí, todos
  los agentes lo ven.

### 4.9 Findings en JSON conformes a finding.schema.json

- **Alternativa descartada**: findings en texto libre.
- **Por qué schema**: machine-readable, deduplicable por `dedup_key`,
  agregable entre agentes, auditable con tooling estándar (jq, JSON Schema
  validators), y produce un audit trail que un CPA podría usar en el futuro
  si el usuario decide ir a certificación oficial.

### 4.10 Archivos técnicos en inglés, documentación estratégica en español

- **Convención**: los prompts, schemas, configs y agentes están en inglés
  porque es el idioma técnico estándar, la mayoría de las herramientas usan
  inglés, y la reutilización entre equipos/empresas es mayor.
- **Documentos estratégicos y de contexto** (este archivo, onboarding prompts,
  comunicaciones internas) en español, porque son lectura humana para el
  equipo del usuario.

---

## 5. Convenciones del proyecto

### 5.1 Nomenclatura de IDs

| Tipo | Formato | Ejemplo |
|---|---|---|
| Test de control | `{control}-T{NN}` | `CC6.1-T01` |
| Finding de código | `{agent}-{year}-{seq}` | `SAST-2026-0042` |
| Finding de compliance | `{control}-F{NN}` | `CC7.2-F03` |
| Run ID | `run-{YYYYMMDD}-{HHMMSS}-{slug}` | `run-20260422-141500-q2-assessment` |
| Evidence ID | `evidence-{sha256[:12]}` | `evidence-a3f2b1c8d9e0` |

### 5.2 Estructura estándar de un agente

Todo agente nuevo debe seguir esta estructura en su `.md`:

```
# Nombre del Agent

## Role
(qué hace, qué NO hace, a quién entrega)

## RUNTIME PARAMETERS
(YAML con parámetros, heredados + específicos)

## Skills to Load
(lista de archivos de /skills/ que debe cargar antes)

## Tools Available
(tool calls permitidos, con alcance)

## Test Execution Procedures (o Detection Procedures según el caso)
(uno por cada test/detección, con pass_criteria y evidencia)

## Standard Flow
(el flujo paso a paso de una corrida)

## Boundaries — What You Don't Do
(explícito; esta sección es crítica)

## Output Summary
(qué escribe y dónde)

## Failure Modes
(qué hacer ante errores de herramientas, credenciales, etc.)
```

### 5.3 Parametrización de paths

- Nunca hardcodees paths. Usa variables del `RUNTIME PARAMETERS`.
- Notación: en prosa usa `{{VAR_NAME}}`, en YAML usa keys directas.
- Si un agente necesita un path nuevo, agrégalo primero a
  `config/environment.template.yaml` y luego lo refiere desde el agente.

### 5.4 Redacción de PII en evidencia

Patrones canónicos (ver `skills/evidence-handling.md`):

| Tipo | Antes | Después |
|---|---|---|
| Email | `juan@acme.com` | `<EMAIL:a3f2b1c8>` |
| Token/API key | `ghp_abc123...` | `<TOKEN:github_pat>` |
| IP privada | `10.0.1.42` | `<IP:internal>` |
| Número de documento | `CC 1020304050` | `<DOC:redacted>` |
| Nombre propio | `Juan Pérez` | `<NAME:hash8>` |

Hash de 8 caracteres permite deduplicar (mismo email → mismo hash) sin exponer el valor.

### 5.5 Transiciones de estado de findings

Los findings NUNCA se eliminan. Solo transicionan:

```
open → triaged → in_remediation → verified → closed
                      ↓
                accepted_risk (requiere justificación firmada)
                      ↓
                false_positive (requiere evidencia)
```

Cerrar un finding sin que el scanner lo confirme como resuelto es una
violación de integridad.

---

## 6. Estado actual del trabajo

### 6.1 Archivos completos y funcionales

- `config/environment.template.yaml` — configuración maestra
- `config/controls.yaml` — catálogo de tests para CC1.1–C1.2 (no exhaustivo,
  pero representativo)
- `skills/` — los 5 skills completos (risk-scoring, finding-schema,
  evidence-handling, control-testing, pr-generation)
- `agents/00-compliance-orchestrator.md` — orquestador maestro
- `agents/01-access-control-cc6.md` a `07-governance-cc1-cc2.md` — 7 agentes de compliance
- `agents/10-code-orchestrator.md` a `15-remediation.md` — 6 agentes de código (incluye orchestrator)
- `templates/finding.schema.json` — schema JSON machine-readable
- `templates/report-outline.md` — plantilla del reporte
- `README.md` — guía de uso para operador humano

### 6.2 Placeholders y mocks conocidos

- `controls.yaml` tiene tests de ejemplo pero no cubre TSC completo (faltan
  CC2.2, CC2.3, CC3.1, CC3.3, CC4.x, CC5.x, CC6.4, CC6.5, CC7.5, CC9.1, A1.1,
  A1.3, P1.x, P2.x si se agrega Privacy).
- Los `BOT_USER_*` en 15-remediation son placeholders.
- Los dominios `acme.com` y similares son placeholders — deben reemplazarse
  al instanciar.

### 6.3 Pendiente de implementar (roadmap discutido)

En orden sugerido de prioridad:

1. **Reglas Semgrep custom** mapeadas 1:1 a los tests de `controls.yaml`.
   Ej: detectar endpoints sin logging de acceso → evidencia para CC6.1.
2. **Implementación de referencia** en Claude Agent SDK + MCPs (GitHub,
   Filesystem, Postgres para evidence store).
3. **Test harness** con repos vulnerables conocidos (OWASP Juice Shop,
   NodeGoat, DVWA) para validar calidad del SAST + Remediation antes de
   apuntar al código real.
4. **Reporte de ejemplo lleno** con data ficticia, para mostrar a clientes
   cómo se verá el deliverable.
5. **Pipeline CI/CD** que ejecute el sistema en cadencia (diaria para code
   agents, semanal para compliance agents, trimestral para el reporte).
6. **Dashboard operacional** para revisar findings abiertos, PRs pendientes
   de review, tests de control fallados.

---

## 7. Anti-patrones — si te piden esto, NO lo hagas sin advertir

### Renombrar el deliverable a algo que sugiera certificación

- "Llámalo SOC 2 Compliance Report" → ❌ violación AICPA, riesgo legal.
- Solución: mantener terminología de readiness/alignment.

### Auto-merge de PRs del Remediation Agent

- "Permite que haga merge de fixes de severidad baja automáticamente" → ❌.
- Razón: elimina el four-eyes principle (CC8), crea vector de ataque.

### Consolidar agentes en uno solo "para simplificar"

- "Fusiona SAST y Secrets en un solo agente" → ❌ sin discusión previa.
- Razón: cada agente tiene contexto, permisos y failure modes distintos.

### Medir éxito por volumen

- "Ranking de agentes por cantidad de findings" → ❌ es una métrica perversa.
- Métrica correcta: rate de findings confirmados como true positive, rate
  de PRs aprobados en primera revisión humana, tiempo medio a remediación.

### Reducir la redacción de PII "porque complica"

- "Guardemos los emails en claro que es más fácil de debuggear" → ❌.
- Razón: exposición regulatoria. La redacción es al capturar, no opcional.

### Eliminar findings del registro

- "Borremos los falsos positivos del histórico" → ❌.
- Los marcas como `false_positive` con justificación. No se borran.

### Dar al agente más permisos "para que pueda hacer más cosas"

- "Dale acceso de admin en AWS para que verifique mejor" → ❌ sin análisis.
- Principio: least privilege. Cada permiso nuevo requiere justificación
  explícita en el prompt y audit trail.

### Saltarse el triage y reportar output crudo de herramientas

- "Para ir más rápido, mandemos todo lo que dice Semgrep al reporte" → ❌.
- El valor del sistema está en el triage. Output crudo abruma a reviewers
  y diluye señal.

---

## 8. Cómo continuar este trabajo en una sesión nueva

### 8.1 Flujo recomendado

1. El usuario pega `_onboarding_prompt.md` al inicio.
2. Claude lee `_context.md` (este archivo) completo.
3. Claude lee `README.md` para entender la estructura.
4. Claude confirma entendimiento y pregunta qué sigue, sin proponer cambios aún.
5. Según la tarea, Claude lee los archivos específicos relevantes.

### 8.2 Si el pedido es agregar un nuevo agente o test de control

- Primero lee `skills/control-testing.md` (para compliance) o
  `skills/finding-schema.md` (para código).
- Copia la estructura de un agente existente similar.
- Agrega los parámetros nuevos a `config/environment.template.yaml` primero.
- Actualiza `README.md` y este archivo en las secciones 6.1 y 6.3.

### 8.3 Si el pedido es modificar una decisión arquitectónica

- **Detente**. Revisa sección 4 para ver la justificación original.
- Pregunta al usuario explícitamente si quiere revertir esa decisión.
- Si procede, actualiza la sección 4 con la nueva decisión y la fecha,
  preservando la racional previa como histórico.

### 8.4 Si el pedido conflictúa con AICPA

- Ver sección 3. No procedas. Explica al usuario.

### 8.5 Si hay ambigüedad

- Pregunta. El usuario prefiere una pregunta aclaratoria corta a un
  entregable grande que tome la dirección equivocada.

---

## 9. Glosario mínimo

| Término | Significado en este proyecto |
|---|---|
| **TSC** | Trust Service Criteria (AICPA): CC (Common Criteria), A (Availability), C (Confidentiality), PI (Processing Integrity), P (Privacy) |
| **CPA** | Certified Public Accountant firm — única entidad que puede emitir SOC 2 oficial |
| **Type I vs Type II** | Type I = punto en el tiempo; Type II = período (típicamente 6–12 meses). Este sistema está orientado a Type II. |
| **Evidence** | Cualquier artefacto (log, screenshot, config snapshot, output de comando) que respalda el resultado de un test de control |
| **Finding** | Hallazgo estructurado en JSON. Puede ser de compliance (control fallado) o de código (vulnerabilidad). |
| **Control** | Proceso o mecanismo que mitiga un riesgo. Ej: "MFA obligatorio para admins" es un control de CC6.1. |
| **Test de control** | Procedimiento verificable que determina si el control está operando. Ej: "listar usuarios admin sin MFA → debe ser cero". |
| **KEV** | Known Exploited Vulnerabilities (catálogo de CISA). Si un CVE está en KEV, se auto-promueve a severidad crítica. |
| **EPSS** | Exploit Prediction Scoring System. Probabilidad de que un CVE sea explotado en 30 días. |
| **Reachability** | Análisis de si una función vulnerable es realmente invocada por el código del producto. Usado para despriorizar CVEs en código muerto. |
| **Readiness** | Preparación para una futura auditoría formal. Distinto de "compliance" (cumplimiento verificado por tercero). |

---

## 10. Notas sobre el estilo de trabajo con este usuario

- **Prefiere discusión arquitectónica antes de código**. No saltes a generar
  archivos si hay una decisión de diseño implícita sin resolver.
- **Técnico y sofisticado**. No expliques fundamentos (qué es CVSS, qué es
  SAST). Asume conocimiento.
- **Habla en español**. Los prompts del sistema están en inglés, pero la
  conversación y los docs estratégicos en español.
- **Agradece advertencias legales/regulatorias explícitas**. La primera
  conversación aclaró la restricción AICPA porque él inicialmente quería
  "self-certify". Valoró la corrección.
- **Valora trade-offs explicitados**. Prefiere "hay tres opciones A/B/C con
  estos costos" a una única recomendación sin alternativas.
- **El proyecto es serio y comercial**. Lo que se genere puede terminar
  enfrente de clientes enterprise o reguladores. Calidad > velocidad.

---

## 11. Última actualización de este documento

- **Creado**: 22 de abril de 2026.
- **Sesiones incluidas**: diseño inicial del sistema (arquitectura de dos
  subsistemas), generación completa de 23 archivos, discusión sobre agentes
  de código con acceso al repo, solicitud de documento de contexto.
- **Próxima revisión recomendada**: cuando se complete el primer roadmap
  item (Semgrep custom rules) o cuando una decisión de la sección 4 cambie.

---

*Fin de `_context.md`. Si después de leer esto tienes dudas sobre el estado
del proyecto, lee `README.md` y los archivos específicos. Si aún así hay
ambigüedad, pregunta al usuario antes de generar o modificar.*
