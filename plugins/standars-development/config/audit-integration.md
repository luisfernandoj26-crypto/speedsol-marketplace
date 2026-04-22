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
