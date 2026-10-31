# Code style and refactors

Goal: code that reads like HiDeoo's plugins — small, pure, well-named functions (NASA "power of ten" spirit), no comments, thin components.

## `libs/` layout

- `config.ts` — the Zod schema, `validateConfig()`, and exported `<Plugin>UserConfig = z.input<…>` / `<Plugin>Config = z.output<…>` types.
- `error.ts` — mirror starlight-blog:
  ```ts
  import { AstroError } from "astro/errors";

  export function throwPluginError(message: string, hint?: string): never {
    const hintHeader = "See the error report above for more informations.";
    const hintFooter = `\n\nIf you believe this is a bug, please file an issue at https://github.com/trueberryless/<repo>/issues/new`;

    throw new AstroError(message, hint ? `${hint}${hintFooter}` : `${hintHeader}${hintFooter}`);
  }
  ```
  Invalid config: `throwPluginError(\`Invalid <plugin> configuration:\n\n${z.prettifyError(config.error)}\n\`)`.
- `vite.ts` — one Vite plugin exposing several virtual modules (`virtual:<plugin>/config`, `/context`, `/images`, …) through a `modules` map, a `moduleResolutionMap`, `resolveVirtualModuleId()` and `type VitePlugin = NonNullable<ViteUserConfig["plugins"]>[number]`, exactly like `starlight-blog/libs/vite.ts`.
- `starlight.ts` — component override helper that warns (twice, like starlight-blog's `overrideComponent`) when the user already overrides a component, telling them to render `<plugin>/components/<Component>.astro` themselves.
- `i18n.ts` and one file per domain concept (e.g. `credit.ts`, `image.ts`).

## Zod 4

- `z.url()` instead of `z.string().url()`.
- `z.record(z.string(), z.string())` — the single-argument form is gone.
- `z.prettifyError(error)` instead of `error.flatten()`.

## Do not depend on Starlight internals

Don't import `virtual:starlight/user-config` or other internal Starlight modules — they have no public types since 0.42 and can change. Compute what you need from the `config` argument of the `config:setup` hook (and `astroConfig` in `astro:config:setup`) and expose it through the plugin's own `virtual:<plugin>/context` module.

## Local files from user config

Resolve relative paths (e.g. a custom image) from the project root inside the Vite plugin — virtual modules have no importer location, so relative imports there are unreliable:

```ts
const moduleId = id.startsWith(".") ? fileURLToPath(new URL(id, astroConfig.root)) : id;
return `import customImage from ${JSON.stringify(moduleId)};\nexport { customImage };`;
```

Update the docs to say paths are relative to the project root.

## Keep logic out of `.astro` frontmatter

Components should read like a sentence — call descriptively named helpers and render:

```astro
---
import { Image } from "astro:assets";

import { getCredit } from "../libs/credit";
import { getCreditImage } from "../libs/image";

type Props = astroHTML.JSX.HTMLAttributes;

const { class: className, ...attrs } = Astro.props;

const credit = getCredit(Astro.locals.t, Astro.currentLocale);
const image = getCreditImage();
---
```

Each helper reads the virtual modules and delegates to a **pure** `resolve<X>(...)` function that receives everything as arguments. Keep pure functions free of virtual-module imports so `index.ts` and `vite.ts` can import shared helpers at config time, and so they stay testable. Also:
- remove every `@ts-ignore` (with correct types they are unnecessary);
- type forwarded attributes with `type Props = astroHTML.JSX.HTMLAttributes` and merge classes with `class:list`;
- compute values once instead of calling the same helper repeatedly in the template.

## Types files — exactly like starlight-blog

- `index.ts` starts with:
  ```ts
  /// <reference path="./locals.d.ts" />
  ```
  Keep it even if a linter suggests ES imports — that was tried and reverted (an `import` of a script `.d.ts` fails with "is not a module").
- `locals.d.ts` is a script file (no imports/exports):
  ```ts
  declare namespace StarlightApp {
    type Translations = typeof import("./translations").Translations.en;
    interface I18n extends Translations {}
  }
  ```
  Add a `declare namespace App { interface Locals … }` block only when the plugin sets its own locals (then mirror starlight-blog). Remove old `App.Locals extends StarlightLocals` blocks otherwise: Starlight ≥ 0.42 augments `App.Locals` itself and no longer exports `StarlightLocals` (the broken import is invisible because `skipLibCheck` skips `.d.ts` files).
- `virtual.d.ts` declares each virtual module, with local aliases such as `type ImageMetadata = import("astro").ImageMetadata;`.

## Astro 7 specifics

- The Rust compiler rejects self-closing non-void HTML elements: `<div class="x" />` → `<div class="x"></div>`.
- `compressHTML: 'jsx'` is the default: check whitespace between inline elements and add `{" "}` where needed.

## Behavior

Preserve existing behavior unless it's clearly broken. Localized user config keys (e.g. `{ en: "…", "zh-CN": "…" }`) are looked up strictly by the exact `lang` of the current locale, then of the default locale — no locale-key aliases, no case-insensitive matching. Describe suspected bugs in the summary instead of silently changing semantics (example seen before: plugin translations keyed `zh` while Starlight looks them up as `zh-CN`).
