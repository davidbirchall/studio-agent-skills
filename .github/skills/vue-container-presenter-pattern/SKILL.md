---
name: "vue-container-presenter-pattern"
description: "Smart Container / Dumb Presenter component split pattern. Containers manage state and data fetching; Presenters receive everything as props and emit events. Clear separation of concerns, testability, and reusability"
confidence: "high"
---

# Vue Container/Presenter Pattern

The **Container/Presenter** (also called Smart/Dumb or Container/Presentational) pattern is the architectural foundation of your component hierarchy. It cleanly separates data management from presentation, making components testable, reusable, and aligned with your atomic design principles.

## Guiding Principles

1. **Presenter components are pure** — Given the same props, always render the same output
2. **Containers orchestrate** — Manage state, fetch data, coordinate sub-components
3. **Presenters never know about stores or API** — They receive everything as props
4. **Containers are rarely reused** — Each page/feature has its own container
5. **Presenters are highly reusable** — Use them across many features
6. **Data flows down, events flow up** — No two-way binding across presenter/container boundary
7. **One responsibility per component** — Containers orchestrate, Presenters display

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Page / Router Component                                     │
│ (Renders container, passes route params)                   │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ route params
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ CONTAINER (Smart)                                           │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ • Fetch data (stores, queries, API)                    │ │
│ │ • Manage local state                                   │ │
│ │ • Handle business logic                                │ │
│ │ • Coordinate sub-components                            │ │
│ │ • Dispatch actions, mutations                          │ │
│ └─────────────────────────────────────────────────────────┘ │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ props (data + callbacks)
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ PRESENTER (Dumb)                                            │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ • Receive all data as props                            │ │
│ │ • Emit events for user interactions                    │ │
│ │ • Focus on UI/UX                                       │ │
│ │ • Composable sub-presenters                            │ │
│ │ • No business logic                                    │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                     ▲
                     │
                     │ events
```

## When to Use Container/Presenter

### ✅ Use Container/Presenter When:

1. **Component needs data from API or store** → Container fetches, Presenter displays
2. **Multiple sub-components need the same data** → Container manages, passes as props
3. **Component has local state** → Container holds state, Presenter receives as props
4. **Reusable UI component** → Presenter version for many features
5. **Complex business logic** → Container orchestrates, Presenter stays simple
6. **Testing is important** → Presenters test easily (props in, events out)

### ❌ When NOT Needed:

- **Leaf atom components** (Button, Input, Icon) → Always just presenters
- **Simple molecules with no state** (Card, Badge, Label) → Presenter only
- **Feature-specific UI with no reuse** → Still split if complex, but simpler container
- **One-off components with simple logic** → Direct component is fine

**Rule of thumb:** If you're fetching data or managing state, create a container. If it's displaying data, make it a presenter.

## Pattern Structure

### File Organization

```
features/
└── user-profile/
    ├── UserProfile.vue              # Page component (routes to container)
    │
    └── components/
        ├── UserProfileContainer.vue # Container (smart)
        │
        └── UserProfile/
            ├── UserProfile.vue      # Presenter (dumb)
            ├── UserAvatar.vue       # Sub-presenter
            ├── UserBio.vue          # Sub-presenter
            ├── UserActions.vue      # Sub-presenter
            └── index.ts
```

**Naming convention:**
- Container: `{Feature}Container.vue` (e.g., `UserProfileContainer.vue`)
- Presenter: `{Feature}.vue` (e.g., `UserProfile.vue`)
- The presenter version is the "public API" — used by containers throughout the app

### Container Component

The container:
- Fetches data from stores, queries, or API
- Manages local UI state (if needed)
- Handles business logic and coordination
- Passes everything to the presenter as props
- Listens to presenter events and responds

**Example container (`UserProfileContainer.vue`):**

```typescript
<template>
  <!-- Pass all data and handlers to presenter -->
  <UserProfile
    v-if="!isLoading"
    :user="user"
    :isEditing="isEditing"
    :isSaving="isSaving"
    :error="error"
    @edit="startEditing"
    @save="handleSave"
    @cancel="cancelEditing"
    @delete="handleDelete"
  />
  
  <div v-else class="loading">Loading user profile...</div>
  <div v-if="error" class="error">{{ error }}</div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useUserStore } from '@/stores/user'
import { useUserQuery } from '@/composables/useUserQuery'
import { useNotificationStore } from '@/stores/notifications'
import UserProfile from './UserProfile/UserProfile.vue'
import type { User } from '@/types'

const props = defineProps<{ userId: string }>()

// ===== STORE & DATA FETCHING =====
const userStore = useUserStore()
const notificationStore = useNotificationStore()
const { data: user, isLoading, error: fetchError, refetch } = useUserQuery(props.userId)

// ===== LOCAL UI STATE =====
const isEditing = ref(false)
const isSaving = ref(false)
const localError = ref<string | null>(null)

// ===== COMPUTED STATE =====
const error = computed(() => localError.value || fetchError.value)

// ===== HANDLERS (called by presenter) =====
const startEditing = () => {
  isEditing.value = true
}

const cancelEditing = () => {
  isEditing.value = false
  localError.value = null
}

const handleSave = async (updatedUser: Partial<User>) => {
  isSaving.value = true
  localError.value = null

  try {
    await userStore.updateUser(props.userId, updatedUser)
    isEditing.value = false
    notificationStore.addNotification({
      type: 'success',
      message: 'Profile updated successfully',
    })
    
    // Refetch to get fresh data
    await refetch()
  } catch (err) {
    localError.value = err instanceof Error ? err.message : 'Update failed'
  } finally {
    isSaving.value = false
  }
}

const handleDelete = async () => {
  if (!confirm('Are you sure? This cannot be undone.')) return

  isSaving.value = true
  try {
    await userStore.deleteUser(props.userId)
    notificationStore.addNotification({
      type: 'success',
      message: 'Profile deleted',
    })
    // Navigate away (parent handles routing)
  } catch (err) {
    localError.value = err instanceof Error ? err.message : 'Delete failed'
  } finally {
    isSaving.value = false
  }
}
</script>
```

**Container characteristics:**
- ✅ Uses stores, composables, queries
- ✅ Manages async state (loading, error)
- ✅ Handles form state locally if complex
- ✅ Coordinates multiple presenters
- ✅ Passes data and callbacks to presenters
- ✅ Listens to presenter events
- ❌ Never appears in multiple places (no reuse)
- ❌ No complex styling (just layout)

### Presenter Component

The presenter:
- Receives **all data as props**
- Emits **events for user actions**
- Contains **all styling and layout**
- Is **purely functional** — given props, always same output
- Can compose **sub-presenters**

**Example presenter (`UserProfile/UserProfile.vue`):**

```typescript
<template>
  <div class="user-profile">
    <!-- Display data from props -->
    <UserAvatar :user="user" class="user-profile__avatar" />
    
    <UserBio
      v-if="!isEditing"
      :user="user"
      @edit="$emit('edit')"
      @delete="$emit('delete')"
    />
    
    <!-- Editing mode -->
    <UserEditForm
      v-else
      :user="user"
      :isSaving="isSaving"
      :error="error"
      @save="$emit('save', $event)"
      @cancel="$emit('cancel')"
    />
  </div>
</template>

<script setup lang="ts">
import UserAvatar from './UserAvatar.vue'
import UserBio from './UserBio.vue'
import UserEditForm from './UserEditForm.vue'
import type { User } from '@/types'

interface Props {
  user: User
  isEditing?: boolean
  isSaving?: boolean
  error?: string | null
}

withDefaults(defineProps<Props>(), {
  isEditing: false,
  isSaving: false,
  error: null,
})

defineEmits<{
  (e: 'edit'): void
  (e: 'save', user: Partial<User>): void
  (e: 'cancel'): void
  (e: 'delete'): void
}>()
</script>

<style scoped>
.user-profile {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-4);
}

.user-profile__avatar {
  align-self: center;
}
</style>
```

**Presenter characteristics:**
- ✅ Receives all data as props
- ✅ Emits events for actions
- ✅ Contains all styling
- ✅ Composable (uses sub-presenters)
- ✅ No stores or queries
- ✅ Pure: same props = same output
- ❌ No business logic
- ❌ No state management

### Sub-Presenter Example

Presenters can compose other presenters. Sub-presenters follow the same rules:

**`UserAvatar.vue` (atom-level presenter):**

```typescript
<template>
  <div class="avatar" :class="`avatar--size-${size}`">
    <img
      :src="user.avatarUrl"
      :alt="`${user.name}'s avatar`"
      class="avatar__image"
    />
  </div>
</template>

<script setup lang="ts">
import type { User } from '@/types'

interface Props {
  user: User
  size?: 'sm' | 'md' | 'lg'
}

withDefaults(defineProps<Props>(), {
  size: 'md',
})
</script>

<style scoped>
.avatar {
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
}

.avatar--size-sm {
  width: var(--size-8);
  height: var(--size-8);
}

.avatar--size-md {
  width: var(--size-12);
  height: var(--size-12);
}

.avatar--size-lg {
  width: var(--size-16);
  height: var(--size-16);
}

.avatar__image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
</style>
```

**`UserBio.vue` (molecule-level presenter):**

```typescript
<template>
  <div class="user-bio">
    <h2 class="user-bio__name">{{ user.name }}</h2>
    <p class="user-bio__email">{{ user.email }}</p>
    <p v-if="user.bio" class="user-bio__bio">{{ user.bio }}</p>
    
    <div class="user-bio__actions">
      <button @click="$emit('edit')" class="btn btn--primary">Edit Profile</button>
      <button @click="$emit('delete')" class="btn btn--danger">Delete Account</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { User } from '@/types'

interface Props {
  user: User
}

defineProps<Props>()

defineEmits<{
  (e: 'edit'): void
  (e: 'delete'): void
}>()
</script>

<style scoped>
.user-bio {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-2);
}

.user-bio__name {
  font-size: var(--font-lg);
  font-weight: bold;
}

.user-bio__email {
  color: var(--color-text-secondary);
  font-size: var(--font-sm);
}

.user-bio__actions {
  display: flex;
  gap: var(--spacing-2);
  margin-top: var(--spacing-4);
}
</style>
```

## State Management Patterns

### Local UI State vs Store State

**When to use container local state (`ref`):**
- Form editing mode (isEditing, isExpanded, activeTab)
- UI-only visibility toggles
- Temporary UI state for this page only
- Complex form field values

**When to use store:**
- User authentication state
- Global theme/language
- Cross-feature shared data
- Notification queue

**Example: Form State**

```typescript
// ❌ DON'T: Store form state in Pinia
// const formStore = useFormStore()
// formStore.setName('John')  // Wrong place

// ✅ DO: Keep form state in container
const formData = ref({
  name: user.value?.name ?? '',
  email: user.value?.email ?? '',
  bio: user.value?.bio ?? '',
})

// Validate locally
const isFormDirty = computed(() => {
  return formData.value.name !== user.value?.name ||
         formData.value.email !== user.value?.email ||
         formData.value.bio !== user.value?.bio
})

// Submit to store/API
const handleSave = async () => {
  try {
    await userStore.updateUser(props.userId, formData.value)
    // Success — presenter shows success state
  } catch (err) {
    // Error — presenter shows error message
  }
}
```

### Data Fetching Strategy

**Container decides what data is needed:**

```typescript
// Pattern: TanStack Query (recommended)
const { data: user, isLoading, error } = useUserQuery(userId)

// Pattern: Pinia store with Query
const userStore = useUserStore()
const { data: user, isLoading } = useUserQuery(userId)
const isEditing = userStore.isEditingUser

// Pattern: Multiple data sources
const userStore = useUserStore()
const { data: user } = useUserQuery(userId)
const { data: posts } = useUserPostsQuery(userId)
const isAdmin = computed(() => userStore.currentUser?.role === 'admin')
```

**Presenter never knows where data comes from:**

```typescript
// ✅ Presenter doesn't care
<UserProfile
  :user="user"        // Could be from Query, store, or hardcoded
  :posts="posts"      // Presenter doesn't know or care
  @save="handleSave"
/>
```

## Error Handling Pattern

**Container handles errors, Presenter displays them:**

```typescript
// Container
const localError = ref<string | null>(null)
const fetchError = ref<string | null>(null)

const error = computed(() => localError.value || fetchError.value)

const handleSave = async (data) => {
  localError.value = null
  try {
    await api.updateUser(data)
  } catch (err) {
    localError.value = err instanceof Error ? err.message : 'Update failed'
  }
}

// Presenter receives error and displays it
<template>
  <div v-if="error" class="error-banner">{{ error }}</div>
  <UserForm :error="error" @save="handleSave" />
</template>
```

## Props Interface Pattern

**Share a props interface between Container and Presenter:**

```typescript
// types/user-profile.types.ts
import type { User } from './user'

export interface UserProfileProps {
  user: User
  isEditing?: boolean
  isSaving?: boolean
  error?: string | null
}

export interface UserProfileEmits {
  (e: 'edit'): void
  (e: 'save', user: Partial<User>): void
  (e: 'cancel'): void
  (e: 'delete'): void
}

// UserProfileContainer.vue
const props = defineProps<{ userId: string }>()

const presenterProps = computed<UserProfileProps>(() => ({
  user: user.value,
  isEditing: isEditing.value,
  isSaving: isSaving.value,
  error: error.value,
}))

// UserProfile.vue
defineProps<UserProfileProps>()
defineEmits<UserProfileEmits>()
```

## Reusable Presenter Pattern

Once you've extracted a presenter, use it everywhere:

```typescript
// Page 1: User Detail Page
import UserProfile from '@/features/user-profile/components/UserProfile.vue'
import UserProfileContainer from '@/features/user-profile/containers/UserProfileContainer.vue'

// Use the container
<UserProfileContainer :userId="route.params.id" />

// Page 2: Admin Panel (same presenter, different container)
import UserProfileAdminContainer from '@/admin/containers/UserProfileAdminContainer.vue'

// Different container, same presenter
<UserProfileAdminContainer :userId="selectedUserId" />

// Page 3: Just show profile (read-only)
import UserProfile from '@/features/user-profile/components/UserProfile.vue'

// Use presenter directly (no container needed)
<UserProfile
  :user="staticUser"
  :isEditing="false"
  @edit="() => {}"
/>
```

## Testing Container/Presenter Split

### Testing Presenter (Simple)

```typescript
import { render, screen } from '@testing-library/vue'
import UserProfile from './UserProfile.vue'

it('displays user name', () => {
  render(UserProfile, {
    props: {
      user: { id: '1', name: 'John', email: 'john@example.com' },
    },
  })
  expect(screen.getByText('John')).toBeInTheDocument()
})

it('emits edit event when button clicked', async () => {
  const wrapper = mount(UserProfile, {
    props: {
      user: { id: '1', name: 'John', email: 'john@example.com' },
    },
  })
  
  await userEvent.click(screen.getByText('Edit Profile'))
  expect(wrapper.emitted('edit')).toHaveLength(1)
})
```

### Testing Container (More Complex)

```typescript
import { render, screen, waitFor } from '@testing-library/vue'
import { createPinia } from 'pinia'
import UserProfileContainer from './UserProfileContainer.vue'

it('fetches user and passes to presenter', async () => {
  render(UserProfileContainer, {
    props: { userId: '123' },
    global: { plugins: [createPinia(), VueQueryPlugin] },
  })

  // MSW intercepts API call
  await waitFor(() => {
    expect(screen.getByText('John')).toBeInTheDocument()
  })
})

it('saves user and shows success', async () => {
  render(UserProfileContainer, {
    props: { userId: '123' },
    global: { plugins: [createPinia(), VueQueryPlugin] },
  })

  await userEvent.click(screen.getByText('Edit Profile'))
  await userEvent.clear(screen.getByDisplayValue('John'))
  await userEvent.type(screen.getByDisplayValue(''), 'Jane')
  await userEvent.click(screen.getByText('Save'))

  await waitFor(() => {
    expect(screen.getByText('Profile updated')).toBeInTheDocument()
  })
})
```

## Anti-Patterns

### ❌ Presenter with Business Logic

```typescript
// WRONG — presenter has logic
<template>
  <div v-if="user.role === 'admin'">
    <AdminPanel />  <!-- Where did user come from? -->
  </div>
</template>

<script setup>
import { useUserStore } from '@/stores/user'  // ❌ Presenter imports store!
const userStore = useUserStore()
const user = userStore.currentUser
</script>

// RIGHT — container decides what to pass
// Container:
<AdminPanel v-if="isAdmin" />

// Presenter receives everything as props
<template>
  <AdminPanel v-if="shouldShowAdmin" />
</template>

<script setup>
defineProps<{ shouldShowAdmin: boolean }>()
</script>
```

### ❌ Two-Way Binding Across Boundary

```typescript
// WRONG
const userStore = useUserStore()

<UserProfile
  :user="userStore.currentUser"
  @update:user="userStore.setUser"  // ❌ Two-way binding
/>

// RIGHT — use separate handlers
<UserProfile
  :user="user"
  @save="handleSave"    // One-way event
/>

// Container handles the save
const handleSave = async (updatedUser) => {
  await userStore.updateUser(updatedUser)
}
```

### ❌ Presenter Importing from Stores

```typescript
// WRONG — presenter couples to implementation
<script setup>
import { useUserStore } from '@/stores/user'
const userStore = useUserStore()
</script>

// RIGHT — presenter receives as props
<script setup>
defineProps<{ user: User }>()
</script>
```

### ❌ Container Without Clear Responsibility

```typescript
// WRONG — container doing too much
const UserPageContainer = {
  // Handles routing
  // Fetches data
  // Manages form state
  // Handles permissions
  // Logs analytics
  // All mixed together
}

// RIGHT — split by responsibility
const UserProfileContainer  // Data + form state for this feature
const UserProfileAuthorized // Permission wrapper (separate container)
const UserProfilePage       // Routing and page layout
```

## Decision Tree: Container or Presenter?

```
Does component need to:
│
├─ Fetch data from API/store? ──→ CONTAINER
│
├─ Manage complex state? ──────→ CONTAINER
│
├─ Handle business logic? ─────→ CONTAINER
│
├─ Need to be reused in multiple places? ──→ PRESENTER
│
├─ Just display UI? ───────────→ PRESENTER
│
└─ Emit events for user actions? ──────────→ PRESENTER
```

## Best Practices Checklist

- [ ] **Container**: Fetches data, manages state, handles business logic
- [ ] **Container**: Passes everything needed to Presenter as props
- [ ] **Container**: Listens to Presenter events and responds
- [ ] **Presenter**: Receives all data as props, never fetches
- [ ] **Presenter**: Emits events, never calls actions directly
- [ ] **Presenter**: Contains all styling and layout
- [ ] **Presenter**: Pure component — same props = same output
- [ ] **Presenter**: Can be used standalone in Storybook
- [ ] **Props interface**: Shared between Container and Presenter
- [ ] **No two-way binding**: Data down, events up
- [ ] **Container rarely reused**: One per feature/page
- [ ] **Presenter highly reused**: Used across many features
- [ ] **Tests**: Presenter tests simple (props/events), Container tests data flow

## File Structure Recap

```
features/
└── user-profile/
    ├── index.ts                      # Export presenter + container
    │
    ├── types/
    │   └── user-profile.types.ts     # Props/Emits interfaces
    │
    ├── containers/
    │   └── UserProfileContainer.vue  # Smart component
    │
    ├── components/
    │   └── UserProfile/
    │       ├── index.ts              # Export presenter
    │       ├── UserProfile.vue       # Main presenter (dumb)
    │       ├── UserAvatar.vue        # Sub-presenter
    │       ├── UserBio.vue           # Sub-presenter
    │       ├── UserEditForm.vue      # Sub-presenter (editing UI)
    │       └── UserProfile.test.ts   # Presenter tests
    │
    ├── composables/
    │   └── useUserProfile.ts         # Shared logic (if needed)
    │
    └── UserProfile.vue               # Page component (routes to container)
```

## Summary

**Container/Presenter splits:**
- **Containers** = smart, manage data/state, rarely reused
- **Presenters** = dumb, receive props, emit events, highly reusable
- **Clear boundary** = data down, events up, no crossing
- **Testable** = presenters test easily, containers test data flow
- **Scalable** = reuse presenters across many features with different containers
- **Aligned with atomic design** = atoms/molecules are presenters, pages use containers

This pattern scales from small components to large feature sets without refactoring.
