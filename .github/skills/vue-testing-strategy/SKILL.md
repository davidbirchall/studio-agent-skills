---
name: "vue-testing-strategy"
description: "Vue 3 testing strategy with Vitest, Vue Testing Library, Playwright, TanStack Query, and Pinia. Emphasizes component behavior over implementation, 90%+ statement coverage, and realistic async testing patterns"
confidence: "medium"
---

# Vue Testing Strategy

Standardized testing approach for Vue 3 components, Pinia stores, and end-to-end flows. Covers unit testing (Vitest + Vue Testing Library), store testing (isolation + integration), server state testing (TanStack Query), and E2E testing (Playwright).

## Guiding Principles

1. **Test behavior, not implementation** — Test what the user sees/does, not component internals
2. **Presenter vs Container split** — Presenters are simple to test (props in, events out); containers test data flow
3. **Realistic async patterns** — Don't mock the Query client; mock the API layer with MSW
4. **90%+ statement coverage** — Focus on critical paths, not 100% coverage dogma
5. **Server state (Query), store state, component state are tested differently** — Each has its own patterns
6. **E2E tests catch integration issues** — Unit tests verify components, E2E verifies flows
7. **Test pyramid** — Many unit tests (fast), some integration tests (slower), few E2E tests (slowest)

## Test Pyramid

```
         🎯
        E2E (few)           - Real browser, real API mocking
       ┌────────┐           - Critical user flows only
       │        │
    📊 │        │ Integration - Components with stores/Query
       │        │           - Multiple components, realistic data
   ┌───┴────────┴───┐
   │                │
   │ Unit Tests     │      - Single component or store
   │ (many) 🔧      │      - Fast, isolated, high coverage
   └────────────────┘
```

**Coverage target:** 90% statements
- Focus: Critical paths (happy path + error handling)
- Skip: Debug utilities, trivial getters, error stubs
- Trade-off: Coverage ≠ quality; test intent matters more

## Test Setup

### Project Configuration

**`vitest.config.ts`:**

```typescript
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'vitest.setup.ts',
        '**/*.test.ts',
        '**/*.spec.ts',
        '**/types.ts',
      ],
      statements: 90,  // Fail if below 90%
      branches: 80,
      functions: 90,
      lines: 90,
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

**`vitest.setup.ts`:**

```typescript
import { expect, afterEach, vi } from 'vitest'
import { cleanup } from '@vue/test-utils'
import { server } from './src/mocks/server'  // MSW server

// Start MSW server before all tests
beforeAll(() => server.listen())

// Reset MSW handlers after each test
afterEach(() => {
  cleanup()
  server.resetHandlers()
})

// Clean up after all tests
afterAll(() => server.close())
```

### Dependencies

**`package.json`:**

```json
{
  "devDependencies": {
    "vitest": "^1.0.0",
    "@vitest/ui": "^1.0.0",
    "@vue/test-utils": "^2.4.0",
    "jsdom": "^23.0.0",
    "@testing-library/vue": "^8.0.0",
    "@testing-library/user-event": "^14.5.0",
    "msw": "^2.0.0",
    "@tanstack/vue-query": "^5.0.0",
    "pinia": "^2.1.0",
    "playwright": "^1.40.0",
    "@playwright/test": "^1.40.0",
    "vitest-canvas-mock": "^0.3.0"
  }
}
```

## Unit Testing Components

### Presenter Component Testing

**Test pattern:** Props in → Events out. No state, no API calls.

**Example component (`Button.vue`):**

```typescript
<template>
  <button
    :disabled="disabled"
    :class="['button', `button--${variant}`]"
    @click="$emit('click')"
  >
    {{ label }}
  </button>
</template>

<script setup lang="ts">
interface Props {
  label: string
  variant?: 'primary' | 'secondary'
  disabled?: boolean
}

withDefaults(defineProps<Props>(), {
  variant: 'primary',
  disabled: false,
})

defineEmits<{
  (e: 'click'): void
}>()
</script>
```

**Test file (`Button.test.ts`):**

```typescript
import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { render, screen } from '@testing-library/vue'
import userEvent from '@testing-library/user-event'
import Button from './Button.vue'

describe('Button', () => {
  // Test 1: Render with props
  it('renders with label', () => {
    render(Button, {
      props: { label: 'Click me' },
    })
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  // Test 2: Apply variant class
  it('applies correct variant class', () => {
    const { container } = render(Button, {
      props: { label: 'Test', variant: 'secondary' },
    })
    expect(container.querySelector('.button--secondary')).toBeInTheDocument()
  })

  // Test 3: Disabled state
  it('disables button when disabled prop is true', () => {
    render(Button, {
      props: { label: 'Test', disabled: true },
    })
    expect(screen.getByRole('button')).toBeDisabled()
  })

  // Test 4: Emit click event
  it('emits click event when clicked', async () => {
    const user = userEvent.setup()
    const wrapper = mount(Button, {
      props: { label: 'Click' },
    })

    await user.click(screen.getByRole('button'))
    expect(wrapper.emitted('click')).toHaveLength(1)
  })

  // Test 5: Keyboard interaction
  it('emits click when Enter key pressed', async () => {
    const user = userEvent.setup()
    const wrapper = mount(Button, {
      props: { label: 'Click' },
    })

    const button = screen.getByRole('button')
    button.focus()
    await user.keyboard('{Enter}')
    expect(wrapper.emitted('click')).toHaveLength(1)
  })
})
```

**Key patterns:**
- ✅ Use `@testing-library/vue` (behavior-focused)
- ✅ Query by accessibility role: `getByRole('button')`
- ✅ Test user interactions: `userEvent.click()`
- ✅ Test emitted events: `wrapper.emitted()`
- ❌ Don't test implementation details (internal `ref` values, computed internals)
- ❌ Don't shallow mount — use full render

### Async Component Testing

**Pattern: Components with async data, loading, error states**

**Example component (`UserCard.vue`):**

```typescript
<template>
  <div v-if="isLoading" class="user-card--loading">Loading...</div>
  <div v-else-if="error" class="user-card--error">
    {{ error }}
    <button @click="retry">Retry</button>
  </div>
  <div v-else class="user-card">
    <h3>{{ user.name }}</h3>
    <p>{{ user.email }}</p>
  </div>
</template>

<script setup lang="ts">
import { useUserQuery } from '@/composables/useUserQuery'

const props = defineProps<{ userId: string }>()
const emit = defineEmits<{ (e: 'loaded', user: User): void }>()

const { data: user, isLoading, error, refetch } = useUserQuery(props.userId)
const retry = () => refetch()

watch(user, (newUser) => {
  if (newUser) emit('loaded', newUser)
})
</script>
```

**Test file (`UserCard.test.ts`):**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { mount, flushPromises } from '@vue/test-utils'
import { screen, waitFor } from '@testing-library/vue'
import userEvent from '@testing-library/user-event'
import { QueryClient, useQuery } from '@tanstack/vue-query'
import UserCard from './UserCard.vue'

describe('UserCard', () => {
  let queryClient: QueryClient

  beforeEach(() => {
    queryClient = new QueryClient({
      defaultOptions: {
        queries: { retry: false }, // Disable retries in tests
      },
    })
  })

  // Test 1: Loading state
  it('shows loading while fetching', async () => {
    render(UserCard, {
      props: { userId: '123' },
      global: {
        plugins: [createTestingPinia(), [VueQueryPlugin, { queryClient }]],
      },
    })

    expect(screen.getByText('Loading...')).toBeInTheDocument()
  })

  // Test 2: Success state
  it('displays user data when loaded', async () => {
    render(UserCard, {
      props: { userId: '123' },
      global: {
        plugins: [createTestingPinia(), [VueQueryPlugin, { queryClient }]],
      },
    })

    // Wait for Query to resolve
    await waitFor(() => {
      expect(screen.queryByText('Loading...')).not.toBeInTheDocument()
    })

    expect(screen.getByText('John Doe')).toBeInTheDocument()
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })

  // Test 3: Error state
  it('shows error message on failure', async () => {
    server.use(
      http.get('/api/users/123', () => {
        return HttpResponse.json(
          { message: 'Not found' },
          { status: 404 }
        )
      })
    )

    render(UserCard, {
      props: { userId: '123' },
      global: {
        plugins: [createTestingPinia(), [VueQueryPlugin, { queryClient }]],
      },
    })

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument()
    })
  })

  // Test 4: Retry on error
  it('retries when retry button clicked', async () => {
    const user = userEvent.setup()
    let callCount = 0

    server.use(
      http.get('/api/users/123', () => {
        callCount++
        if (callCount === 1) {
          return HttpResponse.json(
            { message: 'Error' },
            { status: 500 }
          )
        }
        return HttpResponse.json({ id: '123', name: 'John', email: 'john@example.com' })
      })
    )

    render(UserCard, {
      props: { userId: '123' },
      global: { plugins: [createTestingPinia(), [VueQueryPlugin, { queryClient }]] },
    })

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeInTheDocument()
    })

    await user.click(screen.getByRole('button', { name: /retry/i }))

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })
  })
})
```

**Key patterns:**
- Use `waitFor()` for async state changes
- Use MSW to mock API responses
- Test loading, success, error, and retry states
- Use `flushPromises()` when needed to resolve pending promises

## Store Testing

### Unit Testing Stores (Isolation)

**Test stores in isolation — no components, no API calls (mock them).**

**Example store (`stores/user.store.ts`):**

```typescript
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { api } from '@/services/api'

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const isLoggedIn = computed(() => !!user.value)

  const fetchUser = async (userId: string) => {
    isLoading.value = true
    error.value = null

    try {
      const response = await api.get(`/users/${userId}`)
      user.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to fetch'
      throw err
    } finally {
      isLoading.value = false
    }
  }

  const logout = () => {
    user.value = null
    error.value = null
  }

  return { user, isLoading, error, isLoggedIn, fetchUser, logout }
})
```

**Test file (`user.store.test.ts`):**

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useUserStore } from './user.store'
import * as api from '@/services/api'

vi.mock('@/services/api')

describe('User Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('initializes with null user', () => {
    const store = useUserStore()
    expect(store.user).toBeNull()
    expect(store.isLoggedIn).toBe(false)
  })

  it('fetches user and sets state', async () => {
    vi.mocked(api.get).mockResolvedValue({
      data: { id: '123', name: 'John', email: 'john@example.com' },
    })

    const store = useUserStore()
    await store.fetchUser('123')

    expect(store.user).toEqual({ id: '123', name: 'John', email: 'john@example.com' })
    expect(store.isLoading).toBe(false)
    expect(store.error).toBeNull()
  })

  it('sets error on failed fetch', async () => {
    vi.mocked(api.get).mockRejectedValue(new Error('Network error'))

    const store = useUserStore()
    
    try {
      await store.fetchUser('123')
    } catch (err) {
      // Expected
    }

    expect(store.user).toBeNull()
    expect(store.error).toBe('Network error')
    expect(store.isLoading).toBe(false)
  })

  it('clears user on logout', async () => {
    vi.mocked(api.get).mockResolvedValue({
      data: { id: '123', name: 'John', email: 'john@example.com' },
    })

    const store = useUserStore()
    await store.fetchUser('123')
    expect(store.isLoggedIn).toBe(true)

    store.logout()
    expect(store.user).toBeNull()
    expect(store.isLoggedIn).toBe(false)
  })
})
```

**Key patterns:**
- ✅ Use `vi.mock()` to mock API service
- ✅ Use `setActivePinia()` to isolate each test
- ✅ Test all state transitions (initial → loading → success/error → final)
- ✅ Test computed getters
- ❌ Don't import components in store tests

### Integration Testing (Component + Store)

**Test component + store together — use real store, mock API with MSW.**

**Test file (`UserCard.integration.test.ts`):**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/vue'
import { createPinia } from 'pinia'
import userEvent from '@testing-library/user-event'
import UserCard from './UserCard.vue'

describe('UserCard Integration', () => {
  it('fetches and displays user through store', async () => {
    const pinia = createPinia()

    render(UserCard, {
      props: { userId: '123' },
      global: { plugins: [pinia, VueQueryPlugin] },
    })

    // MSW intercepts the API call
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })
  })

  it('stores user in Pinia and reuses on second mount', async () => {
    const pinia = createPinia()

    // First render — fetches from API
    const { unmount } = render(UserCard, {
      props: { userId: '123' },
      global: { plugins: [pinia] },
    })

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })

    unmount()

    // Second render — should use cached store
    render(UserCard, {
      props: { userId: '123' },
      global: { plugins: [pinia] },
    })

    // Data appears immediately (no Loading state)
    expect(screen.getByText('John Doe')).toBeInTheDocument()
  })
})
```

## Testing TanStack Query

### Query Testing Pattern

**Use real `QueryClient` with MSW — don't mock the Query layer itself.**

**Example composable (`useUserQuery.ts`):**

```typescript
import { useQuery } from '@tanstack/vue-query'
import { api } from '@/services/api'
import type { User } from '@/types'

export function useUserQuery(userId: string) {
  return useQuery<User>({
    queryKey: ['user', userId],
    queryFn: async () => {
      const response = await api.get(`/users/${userId}`)
      return response.data
    },
    staleTime: 5 * 60 * 1000,
  })
}
```

**Test file (`useUserQuery.test.ts`):**

```typescript
import { describe, it, expect, beforeEach } from 'vitest'
import { mount } from '@vue/test-utils'
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { useUserQuery } from './useUserQuery'

describe('useUserQuery', () => {
  let queryClient: QueryClient

  beforeEach(() => {
    queryClient = new QueryClient({
      defaultOptions: {
        queries: { retry: false },
      },
    })
  })

  it('fetches user data', async () => {
    let result
    const TestComponent = {
      setup() {
        result = useUserQuery('123')
        return { result }
      },
      template: '<div>{{ result.data?.name }}</div>',
    }

    mount(TestComponent, {
      global: {
        plugins: [[VueQueryPlugin, { queryClient }]],
      },
    })

    // MSW handles the API call
    await waitFor(() => {
      expect(result.data).toEqual({
        id: '123',
        name: 'John',
        email: 'john@example.com',
      })
    })
  })

  it('caches result (stale time)', async () => {
    const TestComponent = {
      setup() {
        const query = useUserQuery('123')
        return { query }
      },
      template: '<div>{{ query.data?.name }}</div>',
    }

    const wrapper1 = mount(TestComponent, {
      global: { plugins: [[VueQueryPlugin, { queryClient }]] },
    })

    await waitFor(() => expect(wrapper1.vm.query.data).toBeTruthy())

    // Second mount — should use cache (within staleTime)
    const wrapper2 = mount(TestComponent, {
      global: { plugins: [[VueQueryPlugin, { queryClient }]] },
    })

    // Data appears immediately (no Loading state)
    expect(wrapper2.vm.query.data).toEqual(wrapper1.vm.query.data)
  })

  it('handles error', async () => {
    server.use(
      http.get('/api/users/123', () => {
        return HttpResponse.json({ message: 'Not found' }, { status: 404 })
      })
    )

    let result
    const TestComponent = {
      setup() {
        result = useUserQuery('123')
        return { result }
      },
      template: '<div>{{ result.error?.message }}</div>',
    }

    mount(TestComponent, {
      global: { plugins: [[VueQueryPlugin, { queryClient }]] },
    })

    await waitFor(() => {
      expect(result.error).toBeTruthy()
    })
  })
})
```

**Key patterns:**
- ✅ Create fresh `QueryClient` per test
- ✅ Disable retries in test config
- ✅ Use MSW to mock API — don't mock `useQuery` itself
- ✅ Test caching behavior and stale-time
- ❌ Don't mock the Query layer; mock the API

## API Mocking with MSW

### MSW Server Setup

**`src/mocks/server.ts`:**

```typescript
import { setupServer } from 'msw/node'
import { http, HttpResponse } from 'msw'

const handlers = [
  // User endpoints
  http.get('/api/users/:userId', ({ params }) => {
    return HttpResponse.json({
      id: params.userId,
      name: 'John Doe',
      email: 'john@example.com',
    })
  }),

  http.get('/api/users', () => {
    return HttpResponse.json([
      { id: '1', name: 'John', email: 'john@example.com' },
      { id: '2', name: 'Jane', email: 'jane@example.com' },
    ])
  }),

  http.post('/api/users', async ({ request }) => {
    const body = await request.json()
    return HttpResponse.json(
      { id: '123', ...body },
      { status: 201 }
    )
  }),
]

export const server = setupServer(...handlers)
```

**Usage in tests:**

```typescript
import { server } from '@/mocks/server'
import { http, HttpResponse } from 'msw'

describe('User API', () => {
  it('handles errors', async () => {
    // Override handler for this test only
    server.use(
      http.get('/api/users/123', () => {
        return HttpResponse.json(
          { message: 'Not found' },
          { status: 404 }
        )
      })
    )

    // Test code...
  })
})
```

**Key patterns:**
- ✅ Define handlers at global level
- ✅ Override handlers per-test with `server.use()`
- ✅ Reset to defaults after each test (in `vitest.setup.ts`)
- ✅ Return realistic responses (status codes, delays if needed)
- ❌ Don't mock at component level; mock at API level

## End-to-End Testing with Playwright

### E2E Test Structure

**`e2e/user.flow.spec.ts`:**

```typescript
import { test, expect } from '@playwright/test'

test.describe('User Profile Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:5173')
    // Login if needed
    await page.fill('input[type="email"]', 'test@example.com')
    await page.fill('input[type="password"]', 'password')
    await page.click('button:has-text("Login")')
    await page.waitForURL('/dashboard')
  })

  test('navigates to profile and edits user name', async ({ page }) => {
    // Navigate
    await page.click('a:has-text("Profile")')
    await page.waitForURL('/profile')

    // Verify initial state
    await expect(page.locator('text=John Doe')).toBeVisible()

    // Edit
    await page.click('button:has-text("Edit")')
    await page.fill('input[id="name"]', 'Jane Doe')
    await page.click('button:has-text("Save")')

    // Verify update
    await expect(page.locator('text=Jane Doe')).toBeVisible()
  })

  test('handles error gracefully', async ({ page }) => {
    await page.goto('http://localhost:5173/profile/invalid-id')
    await expect(page.locator('text=Not found')).toBeVisible()
  })
})
```

**Configuration (`playwright.config.ts`):**

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
  },
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
  ],
})
```

## Testing Checklist

### Before Committing

- [ ] Unit tests for all new components (90%+ coverage target)
- [ ] Store tests (isolation + integration)
- [ ] Query tests with MSW
- [ ] Error states tested
- [ ] Async state transitions tested
- [ ] Run `npm run test:coverage` — meets 90% statements
- [ ] E2E tests for critical user flows

### Test Commands

```bash
# Run all tests
npm run test

# Run with UI
npm run test:ui

# Run with coverage
npm run test:coverage

# Watch mode
npm run test:watch

# E2E only
npm run test:e2e

# E2E UI
npm run test:e2e:ui
```

**`package.json` scripts:**

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:watch": "vitest --watch",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

## Anti-Patterns

### ❌ Don't: Test Implementation Details

```typescript
// ❌ WRONG — testing internals
it('sets count ref to 5', () => {
  const wrapper = mount(Counter)
  expect(wrapper.vm.count).toBe(0)  // Testing ref directly
  wrapper.vm.count = 5              // Mutating internal state
  expect(wrapper.vm.count).toBe(5)
})

// ✅ RIGHT — testing behavior
it('increments count when button clicked', async () => {
  const user = userEvent.setup()
  render(Counter)
  await user.click(screen.getByRole('button', { name: /increment/i }))
  expect(screen.getByText('1')).toBeInTheDocument()
})
```

### ❌ Don't: Over-Mock (Mock the Query layer)

```typescript
// ❌ WRONG — mocking useQuery directly
vi.mock('@tanstack/vue-query', () => ({
  useQuery: () => ({ data: mockUser })
}))

// ✅ RIGHT — mock the API layer, let Query work
// In MSW:
http.get('/api/users/:id', () => HttpResponse.json(mockUser))
```

### ❌ Don't: Test 100% Coverage

```typescript
// ❌ WRONG — testing trivial getters
it('userName returns user.name', () => {
  const store = useUserStore()
  store.user = { name: 'John' }
  expect(store.userName).toBe('John')  // Obvious, no value
})

// ✅ RIGHT — test complex logic, skip obvious getters
it('computes user initials correctly', () => {
  // Only test complex computed logic
})
```

### ❌ Don't: Test Without Accessibility Queries

```typescript
// ❌ WRONG
it('renders button', () => {
  const { container } = render(Button)
  expect(container.querySelector('button')).toBeInTheDocument()
})

// ✅ RIGHT
it('renders button', () => {
  render(Button)
  expect(screen.getByRole('button')).toBeInTheDocument()
})
```

## Coverage Goals

**Target: 90% statements**

```
✅ Include:
  - Happy path (normal behavior)
  - Error cases (catches, error states)
  - State transitions (loading → success/error)
  - Edge cases (empty lists, null values)

❌ Skip:
  - Debug utilities
  - Type-only exports
  - Obvious getter/setter
  - Mock helpers
  - Error stubs with no real logic
```

**Check coverage:**

```bash
npm run test:coverage
```

Reports: text output + HTML at `coverage/index.html`
