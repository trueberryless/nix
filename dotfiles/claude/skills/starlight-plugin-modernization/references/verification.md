# Verification (before every push)

1. `pnpm install`, `pnpm peers check`, `pnpm format`, `pnpm check` → 0 errors.
2. `pnpm build`. Docs plugins sometimes fetch data at build time (e.g. `@trueberryless-org/starlight-plugins-docs-components` loads a gist). If that fails because of the sandbox network policy, temporarily remove that docs plugin, build, restore the config, and report it as an environment limitation rather than a code problem. `NODE_USE_ENV_PROXY=1` lets Node's `fetch` use the proxy where the policy allows the host.
3. Exercise the plugin's configuration matrix in a temporary docs config and inspect the built HTML (`grep` the relevant markup in `docs/dist/**/index.html`):
   - default options;
   - every preset / option value;
   - custom values (including local file paths);
   - a multilingual setup with a locale whose key differs from its lang, e.g. `locales: { root: { label: "English", lang: "en" }, "zh-cn": { label: "简体中文", lang: "zh-CN" } }` plus a copied page in `src/content/docs/zh-cn/`;
   - an invalid config, to confirm the error message is readable.
   Restore the docs config and delete temporary pages afterwards.
4. If the plugin touches Markdown, build once with Sätteri (default) and once with `unified()` (see `markdown-processors.md`).
5. Start the dev server and take desktop (1440×900) and mobile (390×844) screenshots with Playwright, then look at them. Chromium lives in `/opt/pw-browsers` (e.g. `executablePath: "/opt/pw-browsers/chromium-<rev>/chrome-linux/chrome"`, launch with `--no-proxy-server`). Astro 7 reuses an already running dev server — check `astro dev status` / stop it with `astro dev stop`.
6. `git status` before committing: no temporary files, `dist/` or `.astro/` directories.
