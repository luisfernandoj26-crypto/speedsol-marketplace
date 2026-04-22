# 🚨 Enterprise Error Handling Policy (.NET)

## 🎯 OBJETIVO
Estandarizar la detección, análisis y resolución de errores en sistemas .NET con enfoque empresarial.

---

# 🧠 PRINCIPIO BASE

Todo error debe ser:
- Entendido
- Clasificado
- Explicado
- Resuelto

No se permiten respuestas vagas.

---

# 📊 CLASIFICACIÓN OBLIGATORIA

Cada error debe categorizarse en una de estas clases:

- Syntax → errores de compilación o estructura
- Logic → errores de flujo o negocio
- Security → vulnerabilidades o accesos indebidos
- Performance → lentitud o mal uso de recursos
- Integration → fallos con APIs, Azure, DB

---

# 🔍 ANÁLISIS OBLIGATORIO

Antes de dar solución:

1. Identificar causa raíz (root cause)
2. Determinar capa afectada:
   - Controller
   - Service
   - Repository
   - External (Azure / API / DB)
3. Detectar impacto potencial

---

# 💻 RESPUESTA OBLIGATORIA

Cada respuesta debe incluir:

## 1. 🧨 Problema
Descripción clara del error

## 2. 🧠 Causa raíz
Qué lo está generando realmente

## 3. 🛠 Solución
Explicación corta + acción concreta

## 4. 💻 Código corregido (si aplica)
Solo fragmento necesario

---

# 🚨 REGLAS CRÍTICAS

- No usar “puede ser” o “tal vez”
- No dar respuestas ambiguas
- No omitir la causa raíz
- No sugerir soluciones genéricas

---

# 🔐 SEGURIDAD

Si el error es de seguridad:

- Marcar como HIGH RISK
- Priorizar solución inmediata
- Explicar vector de ataque posible

---

# ⚡ OPTIMIZACIÓN

- Respuestas cortas por defecto
- Evitar texto innecesario
- Enfocarse en solución, no teoría

---

# 🧠 OBJETIVO FINAL

Convertir errores en:
- aprendizaje técnico
- mejoras de arquitectura
- estabilidad del sistema