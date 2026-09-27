---
paths:
  - "**/*.{ts,mts,cts,tsx,js,mjs,cjs,jsx,vue,astro}"
---

# Code style: TypeScript core

A repo's own formatter, linter and existing conventions always win over this file. Match the surrounding code first; apply these defaults where the repo is silent or the code is new.

## Formatting defaults

- No semicolons, single quotes, 2-space indent, trailing commas in multiline literals, ~120 columns.
- `} else {` on one line, but prefer an early return over `else`.
- A guard clause may be one line without braces: `if (!entry) return`. Anything longer gets braces.
- Separate the logical steps of a function with single blank lines: compute, then act, then return.

## Imports

- Order: `node:` builtins, then external packages, then local modules. Blank line between groups, alphabetical within. Always use the `node:` prefix.
- `import type` for anything used only as a type (`verbatimModuleSyntax` is on).
- Named exports everywhere. Use a default export only where a tool requires one: config files, plugin/module/integration entry points, route/event handlers.
- No barrel `index.ts` files that only re-export internals. A package's public entry file re-exports its public types explicitly: `export type { FooOptions } from './libs/config'`.

## Naming

- Functions start with a verb that states the effect: `get`/`set`/`update`/`clear`, `is`/`has`/`should` (return boolean), `ensure`/`strip`/`normalize` (return a transformed copy), `resolve`, `parse`/`format`/`serialize`, `validate` (throws or asserts), `create`/`define` (factories), `add`/`remove`, `throw…` (returns `never`), `use…` (composables only). Name conversions `aToB`: `pathnameToSlug`.
- Precise over short: `normalizePathnameWithBase`, not `normPath`. Single-letter names only in tiny callbacks (`(r) => r.id`) and for `s` (MagicString) or `e`/`error` in catches.
- Booleans read as questions: `isMultilingual`, `hasAuthors`, `configIncludesRssSocial`.
- Module-level constants and regexes use `SCREAMING_SNAKE_CASE`, and regexes take a `_RE` suffix: `const TRAILING_SLASH_RE = /\/$/`. Hoist regexes to module scope instead of rebuilding them per call.
- Prefix with `_` a raw value that gets normalized into a clean name (`_dirs` → `dirs`, `_key` → `key`), or an internal field on an object users can see.
- Files are kebab-case and named for the concept they own (`path.ts`, `config.ts`, `i18n.ts`, `error.ts`). Avoid a catch-all `utils.ts`; if a helper has no obvious home, the module boundary is wrong.

## Functions and data

- Top-level `function` declarations, not `const fn = () =>`. Arrows are for callbacks and one-line helpers passed inline.
- Keep functions small and pure. Pass dependencies in as arguments (config, logger, context) instead of reaching for globals.
- The options object comes last and is optional: `pushEnvVars(file, envs, options?: PushOptions)`. Past two positional parameters, switch to an object.
- Destructure parameters and props at the top of the function body.
- Use `for…of` for iteration with side effects. Use `map`/`filter`/`some` for pure transforms. Never use `forEach`.
- Use `Map`/`Set` for keyed collections and dedupe. For plain dictionaries, use `Object.create(null)` or a `Map`, never `{}`.
- Use `??`, `??=`, `||=` and optional chaining freely. Compare with `===`, except `== null` when you mean null or undefined.
- Sort object keys, interface fields, union members and props alphabetically wherever order carries no meaning. It makes diffs and scanning trivial.
- Prefer template literals over string concatenation. When generating code, build it from an array of lines joined with `\n`, or append to a `let code = ''`.
- Classes only for stateful wrappers (e.g. test page objects) or when an API demands one. Otherwise use modules of functions.

## Types

- `strict` plus `noUncheckedIndexedAccess`, `noImplicitOverride`, `verbatimModuleSyntax` (and `exactOptionalPropertyTypes` when the stack allows it). Handle the `undefined` from indexing; don't silence it with `!`.
- `interface` for object shapes and `type` for unions, mapped types and aliases. No `enum`: use string-literal unions and `as const` arrays (`const KNOWN_ENVS = ['development', 'preview'] as const`).
- Use `satisfies` to check a literal without widening it. Return `never` from functions that always throw. Use `asserts x is T` for validators.
- Avoid `any`. `unknown` plus narrowing is the default; `any` only in overload implementation signatures and rest args.
- Write explicit return types on exported functions whose inferred type would be unclear or unstable. Let inference handle the rest.
- Derive types from runtime sources instead of duplicating them: `z.input`/`z.output`, `typeof X[number]`, `Parameters<typeof fn>[1]`.

## File layout (top → bottom)

1. Imports
2. Module constants
3. Exported functions: the file's public API, read first
4. Private helpers, in the order they're first used
5. Types and interfaces, plus `declare global` / module augmentation

The exception is the main contract of a public module (e.g. `export interface ModuleOptions`), which may sit right after the imports.

## Options and configuration

- Every user-facing option gets a JSDoc block: what it does, when to change it, `@default`, and `@see` for relevant links.
- Validate user input once, at the boundary (a Zod schema, or asserts), and work with the resolved shape everywhere else. Keep two types: `FooUserOptions` (input, optional fields) and `FooOptions` (resolved, defaults applied).
- Merge defaults with `defu(userOptions, defaults)` or schema `.default()`. Never scatter `?? default` through the codebase.

## Errors and logging

- Throw through one small helper per package that adds consistent context: `throwPluginError(message, hint?): never`.
- Messages are full sentences ending with a period. Wrap identifiers, options and paths in backticks. Say what went wrong, then how to fix it: "It looks like you already have a `SiteTitle` override. Either remove it or render `pkg/components/SiteTitle.astro` from it."
- Use the framework's logger when one exists (Astro `logger`, Nuxt `useLogger`/consola). Otherwise prefix messages with `[package-name]`. No stray `console.log`: only `warn`/`error`, or a CLI's output layer.
- Catch only what you can handle or annotate, then rethrow. Never swallow errors silently.

## Comments

- Comments explain why: a constraint, a spec quirk, a browser bug, a link to the issue. Delete comments that restate the code.
- Write JSDoc on every exported API. Libraries add `@since` and `@see` where useful.
- Inline comments are sentences. Put issue or PR links on their own line under the explanation.
- Don't leave commented-out code. Delete it; git remembers.

## Dependencies

- Prefer platform APIs and `node:` builtins, then small focused ESM packages (`pathe`, `ufo`, `defu`, `mlly`, `magic-string`, `consola`, `picomatch`, `github-slugger`). Every dependency must earn its place. No polyfills for anything the supported runtime already has.
- ESM only (`"type": "module"`), `"sideEffects": false`.

## Git

- Conventional Commits, lowercase, imperative, with code in backticks: `fix(kit): resolve \`@nuxt/*\` types from nuxt's own resolution`, `feat: add \`nonce\` option`. Scope = package name in monorepos.
- Keep each commit or PR to one concern. Refactors go in their own commits, separate from behaviour changes.

## Canonical example

```ts
import { posix } from 'node:path'

import type { AstroConfig } from 'astro'

import type { BlogConfig } from './config'
import { stripLeadingSlash } from './path'

const HTML_EXTENSION = '.html'

export function getEntryUrl(config: BlogConfig, slug: string, options?: EntryUrlOptions): string {
  const base = options?.base ?? '/'
  if (!slug) return base

  const path = posix.join(stripLeadingSlash(config.prefix), slug)

  return options?.withExtension ? `${base}${path}${HTML_EXTENSION}` : ensureTrailingSlash(`${base}${path}`)
}

function ensureTrailingSlash(path: string) {
  return path.endsWith('/') ? path : `${path}/`
}

interface EntryUrlOptions {
  base?: AstroConfig['base']
  withExtension?: boolean
}
```
