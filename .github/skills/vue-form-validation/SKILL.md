---
name: "vue-form-validation"
description: "Form state management, validation strategies (client + server), error handling, submission flow, and accessible form patterns for Vue 3"
confidence: "medium"
---

# Vue Form Validation

Standardized approach to form handling in Vue 3: state management, client-side validation, server-side error handling, and submission flow. Focuses on user experience and accessibility.

## Guiding Principles

1. **Validation happens in layers** — Client-side (UX), server-side (security), API response (sync)
2. **State is centralized** — All form data, errors, and state in one place (container component)
3. **Feedback is immediate** — Validate on blur, show errors as user types after first submission
4. **Errors are clear** — Specific messages, not generic
5. **Submission is protected** — Disable button during submit, prevent double-submit
6. **Accessibility first** — ARIA attributes, label associations, error messages linked to fields
7. **Server errors override client** — API response is source of truth for validation

## Form State Management

### Container Component Pattern

**The container manages ALL form state:**

```typescript
// containers/ContactFormContainer.vue
<template>
  <ContactForm
    :formData="formData"
    :errors="errors"
    :isSubmitting="isSubmitting"
    :touchedFields="touchedFields"
    @input="handleInput"
    @blur="handleBlur"
    @submit="handleSubmit"
  />
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useNotificationStore } from '@/stores/notifications'
import { api } from '@/services/api'
import ContactForm from './ContactForm.vue'
import type { ContactFormData } from './types'

// ===== FORM STATE =====
const formData = ref<ContactFormData>({
  name: '',
  email: '',
  subject: '',
  message: '',
})

// ===== VALIDATION STATE =====
const errors = ref<Record<string, string>>({})
const touchedFields = ref<Record<string, boolean>>({})
const isSubmitting = ref(false)

// ===== VALIDATION RULES =====
const validationRules = {
  name: [
    { test: (v: string) => v.trim() !== '', message: 'Name is required' },
    { test: (v: string) => v.trim().length >= 2, message: 'Name must be at least 2 characters' },
  ],
  email: [
    { test: (v: string) => v !== '', message: 'Email is required' },
    {
      test: (v: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v),
      message: 'Enter a valid email address',
    },
  ],
  subject: [
    { test: (v: string) => v.trim() !== '', message: 'Subject is required' },
    { test: (v: string) => v.trim().length >= 3, message: 'Subject must be at least 3 characters' },
  ],
  message: [
    { test: (v: string) => v.trim() !== '', message: 'Message is required' },
    { test: (v: string) => v.trim().length >= 10, message: 'Message must be at least 10 characters' },
  ],
}

// ===== VALIDATION LOGIC =====
const validateField = (field: keyof ContactFormData): string | null => {
  const value = formData.value[field]
  const rules = validationRules[field]

  for (const rule of rules) {
    if (!rule.test(value)) {
      return rule.message
    }
  }

  return null
}

const validateForm = (): boolean => {
  errors.value = {}
  let isValid = true

  for (const field in validationRules) {
    const error = validateField(field as keyof ContactFormData)
    if (error) {
      errors.value[field] = error
      isValid = false
    }
  }

  return isValid
}

// ===== HANDLERS =====
const handleInput = (field: keyof ContactFormData, value: string) => {
  formData.value[field] = value

  // Validate on change only if field was already touched
  if (touchedFields.value[field]) {
    const error = validateField(field)
    if (error) {
      errors.value[field] = error
    } else {
      delete errors.value[field]
    }
  }
}

const handleBlur = (field: keyof ContactFormData) => {
  touchedFields.value[field] = true

  // Validate on blur
  const error = validateField(field)
  if (error) {
    errors.value[field] = error
  } else {
    delete errors.value[field]
  }
}

const handleSubmit = async () => {
  // Validate entire form
  if (!validateForm()) {
    return
  }

  isSubmitting.value = true
  const notificationStore = useNotificationStore()

  try {
    // Submit to API
    await api.post('/contact', formData.value)

    // Success
    notificationStore.addNotification({
      type: 'success',
      message: 'Message sent successfully!',
    })

    // Reset form
    formData.value = { name: '', email: '', subject: '', message: '' }
    errors.value = {}
    touchedFields.value = {}
  } catch (err) {
    // Handle API errors
    if (err instanceof AxiosError && err.response?.status === 422) {
      // Server validation errors
      errors.value = err.response.data.errors
    } else {
      // Generic error
      notificationStore.addNotification({
        type: 'error',
        message: 'Failed to send message. Please try again.',
      })
    }
  } finally {
    isSubmitting.value = false
  }
}
</script>
```

### Presenter Component

**The presenter receives everything and emits events:**

```typescript
// components/ContactForm/ContactForm.vue
<template>
  <form @submit.prevent="$emit('submit')" class="contact-form">
    <FormField
      id="name"
      label="Your Name"
      :model-value="formData.name"
      :error="errors.name"
      required
      @update:model-value="$emit('input', 'name', $event)"
      @blur="$emit('blur', 'name')"
    />

    <FormField
      id="email"
      label="Email Address"
      type="email"
      :model-value="formData.email"
      :error="errors.email"
      required
      @update:model-value="$emit('input', 'email', $event)"
      @blur="$emit('blur', 'email')"
    />

    <FormField
      id="subject"
      label="Subject"
      :model-value="formData.subject"
      :error="errors.subject"
      required
      @update:model-value="$emit('input', 'subject', $event)"
      @blur="$emit('blur', 'subject')"
    />

    <FormField
      id="message"
      label="Message"
      :model-value="formData.message"
      :error="errors.message"
      required
      is-textarea
      @update:model-value="$emit('input', 'message', $event)"
      @blur="$emit('blur', 'message')"
    />

    <div class="contact-form__actions">
      <button
        type="submit"
        class="button button--primary"
        :disabled="isSubmitting || hasErrors"
      >
        <span v-if="isSubmitting" class="spinner" aria-hidden="true" />
        {{ isSubmitting ? 'Sending...' : 'Send Message' }}
      </button>
    </div>
  </form>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import FormField from '@/components/molecules/FormField/FormField.vue'
import type { ContactFormData } from '../types'

interface Props {
  formData: ContactFormData
  errors?: Record<string, string>
  isSubmitting?: boolean
  touchedFields?: Record<string, boolean>
}

withDefaults(defineProps<Props>(), {
  errors: () => ({}),
  isSubmitting: false,
  touchedFields: () => ({}),
})

defineEmits<{
  (e: 'input', field: keyof ContactFormData, value: string): void
  (e: 'blur', field: keyof ContactFormData): void
  (e: 'submit'): void
}>()

const hasErrors = computed(() => Object.keys(errors).length > 0)
</script>

<style scoped>
.contact-form {
  display: flex;
  flex-direction: column;
  gap: var(--spacing-4);
}

.contact-form__actions {
  display: flex;
  gap: var(--spacing-2);
  justify-content: flex-start;
  margin-top: var(--spacing-4);
}

.button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.spinner {
  display: inline-block;
  width: 1em;
  height: 1em;
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

## Validation Strategies

### Client-Side Validation (UX Only)

**Use for immediate feedback, not security:**

```typescript
// Validation rules are pure functions
const rules = {
  email: (v: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v),
  password: (v: string) => v.length >= 8,
  age: (v: number) => v >= 18,
}

// Validate on blur and change (after first touch)
const validateOnBlur = (field: string) => {
  // Always validate on blur
}

const validateOnChange = (field: string) => {
  // Only validate on change if field was already touched
  if (!touchedFields[field]) return
}
```

**✅ DO validate on client:**
- Required fields
- Email format
- Password strength
- Field length
- Pattern matching

**❌ DON'T rely on client for:**
- Username availability (check server)
- Email existence (check server)
- Permission checks (check server)
- Business logic (check server)

### Server-Side Validation (Security)

**Server is the source of truth:**

```typescript
// Backend validation (always happens, regardless of client)
POST /api/contact {
  "name": "John",
  "email": "invalid"  // Client can't check this
}

// Response
422 Unprocessable Entity
{
  "errors": {
    "email": "Email address is already registered",
    "name": "Name contains inappropriate content"
  }
}
```

**Container handles server errors:**

```typescript
const handleSubmit = async () => {
  if (!validateForm()) return  // Client validation

  try {
    await api.post('/contact', formData.value)
    // Success
  } catch (err) {
    if (err.response?.status === 422) {
      // Server validation errors
      errors.value = {
        ...errors.value,
        ...err.response.data.errors,
      }
    }
  }
}
```

## Error Display Pattern

### Before First Submission

```typescript
// ✅ Only show errors for touched fields
if (touchedFields[field]) {
  // Show error
} else {
  // Don't show error (reduce noise)
}
```

### During/After Submission

```typescript
// ✅ Show all errors when submitting
const handleSubmit = async () => {
  if (!validateForm()) {
    // Mark all fields as touched so all errors show
    Object.keys(formData).forEach(field => {
      touchedFields[field] = true
    })
    return
  }

  // Submit...
}
```

### Field-Level Error Display

```vue
<template>
  <!-- Error shows only if touched AND has error -->
  <p v-if="touchedFields[field] && errors[field]" class="error">
    {{ errors[field] }}
  </p>

  <!-- Hint always shows -->
  <p v-if="hint" class="hint">{{ hint }}</p>
</template>
```

## Async Validation

**Validate fields that need server checks:**

```typescript
import { debounce } from 'lodash-es'

// ===== ASYNC VALIDATION =====
const asyncErrors = ref<Record<string, string>>({})
const isCheckingUsername = ref(false)

const checkUsernameAvailable = debounce(async (username: string) => {
  if (!username) {
    delete asyncErrors.value.username
    return
  }

  isCheckingUsername.value = true
  try {
    const response = await api.post('/check-username', { username })
    if (!response.data.available) {
      asyncErrors.value.username = 'Username is already taken'
    } else {
      delete asyncErrors.value.username
    }
  } finally {
    isCheckingUsername.value = false
  }
}, 300)

// ===== HANDLER =====
const handleUsernameChange = (username: string) => {
  formData.value.username = username

  // Sync validation first
  const syncError = validateField('username')
  if (syncError) {
    errors.value.username = syncError
    return
  }

  // Then async validation if sync passed
  delete errors.value.username
  checkUsernameAvailable(username)
}
```

**In template:**

```vue
<FormField
  id="username"
  label="Username"
  :model-value="formData.username"
  :error="errors.username || asyncErrors.username"
  :hint="isCheckingUsername ? 'Checking availability...' : ''"
  @update:model-value="handleUsernameChange"
/>
```

## Multi-Step Forms

### State Management for Wizard

```typescript
// Store current step
const currentStep = ref(1)
const totalSteps = 3

// Validate by step
const steps = {
  1: ['email', 'password'],
  2: ['firstName', 'lastName'],
  3: ['address', 'city', 'zipCode'],
}

const validateStep = (step: number): boolean => {
  errors.value = {}
  const fieldsInStep = steps[step]

  for (const field of fieldsInStep) {
    const error = validateField(field)
    if (error) {
      errors.value[field] = error
    }
  }

  return Object.keys(errors.value).length === 0
}

const handleNext = () => {
  if (!validateStep(currentStep.value)) return
  currentStep.value++
}

const handlePrevious = () => {
  currentStep.value--
}

const handleSubmit = async () => {
  if (!validateStep(currentStep.value)) return
  // Submit form...
}
```

## Form Reset Pattern

```typescript
// ===== INITIAL STATE =====
const initialFormData = {
  name: '',
  email: '',
  message: '',
}

// ===== FORM STATE =====
const formData = ref({ ...initialFormData })

// ===== RESET =====
const resetForm = () => {
  formData.value = { ...initialFormData }
  errors.value = {}
  touchedFields.value = {}
}

// ===== CHECK IF DIRTY =====
const isDirty = computed(() => {
  return JSON.stringify(formData.value) !== JSON.stringify(initialFormData)
})

// Use isDirty to warn on leave:
// window.addEventListener('beforeunload', (e) => {
//   if (isDirty.value) {
//     e.preventDefault()
//   }
// })
```

## Testing Forms

### Testing Validation

```typescript
import { render, screen } from '@testing-library/vue'
import userEvent from '@testing-library/user-event'
import ContactFormContainer from './ContactFormContainer.vue'

it('shows error when email is invalid', async () => {
  const user = userEvent.setup()
  render(ContactFormContainer)

  const emailInput = screen.getByLabelText('Email Address')

  await user.type(emailInput, 'invalid-email')
  await user.click(screen.getByText('Send Message'))

  expect(screen.getByText('Enter a valid email address')).toBeInTheDocument()
})

it('submits form with valid data', async () => {
  const user = userEvent.setup()
  render(ContactFormContainer)

  await user.type(screen.getByLabelText('Your Name'), 'John Doe')
  await user.type(screen.getByLabelText('Email Address'), 'john@example.com')
  await user.type(screen.getByLabelText('Subject'), 'Hello')
  await user.type(screen.getByLabelText('Message'), 'This is a test message')

  await user.click(screen.getByText('Send Message'))

  await waitFor(() => {
    expect(screen.getByText('Message sent successfully!')).toBeInTheDocument()
  })
})
```

## Accessibility Checklist

- [ ] Each input has `<label>` with `for` attribute
- [ ] Error messages have unique `id` and linked to input via `aria-describedby`
- [ ] Invalid inputs have `aria-invalid="true"`
- [ ] Required fields marked with `required` and `aria-required="true"`
- [ ] Form errors announced to screen readers
- [ ] Submit button disabled during submission (prevents double-submit)
- [ ] Keyboard navigation works (Tab to fields, Enter to submit)
- [ ] Error messages clear and specific
- [ ] Hint text has `aria-describedby` linking to help text

## Anti-Patterns

### ❌ Don't: Validate on Every Keystroke

```typescript
// WRONG — too much feedback
<input
  @input="validateField"  // Fires on every keystroke
/>

// RIGHT — validate on blur, then on change after touch
<input
  @blur="handleBlur"      // Validate once on blur
  @input="handleInput"    // Validate on change after touch
/>
```

### ❌ Don't: Show Errors Before User Interaction

```typescript
// WRONG
<p v-if="errors.name">{{ errors.name }}</p>  <!-- Shows immediately -->

// RIGHT
<p v-if="touchedFields.name && errors.name">
  {{ errors.name }}
</p>
```

### ❌ Don't: Trust Client Validation Alone

```typescript
// WRONG — security hole
if (validateClientSide()) {
  submitForm()  // Assumes form is valid
}

// RIGHT — server validates too
try {
  await api.post('/form', data)  // Server validates
} catch (err) {
  // Handle server validation errors
}
```

### ❌ Don't: Generic Error Messages

```typescript
// WRONG
errors.name = 'Invalid'

// RIGHT
errors.name = 'Name must be at least 2 characters'
```

## Best Practices Checklist

- [ ] Form state centralized in container
- [ ] Presenter receives all data as props
- [ ] Validation rules are pure functions
- [ ] Errors only show for touched fields (until submit)
- [ ] All fields validated on submit before sending
- [ ] Server errors override client errors
- [ ] Loading state during submission
- [ ] Submit button disabled during submission
- [ ] Form resets on successful submission
- [ ] Async validation uses debouncing
- [ ] Error messages are specific and helpful
- [ ] Accessibility attributes present (labels, aria-invalid, etc.)
- [ ] Tests cover validation and submission
- [ ] Multi-step forms validate by step
- [ ] Warn on page leave if form is dirty

## Summary

**This pattern gives you:**
- ✅ Clear separation (container manages state, presenter displays)
- ✅ Progressive enhancement (immediate client feedback + server validation)
- ✅ Good UX (errors shown at right time, helpful messages)
- ✅ Accessibility (labels, error linking, keyboard navigation)
- ✅ Security (server validation, not client-only)
- ✅ Testability (validation logic is pure functions)
- ✅ Scalability (works for simple forms and complex wizards)
