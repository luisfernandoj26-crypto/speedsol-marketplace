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
