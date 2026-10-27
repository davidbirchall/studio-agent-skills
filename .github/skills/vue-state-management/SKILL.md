---
name: "vue-state-management"
description: "Pinia state management patterns, TypeScript store design, application-level state vs component state, async data handling with TanStack Query, and store organization across projects"
confidence: "medium"
---

# Vue State Management

Standardized Pinia state management for consistent, predictable state handling across all projects. Enforces clear boundaries: dumb components, smart containers, and application-level stores.

## Guiding Principles

1. **Dumb components → Smart containers** — Low-level components receive data/callbacks, higher-level containers manage state
2. **Store only application state** — Authentication, user, global settings, shared cross-feature data
3. **TanStack Query for server state** — Use `@tanstack/vue-query` for API calls, caching, and loading states
4. **Component state for UI** — Form fields, toggles, local visibility live in components
5. **TypeScript for stores** — Fully typed state, getters, actions
6. **Single store per domain** — One store for auth, one for user, one for notifications, etc.
7. **Organization by responsibility** — Nested structure that mirrors feature hierarchy
8. **Minimize store mutations** — Actions are explicit entry points

## State Boundaries

### What Goes Where

| Category | Store? | Component? | TanStack Query? |
|----------|--------|-----------|-----------------|
| User authentication | ✅ Store | ❌ | ❌ |
| Current logged-in user | ✅ Store | ❌ | ❌ |
| Global theme/language | ✅ Store | ❌ | ❌ |
| App-wide notifications | ✅ Store | ❌ | ❌ |
| Form input values | ❌ | ✅ Component | ❌ |
| Modal open/closed state | ❌ | ✅ Component | ❌ |
| Dropdown visibility | ❌ | ✅ Component | ❌ |
| API list data (users, posts) | ❌ | ❌ | ✅ Query |
| API detail data (user profile) | ❌ | ❌ | ✅ Query |
| Paginated API results | ❌ | ❌ | ✅ Query |
| User preferences (cached) | ✅ Store | ❌ | ✅ Query initial load |

**Decision tree:**
1. **Is it authentication/user identity?** → Store
2. **Is it accessed by 3+ unrelated components?** → Store or Query
3. **Is it API data (frequently changes)?** → TanStack Query
4. **Is it just this component's UI state?** → Component `ref()`
5. **Is it a feature-level setting (sidebar collapsed)?** → Container component `ref()`

## Store Organization

### Directory Structure

```
stores/
├── modules/
│   ├── auth/
│   │   ├── index.ts              # Export store
│   │   ├── auth.store.ts         # Pinia store definition
│   │   ├── auth.types.ts         # TypeScript interfaces
│   │   └── auth.test.ts          # Unit tests
│   ├── user/
│   │   ├── index.ts
│   │   ├── user.store.ts
│   │   ├── user.types.ts
│   │   └── user.test.ts
│   ├── notifications/
│   │   ├── index.ts
│   │   ├── notifications.store.ts
│   │   ├── notifications.types.ts
│   │   └── notifications.test.ts
│   └── settings/
│       ├── index.ts
│       ├── settings.store.ts
│       ├── settings.types.ts
│       └── settings.test.ts
└── index.ts                      # Central export
```

**File naming:**
- `{module}.store.ts` — Pinia store definition
- `{module}.types.ts` — TypeScript interfaces
- `index.ts` — Named exports

### One Store Per Domain

Each domain gets one store. Domains map to features:

```typescript
// ✅ GOOD - One store per domain
useAuthStore()        // Authentication, login, logout
useUserStore()        // Current user profile, preferences
useNotificationStore() // App notifications (toasts, alerts)
useSettingsStore()     // Global app settings (theme, language)

// ❌ BAD - Too many stores
useLoginStore()       // Conflicts with useAuthStore()
useCurrentUserStore() // Redundant, part of user domain
useToastStore()       // Conflicts with useNotificationStore()
```

## Pinia Store Pattern

### Basic Store Structure

```typescript
// stores/modules/auth/auth.types.ts
export interface AuthState {
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
  error: string | null
}

export interface LoginPayload {
  email: string
  password: string
}

export interface AuthContext {
  login(payload: LoginPayload): Promise<void>
  logout(): void
  clearError(): void
}

// stores/modules/auth/auth.store.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { AuthState, LoginPayload, AuthContext } from './auth.types'
import { api } from '@/services/api'

export const useAuthStore = defineStore('auth', (): AuthContext => {
  // State
  const token = ref<string | null>(localStorage.getItem('auth_token'))
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // Getters
  const isAuthenticated = computed(() => !!token.value)
  
  const authHeader = computed(() => 
    token.value ? { Authorization: `Bearer ${token.value}` } : {}
  )

  // Actions
  const login = async (payload: LoginPayload) => {
    isLoading.value = true
    error.value = null

    try {
      const response = await api.post('/auth/login', payload)
      token.value = response.data.token
      localStorage.setItem('auth_token', token.value)
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Login failed'
      throw err
    } finally {
      isLoading.value = false
    }
  }

  const logout = () => {
    token.value = null
    localStorage.removeItem('auth_token')
    error.value = null
  }

  const clearError = () => {
    error.value = null
  }

  return {
    // State
    token,
    isLoading,
    error,
    // Getters
    isAuthenticated,
    authHeader,
    // Actions
    login,
    logout,
    clearError,
  }
})

// stores/modules/auth/index.ts
export { useAuthStore } from './auth.store'
export type { AuthState, LoginPayload, AuthContext } from './auth.types'

// stores/index.ts
export { useAuthStore } from './modules/auth'
export { useUserStore } from './modules/user'
export { useNotificationStore } from './modules/notifications'
export { useSettingsStore } from './modules/settings'
```

### TypeScript Store Pattern (Composition API)

Pinia stores use Composition API under the hood. Define state, computed, and actions explicitly:

```typescript
export const useUserStore = defineStore('user', () => {
  // ===== STATE =====
  const user = ref<User | null>(null)
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // ===== GETTERS =====
  const isLoggedIn = computed(() => !!user.value)
  
  const userName = computed(() => user.value?.name ?? 'Anonymous')
  
  const userInitials = computed(() => {
    if (!user.value) return ''
    const [first, last] = user.value.name.split(' ')
    return `${first[0]}${last?.[0] ?? ''}`.toUpperCase()
  })

  // ===== ACTIONS =====
  const fetchUser = async (userId: string) => {
    isLoading.value = true
    error.value = null

    try {
      const response = await api.get(`/users/${userId}`)
      user.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Failed to fetch user'
      throw err
    } finally {
      isLoading.value = false
    }
  }

  const updateUser = async (payload: Partial<User>) => {
    try {
      const response = await api.put(`/users/${user.value?.id}`, payload)
      user.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Update failed'
      throw err
    }
  }

  const clearUser = () => {
    user.value = null
    error.value = null
  }

  return {
    // State
    user,
    isLoading,
    error,
    // Getters
    isLoggedIn,
    userName,
    userInitials,
    // Actions
    fetchUser,
    updateUser,
    clearUser,
  }
})
```

## Component State vs Store State

### Keep State in Components

✅ **Component-local state (use `ref()`):**

```typescript
<script setup lang="ts">
import { ref, computed } from 'vue'

// Local component state
const isOpen = ref(false)
const formData = ref({
  name: '',
  email: '',
})
const selectedTab = ref('profile')

const isFormDirty = computed(() => 
  formData.value.name || formData.value.email
)

const closeModal = () => isOpen.value = false
</script>

<template>
  <div>
    <button @click="isOpen = true">Open Modal</button>
    
    <Modal v-if="isOpen" @close="closeModal">
      <form @submit.prevent="submit">
        <input v-model="formData.name" />
        <input v-model="formData.email" />
      </form>
    </Modal>
  </div>
</template>
```

**Examples:**
- Form field values
- Modal/dropdown visibility
- Active tab
- Collapsed/expanded state
- Hover states
- Local UI toggles

### Lift State to Store

✅ **Application-level state (use Pinia store):**

```typescript
<script setup lang="ts">
import { useUserStore } from '@/stores'
import { storeToRefs } from 'pinia'

const userStore = useUserStore()
const { user, isLoading } = storeToRefs(userStore)

// Use getters
const isAdmin = computed(() => user.value?.role === 'admin')

// Call actions
const logout = () => userStore.logout()
</script>

<template>
  <div>
    <div v-if="isLoading">Loading...</div>
    <div v-else>
      Hello, {{ user.name }}
      <button v-if="isAdmin">Admin Panel</button>
      <button @click="logout">Logout</button>
    </div>
  </div>
</template>
```

**Examples:**
- Authentication state
- Current user profile
- Global notifications
- App settings/preferences
- Shared cross-feature data

## TanStack Query Integration

Use **@tanstack/vue-query** for server state (API calls, caching, background updates).

### Query Setup

```typescript
// composables/useUserQuery.ts
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
    // Caching
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 10 * 60 * 1000,    // 10 minutes
  })
}

export function useUsersQuery(filters?: { page?: number; limit?: number }) {
  return useQuery<User[]>({
    queryKey: ['users', filters],
    queryFn: async () => {
      const response = await api.get('/users', { params: filters })
      return response.data
    },
    staleTime: 2 * 60 * 1000,
    gcTime: 5 * 60 * 1000,
  })
}
```

### Using Queries in Components

```typescript
<script setup lang="ts">
import { useUserQuery } from '@/composables/useUserQuery'

const userId = '123'
const { data: user, isLoading, isError, error } = useUserQuery(userId)
</script>

<template>
  <div>
    <div v-if="isLoading">Loading user...</div>
    <div v-else-if="isError">Error: {{ error?.message }}</div>
    <div v-else>
      <h1>{{ user?.name }}</h1>
      <p>{{ user?.email }}</p>
    </div>
  </div>
</template>
```

### Query vs Store

| Scenario | Use Query | Use Store |
|----------|-----------|-----------|
| Fetch list of users | ✅ Query | ❌ |
| Cache API responses | ✅ Query | ❌ |
| Paginate API results | ✅ Query | ❌ |
| Current user profile (after login) | ✅ Query then sync to store | Store as fallback |
| Authentication token | ❌ | ✅ Store |
| User permissions (static) | ✅ Query once | ✅ Store after load |
| Real-time notifications | ❌ | ✅ Store + WebSocket |

## Async Action Pattern

### Loading & Error Handling

```typescript
export const useDataStore = defineStore('data', () => {
  const items = ref<Item[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // ✅ GOOD - Clear loading/error flow
  const fetchItems = async () => {
    isLoading.value = true
    error.value = null

    try {
      const response = await api.get('/items')
      items.value = response.data
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unknown error'
      console.error('Failed to fetch items:', err)
      // Optionally rethrow or return error
      throw err
    } finally {
      isLoading.value = false
    }
  }

  // ✅ GOOD - Separate clear function
  const clearError = () => {
    error.value = null
  }

  // ✅ GOOD - Reset store state
  const reset = () => {
    items.value = []
    isLoading.value = false
    error.value = null
  }

  return { items, isLoading, error, fetchItems, clearError, reset }
})
```

### Retry Logic (with TanStack Query)

```typescript
export function useItemsQuery() {
  return useQuery({
    queryKey: ['items'],
    queryFn: async () => {
      const response = await api.get('/items')
      return response.data
    },
    // Retry configuration
    retry: 3,                  // Retry 3 times
    retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 30000), // Exponential backoff
  })
}
```

## Store Usage in Components

### Container Component Pattern

Smart "container" components manage state and pass data to dumb presentational components:

```typescript
// src/components/UserProfile/UserProfileContainer.vue
// This is a CONTAINER - it manages state
<script setup lang="ts">
import { useUserStore } from '@/stores'
import { useUserQuery } from '@/composables/useUserQuery'
import { storeToRefs } from 'pinia'
import UserProfileView from './UserProfileView.vue'

const userId = '123'

// Get store
const userStore = useUserStore()
const { user: storedUser } = storeToRefs(userStore)

// Fetch from server
const { data: queriedUser, isLoading, error } = useUserQuery(userId)

// Sync to store after fetch
const syncUserToStore = async () => {
  if (queriedUser.value) {
    userStore.user = queriedUser.value
  }
}
</script>

<template>
  <UserProfileView 
    :user="storedUser || queriedUser" 
    :is-loading="isLoading"
    :error="error?.message"
    @update="syncUserToStore"
  />
</template>

// src/components/UserProfile/UserProfileView.vue
// This is PRESENTATIONAL (dumb) - no state logic
<script setup lang="ts">
import type { User } from '@/types'

interface Props {
  user?: User
  isLoading?: boolean
  error?: string
}

interface Emits {
  (e: 'update'): void
}

defineProps<Props>()
defineEmits<Emits>()
</script>

<template>
  <div>
    <div v-if="isLoading">Loading...</div>
    <div v-else-if="error">Error: {{ error }}</div>
    <div v-else>
      <h1>{{ user?.name }}</h1>
      <button @click="$emit('update')">Update Profile</button>
    </div>
  </div>
</template>
```

### Using `storeToRefs()`

Always use `storeToRefs()` to destructure state (maintains reactivity):

```typescript
// ✅ GOOD - Reactivity preserved
const authStore = useAuthStore()
const { token, isAuthenticated, isLoading } = storeToRefs(authStore)

// ❌ BAD - Loses reactivity
const { token, isAuthenticated } = useAuthStore()
```

## Testing Stores

### Unit Test Stores

```typescript
// stores/modules/auth/auth.store.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from './auth.store'

describe('Auth Store', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })

  it('initializes with no token', () => {
    const store = useAuthStore()
    expect(store.token).toBeNull()
    expect(store.isAuthenticated).toBe(false)
  })

  it('logs in and sets token', async () => {
    const store = useAuthStore()
    
    // Mock API
    vi.mock('@/services/api', () => ({
      api: {
        post: vi.fn().mockResolvedValue({
          data: { token: 'test_token_123' }
        })
      }
    }))

    await store.login({ email: 'test@example.com', password: 'password' })
    
    expect(store.token).toBe('test_token_123')
    expect(store.isAuthenticated).toBe(true)
  })

  it('clears token on logout', () => {
    const store = useAuthStore()
    store.token = 'test_token'
    
    store.logout()
    
    expect(store.token).toBeNull()
    expect(store.isAuthenticated).toBe(false)
  })
})
```

## Common Patterns

### Getters from State

```typescript
const store = defineStore('example', () => {
  const items = ref<Item[]>([])
  const filter = ref<string>('')

  // Derived data
  const filteredItems = computed(() => 
    items.value.filter(item => 
      item.name.toLowerCase().includes(filter.value.toLowerCase())
    )
  )

  const itemCount = computed(() => items.value.length)

  const isEmpty = computed(() => items.value.length === 0)

  return { items, filter, filteredItems, itemCount, isEmpty }
})
```

### Persisting State to LocalStorage

```typescript
const store = defineStore('settings', () => {
  const theme = ref<'light' | 'dark'>(
    (localStorage.getItem('theme') as any) ?? 'light'
  )

  const setTheme = (value: 'light' | 'dark') => {
    theme.value = value
    localStorage.setItem('theme', value)
  }

  return { theme, setTheme }
}, {
  // Persist entire store
  persist: {
    enabled: true,
    strategies: [
      {
        key: 'settings',
        storage: localStorage,
      }
    ]
  }
})
```

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Massive single store | Hard to maintain, hard to test | One store per domain |
| All state in store | Performance issues, prop drilling | Keep component state local |
| No TypeScript types | Runtime errors, IDE autocomplete | Define types, use `defineStore<T>()` |
| Direct mutations (mutation: `setUser(user)`) | Hard to track changes | Use actions with explicit logic |
| Mixing async/sync in actions | Unclear behavior, error handling | Keep actions focused |
| Querying in store instead of Query | No caching, duplicate requests | Use TanStack Query for server state |
| Not using `storeToRefs()` | Lose reactivity in templates | Always use `storeToRefs()` |

## Store Setup (main.ts)

```typescript
import { createPinia } from 'pinia'
import { createPiniaPersist } from 'pinia-plugin-persist'
import { createApp } from 'vue'
import App from './App.vue'

const app = createApp(App)

// Create Pinia
const pinia = createPinia()

// Optional: Add persistence plugin
pinia.use(createPiniaPersist)

app.use(pinia)
app.mount('#app')
```

## Related Skills

- `vue-component-patterns` — Component structure, prop drilling vs provide/inject
- `vue-testing-strategy` — Testing stores + components together
- `vue-performance` — Store optimization, computed caching

---

**Version:** 1.0  
**Last Updated:** 2026-10-27  
**Confidence:** medium
