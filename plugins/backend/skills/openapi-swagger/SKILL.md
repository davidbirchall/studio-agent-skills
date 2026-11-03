---
name: openapi-swagger
description: OpenAPI and Swagger docs for NestJS with @nestjs/swagger - DocumentBuilder setup, decorators, DTO schemas, the Nest swagger CLI plugin, auth schemes, versioning, spec export, and keeping the spec as the API contract for Postman and generated clients. Load when documenting endpoints, DTOs, or changing the public API contract.
---

# OpenAPI / Swagger

Builds on `nestjs-patterns`, `api-design`, and `data-validation`. Verify decorator names and options against the installed `@nestjs/swagger` version.

## Setup
```ts
const config = new DocumentBuilder()
  .setTitle('Posts API').setVersion(pkg.version)
  .addBearerAuth()
  .build()
const document = SwaggerModule.createDocument(app, config)
SwaggerModule.setup('docs', app, document)
```
- On Fastify, `@fastify/static` is required for the UI (`fastify-adapter`).
- Expose docs only where intended; disable or protect in production if the API is not public.
- Export the spec (`openapi.json`) in CI so it is reviewable and usable by `postman-api-testing` and client generators.

## Code-first by default
- Enable the `@nestjs/swagger` plugin in `nest-cli.json` so DTO properties and comments become schema automatically. Without it, decorate every property with `@ApiProperty`.
- With the plugin, add `@ApiProperty` only to override (examples, enums, formats).
- Contract-first (spec authored first) suits public APIs with external consumers; then the spec file is the source of truth. Do not do both for one API.

## Decorators
- Controller: `@ApiTags('posts')`, `@ApiBearerAuth()`.
- Operation: `@ApiOperation({ summary })`, `@ApiOkResponse({ type })`, `@ApiCreatedResponse`, `@ApiNotFoundResponse`. Document every non-2xx the endpoint can return, including the shared error shape.
- Arrays and generics: `@ApiOkResponse({ type: [PostDto] })`; use `ApiExtraModels` + `getSchemaPath` for generic envelopes such as pagination.
- Name response DTOs distinctly from persistence models; never expose Prisma types.

## Versioning
- Use Nest versioning (`app.enableVersioning`) and generate one document per version.
- Breaking changes need a new version (`api-design`); additive changes do not.

## Review checks
- The spec diff is part of every PR that changes endpoints.
- Examples must be valid against the schema. No `any` or empty object schemas.

## DTO schema details
```ts
export class PostDto {
  @ApiProperty({ format: 'uuid', example: '3b241101-e2bb-4255-8caf-4136c566a962' })
  id!: string

  @ApiProperty({ enum: PostStatus, enumName: 'PostStatus' })
  status!: PostStatus

  @ApiPropertyOptional({ type: String, nullable: true, description: 'Null when unpublished' })
  publishedAt!: string | null

  @ApiProperty({ type: () => [TagDto] })
  tags!: TagDto[]
}
```
- Always set `enumName` so the enum becomes one shared component. Document `nullable` separately from optional; they mean different things on the wire.
- Use `PartialType`, `PickType`, `OmitType` from `@nestjs/swagger` (not `@nestjs/mapped-types`) so metadata carries over (`data-validation`).
- Query DTOs: arrays and nested objects need explicit `@ApiProperty` or `@ApiQuery` options; verify generated parameters in the spec.
- Circular DTO references need lazy types (`type: () => X`).

## CLI plugin notes
- Enable in `nest-cli.json` under `compilerOptions.plugins` with `@nestjs/swagger`; it reads `class-validator` decorators and JSDoc. Check `introspectComments` and `dtoFileNameSuffix` options for the installed version.
- The plugin runs only in the Nest compiler. Under Vitest/SWC the metadata is absent; either run the plugin in the test build or use explicit decorators where tests inspect the document (`backend-testing`, `nestjs-patterns`).

## Hide internal routes
- `@ApiExcludeEndpoint()` / `@ApiExcludeController()` for health, metrics, and admin routes. Or filter with `createDocument(app, config, { include: [PublicModule] })`.
- Hiding docs is not security; internal routes still need guards (`authentication-authorization`, `backend-security`).

## Auth schemes
- `addBearerAuth()` pairs with `@ApiBearerAuth()` per controller; for named schemes pass the name to both. Add `addApiKey` or OAuth2 only if used. Declare security at controller or global level so "Authorize" works in the UI, never ship real tokens in examples.

## Export and contract diff in CI
```ts
// scripts/export-openapi.ts: boot app without listening, write file
const app = await NestFactory.create(AppModule, new FastifyAdapter(), { logger: false })
writeFileSync('openapi.json', JSON.stringify(SwaggerModule.createDocument(app, config), null, 2))
await app.close()
```
- Commit `openapi.json` (stable key order) or publish as an artifact. CI regenerates and fails on uncommitted diff.
- Diff against the main branch spec with a dedicated tool (for example `oasdiff`; verify current flags) and fail on breaking changes unless the version is bumped (`api-design`).
- Feed the spec to `postman-api-testing` and response validation in e2e (`backend-testing`).

## Generated clients
- Treat generated clients as build artifacts; do not hand-edit them. Pin the generator version, review its output on spec changes, and test against the real API.
- Weak spots: unnamed inline schemas (add DTO classes), enums without names, nullable vs optional, and `oneOf` polymorphism; inspect before publishing a client.

## Keeping docs accurate
- Document real behaviour: every status the endpoint returns, the problem shape, auth requirements, pagination params.
- Add an e2e check that the exported document contains each route and error response; stale docs are contract bugs.

## See also

Optional, if installed: technical-documentation (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
