# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Descripción del Proyecto

SpeedSol Marketplace es un **Plugin Marketplace para Claude Code** desarrollado por Speed Solutions S.A.S. Permite registrar, distribuir e instalar plugins reutilizables desde una única fuente. No contiene código ejecutable; todos los componentes son archivos Markdown que definen comportamiento de agentes IA.

## Instalación del Marketplace

```bash
/plugin marketplace add luisfernandoj26-crypto/speedsol-marketplace
```

Para instalar un plugin:
```bash
/plugin install engineering-governance
```

## Arquitectura del Marketplace

### Estructura raíz

- `.claude-plugin/marketplace.json` — Manifiesto principal: lista de plugins disponibles con nombre, versión, source y tags
- `plugins/<nombre-plugin>/` — Directorio de cada plugin
  - `.claude-plugin/plugin.json` — Manifiesto del plugin: nombre, versión, descripción y mapa de componentes

### Estructura interna de un plugin

Cada plugin bajo `plugins/` sigue esta estructura estandarizada:

```
plugins/<plugin-name>/
├── .claude-plugin/plugin.json   # Manifiesto del plugin
├── agents/                      # Definiciones de agentes (rol, skills usados, responsabilidades)
├── commands/                    # Comandos invocables (/nombre): purpose, flow, output format
├── config/                      # Políticas corporativas (rules.md, *-policy.md)
├── hooks/                       # Hooks de ciclo de vida (pre-process, post-process, error-handler)
└── skills/
    └── <skill-name>/SKILL.md    # Skill con frontmatter name/description y prompt estructurado
```

## Plugin: engineering-governance

Plugin de gobernanza IA para equipos .NET enterprise. Componentes disponibles:

### Comandos
| Comando | Agente activado | Propósito |
|---|---|---|
| `/review` | review-agent | Análisis de calidad de código |
| `/security` | security-agent | Detección de vulnerabilidades |
| `/architecture` | architecture-agent | Validación de diseño de sistema |
| `/optimize` | optimize-agent | Reducción de verbosidad y tokens |

### Agentes
- **lead** — Orquestador: decide qué agentes activar y combina sus outputs
- **review** — Senior .NET reviewer: estructura, malas prácticas, compliance arquitectural
- **security** — Especialista seguridad .NET + Azure: vulnerabilidades, auth, secrets
- **architecture** — Validador de diseño: separación de capas, coupling, escalabilidad
- **optimize** — Optimizador de tokens: reduce verbosidad sin perder precisión técnica

### Políticas (`config/`)
- `rules.md` — Estándares .NET: MVC, naming (camelCase/PascalCase/I-prefix), ILogger, try/catch en Services
- `architecture-policy.md` — Flujo obligatorio: Controller → Service → Repository → DB
- `security-policy.md` — Validación inputs, Azure Key Vault, JWT/Azure AD, Managed Identity
- `workflow-policy.md` — Git flow: feature/*, hotfix/*, PRs obligatorios, sin commits directos a main
- `quality-policy.md` — DRY, funciones <50 líneas, deuda técnica documentada
- `error-policy.md` — Sin stack traces expuestos al cliente
- `tokens.md` — Reglas de optimización de tokens

### Hooks
- **pre-process** — Carga config, valida input, rechaza entradas vacías
- **post-process** — Valida formato de output, aplica optimización de tokens
- **error-handler** — Maneja fallos sin exponer detalles internos

## Cómo agregar un nuevo plugin

1. Crear directorio `plugins/<nombre>/`
2. Agregar `.claude-plugin/plugin.json` con nombre, versión y mapa de componentes
3. Crear subdirectorios `agents/`, `commands/`, `config/`, `hooks/`, `skills/` según se necesiten
4. Registrar el plugin en `.claude-plugin/marketplace.json` bajo el array `"plugins"`

## Estándares de los archivos

- **Skills** (`skills/<name>/SKILL.md`): deben incluir frontmatter YAML con `name` y `description`, usar `$ARGUMENTS` como placeholder de entrada, y definir `OUTPUT FORMAT` explícito
- **Commands** (`commands/<name>.md`): definir `Purpose`, `Flow` (qué agente/skill usa) y `Output` esperado
- **Agents** (`agents/<name>.md`): definir `Role`, `Skills Used`, `Responsibilities`, `Does NOT do` y `Behavior Rules`
- **Policies** (`config/*.md`): documentar reglas como obligatorias con sección `REGLA CRÍTICA` al final
