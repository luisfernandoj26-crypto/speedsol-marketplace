# {{PRODUCT_IN_SCOPE}} — SOC 2 Readiness Assessment Report

**Período:** {{ASSESSMENT_PERIOD_START}} a {{ASSESSMENT_PERIOD_END}}
**Organización:** {{ORG_LEGAL_NAME}}
**Versión:** {{REPORT_VERSION}}
**Fecha de emisión:** {{REPORT_DATE}}
**Clasificación:** Confidencial — distribución bajo NDA

---

## Disclaimer / Descargo de Responsabilidad

> Este informe es una **auto-evaluación interna de seguridad y controles** realizada por {{ORG_LEGAL_NAME}} para el producto "{{PRODUCT_IN_SCOPE}}" cubriendo el periodo {{ASSESSMENT_PERIOD_START}} a {{ASSESSMENT_PERIOD_END}}. La evaluación se basa en los Trust Service Criteria de AICPA pero **no constituye un informe SOC 2**. Un informe SOC 2 solo puede ser emitido por una firma independiente de contadores públicos (CPA) licenciada, siguiendo los procedimientos AICPA AT-C 205. Este documento busca comunicar nuestra postura de seguridad a clientes y socios bajo NDA y no constituye certificación, acreditación ni aseguramiento por terceros.

> This report is an **internal security and controls self-assessment** performed by {{ORG_LEGAL_NAME}} for "{{PRODUCT_IN_SCOPE}}" covering {{ASSESSMENT_PERIOD_START}} to {{ASSESSMENT_PERIOD_END}}. It is based on AICPA Trust Service Criteria but **is not a SOC 2 report**. A SOC 2 report can only be issued by an independent licensed CPA firm following AICPA AT-C 205 procedures. This document is intended to communicate our security posture to customers and partners under NDA and does not constitute certification, accreditation, or third-party assurance.

---

## Sección 1 — Declaración de la Administración

Por medio de este documento, {{SIGNING_AUTHORITY_NAME}}, en su calidad de {{SIGNING_AUTHORITY_TITLE}} de {{ORG_LEGAL_NAME}}, declara que:

- Los controles descritos en este informe estuvieron implementados y operando durante el periodo de evaluación.
- La evaluación fue realizada sobre el producto/servicio {{PRODUCT_IN_SCOPE}}.
- Las excepciones, desviaciones y hallazgos abiertos están documentados en la Sección 5.
- Los criterios de control utilizados corresponden a los AICPA Trust Service Criteria aplicables a: {{TSC_IN_SCOPE}}.

**Firma:** {{SIGNATURE_BLOCK}}
**Fecha:** {{SIGNING_DATE}}

---

## Sección 2 — Metodología de la Evaluación

La evaluación fue ejecutada de manera continua durante el periodo mediante un sistema de agentes especializados. Cada control es probado por un agente responsable que:

1. Ejecuta procedimientos automatizados contra sistemas vivos (IdP, nube, Git, SIEM, etc.)
2. Captura evidencia con hash SHA-256 para integridad
3. Evalúa el resultado contra criterios objetivos definidos en el catálogo de controles
4. Produce hallazgos cuando se detectan desviaciones

Los agentes de código analizan el código fuente del producto contra las mejores prácticas relevantes a los controles aplicables:
- Análisis estático (SAST)
- Detección de secretos y criptografía débil
- Vulnerabilidades en dependencias
- Configuración de infraestructura como código

Herramientas empleadas: Semgrep, Gitleaks, OSV-Scanner, Trivy, Checkov, Syft, entre otras. Versiones específicas registradas en el Apéndice B.

---

## Sección 3 — Descripción del Sistema

### 3.1 Servicios prestados
{{SYSTEM_DESCRIPTION_SERVICES}}

### 3.2 Compromisos principales y requisitos
{{PRINCIPAL_COMMITMENTS}}

### 3.3 Componentes del sistema

**Infraestructura:**
{{INFRASTRUCTURE_DESCRIPTION}}

**Software:**
{{SOFTWARE_DESCRIPTION}}

**Personas:**
{{PEOPLE_DESCRIPTION}}

**Procedimientos:**
{{PROCEDURES_DESCRIPTION}}

**Datos:**
{{DATA_DESCRIPTION}}

### 3.4 Límites del sistema
{{SYSTEM_BOUNDARIES}}

### 3.5 Cambios significativos durante el periodo
{{SIGNIFICANT_CHANGES}}

### 3.6 Organizaciones de sub-servicio (vendors en alcance)
{{SUBSERVICE_ORGS_TABLE}}

### 3.7 Controles complementarios del cliente
{{COMPLEMENTARY_USER_CONTROLS}}

---

## Sección 4 — Criterios, Controles y Pruebas

### 4.1 Seguridad (CC1 – CC9)

#### CC1.1 — Demostrar compromiso con la integridad y valores éticos
**Controles implementados:** {{NARRATIVE_CC1_1}}
**Pruebas realizadas:**
| Test ID | Procedimiento | Resultado | Evidencia |
|---------|---------------|-----------|-----------|
{{TESTS_CC1_1}}

#### CC1.4 — Atraer, desarrollar y retener personal competente
{{SECTION_CC1_4}}

#### CC2.1 — Obtener o generar información de calidad
{{SECTION_CC2_1}}

#### CC3.2 — Identificar y analizar riesgos
{{SECTION_CC3_2}}

#### CC3.4 — Evaluar cambios significativos
{{SECTION_CC3_4}}

#### CC6.1 — Medidas de seguridad de acceso lógico
{{SECTION_CC6_1}}

#### CC6.2 — Registro y autorización de usuarios
{{SECTION_CC6_2}}

#### CC6.3 — Autorización, modificación y remoción de acceso
{{SECTION_CC6_3}}

#### CC6.6 — Protección contra amenazas externas
{{SECTION_CC6_6}}

#### CC6.7 — Protección durante transmisión y movimiento
{{SECTION_CC6_7}}

#### CC6.8 — Prevención de software no autorizado
{{SECTION_CC6_8}}

#### CC7.1 — Procedimientos de detección y monitoreo
{{SECTION_CC7_1}}

#### CC7.2 — Monitoreo de anomalías
{{SECTION_CC7_2}}

#### CC7.3 — Evaluación de eventos de seguridad
{{SECTION_CC7_3}}

#### CC7.4 — Respuesta a incidentes
{{SECTION_CC7_4}}

#### CC8.1 — Autorización, diseño, desarrollo, aprobación e implementación de cambios
{{SECTION_CC8_1}}

#### CC9.2 — Gestión de riesgos de terceros
{{SECTION_CC9_2}}

### 4.2 Disponibilidad (A1)

#### A1.2 — Autorización, diseño, operación y monitoreo de disponibilidad
{{SECTION_A1_2}}

### 4.3 Confidencialidad (C1)

#### C1.1 — Identificación y mantenimiento de información confidencial
{{SECTION_C1_1}}

#### C1.2 — Disposición de información confidencial
{{SECTION_C1_2}}

---

## Sección 5 — Resumen de Hallazgos

### 5.1 Estadísticas

| Severidad | Abiertos | Remediados en el periodo | Aceptados (control compensatorio) |
|-----------|----------|--------------------------|-----------------------------------|
| Crítica   | {{n}}    | {{n}}                    | {{n}}                             |
| Alta      | {{n}}    | {{n}}                    | {{n}}                             |
| Media     | {{n}}    | {{n}}                    | {{n}}                             |
| Baja      | {{n}}    | {{n}}                    | {{n}}                             |
| Informativa | {{n}} | {{n}}                    | {{n}}                             |

### 5.2 Hallazgos abiertos (detalle)
{{OPEN_FINDINGS_TABLE}}

### 5.3 Hallazgos remediados durante el periodo
{{REMEDIATED_FINDINGS_TABLE}}

### 5.4 Riesgos aceptados con control compensatorio
{{ACCEPTED_RISKS_TABLE}}

### 5.5 Análisis de tendencias vs. periodos anteriores
{{TREND_ANALYSIS}}

---

## Sección 6 — Hoja de Ruta de Remediación

### Hallazgos críticos/altos abiertos por responsable y fecha

| Finding ID | Severidad | Control | Responsable | SLA | Fecha límite | Estado |
|------------|-----------|---------|-------------|-----|--------------|--------|
{{REMEDIATION_ROADMAP_TABLE}}

### Controles compensatorios en efecto

{{COMPENSATING_CONTROLS_DETAIL}}

---

## Sección 7 — Exclusiones y Limitaciones

### Fuera de alcance
{{OUT_OF_SCOPE_ITEMS}}

### Limitaciones de la evaluación automatizada
- La evaluación automatizada no reemplaza una auditoría SOC 2 formal realizada por un CPA licenciado.
- Ciertos controles requieren atestación humana (política firmada, training completado, entre otros) — ver Apéndice A.
- Sistemas legados sin API de auditoría son evaluados mediante inspección manual documentada.
- {{OTHER_LIMITATIONS}}

### Áreas que requieren auditoría humana en el futuro
{{FUTURE_AUDIT_AREAS}}

---

## Apéndice A — Procedimientos de prueba ejecutados

{{TEST_PROCEDURES_TABLE}}

## Apéndice B — Índice de evidencia

| Test ID | Evidencia | SHA-256 | Fecha captura |
|---------|-----------|---------|---------------|
{{EVIDENCE_INDEX_TABLE}}

## Apéndice C — Metodología de scoring de riesgo

Ver archivo `risk-scoring.md`. Resumen:
- Modelo de 4 dimensiones: Criticidad × 1.5, Exposición × 1.5, Explotabilidad, Detectabilidad
- Composite 21-25 = Crítico, 16-20 = Alto, 11-15 = Medio, 6-10 = Bajo
- SLAs: Crítico 48h, Alto 14d, Medio 60d, Bajo 180d
- Overrides automáticos: secretos vivos → Crítico; CVEs en KEV + alcanzables → Crítico

## Apéndice D — Matriz de controles

{{CONTROLS_MATRIX_CSV_LINK}}

## Apéndice E — Glosario

| Término | Definición |
|---------|------------|
| TSC | Trust Service Criteria (AICPA) |
| CC | Common Criteria (TSC common) |
| MFA | Multi-Factor Authentication |
| SAST | Static Application Security Testing |
| SCA | Software Composition Analysis |
| IaC | Infrastructure as Code |
| SIEM | Security Information and Event Management |
| RTO | Recovery Time Objective |
| RPO | Recovery Point Objective |
| KEV | Known Exploited Vulnerabilities (CISA) |
| EPSS | Exploit Prediction Scoring System |
| CWE | Common Weakness Enumeration |
| CVE | Common Vulnerabilities and Exposures |

## Apéndice F — Distribución y confidencialidad

Este documento se distribuye bajo acuerdo de confidencialidad (NDA). La distribución sin autorización está prohibida. Cualquier consulta sobre el contenido debe dirigirse a {{CONTACT_EMAIL}}.

Firma digital del manifiesto: `{{MANIFEST_SIGNATURE}}`
Hash del reporte: `{{REPORT_SHA256}}`
