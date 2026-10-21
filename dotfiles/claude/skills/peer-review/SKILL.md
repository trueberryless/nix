---
name: peer-review
description: Review code the way a meticulous open-source maintainer would, covering correctness and edge cases, root cause vs symptom, public API and backwards compatibility, regression tests, structure and naming against my code style rules, types, accessibility and CSS, performance and dependencies, and changesets/docs. Supports a depth level (quick | standard | thorough) to control how detailed and nitpicky the review is. Produces prioritized, actionable findings with concrete suggestions. Use when I ask to review, critique, give feedback on, or "look over" my code, a diff, a branch, a commit, a file or a PR/MR (e.g. "review this", "review PR 42", "quick review of my branch", "what would a maintainer say about this?", "is this ready to merge?"), or run /peer-review. Not for applying fixes unless I ask.
argument-hint: "[quick | standard | thorough] [PR/MR number | branch | path] (default: standard, current changes)"
---

# Peer review

Review like a maintainer who will have to live with this code for years. Care about users who depend on it, about the next contributor reading it, and about catching the bug before it ships. Be thorough, precise and kind — but only as verbose as the requested depth allows.

## 0. Parse arguments: depth + scope

Arguments may contain a **depth** keyword and a **scope**, in any order.

Depth (default `standard`). Accept synonyms:

| Depth | Synonyms | Passes run | Report includes |
| --- | --- | --- | --- |
| `quick` | `lgtm`, `light`, `brief`, `-q`, `1` | 1–3 only (correctness, root cause, breaking changes) | **Must fix** only. No nits, no style, no "should fix" unless it's a likely bug. |
| `standard` | `normal`, `default`, `2` | 1–9 | **Must fix**, **Should fix**, **Questions**. Nits omitted, except at most 3 if genuinely worth mentioning. |
| `thorough` | `deep`, `full`, `nitpick`, `pedantic`, `-t`, `3` | 1–10 | Everything, including all nits. |

Also honour natural-language hints in my message ("just a sanity check" → quick, "be pedantic" / "tear it apart" → thorough). State the chosen depth in the scope line.

Depth controls **what is reported and how much context is built**, never correctness: a real bug is always reported, at every depth.

### LGTM rule

If, at the chosen depth, there are no findings worth reporting (and at `standard`, nothing beyond optional polish), respond with just:

> **LGTM!** <one sentence on what the change does / why it looks right>

Optionally add up to 2 one-line `Nit:` bullets at `standard`. No headings, no empty sections, no "what's good" paragraph padding. Don't manufacture findings to avoid saying LGTM.

## 1. Establish scope

- Argument is a PR/MR number or URL:
  - GitHub: `gh pr view <n> --json title,body,baseRefName,files` and `gh pr diff <n>`.
  - GitLab (e.g. this repo has `.gitlab-ci.yml`): use the GitLab MCP tools (`gitlab_get_merge_request`, `gitlab_list_merge_request_changed_files`, `gitlab_get_merge_request_diffs`) or `glab mr view/diff`.
  - Read the description for intent.
- Argument is a branch: diff it against its merge base with the default branch.
- Argument is a path: review those files as they are.
- No scope argument: review the uncommitted changes (`git diff HEAD`, including untracked files). If there are none, review the current branch against its merge base.

State scope and depth in one line before the findings, e.g. `Scope: uncommitted changes (3 files) · Depth: quick`.

## 2. Build context before judging

Scale effort with depth:

- **quick**: read the diff plus enough of each changed file to understand the touched code. Only open callers/callees if a behaviour change looks risky. Don't run tests unless a bug is suspected.
- **standard / thorough**: read each changed file in full, not only the hunks, plus the callers and callees of anything whose behaviour changed. The code-style rules in `~/.claude/rules/code-style/` (if present) are the style baseline; the repo's own lint/format config (`.editorconfig`, analyzers, etc.) and existing conventions override them.
- Understand the intent: what problem is this solving, for whom, and what is the smallest correct change?
- When claims can be checked cheaply, check them (standard/thorough always; quick only for suspected bugs). Run the relevant tests, typecheck/build or lint. Reproduce a suspected bug with a tiny script. Search usages (`grep` locally, `gh search code '<identifier>'` for public packages) before calling a change breaking or harmless.

## 3. Review passes (most important first)

Run only the passes for the chosen depth (see table in §0).

1. **Correctness and edge cases.** Trace real inputs through the code, especially the weird-but-valid ones:
   - URLs with a protocol inside the query string
   - trailing slashes and a non-root `base`
   - locales and RTL
   - empty collections, `undefined`/`null` from indexing
   - SSR vs client, dev vs build, HMR
   - Windows paths
   - concurrent calls, cancelled events/cancellation tokens, viewport resizes
   Find the input that breaks it.
2. **Root cause.** Does the change fix the cause or paper over a symptom? Does it over-apply (replace, invalidate or re-render more than needed)? Is there a simpler place to fix it?
3. **Public surface and compatibility.** Treat as public API: exported functions and types, config options, HTTP endpoints and contracts, component props, slots, CSS class names, DOM structure, custom elements, data attributes, events, virtual modules, file paths users import. For each change, ask:
   - Who relies on this?
   - Is breaking it necessary?
   - Is there a non-breaking path, like keeping the old behaviour when an option is absent, or aliasing?
   - If it must break, is the migration spelled out with before/after examples?
4. **Tests.**
   - Every fix needs a regression test that reproduces the actual failure end to end. A test that asserts a config value was set is not enough.
   - Assert the final state after the full interaction.
   - Compare against literals, not objects the code under test mutates.
   - Use assertions that narrow types.
   - Use auto-retrying assertions in e2e, not timeouts.
   - Add a test for each edge case found in pass 1.
   - Benchmarks must measure the real workload, not a cached shortcut.
5. **Structure and naming** (per the code-style rules).
   - Logic belongs in small pure functions in a module named for its concept, not in components or handlers.
   - Names say what they do.
   - Watch for dead code, needless indirection (a factory that could just return the value), computed-but-unused results and duplicated logic.
   - Helpers with non-obvious contracts need a comment on how to use them correctly.
6. **Types.**
   - No `any`/`dynamic`, no non-null `!` to silence nullability checks, no broad suppressions (`@ts-expect-error`, `#pragma warning disable`) that would also hide future errors (scope narrowly or type the input instead).
   - Test helpers should be typed so invalid options fail to compile.
7. **Platform: HTML, CSS, a11y** (only if the change touches UI).
   - Semantic elements and keyboard/focus behaviour, `aria-*` correctness.
   - Inherit what UA stylesheets override (e.g. `color` in popovers).
   - Namespaced class names that can't collide with user CSS, cascade layers where the project uses them, logical properties.
   - Browser-support claims should match the actual feature set, including what can't be polyfilled.
8. **Performance and dependencies.**
   - Work done per page or request that could be done once.
   - Cache keys and invalidation correctness.
   - New dependencies and polyfills the target runtime doesn't need.
   - Bundle impact of client code.
9. **Docs, changeset, messages.**
   - User-facing changes need a changeset/changelog entry that is precise and guided: what changed, who is affected, how to migrate.
   - Docs must match behaviour.
   - Error and log messages should say what went wrong and how to fix it.
   - Terminology must be consistent with the rest of the docs.
10. **Nits** (thorough only). Formatting the tooling misses, wording, ordering. Keep these last.

## 4. Report

If the LGTM rule applies, stop there.

Otherwise start with a one-line verdict: **ready to merge**, **ready after nits**, **needs changes** or **needs discussion**. Then give findings grouped under these headings, **omitting empty groups and any group excluded by the depth**:

- **Must fix**: bugs, regressions, unintended breaking changes, missing regression tests for a fix.
- **Should fix** (standard, thorough): design, compatibility, test or doc gaps that will cost later.
- **Nits** (thorough; max 3 at standard): optional polish, each prefixed `Nit:`, and "up to you" when it is taste.
- **Questions** (standard, thorough; at quick only if blocking): things you could not determine and need the author's intent for.

Length guidance: `quick` ≈ a few lines; `standard` = only findings that matter; `thorough` = complete.

Each finding contains:

- the location as a clickable `path:line`
- what is wrong, in one or two sentences, with the concrete failing input or scenario
- why it matters, when that isn't obvious
- a concrete suggestion: a `diff` or `suggestion` block, or the exact alternative approach (at `quick`, a one-line suggestion is fine unless code is needed to be clear)
- a link to a spec, docs or the existing in-repo pattern to reuse, when relevant

At `standard`/`thorough`, end with one or two lines on what is genuinely good in the change, if anything is. Only say it if it's real. Skip at `quick`.

## Voice

- Collaborative, not gatekeeping. Frame design points as questions or proposals: "I wonder if we could…", "Should we also…?", "What do you think about…?" Be direct about actual bugs: "This breaks when…".
- Show, don't tell. Every non-trivial point comes with the code you'd write, or a pointer to where the codebase already does it right.
- Weigh trade-offs openly. When there are two reasonable options, lay both out with their costs and say which you lean toward and why.
- Precise, specific, no filler. No generic advice ("consider adding tests"). Say which test, asserting what.
- Don't invent problems to look thorough. If a pass finds nothing, say nothing about it. Mark any finding you're not confident about as a question.

## Boundaries

- Don't edit files unless I ask. Offer to apply the Must/Should fixes at the end (one line).
- Never post comments, reviews or approvals to GitHub/GitLab unless I explicitly ask in chat. Then post exactly what I approved.
