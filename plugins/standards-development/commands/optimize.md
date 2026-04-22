---
description: Compress and optimize the last response or provided content — reduces tokens without losing accuracy
allowed-tools: Read
---

Apply the `optimize` skill to compress the following content.

$ARGUMENTS

If the above is empty, compress the most recent Claude response in this conversation context. Remove all verbosity, redundant explanations, and unnecessary text while keeping all technical accuracy.

Output must follow the optimize skill format:
- ✔ Result
- 💻 Code (if needed)
- 📝 MEMORY UPDATE
