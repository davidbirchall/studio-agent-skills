---
name: retrieval-augmented-generation
description: Retrieval-augmented generation for a TypeScript/NestJS backend - ingestion pipelines, document parsing, chunking strategy, embeddings and model versioning, vector store choice, hybrid keyword plus vector search, reranking, metadata filtering, query rewriting, citations and grounded answers, freshness and re-indexing, access control on retrieved documents, and evaluating retrieval and answer quality. Load when building or tuning search over private documents, adding a knowledge base to a chat or agent, debugging irrelevant or ungrounded answers, or designing an indexing pipeline.
---

# Retrieval-augmented generation

Builds on `llm-integration` for embedding and generation calls, `context-engineering` for fitting results into the window, and `ai-evaluation` for measuring quality. Verify embedding dimensions, limits and vector store features against current provider docs.

## Pipeline shape
- Two paths: ingestion (parse, clean, chunk, embed, index) offline or async, and query (rewrite, retrieve, rerank, assemble, generate) online.
- Keep stages as separate typed functions so each can be tested and swapped. Run ingestion as queued jobs, idempotent per document and version.

## Chunking
- Chunk by document structure (headings, paragraphs, code blocks, table rows) before falling back to size limits. Never cut mid-sentence or mid-code-block when avoidable.
- Start with a few hundred tokens per chunk and modest overlap; tune with retrieval evals, not folklore.
- Prepend context to each chunk (title, section path) so it stands alone. Store parent id to expand to neighbouring or parent text at answer time.
- Parse and clean first: strip navigation, boilerplate and duplicates; keep tables and code intact.

## Embeddings
- Use one embedding model per index. Store model name and version on every record; changing models means re-embedding everything.
- Embed queries and documents with the same model, and apply any query or document prefixes the model requires (check its docs).
- Batch embedding calls, retry transient errors, and cache by content hash to skip unchanged chunks.

## Storage and metadata
- Choose the store by operational fit: existing Postgres with pgvector, a dedicated vector database, or a search engine with vector support. Verify index types and filtering behaviour for the chosen one.
- Store text, source id, URL, title, section, content hash, version, ingested-at, tenant and ACL fields with each chunk.
- Filter on metadata at query time (tenant, type, date, language) inside the index query, not after top-k.

## Retrieval
- Use hybrid search: keyword (BM25 or full text) plus vector, merged with reciprocal rank fusion or weighted scores. Keywords catch ids, names and rare terms that embeddings miss.
```ts
const [dense, sparse] = await Promise.all([vec.search(q, { k: 40, filter }), fts.search(q, { k: 40, filter })])
const fused = reciprocalRankFusion([dense, sparse]).slice(0, 30)
```
- Retrieve wide (tens), rerank with a cross-encoder or model reranker, then keep a small top set (a handful).
- Rewrite follow-up questions into standalone queries using conversation history; consider multi-query or decomposition for complex asks.
- Apply a relevance threshold. If nothing qualifies, answer "not found" instead of padding with weak matches.
- Dedupe near-identical chunks and cap chunks per source for diversity.

## Generation and citations
- Instruct the model to answer only from supplied sources, to say when they are insufficient, and to cite source ids.
- Label each chunk with a stable id, title and URL; return citations as structured fields and validate that cited ids were in the supplied set (`llm-integration`).
- Treat retrieved text as untrusted data inside delimiters (`prompt-engineering`, `ai-security`).
- Respect the context budget: trim by rank, not arbitrarily (`context-engineering`).

## Freshness and ingestion
- Detect changes with content hashes or source modified times; upsert changed chunks and delete removed ones so stale facts disappear.
- Handle deletes and permission changes as first-class events, not just nightly rebuilds.
- Re-index fully into a new index and swap an alias when changing chunking or embedding model.
- Record ingestion failures per document and surface them; do not silently skip.

## Access control
- Enforce authorisation at retrieval, using the caller's identity: filter by tenant and ACL in the query itself. Never rely on the model to withhold content.
- Propagate source permissions into chunk metadata and keep them in sync. Test cross-tenant leakage explicitly (`ai-security`).
- Log which sources were retrieved per answer for audit (`ai-observability`).

## Evaluation
- Build a labelled set of questions with expected source chunks. Measure recall at k, precision, MRR and hit rate before judging answers.
- Separately measure answer faithfulness (supported by sources), relevance and citation correctness (`ai-evaluation`).
- Change one variable at a time (chunk size, k, reranker, model) and compare on the same set; run in CI as regression tests (`ai-testing`, `test-discipline`).
- Review failed queries from production, classify as retrieval, ranking or generation failure, and add them to the set.

## See also

Optional, if installed: search-indexing (the data plugin) for the broader discipline this skill applies. This skill stands on its own.
