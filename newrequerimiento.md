# AI Marketplace Instructions

Este marketplace contiene múltiples plugins. Todos deben cumplir reglas estrictas de comportamiento, memoria, coordinación y ejecución.

---

## 1. Plugin: standards-development

### Reglas críticas

- La memoria de los agentes DEBE funcionar correctamente:
  - No perder contexto.
  - No releer información innecesaria.
  - No asumir información no confirmada.
  - Aprender y adaptarse dentro del contexto del proyecto.

---

### Agente líder (leader)

- Debe utilizar SIEMPRE el optimizador antes de ejecutar tareas.
- Debe revisar el archivo `standards-development/config/rules` en cada solicitud:
  - No releer completamente el archivo si ya está en memoria.
  - Utilizar contexto acumulado para eficiencia.

---

### Procesamiento del prompt

- Antes de ejecutar, el líder debe hacer 1 o 2 preguntas para afinar el requerimiento.
- Debe analizar completamente el contexto del prompt.
- Debe orquestar y ejecutar en paralelo los agentes necesarios según la tarea.

---

### Agentes

- Todos los agentes deben conocer y respetar el archivo `rules`.
- El proceso de review debe garantizar cumplimiento de estándares.
- Debe existir coherencia entre agentes (no contradicciones).

---

### Agente de seguridad

- Debe verificar si existe la carpeta `auditoria`.
- Si existe:
  - Leer el último informe generado.
  - Identificar hallazgos y riesgos pendientes.
  - Coordinar con el agente líder la corrección de dichos hallazgos.

- Una vez corregido:
  - Se debe volver a ejecutar el proceso de auditoría SOC 2.

---

## 2. Plugin: auditor-soc2

### Objetivo

Convertir este plugin en una solución avanzada de auditoría, similar a una firma especializada en certificaciones SOC 2.

---

### Reglas de ejecución

- Analizar TODOS los archivos del proyecto.
- No modificar código bajo ninguna circunstancia.
- Generar un análisis completo del sistema.

---

### Capacidades requeridas

- Evaluación de cumplimiento
- Validación de controles
- Análisis de riesgos
- Generación de reportes detallados

---

### Output obligatorio

- Generar un informe detallado con:
  - Hallazgos
  - Riesgos
  - Recomendaciones

- Guardar el informe en:
/auditoria/YYYY-MM-DD-informe.md


---

### Flujo de corrección

- Si se detectan problemas en código:
- NO corregir directamente.
- Recomendar el uso del plugin:
  ```
  speedsol-marketplace-main\plugins
  ```

- Después de aplicar correcciones:
- Ejecutar nuevamente el auditor-soc2.
- Generar un informe final de certificación que valide el cumplimiento.

---

## 3. Plugin: front-end-designer-speed-solutions

### Objetivo

Crear plugin especializado en diseño frontend corporativo y experiencia de usuario.

---

### Reglas de entrada

Antes de generar cualquier diseño, SIEMPRE preguntar:
- Tipo de aplicación
- Público objetivo
- Contexto de uso

---

### Lineamientos visuales

- Color primario: #1274AC
- Color de énfasis: #4D97C1
- Tipografía: sans-serif

---

### Estándares UI

- Modales consistentes en toda la aplicación
- Uso de tooltips cuando agreguen valor
- Diseño limpio, moderno y envolvente
- Uso moderado de efectos visuales
- Mantener identidad corporativa

---

### UX

- Priorizar claridad y usabilidad
- Interfaces intuitivas
- Consistencia visual
- Accesibilidad básica

---

## Reglas globales

- No duplicar lógica innecesaria.
- Priorizar eficiencia mediante uso de memoria.
- Mantener consistencia entre plugins.
- No generar acciones fuera del alcance del plugin correspondiente.
- Todas las decisiones deben alinearse con estándares empresariales.