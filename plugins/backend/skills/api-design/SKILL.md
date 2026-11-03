---
name: api-design
description: REST API design rules - resource naming, HTTP methods and status codes, pagination, filtering and sorting, error format (RFC 9457 problem details), idempotency, versioning, and deprecation. Load when designing endpoints, response shapes, error handling, or breaking changes.
---

# API design

Record significant design decisions in the project's decision log. Implementation lives in `nestjs-patterns`; the contract in `openapi-swagger`; errors in `error-handling`.

## Resources and methods
- Plural nouns, kebab-case paths: `/posts`, `/posts/{id}/comments`. No verbs; model actions as sub-resources (`POST /orders/{id}/cancellations`).
- `GET` safe and idempotent; `PUT` full replace (idempotent); `PATCH` partial; `DELETE` idempotent; `POST` create or non-idempotent action.
- Nest at most two levels deep.

## Status codes
- `200` read/update, `201` created (+ `Location`), `204` no body, `400` malformed, `401` unauthenticated, `403` forbidden, `404` not found, `409` conflict, `422` valid syntax but failed business rules, `429` rate limited. Pick 400 or 422 for validation and stay consistent.
- Never return `200` with an error body. Use `5xx` only for server faults; do not leak internals.

## Errors
Use RFC 9457 `application/problem+json`: `type`, `title`, `status`, `detail`, `instance`, plus extensions (`errors[]` for field validation, `traceId`). One global exception filter produces it (`nestjs-patterns`, `error-handling`).

## Collections
- Cursor pagination by default for large or changing data (`?limit=20&cursor=...`, response `{ data, nextCursor }`). Offset (`page`, `pageSize`) only for small, stable sets. Cap `limit` server-side.
- Filter with query params (`?status=active`); sort with `?sort=-createdAt`. Whitelist allowed fields; never pass raw params into queries (`data-access-patterns`, `data-validation`).

## Idempotency and concurrency
- Support an `Idempotency-Key` header on non-idempotent `POST`s such as payments.
- Use ETags with `If-Match` (or a `version` field) for optimistic concurrency; return `412` or `409` on mismatch.

## Evolution
- Additive changes are non-breaking. Removing or renaming fields, or changing types or semantics, is breaking: new version, `Deprecation`/`Sunset` headers, and a migration window.
- Ids are opaque strings (`database-design`). Timestamps ISO 8601 UTC. Money as integer minor units or decimal strings, never floats.

### Backward-compatible change rules
- Safe: new optional request field, new response field, new endpoint, new enum value only if clients are documented to tolerate unknown values.
- Breaking: removing or renaming a field, making an optional input required, tightening validation, changing a type, status code, error `code`, default sort or page size.
- Clients must ignore unknown response fields; document that in the API description. Record it in the changelog before the first release that relies on it.
- Deprecate in the spec (`deprecated: true`), send `Deprecation` and `Sunset` headers, log who still calls it, and remove only after the window ends. Strategy: URI versioning (`/v1`) per `nestjs-patterns`; bump the major only for breaking changes.

## PUT vs PATCH
- `PUT` replaces the whole representation; omitted optional fields reset. `PATCH` changes only supplied fields; document how `null` clears a value versus omission leaving it unchanged.
- Return the updated resource from both. Repeating the same `PUT` or `PATCH` with the same body must give the same state.

## Naming and DTOs
- JSON fields camelCase, consistent across the API. Booleans read as facts (`isActive`), not negations.
- DTOs: `CreatePostDto`, `UpdatePostDto`, `ListPostsQueryDto` for input; `PostDto` or `PostSummaryDto` for output. Never return persistence entities directly (`data-validation`).
- Collections respond with an envelope so metadata can be added later: `{ "data": [...], "nextCursor": "..." }`, not a bare array.

## Pagination details
- Cursors are opaque (encode sort key and id), signed or validated, and stable under inserts. Tie-break sort by a unique column.
- Offset pagination: return `total` only when cheap; document the cap on `pageSize`.
- Response may include `Link` headers (`rel="next"`) in addition to the body cursor.

## Async and bulk operations
- Long work: return `202 Accepted` with `Location: /jobs/{id}`. The job resource exposes `status` (`queued`, `running`, `succeeded`, `failed`), progress, and a result link or problem body (`background-processing`).
- Bulk: `POST /posts/batch` accepts a capped array and returns per-item results (`207`-style body or `200` with `results[]`), never all-or-nothing ambiguity. State whether the batch is atomic.

## Idempotency keys
- Client sends `Idempotency-Key: <uuid>`. Server stores key, request fingerprint, and response for a retention window.
- Same key and same body: replay the stored response. Same key and different body: `422` or `409`. In-flight duplicate: `409`.
- Scope keys per caller; store atomically (unique constraint) so concurrent retries cannot both execute.

## Rate limit headers
- On `429` send `Retry-After`. Expose limit state consistently (`RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`); verify header names against the current IETF draft and your throttler version (`backend-security`).

## Error envelope example
```json
{
  "type": "https://api.example.com/problems/validation",
  "title": "Validation failed",
  "status": 422,
  "code": "VALIDATION_FAILED",
  "traceId": "9f1c...",
  "errors": [{ "field": "title", "code": "too_long", "message": "max 120 characters" }]
}
```
`code` is stable and machine-readable; `title` and `detail` are for humans and may change.

## Review checklist
- Every endpoint: correct method, status, documented errors, pagination cap, auth requirement.
- No verbs in paths, no bare arrays, no entity leakage, no breaking change without a version.

## See also

Optional, if installed: technical-design (the shared plugin); technical-documentation (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
