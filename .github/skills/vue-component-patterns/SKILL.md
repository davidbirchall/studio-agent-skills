---
name: "vue-component-patterns"
description: "Vue 3 Composition API component design, TypeScript patterns, sub-component architecture, and reusability best practices for consistent component development across all UI projects"
confidence: "medium"
---

# Vue Component Patterns

Standardized patterns for building consistent, maintainable, and reusable Vue 3 components across all projects. Enforces Composition API + TypeScript + modular sub-component architecture.

## Guiding Principles

1. **Composition API + `<script setup>`** — Modern, concise, type-safe
2. **TypeScript for all props/emits** — Catch errors at build time, better IDE support
3. **Break large components into sub-components** — Keep each component focused and testable
4. **Extract shared logic into composables** — Avoid duplication, name with `use*` convention
5. **Prop drilling is a smell** — Use `provide/inject` for deeply nested data
6. **Performance-aware** — Use `computed` for derived state, avoid unnecessary reactivity

## Template Structure

### File Organization

```
components/
├── Button/
│   ├── Button.vue                    # Main export
│   ├── ButtonGroup.vue               # Sub-component
│   └── index.ts                      # Named exports
├── Modal/
│   ├── Modal.vue
│   ├── ModalHeader.vue
│   ├── ModalBody.vue
│   ├── ModalFooter.vue
│   └── index.ts
└── Form/
    ├── Form.vue
    ├── FormField.vue
    ├── FormError.vue
    └── index.ts
```

**Export convention (index.ts):**
```typescript
export { default as Button } from './Button.vue'
export { default as ButtonGroup } from './ButtonGroup.vue'
export type { ButtonProps, ButtonEmits } from './Button.vue'
```

### Component Size Guidelines

| Size | Lines | Action |
|------|-------|--------|
| < 150 | Simple | Keep as single file |
| 150–300 | Medium | Consider extracting 1-2 sub-components |
| 300–500 | Large | Extract 3+ sub-components + shared logic |
| > 500 | Too Large | Break into multiple focused features |

**When to break into sub-components:**
- ✅ Distinct visual sections (Header, Body, Footer)
- ✅ Repeated UI patterns within the parent
- ✅ Separate control/state flows
- ✅ Reusable in other contexts
- ❌ DON'T over-fragment (every div isn't a component)

## Props & Emits Pattern

### TypeScript Type Definitions

**Define types in the component file:**

```typescript
// Button.vue
export interface ButtonProps {
  /**
   * Button label
   * @required
   */
  label: string
  
  /**
   * Button variant
   * @default "primary"
   */
  variant?: 'primary' | 'secondary' | 'danger'
  
  /**
   * Size
   * @default "md"
   */
  size?: 'sm' | 'md' | 'lg'
  
  /**
   * Disabled state
   * @default false
   */
  disabled?: boolean
  
  /**
   * Loading state
   * @default false
   */
  loading?: boolean
}

export interface ButtonEmits {
  /**
   * Fired when button is clicked
   */
  (e: 'click'): void
  
  /**
   * Fired when button gains/loses focus
   */
  (e: 'focus', focused: boolean): void
}

// Component
defineProps<ButtonProps>()
defineEmits<ButtonEmits>()
```

**Use `withDefaults` for defaults:**

```typescript
interface ButtonProps {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
}

const props = withDefaults(defineProps<ButtonProps>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
})
```

### Validation Rules

- ✅ **Always TypeScript** — Use interfaces for all props
- ✅ **Document with JSDoc** — `@required`, `@default`, description
- ✅ **Use `withDefaults`** — Explicit, not implicit
- ✅ **Boolean props** — Prefix with `is` or `has` (e.g., `isDisabled`, `hasError`)
- ✅ **Union types over magic strings** — Use `type ButtonVariant = 'primary' | 'secondary'`
- ❌ **Avoid `any`** — Always type props, even if generic
- ❌ **Don't use global PropTypes** — TypeScript replaces it

### Common Props Pattern

**Standard props across UI components:**

```typescript
interface ComponentProps {
  // ID for accessibility & testing
  id?: string
  
  // Styling
  class?: string
  style?: Record<string, any>
  
  // Accessibility
  ariaLabel?: string
  ariaDescribedBy?: string
  
  // Data
  disabled?: boolean
  loading?: boolean
  
  // State
  isActive?: boolean
  hasError?: boolean
}
```

## Composition API Pattern

### Basic Component Structure

```typescript
<template>
  <div class="button" :class="buttonClasses">
    <slot />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { ButtonProps, ButtonEmits } from './types'

export interface ButtonProps {
  variant?: 'primary' | 'secondary'
  size?: 'sm' | 'md'
  disabled?: boolean
}

export interface ButtonEmits {
  (e: 'click'): void
}

const props = withDefaults(defineProps<ButtonProps>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
})

defineEmits<ButtonEmits>()

// Derived state with computed()
const buttonClasses = computed(() => ({
  'button--primary': props.variant === 'primary',
  'button--secondary': props.variant === 'secondary',
  'button--sm': props.size === 'sm',
  'button--md': props.size === 'md',
  'button--disabled': props.disabled,
}))
</script>

<style scoped>
.button {
  /* styles */
}
.button--primary {
  /* variant styles */
}
</style>
```

### Reactive State Pattern

**Use `ref()` for direct mutation, `computed()` for derived state:**

```typescript
import { ref, computed } from 'vue'

// Direct state (mutable)
const count = ref(0)
const isOpen = ref(false)

// Derived state (computed)
const doubleCount = computed(() => count.value * 2)
const statusText = computed(() => isOpen.value ? 'Open' : 'Closed')

// Methods
const increment = () => count.value++
const toggle = () => isOpen.value = !isOpen.value
```

**When to use each:**
- `ref()` — Direct component state (form fields, toggles, counters)
- `computed()` — Derived from props/state (classes, display text, derived values)
- `reactive()` — Avoid; use multiple `ref()` instead for better tree-shaking

### Watchers Pattern

**Use sparingly; prefer `computed()` first:**

```typescript
import { watch, watchEffect } from 'vue'

// ❌ Avoid — usually a computed() is better
watch(() => props.modelValue, (newVal) => {
  // synchronous reaction
})

// ✅ Use computed() instead
const isValid = computed(() => props.modelValue?.length > 0)

// ✅ Use watch only for side effects (API calls, etc.)
watch(() => props.userId, (userId) => {
  if (userId) {
    fetchUserData(userId)
  }
})

// ✅ Use watchEffect for complex dependencies
watchEffect(async () => {
  console.log('Props changed:', props.id)
})
```

## Sub-Component Communication

### Parent → Child (Props)

```typescript
// Parent.vue
<template>
  <ModalHeader :title="title" :icon="icon" />
</template>

// ModalHeader.vue
<script setup lang="ts">
interface ModalHeaderProps {
  title: string
  icon?: string
}

defineProps<ModalHeaderProps>()
</script>
```

### Child → Parent (Emits)

```typescript
// Parent.vue
<template>
  <ModalFooter @confirm="handleConfirm" @cancel="handleCancel" />
</template>

<script setup lang="ts">
const handleConfirm = () => console.log('Confirmed')
const handleCancel = () => console.log('Canceled')
</script>

// ModalFooter.vue
<script setup lang="ts">
defineEmits<{
  confirm: []
  cancel: []
}>()
</script>

<template>
  <div class="modal-footer">
    <button @click="$emit('cancel')">Cancel</button>
    <button @click="$emit('confirm')">Confirm</button>
  </div>
</template>
```

### Shared State (Provide/Inject)

**Use `provide/inject` to avoid prop drilling:**

```typescript
// Modal.vue (parent)
import { provide } from 'vue'

<script setup lang="ts">
interface ModalContext {
  isOpen: boolean
  close: () => void
}

const isOpen = ref(true)
const close = () => isOpen.value = false

// Provide context to children
provide<ModalContext>('modal', {
  isOpen: computed(() => isOpen.value),
  close,
})
</script>

// ModalHeader.vue (child — any depth)
<script setup lang="ts">
import { inject } from 'vue'

interface ModalContext {
  isOpen: boolean
  close: () => void
}

const modal = inject<ModalContext>('modal')
</script>
```

**Provide/inject guidelines:**
- ✅ Use for multi-level component trees (Modal, Dialog, Tabs, etc.)
- ✅ Type the injected context with TypeScript
- ✅ Document what's provided (JSDoc in parent)
- ❌ Don't use for sibling communication (use emits + parent state)
- ❌ Don't abuse for "global" state (use Pinia instead)

## Slots Pattern

### Named Slots

```typescript
// Dialog.vue
<template>
  <div class="dialog">
    <div class="dialog-header">
      <slot name="header" />
    </div>
    <div class="dialog-body">
      <slot />  <!-- default slot -->
    </div>
    <div class="dialog-footer">
      <slot name="footer" />
    </div>
  </div>
</template>

// Usage
<Dialog>
  <template #header>
    <h2>Confirm Action</h2>
  </template>
  
  <p>Are you sure?</p>
  
  <template #footer>
    <button @click="confirm">Yes</button>
  </template>
</Dialog>
```

### Scoped Slots

```typescript
// List.vue
<template>
  <div class="list">
    <div v-for="item in items" :key="item.id">
      <!-- Pass item data back to parent -->
      <slot :item="item" :index="index" />
    </div>
  </div>
</template>

// Usage
<List :items="users">
  <template #default="{ item, index }">
    <div class="user-card">
      <span>#{{ index + 1 }}</span>
      <span>{{ item.name }}</span>
    </div>
  </template>
</List>
```

## Composables Pattern

### Naming Convention

Use `use*` prefix for all composables:

```
composables/
├── useFetch.ts              # Data fetching
├── useForm.ts               # Form state & validation
├── useAsync.ts              # Async operations
├── usePagination.ts         # Pagination logic
├── useDebounce.ts           # Debouncing
└── useTheme.ts              # Theme/dark mode
```

### Composable Structure

```typescript
// composables/useForm.ts
import { ref, computed } from 'vue'

interface FormState {
  name: string
  email: string
}

export function useForm(initialState?: Partial<FormState>) {
  const form = ref<FormState>({
    name: '',
    email: '',
    ...initialState,
  })

  const isDirty = computed(() => form.value.name || form.value.email)

  const reset = () => {
    form.value = { name: '', email: '' }
  }

  const submit = async () => {
    // Handle submission
  }

  return {
    form,
    isDirty,
    reset,
    submit,
  }
}
```

### Using Composables in Components

```typescript
<script setup lang="ts">
import { useForm } from '@/composables/useForm'

const { form, isDirty, reset, submit } = useForm({
  name: 'John',
})
</script>

<template>
  <form @submit.prevent="submit">
    <input v-model="form.name" />
    <button :disabled="!isDirty">Submit</button>
    <button @click="reset">Reset</button>
  </form>
</template>
```

## Performance Best Practices

### Use `computed()` for Derived State

❌ **Bad — recalculates on every render:**
```typescript
const filteredUsers = ref([])
watch(() => props.users, (users) => {
  filteredUsers.value = users.filter(u => u.active)
})
```

✅ **Good — caches when dependencies unchanged:**
```typescript
const filteredUsers = computed(() => 
  props.users.filter(u => u.active)
)
```

### Lazy-load Sub-Components

```typescript
import { defineAsyncComponent } from 'vue'

const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
)

// In template:
<HeavyComponent v-if="showHeavy" />
```

### Avoid Inline Object/Array Props

❌ **Bad — creates new object on every render:**
```typescript
<Button :class-names="{ primary: true, large: false }" />
```

✅ **Good — stable reference:**
```typescript
const buttonClasses = computed(() => ({
  primary: true,
  large: false,
}))

<Button :class-names="buttonClasses" />
```

### Use `v-show` for Frequent Toggles

```typescript
<!-- Heavy component that toggles often -->
<Modal v-show="isOpen" />  <!-- ✅ Just hide/show -->

<!-- Component that's rarely shown -->
<Modal v-if="isOpen" />    <!-- ✅ Mount/unmount -->
```

## Testing Pattern

### Setup

```typescript
// Button.test.ts
import { mount } from '@vue/test-utils'
import { describe, it, expect } from 'vitest'
import Button from './Button.vue'

describe('Button', () => {
  it('renders with label', () => {
    const wrapper = mount(Button, {
      props: { label: 'Click me' },
    })
    expect(wrapper.text()).toContain('Click me')
  })

  it('emits click event', async () => {
    const wrapper = mount(Button, {
      props: { label: 'Click' },
    })
    await wrapper.trigger('click')
    expect(wrapper.emitted('click')).toBeTruthy()
  })

  it('disables when disabled prop is true', () => {
    const wrapper = mount(Button, {
      props: { label: 'Click', disabled: true },
    })
    expect(wrapper.find('button').attributes('disabled')).toBeDefined()
  })
})
```

## Common Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Mutating props | Vue won't detect change, warnings in dev | Use emits to notify parent |
| Mixing Options + Composition API | Confusion, harder to maintain | Use only Composition API + `<script setup>` |
| Global component registration | Harder to track dependencies | Use local imports, auto-import via Vite |
| Over-fragmenting components | Prop drilling nightmare, complexity | Keep components focused but not tiny |
| Watchers instead of computed | Stale state, redundant watchers | Use computed() for derived state |
| Inline handlers | Performance issues, harder to test | Extract to methods |
| Deep prop drilling | Hard to refactor, unclear dependencies | Use provide/inject or state management |

## File Template

Use this as a starting point for new components:

```typescript
<template>
  <div class="component" :class="componentClasses">
    <slot />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

export interface ComponentProps {
  /**
   * Component label
   * @required
   */
  label?: string
}

export interface ComponentEmits {
  (e: 'change', value: string): void
}

const props = withDefaults(defineProps<ComponentProps>(), {
  label: '',
})

defineEmits<ComponentEmits>()

const componentClasses = computed(() => ({
  'is-active': true,
}))
</script>

<style scoped>
.component {
  /* styles */
}
</style>
```

## When to Review This Skill

- **Before starting a new Vue project** — Review conventions, set project up correctly
- **Code review** — Ensure components follow patterns
- **Component growing > 300 lines** — Time to break into sub-components
- **Props getting complex** — Reconsider architecture (provide/inject? composable?)
- **Testing components** — Ensure testable structure

## Related Skills

- `vue-state-management` — Pinia patterns, when to lift state
- `vue-testing-strategy` — Component testing approach
- `vue-performance` — Optimization techniques

---

**Version:** 1.0  
**Last Updated:** 2026-10-27  
**Confidence:** medium
