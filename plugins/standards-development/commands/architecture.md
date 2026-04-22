---
description: Architecture validation for .NET — layer separation, DI, coupling, God classes, scalability
allowed-tools: Read, Glob
---

Apply the `architecture` skill to validate the system design of the following .NET code or module.

$ARGUMENTS

If the above is empty, ask the user: "Please provide a file path or module name to validate (e.g., `src/Services/` or `src/Controllers/OrderController.cs`)."

If a file path was provided, read the file before analyzing. If a directory was provided, use Glob to list the relevant `.cs` files first.

Before analyzing, check `memory/project-context.md` for known architecture decisions and approved deviations.

Output must follow the architecture skill format:
- 🔴 Architecture Issues
- 🟡 Design Risks
- 🟢 Improvements
- 💻 Suggested Refactor (if needed)
- 📝 MEMORY UPDATE
