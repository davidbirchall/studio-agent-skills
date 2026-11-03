---
name: file-storage
description: File upload and storage for NestJS and Prisma backends - S3-compatible object storage behind an interface with local disk for dev, presigned URL uploads versus API-proxied uploads, size and type limits with content sniffing, virus scanning hooks, safe key naming, file metadata in Prisma, private-by-default access with short-lived signed download URLs, thumbnails via jobs, streaming, multipart and resumable uploads, lifecycle and orphan cleanup, backups, CDN caching, and testing with a fake store. Load when accepting uploads, serving user files, adding image processing, or designing object storage and file metadata.
---

# File storage

Builds on `nestjs-patterns`, `prisma-patterns`, `background-processing`, and `backend-security`. Provider SDK and option names vary; verify against current docs.

## Storage interface
- Code against an interface, not an SDK. Use an S3-compatible implementation in production, local disk or a local S3-compatible container in dev.
```ts
export interface ObjectStore {
  putStream(key: string, body: Readable, opts: { contentType: string; size?: number }): Promise<void>;
  getStream(key: string): Promise<Readable>;
  signedDownloadUrl(key: string, ttlSeconds: number): Promise<string>;
  signedUploadUrl(key: string, opts: { contentType: string; maxBytes: number; ttlSeconds: number }): Promise<string>;
  delete(key: string): Promise<void>;
}
export const OBJECT_STORE = Symbol('OBJECT_STORE');
```
- Select the implementation from validated config (`data-validation`).

## Upload paths
- Prefer presigned uploads for anything over about 1 MB: API creates a `File` row in `pending`, returns a signed URL, client uploads directly, then calls a confirm endpoint (or a storage event) that verifies size and type and marks `ready`.
- Proxy through the API only for small files needing synchronous validation. Use streaming multipart parsing (busboy via the framework adapter); never buffer whole files in memory (`fastify-adapter`).
- Signed upload URLs: TTL 5 minutes or less, pinned content type and max size, key chosen server-side.
- Files above about 100 MB: multipart or resumable uploads (parts of 5-16 MB, retry per part, abort incomplete uploads via lifecycle rule).

## Validation
- Enforce limits at the edge and in the handler: max bytes per route (for example 5 MB images, 25 MB documents), max count, allowlist of MIME types.
- Never trust the client `Content-Type` or extension. Sniff magic bytes (for example `file-type`) after upload and reject mismatches.
- Re-encode images to strip EXIF and embedded payloads. Reject SVG or sanitise it, and serve with `Content-Disposition: attachment` or a CSP sandbox.
- Virus scan hook: new files stay `pending` until a scan job returns clean; only `ready` files are downloadable. Provider-neutral: scanner service or provider feature; verify.

## Keys and metadata
- Key = server-generated UUID with a tenant or purpose prefix (`${tenantId}/${uuid}`). Never use user-supplied names or paths; store the original name as metadata only and sanitise it for `Content-Disposition`.
```prisma
model File {
  id          String   @id @default(uuid())
  ownerId     String
  key         String   @unique
  contentType String
  sizeBytes   Int
  checksum    String?
  status      FileStatus @default(PENDING)
  originalName String
  createdAt   DateTime @default(now())
  deletedAt   DateTime?
  @@index([ownerId, createdAt])
}
enum FileStatus { PENDING READY REJECTED DELETED }
```
- Authorise every access via the `File` row (ownership or tenant, `authentication-authorization`, `multi-tenancy`), never by key knowledge.

## Access
- Buckets are private by default. Serve via signed download URLs with TTL of 1-15 minutes issued after an authorisation check.
- Public assets (avatars, marketing) go in a separate public bucket behind a CDN with immutable keys and `Cache-Control: public, max-age=31536000, immutable`. Private content: `private, no-store`.
- Stream large downloads (`getStream` piped to the response) with `Range` support; never load into memory.

## Processing
- Thumbnails and transcodes run as jobs (`background-processing`): idempotent, keyed by `fileId:variant`, writing derived keys such as `${key}/thumb-256`. Cap input dimensions and pixel count to prevent decompression bombs.
- Store variants as rows or a JSON column on `File`; generate lazily on first request only if bounded.

## Lifecycle
- Soft-delete the row, then a job deletes the object; make deletion idempotent.
- Orphan cleanup job: `pending` rows older than 24 hours and objects without rows (list and diff, with a safety age).
- Bucket lifecycle rules: abort incomplete multipart uploads after 1-7 days, expire temp prefixes.
- Enable versioning or cross-region replication for irreplaceable data; test restores. DB and bucket backups must be consistent enough to reconcile.

## Testing
- Provide `FakeObjectStore` (in-memory map) implementing the interface; unit-test services against it (`backend-testing`).
- Test: oversize rejected, type spoofing rejected, other-user access denied, expired confirm, duplicate confirm idempotent.

## Anti-patterns
- Buffering uploads in memory.
- Trusting extension or client MIME.
- User-controlled keys; path traversal.
- Permanent public URLs for private files.
- Deleting row without object, or the reverse, with no reconciliation.
- Logging signed URLs (they are credentials).

## Checklist
- [ ] Interface with S3-compatible and fake implementations
- [ ] Presigned upload with pinned type and size; confirm step
- [ ] Limits, sniffing, scan hook before `ready`
- [ ] Server-generated keys; metadata row with ownership
- [ ] Private bucket, short signed URLs, correct cache headers
- [ ] Derived variants via idempotent jobs
- [ ] Orphan cleanup and lifecycle rules; backups tested
