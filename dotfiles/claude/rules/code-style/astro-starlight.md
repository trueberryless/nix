---
paths:
  - "**/*.astro"
  - "**/astro.config.*"
  - "**/content.config.*"
  - "**/{libs,overrides,routes}/**/*.ts"
---

# Code style: Astro and Starlight

## Components

- Frontmatter order:
  1. Imports: packages, then local libs, then (after a blank line) sibling components.
  2. `interface Props`.
  3. `const { a, b = default } = Astro.props`.
  4. Minimal derived values.
- Keep logic out of components. Anything non-trivial is an exported function in `libs/<domain>.ts` that the component calls: `const tags = getEntryTags(entry)`. Components render; libs compute and are unit-tested.
- Use a ternary with `null` for either/or branches in templates, and `&&` for optional blocks. Keep expressions short; hoist the rest into frontmatter.
- Use scoped `<style>` at the bottom with package-prefixed class names (`.sl-blog-tags`, `.sl-kbd`) so user CSS can target them safely. Use logical properties (`margin-inline-start`, `padding-block`), theme CSS variables (`var(--sl-color-gray-3)`, `var(--sl-text-sm)`), and `rem` units.
- Add `not-content` to plugin UI rendered inside Markdown content so it doesn't inherit prose styles.
- Translate every UI string with `Astro.locals.t('pluginName.area.key')`. Nothing user-visible is hardcoded.

## Plugin / integration structure

```
packages/<plugin>/
  index.ts          # default export: the plugin factory; re-exports public types
  libs/             # one module per concept: config, path, i18n, error, vite, content…
  components/       # public components users can import
  overrides/        # Starlight component overrides (thin wrappers around components/)
  routes/           # injected routes
  middleware.ts, schema.ts, translations.ts, virtual.d.ts, styles.css
  tests/{unit,e2e}/
docs/               # Starlight docs site for the plugin
```

- A package without a build step may ship TypeScript source directly (`"exports": { ".": "./index.ts" }`), since Astro compiles it.
- Entry shape:

  ```ts
  export default function starlightFooPlugin(userConfig?: StarlightFooUserConfig): StarlightPlugin {
    const config = validateConfig(userConfig)

    return {
      name: 'starlight-foo',
      hooks: {
        'config:setup'({ addIntegration, astroConfig, command, config: starlightConfig, logger, updateConfig }) {
          if (command !== 'dev' && command !== 'build') return
          // …
        },
      },
    }
  }
  ```

- Rename destructured hook params that would be ambiguous: `config: starlightConfig`, `updateConfig: updateStarlightConfig`.
- Before replacing a user's component override, check for an existing one. If found, warn with how to compose it instead of silently overwriting.
- Expose config and project context to runtime code through a Vite virtual module (`virtual:<pkg>/config`) with a matching `virtual.d.ts`. Don't import user config internals.
- Share build-time data between hooks and runtime through a single, typed `globalThis` store with namespaced keys when a module graph boundary forces it, declared via `declare global`.
- Build-only work (validation, reports) is gated on `command === 'build'`.

## Content and config

- Define collections in `content.config.ts` with loaders and Zod schemas. Plugins extend schemas via an exported `xSchema()` helper rather than asking users to copy fields.
- Validate plugin config with `astro/zod`:
  - Give each option a JSDoc description, `@default` and `@see`.
  - Use `.default()`/`.prefault({})` so resolved config is fully populated.
  - On failure, throw an `AstroError` with a hint that includes the issues link.
