# AI Advisory Subsystem

This subsystem implements the decision-support layer for Campus Care per PRD §5 & §8 and SRS Section 8.

## Principles
1. **Advisory Only (Human-in-the-Loop)**: AI outputs are always treated as suggestions, never facts. Merges and closures always require human confirmation.
2. **Deterministic Evidence Layer**: All aggregate metrics and statistics are calculated by Python/SQL before passing de-identified context to LLMs.
3. **Data Minimization & Privacy**: No reporter PII, internal notes, or raw phone numbers are passed to external LLMs.
4. **Graceful Degradation**: If the AI subsystem is offline or throttled, core issue reporting and resolution workflows remain 100% functional.

## Structure
- `prompts/`: Versioned prompt templates for classification, urgency, dedup, recurrence, recommendations, drafting, and summaries.
- `evaluators/`: Automated quality and safety evaluation suites.
- `schemas/`: Structured JSON schemas for LLM tool/output parsing.
