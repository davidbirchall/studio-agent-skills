---
name: postman-api-testing
description: Postman workflows for APIs - generating collections from the OpenAPI spec, environments and variables, secrets handling, test scripts, collection structure, and running with Newman or the Postman CLI in CI. Load when creating or maintaining Postman collections, environments, or automated API contract checks.
---

# Postman

Builds on `openapi-swagger`. Verify CLI commands and script APIs (`pm.*`) against the current Postman and Newman versions.

## Source of truth
- The OpenAPI spec is the contract. Generate or import the collection from the exported `openapi.json`; do not hand-maintain endpoint lists that will drift.
- Re-import on every contract change and review the collection diff with the spec diff.

## Structure
- Folders per resource, requests named `VERB resource - intent`. Use collection-level auth and pre-request scripts rather than copying per request.
- Use variables: `{{baseUrl}}`, `{{token}}`, ids captured from earlier responses. No hardcoded hosts or ids.

## Environments and secrets
- One environment per target (local, dev, staging). Commit environment files only with non-secret values.
- Secrets (tokens, API keys) use secret-type variables or CI-injected values; never commit them (`secret-handling`). Never run destructive collections against production.

## Tests
```js
pm.test('201 created', () => pm.response.to.have.status(201))
pm.test('matches shape', () => {
  const body = pm.response.json()
  pm.expect(body.id).to.match(/^[0-9a-f-]{36}$/)
})
pm.collectionVariables.set('postId', pm.response.json().id)
```
- Assert status, content type, key fields, and the error shape (`api-design`) for failure cases. Validate against the OpenAPI schema where possible.
- Order requests so they create their own data and clean up; make runs repeatable.

## CI
- Run with Newman (`newman run collection.json -e env.json --reporters cli,junit`) or the Postman CLI against an ephemeral deployment. Fail the build on test failures and publish the JUnit report.
- Postman supplements `backend-testing`; it does not replace automated unit and e2e tests.

## Keep it in the repo
- Store the collection and non-secret environments under `postman/` as JSON, reviewed in PRs like code. Keep a short README with the run command and required CI variables.
- Regenerate from `openapi.json` in a script (verify the converter you use, e.g. `openapi-to-postmanv2`, for current flags), then re-apply only the hand-written tests. Record which parts are generated.

## Variable scoping
- Precedence is local, data, environment, collection, global (verify against current docs). Use collection variables for constants, environment for per-target values (`baseUrl`), local for one-request temporaries.
- Environment files committed to git carry placeholders (`"value": ""`, `"type": "secret"`); real values come from CI secrets via `--env-var`.

## Auth flow
Obtain a token in a collection pre-request script and cache it until expiry:
```js
const exp = Number(pm.environment.get('tokenExpiresAt') || 0)
if (Date.now() > exp - 30000) {
  pm.sendRequest({
    url: pm.environment.get('baseUrl') + '/auth/token',
    method: 'POST',
    header: { 'Content-Type': 'application/json' },
    body: { mode: 'raw', raw: JSON.stringify({
      clientId: pm.environment.get('clientId'),
      clientSecret: pm.environment.get('clientSecret'),
    }) },
  }, (err, res) => {
    if (err) throw err
    pm.environment.set('token', res.json().accessToken)
    pm.environment.set('tokenExpiresAt', Date.now() + res.json().expiresIn * 1000)
  })
}
```
Set collection auth to Bearer `{{token}}`. Use a dedicated test client with least privilege (`authentication-authorization`). Never print tokens with `console.log`.

## More test patterns
```js
pm.test('problem+json on failure', () => {
  pm.response.to.have.status(422)
  pm.expect(pm.response.headers.get('Content-Type')).to.include('application/problem+json')
  const b = pm.response.json()
  pm.expect(b).to.have.keys('type', 'title', 'status', 'code', 'errors')
})
```
- Use `pm.expect(...).to.have.property` instead of deep equality on volatile fields (ids, timestamps).
- Negative cases per resource: missing auth 401, wrong role 403, unknown id 404, invalid body, duplicate 409.

## Data-driven runs
- Feed a CSV or JSON file with `newman run ... -d cases.json` (or the CLI equivalent); read values with `pm.iterationData.get('title')`. Keep each row independent and include the expected status.

## Newman in CI
```
newman run postman/collection.json -e postman/ci.env.json \
  --env-var clientSecret="$API_CLIENT_SECRET" \
  --reporters cli,junit --reporter-junit-export reports/newman.xml \
  --bail --timeout-request 10000
```
- Run against a freshly deployed ephemeral stack with migrated, seeded data, never shared staging data.
- Upload the junit report as an artifact. Mask secrets in CI logs; do not use verbose reporters that echo headers.

## Contract checks
- Fail the run when a response does not match the OpenAPI schema (validate with a schema library in a test script, or in `backend-testing` e2e). Compare the exported spec against the previous release for breaking changes (`openapi-swagger`).

## Avoiding flakes
- Unique data per run (suffix with `{{$guid}}` or `{{$timestamp}}`); clean up in a final folder, also on failure.
- No dependence on wall-clock, other users, or external services; fix timeouts explicitly; rerun failures once only to diagnose, not to hide (`test-discipline`).
- Do not point destructive runs at shared or production hosts; guard with a check that `baseUrl` is on an allowlist.
