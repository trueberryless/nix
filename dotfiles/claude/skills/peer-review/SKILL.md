---
name: peer-review
description: Review code the way a meticulous open-source maintainer would, covering correctness and edge cases, root cause vs symptom, public API and backwards compatibility, regression tests, structure and naming against my code style rules, types, accessibility and CSS, performance and dependencies, and changesets/docs. Produces prioritized, actionable findings with concrete suggestions. Use when I ask to review, critique, give feedback on, or "look over" my code, a diff, a branch, a commit, a file or a PR (e.g. "review this", "review PR 42", "what would a maintainer say about this?", "is this ready to merge?"), or run /peer-review. Not for applying fixes unless I ask.
argument-hint: "[PR number | branch | path] (default: current changes)"
---

# Peer review

Review like a maintainer who will have to live with this code for years. Care about users who depend on it, about the next contributor reading it, and about catching the bug before it ships. Be thorough, precise and kind.

## 1. Establish scope

- Argument is a PR number or URL: `gh pr view <n> --json title,body,baseRefName,files` and `gh pr diff <n>`. Read the description for intent.
- Argument is a branch: diff it against its merge base with the default branch.
- Argument is a path: review those files as they are.
- No argument: review the uncommitted changes (`git diff HEAD`, including untracked files). If there are none, review the current branch against its merge base.

State the scope in one line before the findings.

## 2. Build context before judging

- Read each changed file in full, not only the hunks, plus the callers and callees of anything whose behaviour changed. Reading a changed file also loads the matching code-style rules from `~/.claude/rules/code-style/`, which are the style baseline. The repo's own lint/format config and existing conventions override them.
- Understand the intent: what problem is this solving, for whom, and what is the smallest correct change?
- When claims can be checked cheaply, check them. Run the relevant tests, typecheck or lint. Reproduce a suspected bug with a tiny script. Use `gh search code '<identifier>'` to see how widely a public class name, element, option or export is used before calling a change breaking or harmless.

## 3. Review passes (most important first)

1. **Correctness and edge cases.** Trace real inputs through the code, especially the weird-but-valid ones:
   - URLs with a protocol inside the query string
   - trailing slashes and a non-root `base`
   - locales and RTL
   - empty collections, `undefined` from indexing
   - SSR vs client, dev vs build, HMR
   - Windows paths
   - concurrent calls, cancelled events, viewport resizes
   Find the input that breaks it.
2. **Root cause.** Does the change fix the cause or paper over a symptom? Does it over-apply (replace, invalidate or re-render more than needed)? Is there a simpler place to fix it?
3. **Public surface and compatibility.** Treat as public API: exported functions and types, config options, component props, slots, CSS class names, DOM structure, custom elements, data attributes, events, virtual modules, file paths users import. For each change, ask:
   - Who relies on this?
   - Is breaking it necessary?
   - Is there a non-breaking path, like keeping the old behaviour when a prop is absent, or aliasing?
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
   - No `any`, no non-null `!` to silence `noUncheckedIndexedAccess`, no broad `@ts-expect-error` that would also hide future errors (scope it narrowly or type the input instead).
   - Test helpers should be typed so invalid options fail to compile.
7. **Platform: HTML, CSS, a11y.**
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
   - User-facing changes need a changeset that is precise and guided: what changed, who is affected, how to migrate.
   - Docs must match behaviour.
   - Error and log messages should say what went wrong and how to fix it.
   - Terminology must be consistent with the rest of the docs.
10. **Nits.** Formatting the tooling misses, wording, ordering. Keep these last and few.

## 4. Report

Start with a one-line verdict: **ready to merge**, **ready after nits**, **needs changes** or **needs discussion**. Then give findings grouped under these headings, omitting empty groups:

- **Must fix**: bugs, regressions, unintended breaking changes, missing regression tests for a fix.
- **Should fix**: design, compatibility, test or doc gaps that will cost later.
- **Nits**: optional polish, each prefixed `Nit:`, and "up to you" when it is taste.
- **Questions**: things you could not determine and need the author's intent for.

Each finding contains:

- the location as a clickable `path:line`
- what is wrong, in one or two sentences, with the concrete failing input or scenario
- why it matters, when that isn't obvious
- a concrete suggestion: a `diff` or `suggestion` block, or the exact alternative approach
- a link to a spec, MDN, docs or the existing in-repo pattern to reuse, when relevant

End with one or two lines on what is genuinely good in the change, if anything is. Only say it if it's real.

## Voice

- Collaborative, not gatekeeping. Frame design points as questions or proposals: "I wonder if we could…", "Should we also…?", "What do you think about…?" Be direct about actual bugs: "This breaks when…".
- Show, don't tell. Every non-trivial point comes with the code you'd write, or a pointer to where the codebase already does it right.
- Weigh trade-offs openly. When there are two reasonable options, lay both out with their costs and say which you lean toward and why, even if you're torn.
- Precise, specific, no filler. No generic advice ("consider adding tests"). Say which test, asserting what.
- Don't invent problems to look thorough. If a pass finds nothing, say nothing about it. Mark any finding you're not confident about as a question.

## Boundaries

- Don't edit files unless I ask. Offer to apply the Must/Should fixes at the end.
- Never post comments, reviews or approvals to GitHub unless I explicitly ask in chat. Then post exactly what I approved.
