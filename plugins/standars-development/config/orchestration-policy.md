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
