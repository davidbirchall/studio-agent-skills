---
name: chat-ui-patterns
description: Opinionated UI patterns for high-quality chat interfaces in Vue 3 and Nuxt 3 - message parts instead of strings, frame-batched streaming render, incremental markdown with sanitisation, code blocks with copy, scroll anchoring and jump-to-latest, virtualisation, the composer (autosize, Enter vs Shift+Enter, IME safety, drafts, attachments, paste and drop), stop/regenerate/edit/retry and branch navigation, optimistic messages with pending and failed states, tool calls and citations, empty/loading/error states, thread sidebar, accessibility, mobile viewport handling, and testing with a fake stream. Load when building or reviewing chat message lists, composers, streaming rendering, or conversation controls.
---

# Chat UI patterns

Transport, SSE parsing and abort live in `streaming-client`. State ownership: `state-management`. Sanitisation and XSS: `frontend-security`. Audit pass: `frontend-a11y-check`. Perf budgets: `frontend-performance`.

## Message model
- A message is `{ id, role, status, parts: Part[] }`, never a string. Part = `text | reasoning | tool_call | tool_result | citation | attachment | error` (discriminated union on `type`).
- Render with one component per part type via a map; unknown part types render nothing, not a crash.
- Keep `status: 'pending' | 'streaming' | 'done' | 'failed' | 'aborted'` on the message; the store owns it, components only read.
- Stable `:key="message.id"`. Generate a client id for optimistic messages; replace with the server id in place, do not remount.

## Streaming render
- Append deltas to a plain buffer; flush to reactive state once per `requestAnimationFrame`. Never write reactive state per token.
```ts
let buf = '', raf = 0
function onDelta(d: string) {
  buf += d
  raf ||= requestAnimationFrame(() => { raf = 0; part.text += buf; buf = '' })
}
onBeforeUnmount(() => cancelAnimationFrame(raf))
```
- Only the last message re-renders; memoise finished messages (`v-memo` or a `done`-gated component) so history is never re-parsed.
- Reserve no animated height; let content grow. Avoid per-token transitions (`animation-motion`).

## Markdown and sanitisation
- Parse incrementally: re-parse only the open trailing block, cache closed blocks. Tolerate unclosed fences, lists and emphasis mid-stream.
- Never `v-html` unsanitised output. Sanitise with DOMPurify (or render to a VNode tree from the AST) after parsing; strip scripts, event handlers, `javascript:` URLs. Add `rel="noopener noreferrer" target="_blank"` to links. Sanitise images by allowing only https origins you trust.
- Lazy-load the highlighter (Shiki or similar); highlight a code block only when its fence closes. Verify API against installed version.

## Code blocks
- Header with language label and a copy button; copy raw text, not highlighted HTML (`navigator.clipboard.writeText`, with a fallback and a visible "Copied" state for ~1.5 s).
- Horizontal scroll inside the block; never wrap code.

## Scroll anchoring
- Track `atBottom` with an `IntersectionObserver` on a sentinel (threshold about 48 px). Auto-scroll on new content only when `atBottom` is true.
- If the user scrolls up, stop following and show a "Jump to latest" button (with unread indicator). Sending a message always scrolls to bottom.
- Use `overflow-anchor` and `ResizeObserver` on the list; do not poll `scrollHeight`.
- Virtualise (`@tanstack/vue-virtual`, variable heights) above roughly 200 messages or heavy parts; below that, plain render is faster and keeps find-in-page working. Measure first.

## Composer
- Autosize textarea up to a max height (about 8 lines), then scroll. Enter sends, Shift+Enter newline; Cmd/Ctrl+Enter is an acceptable alternative setting.
- IME safety: ignore Enter when `e.isComposing` or `e.keyCode === 229`.
- Disable send when empty or while a send is in flight; keep the input editable while streaming.
- Persist drafts per thread (debounced, `localStorage`, versioned key); clear on successful send. Never persist attachments' bytes.
- Attachments: paste (`clipboardData.files`), drag-drop with a drop overlay, file picker. Validate type and size client-side, show progress and remove buttons, revoke object URLs on cleanup.

## Message actions
- While streaming, send becomes Stop (aborts, keeps partial text, status `aborted`). Afterwards: Copy, Regenerate, Edit (user messages), Retry (failed).
- Edit and regenerate create a sibling branch, never overwrite. Store `parentId`; show "2 / 3" prev/next navigation per sibling set. Active branch is a path of ids.
- Optimistic user message appears at once as `pending`; on failure mark `failed` with Retry and Delete. Never silently drop it.

## Tool calls and citations
- Tool call: collapsed row with name, state (running, done, error) and expandable JSON args/result; never auto-expand.
- Citations: inline numbered markers linking to a source list; unknown markers render as plain text.

## States
- Empty: suggested prompts and focused composer. Loading: skeleton rows plus typing indicator before first token. Error: inline per message with Retry, plus a banner for connection loss.

## Thread sidebar
- Virtualise long lists, group by date, optimistic rename and delete with undo, active thread in the route (`/chat/[id]`). Collapsible drawer on mobile.

## Accessibility
- The list is `role="log"` with `aria-live="polite"` and `aria-busy` while streaming; do not announce every token. Announce completion ("Response complete") through a separate visually hidden polite region.
- Move focus to the composer after send, and to the new message only on user request. Keep Stop reachable by keyboard.
- Shortcuts: Esc stops, Cmd/Ctrl+K new chat, Up in an empty composer edits the last message. Document them and make them non-conflicting.
- Respect `prefers-reduced-motion`.

## Mobile
- Size the shell with `100dvh`; use `visualViewport` resize to keep the composer above the keyboard. `env(safe-area-inset-bottom)` padding. Font size 16 px minimum in inputs to prevent iOS zoom.

## Testing with a fake stream
- Drive the UI with a fake source emitting deltas via `vi.useFakeTimers()` and a scripted `ReadableStream`; assert on parts, status and live-region text. Wider rules: `frontend-testing`, `test-discipline`.
```ts
const fake = scriptedStream([{ type: 'delta', text: 'Hel' }, { type: 'delta', text: 'lo' }, { type: 'done' }])
```

## Anti-patterns
- Storing messages as one growing string; `v-html` on raw markdown; scrolling on every token regardless of user position; Enter handler without IME check; remounting messages when ids change; announcing each token.

## Checklist
- [ ] Messages are typed parts with status
- [ ] Deltas batched per frame; history not re-rendered
- [ ] Markdown sanitised, no raw `v-html`
- [ ] Scroll follows only at bottom; jump control present
- [ ] IME-safe composer, drafts, attachment limits
- [ ] Stop, regenerate, edit branches, retry work
- [ ] Live region announces completion only
- [ ] Mobile keyboard handled; fake-stream tests pass
