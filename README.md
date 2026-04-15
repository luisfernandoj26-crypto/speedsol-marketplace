# 🚀 SpeedSol Marketplace

Marketplace de plugins para **Claude Code**, diseñado para centralizar herramientas reutilizables que optimizan flujos de desarrollo, automatización y soporte técnico.

---

## 📌 Descripción

Este repositorio funciona como un **Plugin Marketplace** compatible con Claude Code. Permite registrar, distribuir e instalar múltiples plugins desde una única fuente.

Ideal para equipos de desarrollo, soporte técnico y automatización de procesos.

---

## 🧩 Estructura del Proyecto

```
.
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── engineering-governance/
│   │   └── .claude-plugin/
│   │       └── plugin.json
└── README.md
```

---

## ⚙️ Requisitos

* Tener instalado Claude Code
* Acceso a terminal
* Git instalado

---

## 🔌 Instalación del Marketplace

Ejecuta el siguiente comando en Claude Code:

```bash
/plugin marketplace add luisfernandoj26-crypto/speedsol-marketplace
```

---

## 📦 Uso

Una vez agregado el marketplace, puedes listar los plugins disponibles:

```bash
/plugin
```

Para instalar un plugin específico:

```bash
/plugin install engineering-governance
```

---

---


## 📈 Casos de Uso

* Automatización de soporte técnico
* Generación de código
* Validaciones de procesos
* Integraciones internas

---

## 🤝 Contribuciones

1. Haz fork del repositorio
2. Crea una nueva rama
3. Agrega tu plugin en `/plugins`
4. Realiza commit
5. Abre un Pull Request

---

## 🧾 Licencia

Este proyecto está bajo la licencia MIT.

---

## 👨‍💻 Autor

Luis Fernando Jaramillo Cañas
Speed Solutions S.A.S

---

## 💡 Notas Finales

Este marketplace está pensado como base para escalar soluciones internas y acelerar el desarrollo mediante reutilización de componentes.

Si necesitas ayuda para crear plugins o extender funcionalidades, puedes apoyarte en (https://code.claude.com/docs/es/plugins)
