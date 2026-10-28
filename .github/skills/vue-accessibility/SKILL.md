---
name: "vue-accessibility"
description: "Accessible Vue 3 component patterns: semantic HTML, ARIA, keyboard navigation, focus management, testing with axe, and WCAG 2.1 compliance"
confidence: "medium"
---

# Vue Accessibility

Building accessible Vue 3 components following WCAG 2.1 AA standards. Focus on semantic HTML, proper ARIA usage, keyboard navigation, and testing.

## Guiding Principles

1. **Semantic HTML first** — Use native elements (`<button>`, `<input>`, `<nav>`) before ARIA
2. **Keyboard navigation** — All interactive elements operable via keyboard
3. **Screen reader support** — Meaningful announcements and landmarks
4. **Focus management** — Clear visible focus, logical tab order
5. **Color contrast** — 4.5:1 for text, 3:1 for UI components
6. **Testing early** — Use axe-core and manual testing, not an afterthought
7. **User choice** — Respect prefers-reduced-motion, prefers-color-scheme

## Semantic HTML Foundation

### Use Native Elements

```vue
<!-- ❌ WRONG - Non-semantic, requires ARIA, keyboard setup -->
<div class="button" @click="handleClick">Click Me</div>

<!-- ✅ RIGHT - Semantic, keyboard works automatically -->
<button @click="handleClick">Click Me</button>
```

**Why?** Native elements come with:
- Built-in keyboard support (Enter/Space for button)
- Built-in screen reader announcements
- Built-in focus management
- Built-in semantic meaning
- No extra ARIA needed

### Standard HTML Elements

```vue
<!-- Links -->
<a href="/about">About Us</a>

<!-- Buttons -->
<button @click="handleAction">Action</button>
<button type="submit">Submit</button>

<!-- Forms -->
<form @submit.prevent="handleSubmit">
  <label for="email">Email</label>
  <input id="email" type="email" />
  <button type="submit">Send</button>
</form>

<!-- Navigation -->
<nav>
  <ul>
    <li><a href="/home">Home</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

<!-- Main content -->
<main>
  <article>
    <h1>Article Title</h1>
    <p>Content...</p>
  </article>
</main>

<!-- Landmarks -->
<header>Top of page</header>
<main>Main content</main>
<aside>Sidebar</aside>
<footer>Bottom of page</footer>
```

## ARIA (Accessible Rich Internet Applications)

**Use ARIA to enhance, not replace, semantic HTML.**

### When to Use ARIA

| Situation | Solution |
|-----------|----------|
| Need to describe a complex interactive element | Use `aria-label` or `aria-describedby` |
| Custom button-like component (if `<button>` unavailable) | Add `role="button"` and handle keyboard |
| Need to hide visual element from screen readers | Use `aria-hidden="true"` |
| Need to announce dynamic content changes | Use `aria-live` regions |
| Need to link error to form field | Use `aria-invalid` + `aria-describedby` |
| Need to indicate loading state | Use `aria-busy="true"` |

### Common ARIA Attributes

```vue
<!-- aria-label: Label when no visible text -->
<button aria-label="Close dialog" @click="close">
  <icon name="x" />
</button>

<!-- aria-describedby: Link element to description -->
<input
  id="password"
  type="password"
  aria-describedby="pwd-hint"
/>
<p id="pwd-hint">Must be at least 8 characters</p>

<!-- aria-invalid + aria-describedby: Form errors -->
<input
  id="email"
  type="email"
  aria-invalid="true"
  aria-describedby="email-error"
/>
<p id="email-error" role="alert">Invalid email address</p>

<!-- aria-live: Announce dynamic updates -->
<div aria-live="polite" aria-atomic="true">
  {{ message }}
</div>

<!-- aria-busy: Indicate loading state -->
<button :aria-busy="isLoading" @click="load">
  {{ isLoading ? 'Loading...' : 'Load More' }}
</button>

<!-- aria-expanded: Show state of expandable elements -->
<button
  :aria-expanded="isOpen"
  @click="isOpen = !isOpen"
>
  Options
</button>
<div v-if="isOpen">Options content</div>

<!-- aria-current: Indicate current page in navigation -->
<nav>
  <a href="/home" :aria-current="currentPage === 'home' ? 'page' : undefined">
    Home
  </a>
  <a href="/about" :aria-current="currentPage === 'about' ? 'page' : undefined">
    About
  </a>
</nav>

<!-- aria-disabled: For non-button disabled elements -->
<div role="button" :aria-disabled="isDisabled">
  Click Me
</div>

<!-- aria-checked: For custom checkboxes -->
<div
  role="checkbox"
  :aria-checked="isChecked"
  @click="toggle"
>
  {{ label }}
</div>
```

## Keyboard Navigation

### Tab Order

```vue
<template>
  <!-- Tab order: 1 → 2 → 3 → 4 (automatic) -->
  <button>Submit</button>               <!-- 1 -->
  <input type="text" />                 <!-- 2 -->
  <a href="#">Link</a>                  <!-- 3 -->
  <button>Cancel</button>               <!-- 4 -->

  <!-- Custom tab order (avoid if possible) -->
  <button tabindex="0">First</button>   <!-- 1 (always focusable) -->
  <button tabindex="1">Second</button>  <!-- 2 (avoid tabindex > 0) -->
  <button tabindex="-1">Hidden</button> <!-- Not in tab order -->
</template>
```

**✅ Good:**
- Use semantic elements (automatic tab order)
- Natural source order matches visual order
- Use `tabindex="0"` to make custom elements focusable
- Use `tabindex="-1"` for elements managed by JavaScript (modals, tooltips)

**❌ Avoid:**
- `tabindex > 0` (breaks expected tab order)
- Tab order that doesn't match visual order
- Trapping focus unintentionally

### Keyboard Handlers

```typescript
// components/Modal/Modal.vue
<template>
  <div
    v-show="isOpen"
    class="modal-overlay"
    @keydown="handleKeydown"
    role="presentation"
    @click="handleOverlayClick"
  >
    <div
      class="modal-content"
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <h2 id="modal-title">{{ title }}</h2>
      <button
        ref="closeButton"
        aria-label="Close dialog"
        @click="close"
      >
        ×
      </button>
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

interface Props {
  isOpen: boolean
  title: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  (e: 'close'): void
}>()

const closeButton = ref<HTMLButtonElement>()

// Focus management
watch(() => props.isOpen, (isOpen) => {
  if (isOpen) {
    // Focus modal on open
    setTimeout(() => closeButton.value?.focus())
  }
})

// Escape key closes modal
const handleKeydown = (event: KeyboardEvent) => {
  if (event.key === 'Escape') {
    emit('close')
  }
}

// Close on overlay click (not content click)
const handleOverlayClick = (event: MouseEvent) => {
  if (event.target === event.currentTarget) {
    emit('close')
  }
}
</script>
```

### Common Keyboard Events

```typescript
// Button keyboard support
@keydown.enter="handleClick"
@keydown.space="handleClick"

// Close on Escape
@keydown.esc="handleClose"

// Navigation
@keydown.arrow-up="navigateUp"
@keydown.arrow-down="navigateDown"
@keydown.arrow-left="navigatePrev"
@keydown.arrow-right="navigateNext"

// Submit on Enter
@keydown.enter="submit"
```

## Focus Management

### Focus Visibility

```vue
<style scoped>
/* Always show focus indicator */
button:focus,
input:focus,
a:focus {
  outline: 2px solid #4299e1;
  outline-offset: 2px;
}

/* Remove default outline only if providing custom */
button:focus-visible {
  outline: 2px solid #4299e1;
  outline-offset: 2px;
}

/* For users who prefer reduced motion */
@media (prefers-reduced-motion: no-preference) {
  button:focus {
    box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.5);
  }
}
</style>
```

### Focus Trap (Modal, Drawer)

```typescript
// utils/focusTrap.ts
export function createFocusTrap(element: HTMLElement) {
  const focusableElements = element.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
  )

  const firstElement = focusableElements[0] as HTMLElement
  const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement

  const handleKeydown = (event: KeyboardEvent) => {
    if (event.key !== 'Tab') return

    if (event.shiftKey) {
      // Shift+Tab on first element → focus last
      if (document.activeElement === firstElement) {
        lastElement.focus()
        event.preventDefault()
      }
    } else {
      // Tab on last element → focus first
      if (document.activeElement === lastElement) {
        firstElement.focus()
        event.preventDefault()
      }
    }
  }

  const activate = () => {
    firstElement.focus()
    element.addEventListener('keydown', handleKeydown)
  }

  const deactivate = () => {
    element.removeEventListener('keydown', handleKeydown)
  }

  return { activate, deactivate }
}
```

**Usage in component:**

```typescript
import { onMounted, onUnmounted, ref } from 'vue'
import { createFocusTrap } from '@/utils/focusTrap'

const modalContent = ref<HTMLElement>()

onMounted(() => {
  if (modalContent.value) {
    const trap = createFocusTrap(modalContent.value)
    trap.activate()

    onUnmounted(() => trap.deactivate())
  }
})
```

## Accessible Component Examples

### Accessible Button

```vue
<template>
  <button
    :disabled="disabled"
    :aria-busy="isLoading"
    :aria-label="ariaLabel"
    class="button"
    :class="{ 'button--loading': isLoading }"
  >
    <span v-if="isLoading" class="spinner" aria-hidden="true" />
    <slot />
  </button>
</template>

<script setup lang="ts">
interface Props {
  disabled?: boolean
  isLoading?: boolean
  ariaLabel?: string
}

withDefaults(defineProps<Props>(), {
  disabled: false,
  isLoading: false,
})
</script>

<style scoped>
.button {
  padding: 0.5rem 1rem;
  background: #4299e1;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;

  /* Visible focus indicator */
  &:focus-visible {
    outline: 2px solid #2c5aa0;
    outline-offset: 2px;
  }

  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  &:hover:not(:disabled) {
    background: #3182ce;
  }
}

.button--loading {
  pointer-events: none;
}

.spinner {
  display: inline-block;
  width: 1em;
  height: 1em;
  margin-right: 0.5em;
  border: 2px solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
</style>
```

### Accessible Dropdown (Select Alternative)

```vue
<template>
  <div class="dropdown">
    <label :for="`dropdown-${id}`" class="dropdown__label">
      {{ label }}
    </label>

    <button
      :id="`dropdown-${id}`"
      :aria-expanded="isOpen"
      :aria-haspopup="true"
      :aria-controls="`dropdown-menu-${id}`"
      class="dropdown__trigger"
      @click="isOpen = !isOpen"
      @keydown="handleKeydown"
    >
      {{ selectedOption?.label || 'Select...' }}
      <span aria-hidden="true" class="dropdown__arrow">▼</span>
    </button>

    <ul
      v-if="isOpen"
      :id="`dropdown-menu-${id}`"
      role="listbox"
      class="dropdown__menu"
    >
      <li
        v-for="option in options"
        :key="option.value"
        role="option"
        :aria-selected="selectedOption?.value === option.value"
        :class="{ 'dropdown__item--selected': selectedOption?.value === option.value }"
        class="dropdown__item"
        @click="selectOption(option)"
        @keydown.enter="selectOption(option)"
        @keydown.space.prevent="selectOption(option)"
      >
        {{ option.label }}
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

interface Option {
  value: string
  label: string
}

interface Props {
  id: string
  label: string
  options: Option[]
  modelValue?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: '',
})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()

const isOpen = ref(false)

const selectedOption = computed(() => {
  return props.options.find(o => o.value === props.modelValue)
})

const handleKeydown = (event: KeyboardEvent) => {
  switch (event.key) {
    case 'ArrowDown':
      event.preventDefault()
      isOpen.value = true
      break
    case 'Escape':
      isOpen.value = false
      break
  }
}

const selectOption = (option: Option) => {
  emit('update:modelValue', option.value)
  isOpen.value = false
}
</script>

<style scoped>
.dropdown {
  position: relative;
}

.dropdown__label {
  display: block;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
  font-weight: 500;
}

.dropdown__trigger {
  width: 100%;
  padding: 0.5rem;
  background: white;
  border: 1px solid #cbd5e0;
  border-radius: 4px;
  text-align: left;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;

  &:focus-visible {
    outline: 2px solid #4299e1;
    outline-offset: 2px;
  }
}

.dropdown__menu {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  list-style: none;
  margin: 0;
  padding: 0;
  background: white;
  border: 1px solid #cbd5e0;
  border-top: none;
  border-radius: 0 0 4px 4px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

.dropdown__item {
  padding: 0.5rem;
  cursor: pointer;

  &:hover {
    background: #f7fafc;
  }

  &--selected {
    background: #e6fffa;
    font-weight: 600;
  }

  &:focus {
    outline: 2px solid #4299e1;
    outline-offset: -2px;
  }
}
</style>
```

### Accessible Toast/Alert

```vue
<template>
  <Teleport to="body">
    <div
      v-if="isVisible"
      class="toast"
      :class="`toast--${type}`"
      role="alert"
      aria-live="polite"
      aria-atomic="true"
    >
      <div class="toast__content">
        <span class="toast__icon" aria-hidden="true">
          {{ icon }}
        </span>
        <p class="toast__message">{{ message }}</p>
      </div>
      <button
        aria-label="Close notification"
        class="toast__close"
        @click="close"
      >
        ×
      </button>
    </div>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Teleport } from 'vue'

interface Props {
  message: string
  type?: 'success' | 'error' | 'info' | 'warning'
  duration?: number
}

const props = withDefaults(defineProps<Props>(), {
  type: 'info',
  duration: 5000,
})

const emit = defineEmits<{
  (e: 'close'): void
}>()

const isVisible = ref(true)

const icons = {
  success: '✓',
  error: '✕',
  info: 'ⓘ',
  warning: '⚠',
}

const icon = icons[props.type]

const close = () => {
  isVisible.value = false
  emit('close')
}

onMounted(() => {
  if (props.duration > 0) {
    setTimeout(close, props.duration)
  }
})
</script>

<style scoped>
.toast {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  min-width: 300px;
  max-width: 500px;
  padding: 1rem;
  background: white;
  border-left: 4px solid #48bb78;
  border-radius: 4px;
  box-shadow: 0 10px 15px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  animation: slideIn 0.3s ease-out;

  &--success {
    border-left-color: #48bb78;
  }

  &--error {
    border-left-color: #f56565;
  }

  &--info {
    border-left-color: #4299e1;
  }

  &--warning {
    border-left-color: #ed8936;
  }
}

.toast__content {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex: 1;
}

.toast__icon {
  font-weight: bold;
  font-size: 1.25rem;
}

.toast__message {
  margin: 0;
}

.toast__close {
  background: none;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 0;
  color: #718096;

  &:hover {
    color: #2d3748;
  }

  &:focus-visible {
    outline: 2px solid #4299e1;
  }
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
</style>
```

## Testing Accessibility

### Axe Testing

```typescript
import { render } from '@testing-library/vue'
import { axe, toHaveNoViolations } from 'jest-axe'
import MyComponent from './MyComponent.vue'

expect.extend(toHaveNoViolations)

it('has no accessibility violations', async () => {
  const { container } = render(MyComponent)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

### Manual Testing

```typescript
import { render, screen } from '@testing-library/vue'
import userEvent from '@testing-library/user-event'

it('keyboard navigation works', async () => {
  const user = userEvent.setup()
  render(Dropdown, {
    props: { options: [...] }
  })

  const trigger = screen.getByRole('button')

  // Focus and open with keyboard
  await user.tab()
  expect(trigger).toHaveFocus()

  await user.keyboard('{ArrowDown}')
  expect(screen.getByRole('listbox')).toBeVisible()

  // Navigate with arrow keys
  const items = screen.getAllByRole('option')
  await user.keyboard('{ArrowDown}')
  expect(items[0]).toHaveFocus()
})

it('button announces loading state', () => {
  const { getByRole } = render(Button, {
    props: { isLoading: true }
  })

  const button = getByRole('button')
  expect(button).toHaveAttribute('aria-busy', 'true')
})
```

## Color Contrast

### Contrast Ratios

| Content | Minimum (AA) | Enhanced (AAA) |
|---------|--------------|----------------|
| Normal text | 4.5:1 | 7:1 |
| Large text | 3:1 | 4.5:1 |
| UI components | 3:1 | 3:1 |

```vue
<style scoped>
/* ✅ Good: 7.45:1 contrast -->
.text {
  color: #1a202c;        /* Dark gray */
  background: #ffffff;   /* White */
}

/* ❌ Poor: 1.9:1 contrast (fails WCAG) -->
.text {
  color: #999999;        /* Medium gray */
  background: #ffffff;   /* White */
}
</style>
```

**Tools:**
- WebAIM Contrast Checker
- Stark (browser plugin)
- ColorOracle (color blindness simulator)

## Motion and Animation

### Respect Prefers-Reduced-Motion

```vue
<style scoped>
.fade-enter-active {
  transition: opacity 0.3s ease;
}

/* Respect user's motion preference */
@media (prefers-reduced-motion: reduce) {
  .fade-enter-active {
    transition: none;
  }
}
</style>
```

```typescript
// Detect preference in component
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches

if (!prefersReducedMotion) {
  // Animate
}
```

## Checklist for Every Component

- [ ] Uses semantic HTML (`<button>`, `<a>`, `<form>`, etc.)
- [ ] All inputs have `<label>` with `for` attribute
- [ ] Color not sole means of conveying information
- [ ] Focus visible on all interactive elements
- [ ] Tab order is logical and matches visual order
- [ ] Keyboard operable (no mouse-only interactions)
- [ ] Error messages linked to form fields with `aria-describedby`
- [ ] Dynamic content announced with `aria-live` if needed
- [ ] Images have alt text or `aria-hidden="true"`
- [ ] No flash/flicker more than 3 times per second
- [ ] Text has sufficient color contrast (4.5:1 minimum)
- [ ] Modals trap focus and announce themselves
- [ ] Respects `prefers-reduced-motion`
- [ ] Tests pass axe-core scan
- [ ] Screen reader tested manually

## Anti-Patterns

### ❌ Don't: Use `<div>` for Interactive Elements

```typescript
// WRONG
<div class="button" @click="handleClick">
  Click me
</div>

// RIGHT
<button @click="handleClick">
  Click me
</button>
```

### ❌ Don't: Forget `aria-label` for Icon-Only Buttons

```typescript
// WRONG
<button>
  <icon name="delete" />
</button>

// RIGHT
<button aria-label="Delete item">
  <icon name="delete" aria-hidden="true" />
</button>
```

### ❌ Don't: Use `tabindex > 0`

```typescript
// WRONG - breaks tab order
<div tabindex="1">First</div>
<div tabindex="2">Second</div>

// RIGHT - use semantic elements or tabindex="0"
<button>First</button>
<button>Second</button>
```

### ❌ Don't: Hide Error Messages Visually

```typescript
// WRONG - screen reader can't find error
<input />
<p style="display: none;">{{ error }}</p>

// RIGHT - always announce errors
<input aria-describedby="error" />
<p id="error" v-if="error">{{ error }}</p>
```

## Resources

- **WCAG 2.1 Guidelines:** https://www.w3.org/WAI/WCAG21/quickref/
- **WAI-ARIA Authoring Practices:** https://www.w3.org/WAI/ARIA/apg/
- **axe DevTools:** Browser extension for testing
- **Lighthouse:** Built into Chrome DevTools
- **VoiceOver:** Built into macOS/iOS
- **NVDA:** Free screen reader for Windows
- **JAWS:** Commercial screen reader

## Summary

**This pattern gives you:**
- ✅ WCAG 2.1 AA compliant components
- ✅ Full keyboard support
- ✅ Screen reader accessible
- ✅ Clear visual focus
- ✅ Proper contrast ratios
- ✅ Semantic, maintainable HTML
- ✅ Testable with axe-core
- ✅ Respects user preferences
