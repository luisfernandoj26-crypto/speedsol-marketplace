# 🏗 Architecture Policy (Enterprise System)

## 🎯 OBJETIVO
Definir estructura global del sistema para escalabilidad y mantenimiento.

---

## 🧱 CAPAS OBLIGATORIAS

- Presentation Layer (Controllers)
- Business Layer (Services)
- Data Layer (Repositories)
- External Integrations (APIs / Azure)

---

## 🔄 FLUJO DE DATOS

Controller → Service → Repository → DB

- Controllers no contienen lógica
- Services contienen reglas de negocio
- Repositories solo acceso a datos

---

## 🧩 MODULARIDAD

- Cada módulo debe ser independiente
- Evitar dependencias cruzadas innecesarias
- Reutilizar servicios comunes

---

## ⚙️ DEPENDENCIAS

- Usar Dependency Injection
- Evitar dependencias directas entre capas
- Mantener bajo acoplamiento

---

## 📦 ESCALABILIDAD

- Diseñar pensando en crecimiento horizontal
- Servicios deben ser desacoplados
- APIs deben ser independientes

---

## 🚨 REGLA CRÍTICA

No se permite lógica de negocio en Controllers ni acceso directo a DB desde UI.