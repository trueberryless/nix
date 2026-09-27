---
name: starlight-plugin-modernization
description: Modernize a trueberryless-org Starlight plugin monorepo (pnpm workspace with packages/PLUGIN and a docs/ site) — update Astro/Starlight and all dependencies following release notes, standardize package.json metadata, move tsconfig to the repo root, refactor into HiDeoo/starlight-blog-style small pure functions, add Sätteri + unified Markdown processor support, fix trueberryless.org domains and repo-relative links, and write changesets. Use this whenever the user asks to update, upgrade, modernize, clean up, refactor or "make functional again" one of their Starlight plugins (starlight-*), mentions bumping Astro/Starlight versions in a plugin repo, asks to follow HiDeoo's plugin style, or wants the same refactors applied as in starlight-cooler-credit — even if they only mention one part of it.
---

# Starlight plugin modernization

You are bringing one of trueberryless' Starlight plugin monorepos up to the current standard. The layout is a pnpm workspace with the plugin in `packages/<plugin>/` and a Starlight docs site in `docs/` that also demos the plugin.

## Reference implementations

- **Reference result:** `trueberryless-org/starlight-cooler-credit` on `main` (release v0.7.0). When you are unsure what the finished state looks like, compare with it.
- **Style reference:** HiDeoo's plugins, above all `HiDeoo/starlight-blog` and `HiDeoo/starlight-image-zoom`. The user wants their codebases to read like HiDeoo's because that style is easy to maintain. **When in doubt, do exactly what starlight-blog does.** Read its `packages/starlight-blog/index.ts`, `libs/*.ts`, `locals.d.ts`, `virtual.d.ts`, `package.json`, root `tsconfig.json` and `docs/tsconfig.json` before refactoring. If GitHub is out of scope for your tools, fetch them with `curl -sSL https://raw.githubusercontent.com/HiDeoo/starlight-blog/main/<path>` or `npm pack starlight-blog`.

## Guiding principles (learned the hard way)

These came from the user's corrections on the first repo. They matter more than any individual step.

1. **Preserve behavior unless something is clearly broken.** "Fixes" that change semantics were reverted. Example: localized config keys are matched strictly by the exact language tag (`zh-CN`), never by locale directory keys (`zh-cn`) or case-insensitively — the docs already define this distinction, and the plugin should enforce it, not paper over user mistakes. If you believe existing behavior is wrong, describe it in the summary and let the user decide.
2. **Copy HiDeoo precisely, not approximately.** Half-adopting a pattern (or "improving" it) caused churn. If starlight-blog does it, mirror it — including things a linter hints against, like the `/// <reference path="./locals.d.ts" />` at the top of `index.ts`. Deliberate deviations (HiDeoo's personal `@hideoo/*` configs, `devEngines`) are fine but must be listed in the summary.
3. **Document once, describe the rest.** Docs follow Starlight's own approach: one example, then a sentence explaining how to adapt it for the other cases. Don't add parallel examples.
4. **Never guess URLs.** If a redirect can't be resolved, ask.
5. **No code comments** in the plugin source; function names should carry the meaning instead.

## Workflow

Work on the branch you were given, commit in logical steps, push, and do not open a PR unless asked. If the branch's previous PR was already merged, restart the branch from the latest default branch before new work.

1. **Survey** the repo: all `package.json` files, plugin source, docs content, workflows, `.changeset/`, READMEs, CHANGELOGs. Grep for `trueberryless.org` (fixed string) and repo-relative links.
2. **Dependencies & package manager** → read `references/dependencies-and-packages.md`. Update everything, read every relevant release note, standardize all three `package.json` files, set `packageManager` to `pnpm@11.28.0`.
3. **TypeScript at the root** → also in `references/dependencies-and-packages.md` (root `tsconfig.json`, `docs/tsconfig.json` extends it, single root `pnpm check`).
4. **Code refactor** → read `references/code-style.md`. `libs/` split, Zod 4, own virtual modules instead of Starlight internals, logic out of `.astro` frontmatter into helpers backed by pure functions, types files exactly like starlight-blog, Astro 7 compiler gotchas.
5. **Markdown processors** → if the plugin uses remark/rehype in any way, read `references/markdown-processors.md` and add Sätteri support alongside unified. Skip otherwise.
6. **Docs, domains, links** → read `references/docs-and-links.md`.
7. **Changesets** → read `references/changesets.md`.
8. **Verify** → read `references/verification.md` and run all of it before every push.
9. **Summarize** for the user (format below).

## Final summary format

Report, briefly and concretely:
- Dependency updates, including anything intentionally not updated and why (e.g. TypeScript 6 instead of 7).
- Behavior changes and bug fixes (and suspected bugs you did *not* change).
- Every change inspired by starlight-blog/HiDeoo, and what you deliberately did not copy.
- Links and domains replaced (flag any you could not resolve).
- What you verified and how; anything you could not verify (e.g. network-blocked build steps).
- Open questions for the user.
