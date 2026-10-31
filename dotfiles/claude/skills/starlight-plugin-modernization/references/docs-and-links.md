# Docs, domains and links

## Documentation style

- Follow Starlight's own approach: **document once, then describe how to adapt it.** For example, for component overrides list every overridden component, explain that users with their own override must render the plugin's matching component, and show a single example (e.g. only `TableOfContents`, not also `Pagination`).
- Update docs whenever behavior or config semantics change (e.g. custom image paths are relative to the project root; keep required options such as an alt text in examples).
- Fix typos you come across.

## Domains

The custom domain `trueberryless.org` was removed from all projects.

- `<project>.trueberryless.org` → `<project>.netlify.app` everywhere: `homepage` fields, READMEs, docs, CHANGELOGs.
- Search with a fixed string so `trueberryless-org` (the GitHub org) isn't matched:
  ```sh
  grep -rnF "trueberryless.org" --exclude-dir=node_modules --exclude-dir=.git .
  ```
- Blog links (`blog.trueberryless.org/...`) moved to a different host. Follow the old URL's redirect (`curl -sIL <url>`) and use the final location. Known mapping: `https://blog.trueberryless.org/blog/starlight-customize-toc-additional-content/` → `https://desired-state.leaflet.pub/3mpvkbvkhtc2u`. If the redirect can't be resolved (e.g. network policy), ask the user — a guessed URL was wrong last time.

## Repo-relative links

READMEs, CHANGELOGs and changesets are rendered on npm, where repo-relative links break. Convert every link relative to the repo root (`/LICENSE`, `./src/content/docs/`, `/packages/<plugin>/`) to an absolute GitHub URL:
- files: `https://github.com/trueberryless/<repo>/blob/main/<path>`
- directories: `https://github.com/trueberryless/<repo>/tree/main/<path>`

Links inside docs pages (e.g. `/getting-started/`) are site links — leave them relative.

## READMEs

- Root README: short description, link to the docs site, pointer to the package directory, project structure, license "Copyright © trueberryless." with an absolute LICENSE link.
- Docs README: title `<repo>-docs`, link to the deployed site, how to run locally.
- Plugin README: link to `https://<project>.netlify.app/getting-started/`, absolute LICENSE link.
