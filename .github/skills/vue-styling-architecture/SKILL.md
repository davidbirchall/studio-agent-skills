---
name: "vue-styling-architecture"
description: "Design token management, CSS variable strategy, scoped CSS patterns, component styling hierarchy, and design-to-code workflows without Tailwind"
confidence: "high"
---

# Vue Styling Architecture

Standardized approach to styling Vue 3 components using **CSS variables, design tokens, and scoped CSS**. Replaces Tailwind with explicit, composable, design-token-driven styling that maintains fidelity with design systems.

## Guiding Principles

1. **Design tokens are the source of truth** — Colors, spacing, typography defined in one place
2. **CSS variables for runtime flexibility** — Change themes without rebuilding
3. **Scoped CSS for encapsulation** — No naming collisions, component styling stays local
4. **Design-driven, not utility-driven** — Semantics matter; understand what each class does
5. **Atomic design hierarchy** — Atoms inherit minimal styles, molecules compose atoms, organisms compose molecules
6. **Explicit over implicit** — Spell out styles; avoid magic utility combinations
7. **No Tailwind** — Better design fidelity, clearer intent, easier to customize
8. **CSS-in-JS only when needed** — Prefer scoped `<style>` over styled-components or CSS-in-JS

## Design Token System

### Token Categories

Organize tokens into semantic categories aligned with design systems (Figma, Storybook):

```
design-tokens/
├── colors/
│   ├── base.css         # Primary palette
│   ├── semantic.css     # Functional colors (success, warning, error)
│   └── dark-mode.css    # Dark theme overrides
├── spacing/
│   └── scale.css        # Spacing scale (8px base)
├── typography/
│   ├── font-family.css
│   ├── font-size.css
│   └── line-height.css
├── shadows/
│   └── elevations.css   # Shadow system
├── borders/
│   └── radius.css       # Border radius scale
└── transitions/
    └── timing.css       # Animation timing functions
```

### Token Definition

**`design-tokens/colors/base.css` (semantic naming):**

```css
:root {
  /* Primary colors */
  --color-primary: #007bff;
  --color-primary-light: #e7f1ff;
  --color-primary-dark: #0056b3;
  
  /* Secondary colors */
  --color-secondary: #6c757d;
  --color-secondary-light: #f0f1f3;
  --color-secondary-dark: #495057;
  
  /* Neutral colors */
  --color-white: #ffffff;
  --color-black: #000000;
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;
  
  /* Text colors */
  --color-text-primary: var(--color-gray-900);
  --color-text-secondary: var(--color-gray-600);
  --color-text-tertiary: var(--color-gray-500);
  --color-text-inverse: var(--color-white);
  
  /* Background colors */
  --color-bg-primary: var(--color-white);
  --color-bg-secondary: var(--color-gray-50);
  --color-bg-tertiary: var(--color-gray-100);
  
  /* Status colors */
  --color-success: #28a745;
  --color-warning: #ffc107;
  --color-danger: #dc3545;
  --color-info: #17a2b8;
  
  /* Borders */
  --color-border-light: var(--color-gray-200);
  --color-border-default: var(--color-gray-300);
  --color-border-dark: var(--color-gray-400);
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-text-primary: var(--color-gray-100);
    --color-text-secondary: var(--color-gray-400);
    --color-text-tertiary: var(--color-gray-500);
    --color-bg-primary: var(--color-gray-900);
    --color-bg-secondary: var(--color-gray-800);
    --color-bg-tertiary: var(--color-gray-700);
    --color-border-light: var(--color-gray-700);
    --color-border-default: var(--color-gray-600);
    --color-border-dark: var(--color-gray-500);
  }
}
```

**`design-tokens/spacing/scale.css` (8px base scale):**

```css
:root {
  /* 8px base scale */
  --spacing-0: 0;
  --spacing-1: 0.25rem;   /* 4px */
  --spacing-2: 0.5rem;    /* 8px */
  --spacing-3: 0.75rem;   /* 12px */
  --spacing-4: 1rem;      /* 16px */
  --spacing-6: 1.5rem;    /* 24px */
  --spacing-8: 2rem;      /* 32px */
  --spacing-12: 3rem;     /* 48px */
  --spacing-16: 4rem;     /* 64px */
  --spacing-20: 5rem;     /* 80px */
  --spacing-24: 6rem;     /* 96px */
  
  /* Size shortcuts (same scale) */
  --size-4: var(--spacing-1);
  --size-8: var(--spacing-2);
  --size-12: var(--spacing-3);
  --size-16: var(--spacing-4);
  --size-24: var(--spacing-6);
  --size-32: var(--spacing-8);
  --size-48: var(--spacing-12);
}
```

**`design-tokens/typography/font-size.css`:**

```css
:root {
  /* Font sizes (modular scale 1.125x) */
  --font-xs: 0.75rem;     /* 12px */
  --font-sm: 0.875rem;    /* 14px */
  --font-base: 1rem;      /* 16px */
  --font-lg: 1.125rem;    /* 18px */
  --font-xl: 1.25rem;     /* 20px */
  --font-2xl: 1.5rem;     /* 24px */
  --font-3xl: 1.875rem;   /* 30px */
  --font-4xl: 2.25rem;    /* 36px */
  
  /* Line heights */
  --line-tight: 1.25;
  --line-normal: 1.5;
  --line-relaxed: 1.75;
  --line-loose: 2;
  
  /* Font weights */
  --font-regular: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;
}
```

**`design-tokens/shadows/elevations.css`:**

```css
:root {
  /* Shadow system (elevation levels) */
  --shadow-none: none;
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-base: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06);
  --shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1), 0 4px 6px rgba(0, 0, 0, 0.05);
  --shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.1), 0 10px 10px rgba(0, 0, 0, 0.04);
  --shadow-2xl: 0 25px 50px rgba(0, 0, 0, 0.25);
  
  /* Transitions */
  --transition-fast: 150ms ease-in-out;
  --transition-base: 300ms ease-in-out;
  --transition-slow: 500ms ease-in-out;
}
```

### Token Import Strategy

**`src/styles/globals.css` (loads all tokens + resets):**

```css
/* Design tokens */
@import 'design-tokens/colors/base.css';
@import 'design-tokens/colors/semantic.css';
@import 'design-tokens/spacing/scale.css';
@import 'design-tokens/typography/font-family.css';
@import 'design-tokens/typography/font-size.css';
@import 'design-tokens/shadows/elevations.css';
@import 'design-tokens/borders/radius.css';
@import 'design-tokens/transitions/timing.css';

/* Reset & normalize */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-family-base);
  font-size: var(--font-base);
  line-height: var(--line-normal);
  color: var(--color-text-primary);
  background-color: var(--color-bg-primary);
  transition: background-color var(--transition-base),
              color var(--transition-base);
}

/* Typography defaults */
h1 {
  font-size: var(--font-4xl);
  font-weight: var(--font-bold);
  line-height: var(--line-tight);
}

h2 {
  font-size: var(--font-3xl);
  font-weight: var(--font-bold);
  line-height: var(--line-tight);
}

h3 {
  font-size: var(--font-2xl);
  font-weight: var(--font-semibold);
  line-height: var(--line-tight);
}

p {
  margin-bottom: var(--spacing-4);
}
```

**`src/main.ts` (import globally):**

```typescript
import './styles/globals.css'
```

## Component Styling Patterns

### Atom Component (Simple)

**`components/atoms/Button/Button.vue`:**

```vue
<template>
  <button
    :class="['button', `button--${variant}`, `button--${size}`]"
    :disabled="disabled"
  >
    <slot />
  </button>
</template>

<script setup lang="ts">
interface Props {
  variant?: 'primary' | 'secondary' | 'tertiary'
  size?: 'sm' | 'md' | 'lg'
  disabled?: boolean
}

withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  disabled: false,
})
</script>

<style scoped>
.button {
  /* Base styles */
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--spacing-2);
  border: none;
  border-radius: var(--radius-base);
  font-weight: var(--font-medium);
  cursor: pointer;
  transition: all var(--transition-base);
  
  /* Remove default button appearance */
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
}

/* Size variants */
.button--sm {
  padding: var(--spacing-2) var(--spacing-3);
  font-size: var(--font-sm);
}

.button--md {
  padding: var(--spacing-2) var(--spacing-4);
  font-size: var(--font-base);
}

.button--lg {
  padding: var(--spacing-3) var(--spacing-6);
  font-size: var(--font-lg);
}

/* Color variants */
.button--primary {
  background-color: var(--color-primary);
  color: var(--color-text-inverse);
  box-shadow: var(--shadow-base);
}

.button--primary:hover:not(:disabled) {
  background-color: var(--color-primary-dark);
  box-shadow: var(--shadow-md);
  transform: translateY(-1px);
}

.button--primary:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: var(--shadow-sm);
}

.button--secondary {
  background-color: var(--color-bg-secondary);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border-default);
}

.button--secondary:hover:not(:disabled) {
  background-color: var(--color-bg-tertiary);
  border-color: var(--color-border-dark);
}

.button--tertiary {
  background-color: transparent;
  color: var(--color-primary);
  border: 1px solid var(--color-primary);
}

.button--tertiary:hover:not(:disabled) {
  background-color: var(--color-primary-light);
}

/* Disabled state */
.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
```

### Molecule Component (Composed)

**`components/molecules/FormField/FormField.vue`:**

```vue
<template>
  <div class="form-field" :class="{ 'form-field--error': !!error }">
    <Label
      :for="id"
      :required="required"
      class="form-field__label"
    >
      {{ label }}
    </Label>
    
    <Input
      :id="id"
      v-model="modelValue"
      :type="type"
      :placeholder="placeholder"
      :disabled="disabled"
      :aria-invalid="!!error"
      :aria-describedby="error ? `${id}-error` : undefined"
      class="form-field__input"
      @blur="$emit('blur')"
    />
    
    <p v-if="error" :id="`${id}-error`" class="form-field__error">
      {{ error }}
    </p>
    
    <p v-if="hint" class="form-field__hint">
      {{ hint }}
    </p>
  </div>
</template>

<script setup lang="ts">
import Label from '../Label/Label.vue'
import Input from '../Input/Input.vue'

interface Props {
  id: string
  label: string
  modelValue: string
  type?: 'text' | 'email' | 'password' | 'number'
  placeholder?: string
  error?: string
  hint?: string
  required?: boolean
  disabled?: boolean
}

withDefaults(defineProps<Props>(), {
  type: 'text',
  required: false,
  disabled: false,
})

defineEmits<{
  (e: 'update:modelValue', value: string): void
  (e: 'blur'): void
}>()
</script>

<style scoped>
.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.form-field__label {
  font-weight: var(--font-medium);
  color: var(--color-text-primary);
}

.form-field__input {
  padding: var(--spacing-2) var(--spacing-3);
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-sm);
  font-size: var(--font-base);
  transition: border-color var(--transition-base);
}

.form-field__input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px var(--color-primary-light);
}

.form-field__input:disabled {
  background-color: var(--color-bg-tertiary);
  cursor: not-allowed;
}

/* Error state */
.form-field--error .form-field__input {
  border-color: var(--color-danger);
}

.form-field--error .form-field__input:focus {
  box-shadow: 0 0 0 3px rgba(220, 53, 69, 0.1);
}

.form-field__error {
  font-size: var(--font-sm);
  color: var(--color-danger);
  margin: 0;
}

.form-field__hint {
  font-size: var(--font-sm);
  color: var(--color-text-secondary);
  margin: 0;
}
</style>
```

### Organism Component (Complex)

**`components/organisms/Card/Card.vue`:**

```vue
<template>
  <div class="card" :class="{ 'card--interactive': interactive }">
    <div v-if="$slots.header" class="card__header">
      <slot name="header" />
    </div>
    
    <div class="card__body">
      <slot />
    </div>
    
    <div v-if="$slots.footer" class="card__footer">
      <slot name="footer" />
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  interactive?: boolean
}

defineProps<Props>()
</script>

<style scoped>
.card {
  background-color: var(--color-bg-primary);
  border-radius: var(--radius-lg);
  border: 1px solid var(--color-border-light);
  box-shadow: var(--shadow-base);
  overflow: hidden;
}

.card--interactive {
  cursor: pointer;
  transition: all var(--transition-base);
}

.card--interactive:hover {
  border-color: var(--color-border-default);
  box-shadow: var(--shadow-md);
  transform: translateY(-2px);
}

.card__header {
  padding: var(--spacing-4);
  border-bottom: 1px solid var(--color-border-light);
}

.card__body {
  padding: var(--spacing-4);
}

.card__footer {
  padding: var(--spacing-4);
  border-top: 1px solid var(--color-border-light);
  background-color: var(--color-bg-secondary);
}
</style>
```

## Scoped CSS Best Practices

### ✅ DO

```vue
<style scoped>
/* Scoped = CSS only applies to this component */
.button {
  /* Semantic class name */
}

.button--primary {
  /* Variant using BEM-like naming */
}

.button__icon {
  /* Child element using BEM */
}

/* Use design tokens everywhere */
.button {
  padding: var(--spacing-3);
  background-color: var(--color-primary);
  border-radius: var(--radius-base);
}

/* Responsive */
@media (max-width: 640px) {
  .button--lg {
    padding: var(--spacing-2);
  }
}

/* State variations */
.button:hover {
  background-color: var(--color-primary-dark);
}

.button:disabled {
  opacity: 0.5;
}
</style>
```

### ❌ DON'T

```vue
<style scoped>
/* Magic numbers without tokens */
.button {
  padding: 12px 24px;   /* ❌ Use var(--spacing-3) */
}

/* Utility classes (Tailwind-style) */
.mt-4 {           /* ❌ Avoid utility classes */
  margin-top: 16px;
}

/* Unclear naming */
.big-blue-box {   /* ❌ Not semantic */
}

/* Duplicated tokens */
.button {
  --primary-color: #007bff;  /* ❌ Define once in design-tokens */
}

/* Inline styles in template */
<div :style="{ color: 'blue' }">  <!-- ❌ Use scoped CSS -->
</div>
</style>
```

## Theme Switching

### Dark Mode Support

**CSS variables automatically support dark mode via `prefers-color-scheme`:**

```css
/* design-tokens/colors/base.css */
:root {
  --color-text: #000;
  --color-bg: #fff;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-text: #fff;
    --color-bg: #1a1a1a;
  }
}

/* Components automatically adapt — no changes needed */
.card {
  color: var(--color-text);
  background: var(--color-bg);
}
```

### Manual Theme Switching

**For user-controlled themes:**

```typescript
// composables/useTheme.ts
import { ref, watch } from 'vue'

type Theme = 'light' | 'dark'

const theme = ref<Theme>('light')

const setTheme = (newTheme: Theme) => {
  theme.value = newTheme
  document.documentElement.dataset.theme = newTheme
  
  // Save preference
  localStorage.setItem('theme-preference', newTheme)
}

const initTheme = () => {
  const saved = localStorage.getItem('theme-preference') as Theme | null
  if (saved) {
    setTheme(saved)
  } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    setTheme('dark')
  }
}

export { theme, setTheme, initTheme }
```

**`design-tokens/colors/base.css` with data-theme:**

```css
:root,
[data-theme='light'] {
  --color-text: #000;
  --color-bg: #fff;
}

[data-theme='dark'] {
  --color-text: #fff;
  --color-bg: #1a1a1a;
}
```

## Design System Integration

### Figma → Code Workflow

1. **Design in Figma** with design tokens
2. **Export tokens** (use Figma plugins like Tokens Studio)
3. **Generate CSS** from exported tokens
4. **Import in project** via `globals.css`
5. **Build components** using tokens

### Storybook with Tokens

**`.storybook/preview.ts`:**

```typescript
import '../src/styles/globals.css'

export const parameters = {
  backgrounds: {
    default: 'light',
    values: [
      { name: 'light', value: 'var(--color-bg-primary)' },
      { name: 'dark', value: 'var(--color-bg-primary)' },
    ],
  },
}
```

**Components appear correctly in Storybook** — no extra setup needed.

## Performance Considerations

### CSS Variable Performance

- ✅ CSS variables are fast (no JavaScript overhead)
- ✅ Browser-native (no build step required)
- ✅ No CSS-in-JS bundle size
- ✅ Caching-friendly (CSS tokens in one file)

### Scoped CSS Performance

- ✅ No naming collisions (no specificity wars)
- ✅ Small CSS per-component (loaded on-demand with component)
- ✅ Dead code elimination (unused component CSS stays out of bundle)
- ✅ No CSS parsing overhead (simpler, smaller CSS)

### Optimization

```typescript
// vite.config.ts — ensure scoped styles are preserved
export default defineConfig({
  plugins: [vue()],
  // Scoped CSS is default — no extra config needed
})
```

## Anti-Patterns

### ❌ Don't: Mix Token Definitions

```css
/* WRONG — tokens scattered everywhere */
.button { --btn-color: #007bff; }
.card { --card-color: #007bff; }

/* RIGHT — centralized in design-tokens */
:root {
  --color-primary: #007bff;
}
```

### ❌ Don't: Use Global Styles for Component-Specific Rules

```css
/* WRONG — pollutes global namespace */
/* globals.css */
.button { ... }
.button--primary { ... }

/* RIGHT — scoped to component */
/* Button.vue <style scoped> */
.button { ... }
```

### ❌ Don't: Tailwind-Style Utilities

```html
<!-- WRONG -->
<div class="mt-4 mb-2 text-lg font-bold">

<!-- RIGHT — use scoped CSS -->
<div class="card__title">
```

### ❌ Don't: Skip Dark Mode

```css
/* WRONG */
.card {
  background: #fff;
  color: #000;
}

/* RIGHT — uses tokens that respect prefers-color-scheme */
.card {
  background: var(--color-bg-primary);
  color: var(--color-text-primary);
}
```

## File Structure

```
src/
├── styles/
│   ├── globals.css                  # Token imports + resets
│   └── design-tokens/
│       ├── colors/
│       │   ├── base.css
│       │   ├── semantic.css
│       │   └── dark-mode.css
│       ├── spacing/
│       │   └── scale.css
│       ├── typography/
│       │   ├── font-family.css
│       │   ├── font-size.css
│       │   └── line-height.css
│       ├── shadows/
│       │   └── elevations.css
│       ├── borders/
│       │   └── radius.css
│       └── transitions/
│           └── timing.css
│
├── components/
│   ├── atoms/
│   │   ├── Button/
│   │   │   ├── Button.vue           # <style scoped>
│   │   │   └── Button.test.ts
│   │   └── Input/
│   │       ├── Input.vue
│   │       └── Input.test.ts
│   ├── molecules/
│   │   ├── FormField/
│   │   │   ├── FormField.vue        # <style scoped>
│   │   │   └── FormField.test.ts
│   │   └── Card/
│   │       ├── Card.vue
│   │       └── Card.test.ts
│   └── organisms/
│       ├── Modal/
│       │   ├── Modal.vue            # <style scoped>
│       │   └── Modal.test.ts
│       └── Form/
│           ├── Form.vue
│           └── Form.test.ts
│
└── main.ts
    └── import './styles/globals.css'
```

## Checklist

- [ ] Design tokens defined for colors, spacing, typography, shadows
- [ ] All tokens use CSS variables (`:root`, `@media prefers-color-scheme`)
- [ ] Globals CSS imports all token files
- [ ] Components use `<style scoped>` (never global styles)
- [ ] All color values use `var(--color-*)`
- [ ] All spacing uses `var(--spacing-*)`
- [ ] All font sizes use `var(--font-*)`
- [ ] Dark mode support via CSS variables (no JavaScript needed)
- [ ] Semantic class names (`.button`, `.button--primary`, not `.mt-4`)
- [ ] Design tokens match Figma design system
- [ ] No Tailwind dependencies
- [ ] Storybook uses same token system
- [ ] Responsive design via `@media` queries
- [ ] No hardcoded colors or spacing values

## Summary

**This approach gives you:**
- ✅ Design fidelity (tokens match Figma exactly)
- ✅ Maintainability (change tokens once, all components update)
- ✅ Reusability (presenters composable, tokens shared)
- ✅ Dark mode (free with `prefers-color-scheme`)
- ✅ Performance (no utility CSS overhead)
- ✅ Clarity (semantic naming, intent obvious)
- ✅ Encapsulation (scoped CSS, no collisions)
- ✅ Flexibility (swap tokens for themes without changing components)
