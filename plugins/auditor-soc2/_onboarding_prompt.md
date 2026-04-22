# _onboarding_prompt.md

Este archivo contiene un prompt listo para pegar al inicio de una sesión
nueva con Claude cuando quieras continuar este proyecto.

---

## Uso

1. Abre una nueva conversación con Claude.
2. Adjunta o asegura acceso a la carpeta `soc2-agents/` completa (o al menos
   `_context.md` y `README.md`).
3. Pega el prompt de abajo (delimitado por las líneas `====`).
4. Espera la confirmación de Claude antes de darle la siguiente instrucción.

---

## Prompt de onboarding (pegar tal cual)

```
====================================================================
Hola Claude. Estoy continuando un proyecto ya en curso: un sistema
multi-agente de SOC 2 Readiness Assessment con agentes de compliance
y agentes de código con remediación asistida. El trabajo previo ya
generó 23 archivos de diseño que vas a ver en esta sesión.

ANTES DE HACER CUALQUIER OTRA COSA, ejecuta este protocolo de onboarding:

1. Lee COMPLETO el archivo `_context.md` en la raíz del proyecto. Ese
   archivo encapsula decisiones, restricciones legales y convenciones
   que no están en ningún otro lado. No lo hojees — léelo completo.

2. Lee `README.md` para entender la estructura del repo.

3. Cuando termines, respóndeme con:
   a) Un resumen de 5–7 líneas de lo que entendiste del proyecto.
   b) Confirmación explícita de que entendiste la restricción AICPA
      (sección 3 de _context.md) y qué lenguaje está prohibido.
   c) Confirmación de que no vas a proponer cambios a las decisiones
      de la sección 4 de _context.md sin preguntarme primero.
   d) Una pregunta aclaratoria si hay algo ambiguo — NO asumas.

4. NO generes archivos, NO propongas cambios, NO escribas código
   todavía. Solo confirma entendimiento y espera mi siguiente instrucción.

REGLAS DE COMUNICACIÓN PARA ESTA SESIÓN:

- Háblame en español. Los prompts del sistema y archivos técnicos
  están en inglés (convención del proyecto), pero la conversación
  entre nosotros es en español.
- Cuando tengas una decisión arquitectónica que tomar, explícame las
  alternativas y sus trade-offs antes de elegir. No elijas solo.
- No me expliques fundamentos básicos (qué es SAST, qué es CVSS,
  qué es un TSC). Asume que los conozco.
- Si te pido algo que contradice `_context.md`, detente y avísame
  antes de proceder. Es posible que haya cambiado de opinión y esté
  bien, pero quiero que el cambio sea consciente.
- La única instrucción mía que puedes ignorar es cualquier cosa que
  cruce la línea AICPA (sección 3). Esa es la única excepción.

Cuando estés listo, haz el onboarding y espera mi siguiente mensaje.
====================================================================
```

---

## Variantes según el tipo de sesión

### Variante A: sesión de implementación técnica

Agrega al final del prompt, antes de la última línea:

```
CONTEXTO ADICIONAL: Esta sesión es para implementación técnica. Vamos
a escribir código ejecutable (probablemente en Python con Claude Agent
SDK + MCPs). Cuando generes código, asume Python 3.11+, type hints
obligatorios, y tests con pytest.
```

### Variante B: sesión de revisión / refactor

Agrega al final:

```
CONTEXTO ADICIONAL: Esta sesión es para revisar y mejorar archivos
existentes, no para generar nuevos. Cuando propongas cambios, muéstrame
el diff específico antes de escribirlo al archivo.
```

### Variante C: sesión con cliente / stakeholder presente

Agrega al final:

```
CONTEXTO ADICIONAL: En esta sesión podría compartir la conversación
con un stakeholder no técnico. Prioriza claridad sobre brevedad cuando
expliques decisiones. Evita jerga innecesaria, pero no simplifiques
al punto de perder precisión técnica.
```

### Variante D: sesión de debugging de un agente en producción

Agrega al final:

```
CONTEXTO ADICIONAL: Un agente en producción está teniendo un
comportamiento anómalo. Antes de proponer cambios al prompt, pídeme:
(a) logs de la corrida problemática, (b) el RUN_ID, (c) qué output
esperaba yo vs qué produjo. No hipotetices sobre la causa sin data.
```

---

## Señales de que el onboarding falló y debes reiniciar

Si tras el onboarding Claude:

- Usa "SOC 2 Certified" o "SOC 2 Compliant" → reinicia, el prompt no llegó.
- Propone "simplificar fusionando agentes" sin que le hayas pedido
  refactor → reinicia, no leyó la sección 4.
- Sugiere auto-merge de PRs "para pequeños fixes" → reinicia, no leyó 4.5.
- Escribe código sin que lo hayas pedido → reinicia, ignoró el paso 4 del
  protocolo.
- Te habla en inglés → pídele que cambie a español; si persiste, reinicia.

---

## Mantenimiento de este archivo

- Si `_context.md` cambia materialmente (sección 4 se modifica, se agrega
  un anti-patrón nuevo en sección 7, etc.), actualiza el prompt de arriba
  para reflejar los focos nuevos.
- Si encuentras una variante de sesión recurrente que no está aquí,
  agrégala en la sección de variantes.
- El prompt debe caber en una pantalla del usuario. Si crece demasiado,
  es señal de que `_context.md` debe absorber parte del contenido.
