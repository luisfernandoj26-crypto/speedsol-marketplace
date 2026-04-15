# Error Handler Hook

## Purpose
Handle failures in agent execution.

## Rules
- Never expose internal stack traces
- Return simplified error message
- Suggest retry or fallback agent