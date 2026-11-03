---
name: typescript-conventions
description: Framework-neutral TypeScript conventions covering strictness and tsconfig inheritance from a shared base config, unknown over any, non-null assertions, @ts-expect-error with a reason, type vs interface, no enums with an as const alternative, import type, naming, discriminated unions, type guards, satisfies, utility types, schema-derived types (Zod), API response typing, catch clause errors, module augmentation, generics, branded types, and where types live. Load when writing or reviewing any TypeScript, defining shared types, or configuring tsconfig.
---

# TypeScript conventions

Framework-specific typing (Vue, Nuxt) lives in the relevant framework skill. Review checklist: `code-review`.

## Strictness
- `strict` is on, inherited from the shared base tsconfig. Extend it with `extends`; do not redefine or loosen compiler options. A local override needs a comment saying why.
- Keep per-project tsconfig minimal: `include`, `paths`, and environment-specific `lib`/`types` only.
- Run the project's typecheck command (for example `tsc --noEmit`) in CI and fail on errors.
- No `any` without a comment justifying it. Use `unknown` and narrow.
- No non-null assertions (`!`). Narrow with a check, early return, or type guard. If unavoidable, comment why it is safe.
- `@ts-expect-error` over `@ts-ignore`, always with a reason. It fails when the error disappears, so stale suppressions surface.

## Declarations
- `type` by default. Use `interface` for object shapes meant to be extended or merged (module augmentation, class contracts).
- No `enum`. Use a union or an `as const` object:
```ts
const Size = { sm: 'sm', lg: 'lg' } as const
type Size = (typeof Size)[keyof typeof Size]
```
- Type-only imports: `import type { User } from './types'`.
- Naming: PascalCase for types and generics (`UserProfile`, `T`, `TItem` when clarity needs it). No `I` prefix, no `Type` suffix. camelCase values, UPPER_SNAKE for true constants.
- Infer locals and return types of small functions. Annotate exported function signatures and public API returns.

## Modelling
- Utility types over hand-copied shapes: `Pick`, `Omit`, `Partial`, `Required`, `Record`, `ReturnType`, `Parameters`, `Awaited`.
- `satisfies` checks a value against a type while keeping its narrow inferred type (config objects, lookup tables).
- Model states as a discriminated union, not optional flags:
```ts
type Result<T> =
  | { status: 'loading' }
  | { status: 'error'; error: Error }
  | { status: 'success'; data: T }
```
- Narrow with `switch (result.status)`; add `default: assertNever(result)` where exhaustiveness matters.
- Type guards (`value is T`) must actually check the shape; a guard that returns `true` is a cast.
- Generics: constrain (`T extends { id: string }`), keep few parameters, name them for meaning when more than one. Do not add a generic that appears only once.
- Branded types for ids that must not mix: `type UserId = string & { readonly __brand: 'UserId' }`, created only by a validating constructor.

## Schemas and API data
- For validated data (forms, untrusted or third-party responses), the schema is the single source of truth: `type User = z.infer<typeof userSchema>`. Never hand-write a parallel type.
- Use `z.input<typeof s>` and `z.output<typeof s>` when the schema transforms or defaults values.
- Typing a response generic (`fetch<User>()`) is compile-time only and validates nothing. Parse at the boundary when data is untrusted.
- Keep wire types (response shape) separate from domain or view types; map between them in one place.

## Errors
- `catch (error)` is `unknown`. Narrow with `instanceof Error` or a guard before reading properties.
- Throw `Error` instances only. Wrap with `new Error(msg, { cause })`.

## Module augmentation
- Augment third-party types by declaration merging, not casting:
```ts
declare module 'some-lib' {
  interface Options { tenantId?: string }
}
export {}
```
- Put augmentations in a `.d.ts` or a file with a top-level `export`; one file per augmented module, in `types/`.

## Where types live
- Colocate a type with its only consumer.
- Types shared by 2+ features go in `types/` or the feature's `types.ts`. Schema-derived types live beside their schema.
- No global `types.ts` dumping ground. Export types from the module that owns the concept.
