---
paths:
  - "**/package.json"
  - "**/pnpm-workspace.yaml"
  - "**/{tsconfig,tsdown.config,eslint.config,knip}.*"
  - "**/.github/workflows/*.{yml,yaml}"
  - "**/.changeset/*"
---

# Code style: project setup, packaging, CI

## Layout

- Use pnpm workspaces. A single library can be a flat repo with a `playground/`. Anything with docs or several packages becomes a monorepo:
  ```
  packages/<name>/   # published packages
  docs/              # docs site (Starlight)
  playground/        # manual testing app, wired via workspace:*
  ```
- The root `package.json` is private and named `<name>-monorepo`, holding shared dev tooling and scripts only.
- Pin the runtime and package manager with `devEngines` (`onFail: "download"`) and target the current Node LTS.

## package.json

- `"type": "module"`, `"sideEffects": false`, `"license": "MIT"`, and `author`, `repository` (with `directory` in monorepos), `homepage`, `bugs`, `keywords`.
- `exports` map only (including `"./package.json"`), never `main`. For built packages, point `exports` at `src/*.ts` during dev and override with `publishConfig.exports` → `dist/*.mjs`, publishing only `"files": ["dist"]`.
- Framework packages go in `peerDependencies` with a `>=` floor. Keep `dependencies` minimal.
- Scripts: `build`, `dev`, `lint`, `test`, plus `test:unit`/`test:types`/`test:knip` in libraries and `format` in Prettier-based repos.

## Tooling

- Build: `tsdown` (ESM only, `dts`, `publint: true`, `attw` with `profile: 'esm-only'`).
- Types: `tsc --noEmit` in CI with strict flags (`strict`, `noUncheckedIndexedAccess`, `noImplicitOverride`, `verbatimModuleSyntax`, `moduleResolution: bundler`/`module: preserve`).
- Lint: ESLint flat config (`typescript-eslint` strict type-checked + `unicorn` + import ordering, e.g. `@antfu/eslint-config`), run with `--max-warnings=0` in CI.
- Dead code: `knip` in CI. Commit hooks: `simple-git-hooks` + `nano-staged`/`lint-staged` running `eslint --fix` on staged files.
- Versioning: Changesets (`.changeset/*.md`, with a user-facing, past-tense summary of the change) or changelogen driven by Conventional Commits. Pick one per repo.
- Dependency updates: Renovate.

## CI (GitHub Actions)

- Top-level `permissions: contents: read`. Grant more per job only when needed.
- Pin actions to a full commit SHA with a version comment: `uses: actions/checkout@<sha> # v5`.
- Use separate `lint` and `test` jobs. Short step names with an emoji prefix are fine (`📦 Install dependencies`, `🧪 Test project`).
- Triggers: `pull_request`, `push` to `main`, `merge_group`.
- Publish with npm provenance / trusted publishing. Set up `pkg-pr-new` for preview releases on PRs.
- Add an autofix workflow (lint `--fix` + format) instead of failing PRs over style.
