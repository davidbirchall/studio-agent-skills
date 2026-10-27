---
name: "vue-component-patterns"
description: "Vue 3 Composition API component design, TypeScript patterns, sub-component architecture, and reusability best practices for consistent component development across all UI projects"
confidence: "medium"
---

# Vue Component Patterns

Standardized patterns for building consistent, maintainable, and reusable Vue 3 components across all projects. Enforces Composition API + TypeScript + modular sub-component architecture.

## Guiding Principles

1. **Design is the source of truth** — Components implement design specs exactly, not creative interpretations
2. **Atomic Design hierarchy** — Atoms → Molecules → Organisms → Templates → Pages
3. **Composition API + `<script setup>`** — Modern, concise, type-safe
4. **TypeScript for all props/emits** — Catch errors at build time, better IDE support
5. **Break large components into sub-components** — Keep each component focused and testable
6. **Extract shared logic into composables** — Avoid duplication, name with `use*` convention
7. **Prop drilling is a smell** — Use `provide/inject` for deeply nested data
8. **Performance-aware** — Use `computed` for derived state, avoid unnecessary reactivity
9. **Scoped CSS styling** — Style encapsulation, no global styles, design fidelity

## Template Structure

### Atomic Design Hierarchy

Follow atomic design principles to organize components by complexity and reusability:

```
components/
├── atoms/                           # Single responsibility, reusable building blocks
│   ├── Button/
│   ├── Input/
│   ├── Label/
│   ├── Icon/
│   └── Badge/
├── molecules/                       # Simple component groups, multiple atoms
│   ├── FormField/                   # Label + Input + Error
│   ├── SearchBox/                   # Input + Icon + Button
│   ├── Card/                        # Container with header/body structure
│   └── NavItem/                     # Link + Icon + Badge
├── organisms/                       # Complex components, multiple molecules/atoms
│   ├── Modal/                       # Header + Body + Footer (molecules + atoms)
│   ├── Form/                        # Multiple FormFields (molecules)
│   ├── Navigation/                  # Multiple NavItems (molecules)
│   ├── DataTable/                   # Header + Rows + Pagination
│   └── Sidebar/                     # Multiple sections, nested atoms/molecules
├── templates/                       # Page-level component structure (rarely need to code)
│   ├── DashboardTemplate.vue        # Layout: Sidebar + Header + Content
│   └── FormTemplate.vue
└── pages/                           # Full page implementations
    ├── Dashboard.vue
    └── Settings.vue
```

**Hierarchy rules:**
- **Atoms** — Cannot be broken down further (Button, Input, Icon, Badge)
- **Molecules** — Combine 2+ atoms into a functional unit (FormField = Label + Input)
- **Organisms** — Complex sections combining molecules/atoms (Modal, Form, DataTable)
- **Templates** — Page layout (rarely Vue components — usually just container structure)
- **Pages** — Full implementations combining templates + data

**Benefits:**
- ✅ Clear component scope and responsibility
- ✅ Atomic components are highly reusable
- ✅ Easier to refactor — know exactly what breaks
- ✅ Design system alignment — mirrors Figma component hierarchy
- ✅ Scalability — new features use existing atoms/molecules

### File Organization

```
components/
├── atoms/
│   └── Button/
│       ├── Button.vue                # Main export
│       ├── Button.test.ts
│       └── index.ts
├── molecules/
│   └── FormField/
│       ├── FormField.vue             # Main export
│       ├── FormField.test.ts
│       └── index.ts
└── organisms/
    └── Modal/
        ├── Modal.vue
        ├── ModalHeader.vue           # Sub-component for Modal (molecule-level)
        ├── ModalBody.vue
        ├── ModalFooter.vue
        ├── Modal.test.ts
        └── index.ts
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

## Design-Driven Development

### Design is the Source of Truth

Every component implements a design specification exactly. The design file (Figma, etc.) defines:
- Visual appearance (spacing, sizing, colors, typography)
- Component states (default, hover, active, disabled, loading, error)
- Interactions (what happens on click, hover, focus)
- Responsive behavior (breakpoints, stacking, visibility)

**Component contract:**
1. Review design in Figma/design tool
2. Extract component spec (props, variants, states)
3. Implement exactly as designed
4. Measure against design — pixel-perfect where possible
5. Implement all states shown in design

**Props from Design:**
- Each Figma variant becomes a prop (e.g., `variant="primary"`, `size="lg"`)
- Each documented state becomes a prop (e.g., `disabled`, `loading`, `isActive`)
- Each responsive breakpoint is a design decision (not a guess)

### Design Handoff Checklist

Before implementing a component:

- [ ] Design file link documented in component file (comment at top)
- [ ] All variants mapped to props (primary/secondary variants → `variant` prop)
- [ ] All states shown in design (hover, focus, disabled, error, loading)
- [ ] Responsive behavior specified (mobile/tablet/desktop layouts)
- [ ] Typography/spacing follows design tokens (no arbitrary pixel values)
- [ ] Colors use design color variables (not hardcoded hex)
- [ ] Animations/transitions match design specs
- [ ] Accessibility considered (focus states, ARIA labels, keyboard nav)

**Example design handoff:**
```typescript
/**
 * Button Component
 * 
 * Design: https://figma.com/file/xxx/Design?node-id=123
 * 
 * Variants (from Figma):
 * - Primary (default) → variant="primary"
 * - Secondary → variant="secondary"
 * - Danger → variant="danger"
 * - Ghost → variant="ghost"
 * 
 * States (from Figma):
 * - Default / Hover / Active / Focus / Disabled / Loading
 * - All states must match design exactly
 * 
 * Sizes (from Figma):
 * - Small (28px) → size="sm"
 * - Medium (36px) → size="md"
 * - Large (44px) → size="lg"
 */

export interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
  loading?: boolean
}
```

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

## Scoped CSS Styling

Use scoped CSS for style encapsulation. Styles are automatically scoped to the component and won't leak to other components or global styles.

### Scoped CSS Basics

```vue
<template>
  <div class="button" :class="buttonClasses">
    <slot />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{ variant?: 'primary' | 'secondary' }>(), {
  variant: 'primary',
})

const buttonClasses = computed(() => ({
  'button--primary': props.variant === 'primary',
  'button--secondary': props.variant === 'secondary',
}))
</script>

<style scoped>
/* These styles ONLY apply to this component */
.button {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 0.25rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.button--primary {
  background-color: #0066cc;
  color: white;
}

.button--primary:hover {
  background-color: #0052a3;
}

.button--secondary {
  background-color: #e0e0e0;
  color: #333;
}
</style>
```

**Key points:**
- ✅ `<style scoped>` automatically prefixes classes with component scope
- ✅ No naming collisions across components
- ✅ Styles encapsulated, won't leak to child components
- ✅ Child components can still style themselves

### CSS Organization

```vue
<style scoped>
/* 1. Base component styles */
.button {
  padding: 0.5rem 1rem;
  border: none;
  cursor: pointer;
}

/* 2. Variants */
.button--primary { /* primary variant */ }
.button--secondary { /* secondary variant */ }

/* 3. Sizes */
.button--sm { /* small size */ }
.button--md { /* medium size */ }

/* 4. States */
.button:hover { /* hover state */ }
.button:active { /* active state */ }
.button:disabled { /* disabled state */ }
.button:focus { /* focus state */ }

/* 5. Responsive */
@media (max-width: 640px) {
  .button { /* mobile styles */ }
}

/* 6. Modifiers/combinations */
.button.is-loading { /* loading state */ }
.button.has-icon { /* button with icon */ }
</style>
```

### CSS Variables for Design Tokens

Use CSS variables for design tokens (colors, spacing, typography):

```vue
<style scoped>
:root {
  /* Define design tokens */
  --color-primary: #0066cc;
  --color-primary-hover: #0052a3;
  --color-text: #333;
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --font-weight-regular: 400;
  --font-weight-bold: 600;
  --border-radius-sm: 0.25rem;
  --transition-fast: 0.2s ease;
}

.button {
  padding: var(--spacing-sm) var(--spacing-md);
  border: none;
  border-radius: var(--border-radius-sm);
  font-weight: var(--font-weight-bold);
  cursor: pointer;
  transition: all var(--transition-fast);
}

.button--primary {
  background-color: var(--color-primary);
  color: white;
}

.button--primary:hover {
  background-color: var(--color-primary-hover);
}
</style>
```

**Benefits:**
- ✅ Consistent spacing/colors across components
- ✅ Easy to theme (swap variable values)
- ✅ Single source of truth for design tokens
- ✅ Easy updates (change token once, affects all components)

### Avoid Tailwind

Do **not** use Tailwind CSS utility classes. Use scoped CSS instead:

```typescript
// ❌ DON'T do this
<div class="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600">

// ✅ DO this
<div class="button button--primary">
```

**Why scoped CSS over Tailwind for design systems:**
- Scoped CSS enforces style encapsulation (no accidental overwrites)
- Easier to see component styles at a glance (all in one place)
- Design tokens are explicit (CSS variables)
- Smaller build output (less utility class bloat)
- Design fidelity (matches Figma spec exactly)

### Deep Selectors (When Needed)

If you need to style a child component's scoped CSS (rare):

```vue
<template>
  <Modal>
    <Button />  <!-- Need to style Button from Modal -->
  </Modal>
</template>

<style scoped>
/* Use :deep() to pierce into child component's scoped styles */
:deep(.button) {
  width: 100%; /* Make child button full width */
}
</style>
```

**Use sparingly** — usually indicates child component needs a prop instead.

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
- `vue-styling-architecture` — Design tokens, CSS variables, component styling strategy

---

**Version:** 1.0  
**Last Updated:** 2026-10-27  
**Confidence:** medium
