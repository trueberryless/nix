# Dependencies, package.json and TypeScript config

## Dependencies

1. Update every dependency, devDependency and peerDependency in all `package.json` files to the latest version (`npm view <pkg> version`).
2. Read the release notes / migration guides for every major or breaking bump and apply them — Astro upgrade guide (`withastro/docs` → `src/content/docs/en/guides/upgrade-to/v<N>.mdx`), Starlight `packages/starlight/CHANGELOG.md` since the currently supported version, Changesets, Vite, Zod. The raw files on `raw.githubusercontent.com` or the npm tarballs (`npm pack <pkg>`) are the quickest sources.
   - Known facts: Starlight ≥ 0.42 requires Astro ≥ 7.2.10 and ships compiled JS + `.d.ts` — no TS sources, no `StarlightLocals` export, no typings for `virtual:starlight/*`. Astro 7 uses Vite 8, the Rust compiler and Sätteri as default Markdown processor.
3. Root `package.json`: `"packageManager": "pnpm@11.28.0"`; remove `packageManager` from nested packages. Keep the field (the `pnpm/action-setup` workflows read it). Reinstall with that pnpm version (`COREPACK_ENABLE_DOWNLOAD_PROMPT=0 pnpm install`) so the lockfile matches.
4. Peer dependencies: only `@astrojs/starlight`, as `>=<latest minor you tested>` (e.g. `>=0.42.0`). `@astrojs/starlight` and `astro` go into the plugin's `devDependencies`.
5. Replace deprecated packages (`npm view <pkg> deprecated`). Known: `starlight-contributor-list` → `astro-contributors` (drop-in, same `ContributorList` export).
6. Drop dependencies that a few lines of code can replace (e.g. `change-case` used for a fixed set of strings → a lookup table).
7. `typescript@^6`, not 7 — `@astrojs/check` does not support TypeScript 7 yet.
8. `engines.node`: `>=22.12.0` (Astro 7 minimum) everywhere.
9. `pnpm peers check` must be clean.

## package.json templates

Field order matters for consistency; adapt name, description and keywords.

### Plugin — `packages/<plugin>/package.json`

```json
{
  "name": "<plugin>",
  "version": "<unchanged>",
  "license": "MIT",
  "description": "Starlight plugin to …",
  "author": "trueberryless <trueberryless@gmail.com> (https://felixs.dev)",
  "type": "module",
  "exports": {
    ".": "./index.ts",
    "./package.json": "./package.json"
  },
  "dependencies": {},
  "devDependencies": {
    "@astrojs/starlight": "^x",
    "astro": "^x"
  },
  "peerDependencies": {
    "@astrojs/starlight": ">=x"
  },
  "engines": {
    "node": ">=22.12.0"
  },
  "publishConfig": {
    "access": "public"
  },
  "sideEffects": false,
  "keywords": ["starlight", "plugin", "…", "documentation", "astro", "withastro", "astro-integration"],
  "homepage": "https://<project>.netlify.app",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/trueberryless/<repo>.git",
    "directory": "packages/<plugin>"
  },
  "bugs": "https://github.com/trueberryless/<repo>/issues"
}
```

- Copy the root `LICENSE` into the plugin package so npm publishes it.
- No `scripts` in the plugin package.

### Docs — `docs/package.json`

Same metadata fields, plus `"private": true`, description `Documentation for the <Name> plugin.`, `repository.directory: "docs"`, scripts `astro`, `build`, `dev`, `preview`, `start`, dependencies sorted alphabetically, no `devDependencies`.

### Root — `package.json`

Name `<repo>-monorepo`, version `0.0.0`, `"private": true`, same metadata without `directory`, and:

```json
{
  "scripts": {
    "build": "pnpm --filter <docs-package> build",
    "check": "pnpm --filter <docs-package> astro sync && astro check --noSync",
    "dev": "pnpm --filter <docs-package> dev",
    "format": "prettier . --write --cache --ignore-unknown",
    "version": "pnpm changeset version && pnpm i --no-frozen-lockfile"
  }
}
```

Root devDependencies: `@astrojs/check`, `astro`, `typescript@^6`, `@changesets/cli`, `@changesets/changelog-github`, `prettier` and its plugins.

### Changesets config

Bump `$schema` in `.changeset/config.json` to the current `@changesets/config` major. Changesets 3 no longer versions private packages by default and `changeset version` exits 1 when nothing is pending — keep the existing release workflow but mention it in the summary.

## TypeScript config at the repo root (like starlight-blog)

Root `tsconfig.json`:

```json
{
  "extends": "astro/tsconfigs/strictest",
  "include": ["docs/.astro/types.d.ts", "**/*"],
  "exclude": ["**/dist"]
}
```

`docs/tsconfig.json`:

```json
{
  "extends": "../tsconfig.json"
}
```

Delete the plugin's own `tsconfig.json`, and its `.npmignore` if that only listed `tsconfig.json`. `astro` must be a root devDependency so `astro/tsconfigs/strictest` resolves. Confirm `pnpm check` really type-checks both packages by temporarily adding a deliberate type error in each and seeing both reported.
