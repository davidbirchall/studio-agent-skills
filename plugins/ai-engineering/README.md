# squad-skills-ai-engineering

AI engineering skills for LLM-powered applications and agent systems: LLM integration, prompt engineering, agent design and orchestration, tool and MCP integration, context engineering, retrieval-augmented generation, evaluation, testing, security, and observability.

Version `0.2.0`, 16 skills.

## Install

```
copilot plugin install ./plugins/ai-engineering
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `agent-design` | Agent vs workflow, loop, stop conditions, memory, human-in-the-loop | Designing an agent |
| `agent-orchestration` | Routing, parallel, handoff, shared state, durability, loop control | Coordinating multiple agents or steps |
| `ai-cost-latency-control` | Controlling cost and latency of LLM features in a TypeScript/NestJS chat backend - budgets per user, tenant, and request, token accounting from... | Estimating or capping spend, reducing response latency, adding retries or fallbacks, or setting up cost monitoring |
| `ai-evaluation` | Datasets, graders, LLM-as-judge, CI regression gates | Measuring AI quality |
| `ai-observability` | Traces, token and cost metrics, redacted logging, feedback | Monitoring AI in production |
| `ai-security` | Prompt injection, least privilege, exfiltration, tenant isolation | Hardening AI features |
| `ai-testing` | Fakes, recorded responses, contract tests, vitest patterns | Testing AI code |
| `chat-application-architecture` | End-to-end architecture of a conversational AI application in TypeScript with NestJS, Prisma, PostgreSQL and a Nuxt client - performance first... | Designing or reviewing the data model, API, performance, or request flow of a chat application |
| `context-engineering` | Context budgeting, compaction, memory tiers, caching | Managing what the model sees |
| `conversation-memory` | Conversation memory for chat applications in TypeScript - assembling the context window from stored messages along the active branch, token... | Building or debugging chat history handling, summaries, saved user memories, or personalisation, or when long conversations degrade |
| `llm-integration` | Provider abstraction, streaming, structured output, retries, cost budgets | Calling an LLM from the backend |
| `mcp-integration` | MCP servers and clients, transports, auth, trust | Using or building MCP servers |
| `prompt-engineering` | Prompt structure, roles, few-shot, output contracts, versioning | Writing or changing prompts |
| `retrieval-augmented-generation` | Chunking, embeddings, hybrid search, reranking, citations, access control | Building retrieval pipelines |
| `streaming-llm-responses` | Streaming LLM responses end to end in TypeScript with NestJS and a Nuxt client - parsing provider SSE chunks, accumulating deltas, assembling... | Implementing or debugging streaming chat output, tool-call streaming, stop buttons, reconnects, or stream tests |
| `tool-integration` | Tool schemas, validation, idempotency, permissions, error results | Exposing tools to a model |

## Related plugins

Works well with: backend, shared, platform-engineering, data (search and retrieval). Skills may mention skills from other plugins in a short "See also" note; each skill stands on its own if those plugins are not installed.
