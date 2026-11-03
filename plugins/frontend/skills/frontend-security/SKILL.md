---
name: frontend-security
description: security standards for Vue/Nuxt frontends — auth token storage decision, XSS (v-html, dynamic URLs), CSP and security headers, env/secrets, dependency hygiene, server-route input validation. Load when handling auth/tokens, rendering user content, configuring headers or env, adding dependencies, or writing server routes.
---

# Frontend security

## Auth token storage
Not standardised; it varies per project. **Record the decision per project** (docs or ADR) with its CSRF and XSS reasoning. Guide:
- **Prefer** `httpOnly` + `Secure` + `SameSite` (`Lax`, or `Strict` if flows allow) cookies set by the server. JS cannot read them, so XSS cannot steal the token. Cookie auth needs CSRF handling (SameSite plus a CSRF token on state-changing requests when cross-site requests are possible).
- **Avoid `localStorage`/`sessionStorage` for tokens**; any XSS reads them.
- If a token must live in JS (e.g. third-party API constraint), keep it in memory only, short-lived, and document why.
- Forward cookies on SSR service calls through the per-request axios instance (`api-client-patterns`).

## XSS
- **Never `v-html` with untrusted content.** If unavoidable, sanitize with DOMPurify immediately before binding and add a code comment stating the source and why it is safe.
```vue
<!-- v-html: CMS rich text, sanitized with DOMPurify; no plain-text alternative -->
<div v-html="sanitizedHtml" />
```
- DOMPurify needs a DOM; on SSR use a DOM-backed setup (e.g. `isomorphic-dompurify`) or render the content client-only. Check the project's choice.
- Do not bind user-controlled values to `:href`, `:src` or `:action` without validating the scheme; `javascript:` URLs execute. Allow-list `http:`, `https:`, `mailto:`, `tel:` (parse with `new URL()`, reject the rest). External links get `rel="noopener noreferrer"`.
- No `innerHTML`, `eval` or `new Function` in components.

## Links, redirects and CSRF
- `target="_blank"` links get `rel="noopener noreferrer"`.
- Open redirects: never navigate to a `redirect`/`next` query value unchecked. Accept only relative paths that start with a single `/` (reject `//host` and `/\\host`) or an allow-list of origins.
```ts
export function safeRedirect(value: unknown, fallback = '/'): string {
  return typeof value === 'string' && /^\/(?![/\\])/.test(value) ? value : fallback
}
```
- Cookie auth: `SameSite` plus a CSRF token (or a custom header requirement) on state-changing requests; never mutate state on `GET`. Confirm CORS does not allow credentials for wildcard origins.

## CSP and security headers
Set via the `nuxt-security` module or `routeRules` headers; exact config keys vary by module version, so check its docs.
- Minimum: `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`, `Permissions-Policy`, and clickjacking protection (CSP `frame-ancestors`).
- CSP: start strict, avoid `unsafe-inline`/`unsafe-eval`; allow-list third-party origins explicitly (every third-party script in `frontend-performance` needs an entry). Nuxt SSR inline scripts need nonces or hashes; test against a production build, not dev.
- Roll out with `Content-Security-Policy-Report-Only` first.

### Nonce and report basics
- A nonce is a per-response random value placed in the CSP header and on each allowed inline script; it must be unpredictable and never cached across responses. Hashes suit static inline scripts. Check how your `nuxt-security` version supplies nonces, and whether your CDN caches pages (a cached nonce breaks the policy).
- Add a reporting endpoint in Report-Only to see violations before enforcing.

## Third-party scripts
- Every third-party script needs an owner, a reason, a CSP entry and a performance check (`frontend-performance`).
- Where the file is static and versioned, add Subresource Integrity (`integrity="sha384-..." crossorigin="anonymous"`). SRI does not work for scripts that change at the same URL; prefer self-hosting those or a vendor with a stable version URL.
- Load after consent where privacy rules require it; sandbox embeds with `iframe sandbox`.

## User-generated content and uploads
- Render user text as text (interpolation), never as HTML. Markdown from users goes through a sanitizing renderer.
- Uploads: validate type by content on the server, not by file name or the client `Content-Type`; enforce size limits; store outside the web root or in object storage with a separate origin; serve with `Content-Disposition` and `nosniff` where inline rendering is unneeded. Do not render uploaded SVG inline unsanitized.
- Client checks on file type and size are UX only.

## Env and secrets
- Only `runtimeConfig.public` is exposed to the client. **Never put secrets there**; private keys go at the `runtimeConfig` top level (see `nuxt-project-patterns`), supplied via `NUXT_*` env vars.
- Never commit `.env`; commit a `.env.example` with placeholders and keep `.env` in `.gitignore`.
- Never log tokens or secrets. See `secret-handling`.
- Anything in the client bundle is public, including `NUXT_PUBLIC_*` values and source maps' contents; do not rely on obscurity.
- Public config example: `runtimeConfig.public.apiBase` is fine; `runtimeConfig.apiSecret` is server-only. If a secret is read in a component, it is a bug.

## Dependencies
- Commit `pnpm-lock.yaml`; CI installs with `pnpm install --frozen-lockfile`.
- Run `pnpm audit` in CI (verify flags such as `--prod` and `--audit-level` against the installed version) and fail on high/critical.
- Review every new dependency: maintenance, size (`frontend-performance`), install scripts, transitive count. Prefer the platform or existing deps.
- Pin versions or automate updates with Renovate/Dependabot; review update PRs, don't auto-merge majors.
- Tooling setup: `frontend-code-quality`.

## Server routes
Validate **all** input (body, query, params, any header you act on) with Zod and return 400 on failure; see `nuxt-project-patterns`. Client-side validation (`form-handling`) is UX only. Authorize on the server for every request, not just in route middleware.

Security review (Rai) is a backstop for risky changes, not a substitute for these rules.

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
