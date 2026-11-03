---
name: form-handling
description: form standards for Vue/Nuxt — VeeValidate with schema validation (Yup in existing code, Zod for new), accessible error handling, atom/organism split, submitting via TanStack Query mutations, server error mapping. Load when building, migrating, reviewing or testing forms.
---

# Form handling

## Validation library
- **Existing projects:** VeeValidate + **Yup**. Leave working forms on Yup.
- **New code:** VeeValidate + **Zod** (stronger TS inference; schemas can be shared with Zod validation in server routes, see `nuxt-project-patterns`).
- **Never mix Yup and Zod in the same form.** Migrate opportunistically, a form at a time when already touching it; no big-bang rewrite.

Adapter API depends on the installed `vee-validate` version. Historically schemas were wrapped with `toTypedSchema` from `@vee-validate/zod` or `@vee-validate/yup`; newer versions may accept Standard Schema libraries directly. **Check the installed version's docs** (`pnpm why vee-validate`) before writing or copying the wiring; do not assume one API.

```ts
// Adapter-based wiring; verify against the installed version
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { z } from 'zod'

const schema = z.object({ email: z.string().email(), name: z.string().min(1) })
const { handleSubmit, errors, setErrors } = useForm({
  validationSchema: toTypedSchema(schema),
})
```

## Accessibility
Baseline rules: `frontend-a11y-check`. Form-specific decisions:
- Every field has a **visible `<label>`** (a placeholder is not a label).
- Invalid field: `aria-invalid="true"` and `aria-describedby` pointing at its error element (plus hint, if any).
- Error text says what is wrong and how to fix it; never convey errors by colour alone (add icon and text).
- On failed submit, render an **error summary** (heading + links to each invalid field) and move focus to it. Each link focuses its field.
- **Never clear user input** on error.
- Set `autocomplete` tokens (`email`, `given-name`, `current-password`, `new-password`, ...) on personal-data fields.
- Use native input types and `inputmode`; mark required fields in text, not only `*`.

## Component split
See `atomic-components-design` and `nuxt-project-patterns`.
- Input atoms (`BaseInput`, `BaseSelect`) are presentational: they take `modelValue`, `label`, `error`, `hint`, wire ids/ARIA, and emit. No VeeValidate, no schema, no fetching.
- The **form organism** owns the schema, `useForm` and form state. It emits `submit` with the validated values and never touches queries, mutations or stores.
- The **page** owns the TanStack Query mutation, `isPending` and server-error mapping. It passes `isPending` and server `errors` down as props; the organism applies them to the form.

## Submitting
The page runs the mutation (composable from `nuxt-project-patterns`, not a raw axios call) and maps the server error to field errors.
The schema and its inferred type live in a shared file. Both the organism and the page import from it (Nuxt does not auto-import types, and importing types out of a `.vue` file is awkward). The server route can reuse the same schema for validation, see `nuxt-project-patterns`.
```ts
// schemas/signup.ts
import { z } from 'zod'

export const signupSchema = z.object({ email: z.string().email() })
export type SignupValues = z.infer<typeof signupSchema>
```
```vue
<!-- pages/signup.vue -->
<template>
  <SignupForm :pending="isPending" :server-errors="serverErrors" :summary-error="summaryError" @submit="onSubmit" />
</template>

<script setup lang="ts">
import type { SignupValues } from '~/schemas/signup'
import type { ApiError } from '~/types/api' // defined in api-client-patterns

const { mutateAsync, isPending } = useCreateAccount()
const serverErrors = ref<Record<string, string>>({})
const summaryError = ref('')

async function onSubmit(values: SignupValues) {
  serverErrors.value = {}
  summaryError.value = ''
  try {
    await mutateAsync(values)
  } catch (e) {
    const err = e as ApiError // normalised by the axios interceptor (api-client-patterns)
    if (err.fieldErrors) {
      // first message per field; server field names must match form field names
      serverErrors.value = Object.fromEntries(
        Object.entries(err.fieldErrors).map(([field, messages]) => [field, messages[0] ?? '']),
      )
    } else {
      summaryError.value = 'Something went wrong. Try again.'
    }
  }
}
</script>
```
The organism validates, emits, and applies the props. The example omits the full error summary (heading, links to each invalid field, focus moved on failed submit) for brevity; it must be implemented per the Accessibility section.
```vue
<!-- components/organisms/SignupForm.vue -->
<template>
  <form novalidate @submit.prevent="onSubmit">
    <p v-if="summaryError" role="alert">{{ summaryError }}</p>
    <BaseInput v-model="email" label="Email" type="email" autocomplete="email" :error="errors.email" />
    <button type="submit" :disabled="pending">Create account</button>
  </form>
</template>

<script setup lang="ts">
import { useForm } from 'vee-validate'
import { toTypedSchema } from '@vee-validate/zod'
import { signupSchema, type SignupValues } from '~/schemas/signup'

const props = defineProps<{
  pending: boolean
  serverErrors: Record<string, string>
  summaryError?: string
}>()
const emit = defineEmits<{ submit: [values: SignupValues] }>()

const { handleSubmit, errors, setErrors, defineField } = useForm({
  validationSchema: toTypedSchema(signupSchema),
})
const [email] = defineField('email')

watch(() => props.serverErrors, (e) => setErrors(e))

const onSubmit = handleSubmit((values) => {
  if (props.pending) return
  emit('submit', values)
})
</script>
```
- Prevent double submit: `:disabled="props.pending"` on the submit button (use `aria-disabled` plus a guard if focus must stay on it) and guard in the handler too.
- **Map server errors back to fields**: the page extracts them, the organism calls `setErrors`. Use the same schema on the server route so client and server agree. Errors not tied to a field go in the summary. The normalised `ApiError` shape comes from `api-client-patterns`; the mapping from server field names to form field names is illustrative and project-specific, so check it.
- Server 400s from validation are expected; don't log them as bugs.

## Testing
See `frontend-testing`: submit invalid data and assert the error summary, `aria-invalid` and focus via roles/labels; keep an axe scan on the form in e2e.
