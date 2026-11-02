---
name: refine-prompt
description: >-
  Optimize, refine, and engineer prompts for Gemini and other LLMs. Supports Dual-Mode
  operation: generating interactive pair-programming prompts or production-grade application code
  with Pydantic schemas and variable interpolation. Use when the user asks to "optimize a prompt",
  "improve prompt", "write better prompts", "structure prompt", "pydantic prompt", or convert a draft
  task into a high-performance prompt.
---

# Prompt Optimizer

A structured engine to analyze, critique, and systematically reconstruct user-provided prompts into high-performance, deterministic instructions tailored for Gemini and modern LLMs.

## When to Use

- When the user asks to improve, refine, polish, or optimize an existing prompt.
- When the user provides a draft task and wants it structured for better LLM adherence.
- When converting natural language instructions into type-safe, production-ready schemas (Pydantic / JSON Mode).
- When diagnosing why a prompt generates hallucinations, excessive verbosity, format drift, or unverified logic.
- When creating modular, reusable prompt templates for specific engineering, academic, or coding domains.

## Core Restrictions

- **Do not execute the prompt itself.** Focus exclusively on analyzing and optimizing the prompt specification.
- **No artificial fluff.** Every added token must serve a structural, disambiguating, or constraint-enforcing purpose.
- **Preserve core intent.** Never alter the underlying goal or inject hallucinated domain requirements outside what the user implied.

---

## Dual-Mode Operation

Detect the user's intended target environment and select the appropriate operating mode:

### Mode 1: Interactive Markdown (Default)
Use when the prompt is intended for human-in-the-loop chat, pair-programming, or CLI agent sessions.

**Output Structure:**
```markdown
## 🔍 Original Prompt Analysis
- **Goal:** <Extracted primary intent>
- **Issues Identified:** <Diagnosed list of weaknesses based on references/failure-modes.md>

## 🚀 Optimized Prompt
<Fully copy-pasteable, delimited prompt template>

## 🧠 Improvements Applied
- <Specific structural improvement 1 and rationale>
- <Specific structural improvement 2 and rationale>
- <Specific structural improvement 3 and rationale>
```

### Mode 2: Application & Pydantic (Code-Ready)
Use when the user specifies code integration, API pipelines, automated agents, JSON extraction, or asks for Pydantic models.

**Output Structure:**
1. **Pydantic Schema:** Strict, validated `BaseModel` with descriptive `Field` annotations and literals.
2. **Parameterized Prompt Template:** Decoupled prompt text using variable placeholders (e.g. `{input_data}`).
3. **Execution Snippet:** Clean Python invocation using structured outputs (Google GenAI, Anthropic, or LangChain).

---

## 5-Stage Optimization Pipeline

### 1. Intent Extraction
Identify the foundational parameters of the input:
- **Primary Objective:** What is the single non-negotiable outcome?
- **Target Mode:** Interactive (Markdown) vs. Application (Pydantic / Code).
- **Domain Context:** Systems architecture, web dev, security, academic modeling, administrative.
- **Target Model:** Gemini 2.5/3, Claude 3.7 Sonnet, GPT-4o.

### 2. Failure Mode Diagnosis
Audit the prompt against the failure taxonomy in [references/failure-modes.md](./references/failure-modes.md):
- **Ambiguity & Under-specification:** Missing boundary conditions or loose verbs.
- **Negative Constraint Collapse:** Fragile "do not" phrasing lacking positive framing.
- **Format Drift:** Lack of explicit schema markers or delimiters.
- **Context Bloat:** Unnecessary pleasantries and conversational filler.

### 3. Reconstruction Strategy
Incorporate verified reasoning and prompting heuristics:
- **Persona Grounding:** Assign concrete domain role and evaluation perspective.
- **Delimiters & Sections:** Structure prompt with XML tags (`<context>`, `<input>`, `<constraints>`) or Markdown headings.
- **Reasoning Patterns:** Inject structured Chain-of-Thought and backward self-verification loops ([references/reasoning-patterns.md](./references/reasoning-patterns.md)).
- **Type-Safe Schemas:** Apply strict Pydantic models when structured JSON is required ([references/structured-outputs.md](./references/structured-outputs.md)).
- **Starter Templates:** Consult [assets/prompt-template-library.md](./assets/prompt-template-library.md) for proven architectural archetypes.

### 4. Output Formatting
Render the output cleanly adhering strictly to **Mode 1** or **Mode 2** output schemas.

### 5. Quality Checklist
Before presenting the reconstructed prompt, verify:
- [ ] Explicit constraints (length, style, format, and negative boundaries) are unambiguous.
- [ ] Delimiters cleanly separate instructions from variable input slots.
- [ ] The output is directly copy-pasteable or importable without requiring user guesswork.
- [ ] Backward verification checks are included for complex multi-step reasoning.
