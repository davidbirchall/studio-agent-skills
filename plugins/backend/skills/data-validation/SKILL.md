---
name: data-validation
description: Validating and shaping data at every trust boundary in Node.js and NestJS services - HTTP input, env config, queue messages, upstream responses, and webhooks - with class-validator DTOs or Zod, whitelisting against mass assignment, coercion, query and pagination bounds, file upload validation, sanitisation versus validation, custom and cross-field validators, normalisation, response serialization, persisted JSON columns, unknown-field policy, and testing validators. Load when writing DTOs or schemas, validating input or config, handling uploads or webhooks, or shaping responses.
---

# Data validation

Builds on `nestjs-patterns`, `nodejs-conventions`, and `openapi-swagger`. Verify option names against the installed `class-validator`, `class-transformer`, `zod`, and `@nestjs/common` versions.

## Boundary principle
- Validate at every trust boundary: HTTP body/query/params/headers, env config at boot, queue and event messages, webhook payloads, upstream API responses, and JSON read from the database.
- Inside the boundary, trust the parsed type. Do not re-validate in every service.
- Parse, do not just check: the output is a typed value, and raw input never travels past the boundary.
- Pick one tool per layer and do not mix: class-validator for Nest HTTP DTOs, Zod for env config, messages, upstream responses, and schemas shared with clients.

## class-validator DTOs
Register once, globally (use `APP_PIPE` when the pipe needs DI):
```ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,
  forbidNonWhitelisted: true,
  transform: true,
}))
```
- `whitelist` strips unknown properties (blocks mass assignment); `forbidNonWhitelisted` rejects them with an error.
- `transform: true` yields real DTO instances.

## DTO rules
- One DTO class per input shape: `CreatePostDto`, `UpdatePostDto` (`PartialType` from `@nestjs/swagger` so docs stay in sync), `ListPostsQueryDto`.
- Every property has a validator. Optional ones use `@IsOptional()`. Strings get `@IsString()` plus `@MaxLength`; ids `@IsUUID()`; enums `@IsEnum()`.
- Nested objects: `@ValidateNested()` + `@Type(() => Child)`. Arrays: `@IsArray()` + `@ValidateNested({ each: true })` + `@ArrayMaxSize`.
- DTOs are classes (metadata is needed), hold no logic, and are never Prisma models.
- Never accept server-owned fields (`id`, `role`, `createdAt`, `tenantId`) in input DTOs; set them in the service.

## Zod
```ts
const Env = z.object({ PORT: z.coerce.number().int().min(1).max(65535), DATABASE_URL: z.string().url() })
export const parseEnv = (raw: NodeJS.ProcessEnv) => Env.parse(raw)
```
- Use `.strict()` where unknown keys must be rejected; Zod strips them by default.
- Use `safeParse` for messages and upstream responses so you can dead-letter or log instead of crashing.
- For Nest, use a small custom pipe or `nestjs-zod`; derive types with `z.infer`.

## Coercion and parsing
- Query and path values arrive as strings. Convert explicitly (`@Type(() => Number)`, `z.coerce`), never rely on implicit conversion.
- Booleans from strings: parse `'true'`/`'false'` explicitly; `Boolean('false')` is true.
- Path params: `ParseUUIDPipe` or `ParseIntPipe`.
- Dates: accept ISO 8601 strings, validate with `@IsISO8601()` or `z.string().datetime()`, then convert.
- Arrays in query strings: define the accepted form (repeated key or comma-separated) and test it.

## Pagination and list params
- Bound everything: `limit` `@IsInt() @Min(1) @Max(100)` with a default; `offset`/`page` `@Min(0)`/`@Min(1)`.
- Sort and filter fields come from an allowlist enum, never passed straight to Prisma `orderBy`/`where`.
- Cursor values are opaque strings validated for format.

## File uploads
- Enforce size limits at the parser (multipart plugin option, `fastify-adapter`), not after buffering.
- Validate declared MIME type against an allowlist, and sniff content (magic bytes, for example `file-type`) because the header and extension are client-controlled.
- Generate the stored filename; never use the client name in paths. Limit file count.
- Scan or re-encode untrusted images/documents where risk warrants (`backend-security`).

## Sanitisation vs validation
- Validation rejects bad input; sanitisation changes it. Reject first; sanitise only for a stated reason.
- Normalise with `@Transform`/`.transform`: trim strings, lowercase emails, strip control characters. Never use normalisation to hide invalid input.
- Do not "sanitise" SQL or HTML by stripping characters. Use parameterised queries (`data-access-patterns`) and context-aware output encoding (`backend-security`).

## Custom and cross-field validation
- Custom rules: `@ValidatorConstraint` + `@Validate`, or Zod `.refine`. Keep them pure and synchronous; if a check needs the database (uniqueness), do it in the service and throw a domain error, not in a validator.
- Cross-field rules (`endDate > startDate`, one-of fields): class-level `@Validate` or Zod `.superRefine` with the issue `path` pointing at the offending field.

## Unknown fields policy
- Requests: reject unknown fields (`forbidNonWhitelisted`, `.strict()`).
- Upstream responses and webhooks: tolerate unknown fields (strip) so provider additions do not break you, but require every field you use.

## Responses
- Return response DTOs, not entities. Use `ClassSerializerInterceptor` with `@Exclude()`/`@Expose()` or map explicitly. Never leak password hashes, tokens, internal ids, or other tenants' data.
- Prefer an explicit allowlist (`@Expose` with `excludeExtraneousValues: true`, or a mapper) over an exclude list.

## Persisted JSON columns
- Prisma `Json` is untyped. Validate with a Zod schema on write and on read; version the schema (`{ v: 1, ... }`) and migrate old rows.
- Never cast `as Foo` on read.

## Errors
Validation failures map through the global exception filter to the project problem format with per-field messages (`error-handling`, `api-design`). Return 400 or 422 consistently; do not echo raw submitted values for sensitive fields.

## Testing
- Test validators as a table of valid and invalid cases, including boundaries (min, max, empty, null, wrong type) and unknown fields (`backend-testing`, `test-discipline`).
- Assert on the field path and error code, not the full message text.
- Add one e2e test per endpoint proving a bad body yields the standard error shape and a mass-assignment attempt is rejected.

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
