# Markdown processors: unified and Sätteri

Astro 7 renders Markdown/MDX with **Sätteri** by default. The remark/rehype (`unified()`) pipeline is only used when a project installs `@astrojs/markdown-remark` and sets `markdown.processor: unified()`. A plugin that ships or registers remark/rehype plugins (or relies on `markdown.remarkPlugins` / `markdown.rehypePlugins`) silently does nothing on default Astro 7 sites unless it also supports Sätteri. Support **both**.

Follow HiDeoo's implementations exactly — read them first:
- `HiDeoo/starlight-blog`: `packages/starlight-blog/libs/processor.ts`, `libs/satteri.ts`, `libs/remark.ts` — MDAST-level transform.
- `HiDeoo/starlight-image-zoom`: `packages/starlight-image-zoom/libs/processor.ts`, `libs/satteri.ts`, `libs/rehype.ts`, `libs/integration.ts` — HAST-level transform, raw HTML, preserving code metadata across the MDAST→HAST boundary.

## Pattern

1. Put the transformation logic in shared, processor-agnostic pure helpers (e.g. `libs/markdown.ts`). Then write two thin adapters:
   - `libs/remark.ts` or `libs/rehype.ts` for unified;
   - `libs/satteri.ts` with `defineMdastPlugin()` / `defineHastPlugin()` from `satteri` (add `satteri` as a dependency).
   In Sätteri visitors use the context API — `ctx.replaceNode`, `ctx.setProperty`, `ctx.data` — rather than mutating nodes, and type custom data via:
   ```ts
   declare module "satteri" {
     interface DataMap {
       myPluginFlag: boolean;
     }
   }
   ```
2. Add `libs/processor.ts`:
   ```ts
   import type { AstroConfig } from "astro";

   import { throwPluginError } from "./error";
   import { remarkMyPlugin } from "./remark";
   import { satteriMyPlugin } from "./satteri";

   export function applyMarkdownPlugin(processor: MarkdownProcessor) {
     if (isSatteriProcessor(processor)) {
       processor.options.mdastPlugins.push(satteriMyPlugin());
     } else if (isUnifiedProcessor(processor)) {
       processor.options.remarkPlugins.push([remarkMyPlugin]);
     } else {
       throwPluginError("The configured 'markdown.processor' is not supported by the <plugin> plugin.");
     }
   }

   function isSatteriProcessor(processor: unknown): processor is SatteriMarkdownProcessor {
     if (typeof processor !== "object" || processor === null) return false;
     const candidate = processor as { name?: unknown; options?: { mdastPlugins?: unknown } };
     return candidate.name === "satteri" && Array.isArray(candidate.options?.mdastPlugins);
   }

   function isUnifiedProcessor(processor: unknown): processor is UnifiedMarkdownProcessor {
     if (typeof processor !== "object" || processor === null) return false;
     const candidate = processor as { name?: unknown; options?: { remarkPlugins?: unknown } };
     return candidate.name === "unified" && Array.isArray(candidate.options?.remarkPlugins);
   }

   type MarkdownProcessor = NonNullable<AstroConfig["markdown"]["processor"]>;

   interface SatteriMarkdownProcessor {
     name: "satteri";
     options: { mdastPlugins: unknown[] };
   }

   interface UnifiedMarkdownProcessor {
     name: "unified";
     options: { remarkPlugins: unknown[] };
   }
   ```
   For HAST-level plugins use `hastPlugins` / `rehypePlugins` instead and check those arrays in the guards.
3. Call `applyMarkdownPlugin(astroConfig.markdown.processor)` from the `astro:config:setup` hook of the integration added in `config:setup`, replacing any `updateConfig({ markdown: { remarkPlugins/rehypePlugins } })`.
4. Enable Sätteri features the transform relies on — e.g. `processor.options.features.rawHtml = true` when raw HTML must be parsed (the unified equivalent is `rehype-raw`) — and mind ordering (`unshift` vs `push`), as starlight-image-zoom does.
5. Verify both pipelines: build the docs with the default (Sätteri) processor, then temporarily add `@astrojs/markdown-remark` to the docs, set `markdown: { processor: unified() }` (import `unified` from `@astrojs/markdown-remark`), build again and compare the rendered output. Restore the docs afterwards.
6. Mention it in a changeset, e.g. "Adds support for Astro's Sätteri Markdown processor."
