---
description: Security audit for .NET + Azure — OWASP checklist, auth, SQL injection, secrets, Azure security
allowed-tools: Read, Grep, Glob
---

Apply the `security` skill to audit the following .NET code for security vulnerabilities.

$ARGUMENTS

If the above is empty, ask the user: "Please provide a file path (e.g., `src/Controllers/AuthController.cs`) to audit."

If a file path was provided, read the file before analyzing.

Before analyzing, check `memory/project-context.md` for already resolved security issues on this file.

Output must follow the security skill format:
- 🔴 CRITICAL RISKS
- 🟠 HIGH RISKS
- 🟡 MEDIUM RISKS
- 🟢 RECOMMENDATIONS
- 💻 FIX (if needed)
- 📝 MEMORY UPDATE
