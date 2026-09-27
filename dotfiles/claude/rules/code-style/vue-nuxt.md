---
paths:
  - "**/*.vue"
  - "**/nuxt.config.*"
  - "**/app.config.*"
  - "**/{composables,server,middleware,plugins,layers,modules}/**/*.{ts,mts,js,mjs}"
  - "**/src/{module,runtime/**/*}.ts"
---

# Code style: Vue and Nuxt

## Components

- Block order: `<script setup lang="ts">`, then `<template>`, then `<style scoped>` (if any). Composition API with `<script setup>` only; no Options API.
- Type props with `defineProps<{ … }>()` and use reactive destructuring with defaults: `const { size = 'md' } = defineProps<…>()`. Type emits with `defineEmits<{ select: [id: string] }>()`. Use `defineModel()` for v-model.
- Components are PascalCase files. Singletons that appear once per app take a `The` prefix (`TheSiteHeader.vue`). Group by feature in subfolders (`components/admin/PostForm.vue` becomes `<AdminPostForm>`).
- Use `.client.vue` / `.server.vue` suffixes for render-mode-specific components. Prefer server components for static, heavy markup.
- Templates stay declarative. Anything beyond one expression becomes a `computed` or a named function in `<script setup>`. Name handlers for what they do (`navigateToRepo`), not `handleClick`.
- Use semantic HTML and real accessibility: `<button type="button">`, `aria-label` on icon-only controls, `sr-only` text, `motion-safe:` for animation.

## Composables

- One domain per file in `composables/<domain>.ts`, exporting `useX()` functions: `composables/repos.ts` → `useRepos()`. A non-reactive helper belongs in `utils/`, not `composables/`.
- Accept `MaybeRefOrGetter<T>` (or plain getters `() => T`) as input and read it with `toValue()` inside `computed`/`watch`, so callers can pass refs, getters or plain values.
- Return refs, or an object of refs and functions. Never return a `reactive()` that callers would destructure.
- Wrap data fetching in domain composables (`useRepos()` around `useFetch('/api/repos', …)`) instead of repeating `useFetch` options across pages. Always give a `default` factory so `data` is never `undefined` in templates.
- Clean up everything you start: `watch` stop handles and listeners go in `onScopeDispose`/`onBeforeUnmount`.
- SSR safety:
  - No module-level mutable state that could leak between requests. Use `useState(key, init)` for shared state.
  - Guard browser-only code with `import.meta.client` or `onMounted`.
  - Use `import.meta.dev`/`import.meta.server` for build-time branches.
  - Call composables synchronously in setup, before any `await`.
- Rely on auto-imports inside a Nuxt app (don't import `ref`, `computed`, `useFetch`, …). In modules, runtime code and libraries, import explicitly from `vue`/`#imports`/`nuxt/app`.

## Nuxt app structure (Nuxt 4 `app/` layout)

```
app/{app.vue,error.vue,components/,composables/,pages/,layouts/,middleware/,plugins/,utils/}
server/{api/,routes/,middleware/,plugins/,tasks/,utils/}
shared/{types/,utils/}   # code used by both app and server
modules/                 # local modules for project-specific build logic
```

- Server handlers: `server/api/<resource>/[id].<method>.ts` → `export default defineEventHandler(async (event) => { … })`.
  - Validate params and body first (`getValidatedRouterParams`/`readValidatedBody` with a schema).
  - Throw `createError({ statusCode, message })` with a sentence-case message.
  - Return plain data.
- Shared server logic lives in `server/utils/<domain>.ts` (auto-imported), as small verb-named functions. Handlers stay thin.
- `runtimeConfig`: declare every key with an empty default, fill it from `NUXT_*` env vars, and put public values under `public`.
- Keep `nuxt.config.ts` declarative. When logic grows, move it into a local module in `modules/`.

## Nuxt modules

```
src/module.ts                      # defineNuxtModule: meta, defaults, setup
src/runtime/{plugins,composables,components,server}/…
playground/                        # manual testing app
test/                              # fixtures + e2e via @nuxt/test-utils
```

- `defineNuxtModule<ModuleOptions>({ meta: { name, configKey }, defaults, setup(options, nuxt) {} })`. `export interface ModuleOptions` sits at the top with JSDoc per option.
- Resolve runtime paths with `createResolver(import.meta.url)`. Register through kit helpers (`addPlugin`, `addServerPlugin`, `addImports`, `addComponent`, `addTemplate`/`addTypeTemplate`, `addBuildPlugin`) rather than mutating `nuxt.options` by hand.
- Respect layers (`nuxt.options._layers`) and aliases (`resolveAlias`) when scanning directories. Generate types for anything you auto-import. Update templates on `builder:watch` for the files you own.
- Bail out early for unsupported modes (`if (nuxt.options._prepare) return`, dev-only features behind `nuxt.options.dev`).
- Build-time code transforms use `unplugin` + `magic-string` with sourcemaps, filtered to the ids you care about.

## Styling

- Use utility CSS (UnoCSS/Tailwind) in templates, with theme tokens defined once in config. Use scoped `<style>` only for what utilities can't express.
