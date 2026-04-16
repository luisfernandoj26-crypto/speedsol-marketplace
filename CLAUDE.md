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

Plugin de gobernanza IA para equipos .NET enterprise. **Estado: production-ready.**

Setup por desarrollador (una sola vez):
```powershell
./plugins/engineering-governance/hooks/setup.ps1
```

### Comandos (7)
| Comando | Propósito |
|---|---|
| `/lead` | Orquestador — lee memoria, selecciona skills automáticamente |
| `/review` | Calidad de código .NET |
| `/security` | Auditoría de seguridad OWASP + Azure |
| `/architecture` | Validación de diseño de sistema |
| `/workflow` | Validación Git/PR/pipeline |
| `/debug` | Análisis de errores .NET con causa raíz |
| `/optimize` | Compresión de respuestas (reduce tokens) |

### Skills (7) — todos con frontmatter + políticas inlineadas
Cada skill (`skills/<name>/SKILL.md`) contiene el prompt completo con políticas de empresa embebidas. El contenido de `config/` está incrustado directamente en cada skill que lo necesita.

### Agentes (5) — subagent system prompts completos
`lead`, `review`, `security`, `architecture`, `optimize` — reescritos como prompts de sistema invocables por Claude Code.

### Hooks reales (3 scripts PowerShell)
- `hooks/scripts/pre-process.ps1` — `PreToolUse (Write|Edit)`: bloquea secretos hardcodeados en `.cs`
- `hooks/scripts/post-process.ps1` — `Stop`: extrae `📝 MEMORY UPDATE` y persiste en memoria
- `hooks/scripts/error-handler.ps1` — `PostToolUse (Bash)`: registra comandos fallidos en `logs/`
- `hooks/setup.ps1` — registra los 3 hooks en `.claude/settings.json` (distribuible al equipo)

### Sistema de memoria (3 capas)
- `memory/project-context.md` — conocimiento acumulado del proyecto (en git, compartido)
- `memory/team-log.md` — audit trail append-only (en git, compartido)
- `memory/session.md` — contexto de sesión actual (local, en .gitignore)

### Políticas (`config/`)
Los archivos de `config/` son la fuente de verdad de las reglas. Su contenido está incrustado en los skills. No es necesario editarlos para que los skills funcionen, pero modificarlos requiere actualizar también los skills relevantes.

## Cómo agregar un nuevo plugin

1. Crear directorio `plugins/<nombre>/`
2. Agregar `.claude-plugin/plugin.json` con nombre, versión y mapa de componentes
3. Crear subdirectorios `agents/`, `commands/`, `config/`, `hooks/`, `skills/` según se necesiten
4. Registrar el plugin en `.claude-plugin/marketplace.json` bajo el array `"plugins"`

## Estándares de los archivos

- **Skills** (`skills/<name>/SKILL.md`): frontmatter YAML obligatorio con `name` y `description`; usar `$ARGUMENTS` como placeholder de entrada; políticas de empresa inlineadas directamente en el prompt; terminar con sección `🧠 MEMORY PROTOCOL` y `📤 OUTPUT FORMAT`
- **Commands** (`commands/<name>.md`): frontmatter con `description` y `allowed-tools`; invocar el skill correspondiente por nombre; manejar caso sin `$ARGUMENTS`; definir output format esperado
- **Agents** (`agents/<name>.md`): system prompt completo con rol, herramientas disponibles, reglas de empresa inlineadas, restricciones ("Do NOT do") y output format
- **Policies** (`config/*.md`): fuente de verdad de las reglas — su contenido debe estar incrustado en los skills que las referencian
- **Hook scripts** (`hooks/scripts/*.ps1`): leen datos via stdin JSON; exit 0 = permitir, exit 1 = bloquear; siempre registrar en `logs/`
