---
name: realtime-streaming
description: Token streaming from NestJS on Fastify to a browser client - SSE versus WebSocket decision, @Sse with Observable and raw Fastify reply handling, event framing and types (delta, done, error, heartbeat), event IDs and resumable streams via Last-Event-ID with a Redis stream or DB buffer, client disconnect detection and AbortSignal cancellation of upstream LLM calls, backpressure, heartbeats and proxy buffering headers, timeouts, one stream per request, persisting the final message after disconnect, error-after-start semantics, and load limits. Load when building or debugging streaming chat responses, SSE endpoints, resumable streams, or LLM token delivery.
---

# Realtime streaming

Builds on `nestjs-patterns`, `rxjs`, `fastify-adapter`, `error-handling`, and `rate-limiting-quotas`. Verify `@Sse`, `MessageEvent`, and Fastify reply APIs against the installed versions.

## Transport choice
- Default to SSE for token streaming: one-way, plain HTTP, auth via normal headers/cookies, automatic reconnect.
- Use WebSocket only for true bidirectional needs (live collaboration, voice). Cancel and regenerate are ordinary HTTP calls, not a reason for WS.
- Native `EventSource` cannot POST or set headers. For POST-with-body streaming, use `fetch` + a stream reader on the client; same wire format.
- Prefer two calls: `POST /chats/:id/messages` creates the message and returns `{ messageId }`; `GET /messages/:id/stream` streams it. This makes reconnect and resume trivial.

## Event framing
- One JSON object per `data:` line. Always set `event:` and `id:`.
- Event types: `delta` ({ text }), `done` ({ messageId, usage, finishReason }), `error` ({ code, message, retryable }), `heartbeat` (empty). No other types without a versioned contract (`api-design`).
- `done` or `error` is always the last event; the server then closes. Clients treat a close without either as a drop and resume.
- Batch tiny deltas: flush at most every 30-50 ms. Never emit one event per character.

## NestJS on Fastify
```ts
@Sse('messages/:id/stream')
stream(@Param('id') id: string, @Req() req: FastifyRequest, @Headers('last-event-id') last?: string): Observable<MessageEvent> {
  const ac = new AbortController()
  req.raw.on('close', () => ac.abort())
  return this.streams.open(id, { signal: ac.signal, after: last }).pipe(
    map((e) => ({ id: e.seq, type: e.type, data: e.payload })),
    finalize(() => ac.abort()),
  )
}
```
- Return an `Observable`; never write to `reply.raw` inside `@Sse` as well. For full control, use `@Res({ passthrough: false })` and `reply.raw.write()`, and set headers via `reply.raw.writeHead`.
- Required headers: `Content-Type: text/event-stream`, `Cache-Control: no-cache, no-transform`, `X-Accel-Buffering: no`. Do not set `Connection` on HTTP/2.
- Compression middleware must skip `text/event-stream`, or tokens arrive in bursts.
- Disable idle `connectionTimeout`/`requestTimeout` effects on streaming routes; verify Fastify server timeout options against the installed version.

## Cancellation and disconnect
- Pass an `AbortSignal` into the LLM SDK call. Abort on client close, explicit stop endpoint, and server shutdown. Unaborted upstream calls burn money.
- Disconnect from the client is not failure: the generation task continues only if you chose "finish in background" (below); otherwise abort.
- Subscribe cleanup (`finalize`, `takeUntil(close$)`) must release timers, Redis subscriptions, and listeners (`rxjs`).

## Persist independently of the socket
- Run generation in a service task decoupled from the HTTP response. Write each event to a buffer, then fan out to the stream.
- Always persist the final assistant message (content, usage, finishReason) even if the client left. Status: `streaming` -> `complete | failed | cancelled`.
- Explicit user stop persists partial text with `cancelled`. Sweep stale `streaming` rows on boot and on a timer (> 2x max generation time) to `failed`.

## Resumable streams
- Assign monotonically increasing `id` per message stream (Redis Stream entry ID or a sequence). Buffer events in Redis Streams (`XADD` with `MAXLEN ~`, TTL 5-15 min after `done`) or a DB table for durable replay.
- On reconnect, read `Last-Event-ID`, replay events after it, then join live. Replay and live join must not drop or duplicate events: read from the stream with blocking `XREAD`, not pub/sub plus a separate query.
- If the buffer expired, serve the completed message from the DB as one `delta` plus `done`.
- Send `retry: 2000` once at start to control client reconnect delay.

## Heartbeats, backpressure, timeouts
- Send `: ping` comment or `heartbeat` event every 15 s; proxies and load balancers close idle connections at 30-60 s.
- Honor backpressure: if `reply.raw.write()` returns false, wait for `drain`; if a client stays blocked > 10 s, drop it. Never buffer unboundedly per client.
- Hard cap stream duration (e.g. 5 min default, configurable per model) and emit `error` with `code: "timeout"`.
- Retry upstream only before the first token. After the first delta, retrying duplicates text.

## Errors after start
- HTTP status is already 200. Emit an `error` event with a stable code, persist status `failed`, close. Exception filters cannot change the status; handle errors inside the stream (`catchError` -> error event -> complete).
- Never leak provider messages or stack traces in `error` payloads (`backend-security`).
- Errors before the first byte use normal HTTP status codes and the standard error body.

## Load
- One active stream per request; cap concurrent streams per user (default 2-3) and per instance (`rate-limiting-quotas`).
- Each stream holds a socket and memory: set `ulimit`/pool sizes, keep per-stream state small, drain on shutdown (`app.enableShutdownHooks()`, stop accepting, wait up to 30 s).
- Log stream start/end, duration, token count, abort reason (`backend-observability`).

## Anti-patterns
- WebSocket for one-way tokens; per-token DB writes (write on batch or finish); streaming from a request-scoped provider.
- Ignoring client close; generating with no AbortSignal; buffering the whole answer then sending.
- Letting the stream be the only copy of the message.

## Checklist
- [ ] SSE headers set, compression and proxy buffering off
- [ ] Events typed with id; `done`/`error` terminal
- [ ] Heartbeat 15 s; max duration enforced
- [ ] AbortSignal wired to disconnect, stop, shutdown
- [ ] Final message persisted regardless of client
- [ ] Resume via Last-Event-ID tested, no dup/drop
- [ ] Concurrent stream caps in place
