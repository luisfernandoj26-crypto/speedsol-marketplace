# Command: /lead

## Purpose

Invoke the orchestration engine to automatically classify your task and invoke relevant agents (review, architecture, security, optimize) in parallel.

## How It Works

1. You describe what you need
2. Lead asks 1-2 clarifying questions (optional)
3. Lead classifies task type automatically
4. Lead invokes relevant agents in parallel
5. Lead synthesizes results into unified report
6. Response is optimized for conciseness

## Usage

```
/lead I need to review this API endpoint for security and design patterns
```

## What Agents Get Invoked (Automatic)

- **code-review task** → review, security, optimize
- **architecture task** → architecture, security, optimize
- **security-audit task** → security, optimize
- **general inquiry** → optimize

## Output

Unified analysis from all agents + recommendations, ordered by severity.

## When to Use /lead

- General architecture or code review questions
- Security assessments
- Performance optimization
- Multi-faceted analysis requiring multiple perspectives

## When to Use Individual Agents

- `/review` — code quality only
- `/architecture` — design validation only
- `/security` — security only
- `/optimize` — compress response only
