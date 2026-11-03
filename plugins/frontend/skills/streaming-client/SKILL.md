---
name: streaming-client
description: Rules for consuming server-sent token streams in the browser with Vue 3 and Nuxt 3 - fetch plus ReadableStream versus EventSource, robust SSE frame parsing (partial chunks, multi-line data, TextDecoder stream mode), typed and validated event schemas, AbortController for stop and navigation, reconnect with Last-Event-ID and resume, event-id dedupe, retry and backoff, auth on long streams, a useChatStream composable with a status state machine, store ownership, SSR and client-only caveats, unmount cleanup, and testing with mocked streams. Load when implementing or debugging a streaming chat client, SSE parsing, stop or resume behaviour, or stream error handling.
---

# Streaming client

Rendering the tokens: `chat-ui-patterns`. Ordinary requests (axios) and error normalisation: `api-client-patterns`. Token storage: `frontend-security` and `secret-handling`. State ownership: `state-management`.

## Transport choice
- Default: `fetch` + `response.body.getReader()`. It supports POST bodies, custom headers (`Authorization`) and `AbortSignal`.
- `EventSource` only for simple GET streams with cookie auth: it cannot POST or set headers, and its auto-reconnect is hard to control.
- Do not use axios for streams (the default XHR adapter buffers the response; stream support exists only via the fetch adapter, so verify against the installed version). Use axios for everything else.
- Check `res.ok` and `content-type: text/event-stream` before reading; a non-2xx body is a normal error payload, not a stream.

## Parsing SSE frames
- Decode with a single `TextDecoder` and `decode(chunk, { stream: true })`; multi-byte characters split across chunks otherwise corrupt.
- Buffer text, split on a blank line (`\n\n`, also accept `\r\n\r\n`); keep the trailing partial in the buffer.
- Per frame: lines starting `:` are comments (keepalive); `data:` lines join with `\n`; also read `event:`, `id:`, `retry:`. Strip exactly one leading space after the colon.
```ts
export async function* parseSse(body: ReadableStream<Uint8Array>) {
  const reader = body.getReader(), dec = new TextDecoder()
  let buf = ''
  try {
    for (;;) {
      const { done, value } = await reader.read()
      if (done) break
      buf += dec.decode(value, { stream: true })
      let m: RegExpExecArray | null
      while ((m = /\r?\n\r?\n/.exec(buf))) {
        const raw = buf.slice(0, m.index)
        buf = buf.slice(m.index + m[0].length)
        const f = parseFrame(raw)
        if (f) yield f
      }
    }
  } finally { reader.releaseLock() }
}
```
- Treat `data: [DONE]`-style sentinels as protocol, handled before JSON parsing.

## Event schema
- Define a discriminated union (`delta`, `tool_call`, `citation`, `error`, `done`) and validate each frame with zod or valibot at the boundary. Unknown event types are ignored; invalid payloads raise a typed `StreamProtocolError`.
- Never trust `JSON.parse` output as typed; never put raw event data into `v-html`.

## Abort
- One `AbortController` per stream. Stop button, route change (`onBeforeRouteLeave`), new send and unmount all call `abort()`. An abort is `status: 'aborted'`, not an error; swallow `AbortError`.
- Keep the partial text already received. Tell the server too if the API has a cancel endpoint.

## Reconnect and resume
- Track the last `id:`. On network drop mid-stream, reconnect with `Last-Event-ID` header (fetch) only if the backend supports resume; otherwise show Retry and do not replay a POST that may have side effects.
- Dedupe by event id (keep last seen id or a bounded `Set`); drop anything not newer.
- Honour server `retry:` ms as the minimum delay.

## Retry and backoff
- Retry only connection failures, 502/503/504 and 429 (respect `Retry-After`) before the first byte, or resumable drops. Exponential backoff with jitter, max 3 attempts, cancelled by abort.
- Never retry 400/401/403/404/422 or protocol errors. On 401 refresh the token once, then fail.

## Auth on long streams
- Attach the token at request start via the same provider the axios interceptor uses. A stream cannot refresh mid-flight: refresh proactively if expiry is near, and on a mid-stream auth error resume with a fresh token.
- Never put tokens in the URL query (they leak into logs).

## useChatStream shape
- Status machine: `idle -> connecting -> streaming -> done | error | aborted`; any terminal state returns to `idle` on next `send`. Illegal transitions are ignored.
```ts
export function useChatStream(threadId: MaybeRef<string>) {
  const chat = useChatStore()
  const status = ref<StreamStatus>('idle')
  let ctrl: AbortController | null = null

  async function send(input: string) {
    ctrl?.abort(); ctrl = new AbortController()
    status.value = 'connecting'
    const msgId = chat.beginAssistant(unref(threadId))
    try {
      const res = await fetch('/api/chat', { method: 'POST', signal: ctrl.signal, headers, body })
      status.value = 'streaming'
      for await (const ev of parseSse(res.body!)) chat.applyEvent(msgId, parseEvent(ev))
      status.value = 'done'
    } catch (e) { status.value = isAbort(e) ? 'aborted' : 'error' }
  }
  const stop = () => ctrl?.abort()
  onScopeDispose(stop)
  return { status, send, stop }
}
```
- The store owns messages and applies events (`applyEvent`); the composable owns only transport and status. Components never mutate messages from the stream.

## SSR and Nuxt
- Streams run client-side only: call `send` from event handlers, never from setup or `useAsyncData`. Guard with `import.meta.client`. Do not open a stream during SSR.
- If proxying through a Nitro route, return a stream (`sendStream`) and disable buffering/compression for that route; verify against installed version.

## Testing
- Build a `ReadableStream` from scripted chunks, deliberately splitting frames and multi-byte characters mid-chunk; stub `fetch` with `vi.stubGlobal`. Assert frames, status transitions, abort and dedupe. Rules: `frontend-testing`, `test-discipline`.
```ts
const stream = new ReadableStream({ start(c) { for (const s of chunks) c.enqueue(enc.encode(s)); c.close() } })
vi.stubGlobal('fetch', vi.fn().mockResolvedValue(new Response(stream, { headers: { 'content-type': 'text/event-stream' } })))
```

## Anti-patterns
- Splitting on `\n` per chunk; decoding without `stream: true`; `EventSource` for POST chat; retrying non-idempotent POSTs blindly; treating abort as error; stream opened in SSR; leaking controllers on unmount.

## Checklist
- [ ] fetch streaming with abort wired to stop, route, unmount
- [ ] Parser handles partial chunks, multi-line data, comments
- [ ] Events validated; unknown types ignored
- [ ] Resume uses Last-Event-ID with id dedupe
- [ ] Retry limited, jittered, never on 4xx
- [ ] Status machine explicit; store owns messages
- [ ] Client-only; mocked-stream tests cover splits
