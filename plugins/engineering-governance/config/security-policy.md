# 🔐 Security Policy (Enterprise .NET + Azure)

## 🎯 OBJETIVO
Garantizar seguridad en código, APIs y arquitectura.

---

## 🧩 VALIDACIÓN DE ENTRADAS

- Validar todos los inputs del usuario
- Sanitizar datos antes de procesarlos
- Nunca confiar en datos externos

---

## 🛑 SECRETOS Y CREDENCIALES

- Prohibido hardcodear keys, passwords o tokens
- Usar Azure Key Vault o variables de entorno
- Nunca exponer secretos en logs o respuestas

---

## 🧨 SQL / DATA SECURITY

- Usar siempre parámetros en queries
- Evitar concatenación de strings en SQL
- Prevenir SQL Injection obligatoriamente

---

## 🌐 API SECURITY

- Validar autenticación en todos los endpoints
- Usar JWT o Azure AD
- Aplicar autorización por roles

---

## ☁️ AZURE SECURITY

- Usar Managed Identity cuando sea posible
- Restringir permisos mínimos necesarios (Least Privilege)
- Proteger conexiones a Azure services

---

## 🚨 REGLA CRÍTICA

Cualquier código inseguro debe ser rechazado o corregido automáticamente.