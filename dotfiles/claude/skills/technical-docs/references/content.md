# What to document, and how to structure it

Good docs are as much about what you leave out as what you put in. A reader wants a clean, human explanation of how the thing works and how to use it. They do not care how the repository checks its own bundle size or how its tests enforce a feature table.

## Contents

1. The audience test
2. What to cut, move, trim and keep
3. The audit step
4. Page types and their structure
5. Provider, integration and adapter pages
6. Reference pages and generated content
7. Examples and recipes
8. Landing pages and blurbs
9. Information architecture
10. Duplication between pages

## 1. The audience test

For every paragraph, section and page, ask: **does a person who uses this project need this to use it correctly or understand it?**

- If yes, keep it and make it clear.
- If it is about developing the project itself (building, testing, releasing, CI, internal architecture, how a check is enforced), it is for contributors. Move it to the contributing docs, or drop it if it adds nothing there.
- If it is a detail that only matters in a rare edge case, keep the user-visible consequence and drop the mechanics.
- If it is marketing for the project's own virtues, replace it with a plain statement of what the reader gets.

When in doubt, imagine the reader on a deadline with a specific question. Would this paragraph help them, or slow them down?

## 2. What to cut, move, trim and keep

**Cut or move to contributing docs:**

- How continuous integration checks the project: size budgets, capability checks, snapshot tests, link checks, the scripts behind them.
- Internal file paths and test setup that a user never touches (a test setup file that records which methods are called, a script that measures bundles).
- Contributor-only recording, fixture or release steps placed inside user-facing pages (move them to one page in the contributing section, with one clearly named section per item).
- "How we ensure quality" statements, unless the user needs the guarantee to understand a level of support (then say what the level means in user terms, and mention the check in a clause at most).
- Roadmap talk, plans and promises about the future.
- History: how the project got here, what an earlier version did, what changed, why a decision was made in the past. See "Current state, not history" below.

**Trim to what the reader needs to do:**

- Mechanics of internal limits, retry counts and implementation order. Keep the user-visible consequence ("keep reading for as long as the cursor is set, because a page can come back short") and drop the algorithm.
- Long lists of operations that happen to use a particular transport, unless the reader chooses by it.
- Edge cases that apply to one provider or option, in a general guide. Move them to the page of that provider or option, with a link.

**Keep (but make readable):**

- Behaviour that differs by provider, platform or mode, and the reason for the difference.
- Authentication, configuration, defaults, limits the user hits, errors the user must handle.
- Security-relevant behaviour and warnings.
- Genuinely useful comparisons the maintainer wants (for example a size table), with honest framing.
- Anything the maintainer explicitly asks to keep.

**Never silently delete a user-relevant fact.** If a rewrite moves a fact, make sure it lands somewhere a reader can find it, and report where.

### Current state, not history

Docs are read to find out how the project works today. They describe the present, and the present only.

What to remove or rewrite:

- Change narration: "now supports", "no longer needs", "has been replaced by", "previously", "used to", "formerly", "newly added", "recently", "as of this release", "in older versions".
- Origin stories and design history: "originally", "we started with", "after trying X we chose Y", "this was added because of issue 123".
- Time-bound hedges: "currently" and "for now" in front of a behaviour that is simply how it works. Keep them only when the state really is transitional and the reader needs to know it will change (for example an experimental feature), and then say what the reader should do about it.
- Plans and promises: "will be supported soon", "a future version will".
- Statements about other people's past: "the forge retired X in 2026". Say what is true now ("the forge doesn't accept X") and, if useful, what to use instead.

How to rewrite:

| History | Current state |
| --- | --- |
| The provider now retries once after a short rate limit. | After a short rate limit, the provider retries once. |
| Bitbucket Cloud has retired app passwords, so they no longer work. | Bitbucket Cloud doesn't accept app passwords. Use an API token. |
| This option used to be called `host`, and `baseUrl` replaces it. | `baseUrl` sets the host of the instance. |
| Gitee support was added experimentally and is being verified. | The Gitee provider is experimental. Its behaviour hasn't been verified against the live forge, so most of its capabilities are marked experimental. |
| We changed merging to be asynchronous because direct merges timed out. | `merge()` requests a direct merge through the asynchronous merge API and waits for the result. |

If a sentence only has meaning as a comparison with the past, and removing the history leaves nothing, delete it.

What stays, because it is current state:

- Version requirements and availability the reader needs to choose correctly: "requires version 3.13 or later", "Dependabot alerts need 3.8 or later".
- Deprecations: what is deprecated, what to use instead, and what happens if the reader keeps using it. Add a date or a version only when the reader needs it to plan.
- Present-tense reasons: why the behaviour is what it is today, when it is verified (see `accuracy.md` section 5).
- Experimental or unstable status, stated as a present fact with its consequence for the reader.

Where history is the subject, it belongs in its own place and not in the main docs:

- Blog posts and announcements.
- Changelogs and release notes.
- Migration and upgrade guides, which describe differences between versions on purpose. Even these should tell the reader what to do today first, and keep the past short.

When the maintainer asks you to keep a piece of history in the main docs, keep it, and keep it short.

## 3. The audit step

Before rewording a page, write down for each section: keep, trim, move or remove, and why. Do this for the whole docs set first, because you will notice duplicates and misplaced material only by seeing everything.

- Report the plan briefly and proceed with what is clearly right.
- Ask the maintainer only about decisions that are genuinely theirs: a table that is half marketing, an audience question (do contributing docs get the same rewrite?), a section whose removal changes what the project promises. Give a recommendation with the question.
- Keep a short list of removals and moves for the handover.
- While auditing, mark every sentence that narrates change or history. They are removal or rewrite candidates.

## 4. Page types and their structure

### Introduction or overview

1. One or two paragraphs: what it is, the problem it solves, how it differs.
2. What is supported or covered, with links.
3. What you can build or do with it, as examples.
4. How it works, in prose: the mental model in two paragraphs.
5. Next steps with reasons.

### Installation

Install commands for common package managers, requirements (runtime versions, module format), what is included, then the choices a reader must make (import paths, entry points, environments). Explain each choice in a sentence with its reason.

### Quick start or tutorial

A numbered path with a result at each step. Prerequisites first (accounts, tokens, environment variables). Every step says what to do, shows the code, and says what happens. Mention side effects before the step that has them. End with next steps.

### Guide (how to do X)

- Open with the situation and the goal in two or three sentences.
- One section per task, named by the task.
- Each section: the simplest working way first, then variations and edge cases, each with its reason.
- Link to concepts for the why and to reference for the full option list.

### Concept

Explain the model and why it is designed that way, in prose with small examples. Define terms. Say how pieces relate. Avoid step-by-step instructions, link to guides for those.

### Reference

A uniform shape per entry. Prose is short and regular. Include type, default, behaviour in one paragraph, and links. Never leave a fragment that depends on the previous entry. Where the reference is generated from source comments, change the comment, not the page.

### Contributing docs

Written for someone who wants to help: set up, run, test, how pieces fit, how to add a feature, what generated files exist and how to update them, commit and pull request conventions the project enforces (for example commit message format). Not writing or style rules (see `repo-files.md`).

## 5. Provider, integration and adapter pages

Pages that describe one backend, platform or integration deserve a consistent structure, because readers compare them.

1. Opening paragraph: what it works with, what it can do, what it cannot do.
2. A generated header block with the import path, factories and auth kinds, if the project has one. Leave it unchanged.
3. A note if the integration is experimental, saying what that means for the reader and linking to the explanation.
4. Authentication or setup, with the accepted credential types, a sample, and what happens without credentials.
5. Instance, base URL and refs: how identifiers map.
6. One section per behaviour that differs from the shared model, each starting with the situation, then the behaviour, then the reason or what to do instead. Examples: merging, reviews, search, notifications, checks, releases, accounts.
7. Webhooks or events: the secret option, the headers the platform sends in a table, how events map, what management operations are missing.
8. The generated capability table at the end, unchanged.

Group sections in the same order across all provider pages so a reader can jump to "Merging" on any of them. Link shared behaviour between related pages instead of duplicating it.

## 6. Reference pages and generated content

- Learn which pages are generated and by what (marker blocks, scripts, source comments). Do not edit generated text.
- Hand-written reference pages (environment variables, schemas, matrices) still need a proper introduction: what the page lists, who needs it, how it relates to the guide, followed by the data.
- Conventions or exceptions that apply to every row belong in a sentence above the table ("Most fields set the option of the same name, and the table describes what each one does.").
- If the generated pages come from source comments and the comments are poor, report it as an open item. Rewriting source comments is a separate pass and is only done when asked.

## 7. Examples and recipes

- Open with what the example does and for whom, then "run it", then what it demonstrates, then how its tests work.
- Name every command and variable exactly as the example's code reads them.
- State the output the reader should expect when it is real (derived from the code or produced by running it).
- Mirror the example's own README and its docs page, so they never disagree. Update both together.
- Explain what the example shows in terms of the library's concepts, so it works as a teaching page and not only as a code tour.

## 8. Landing pages and blurbs

Short copy still has to be accurate and relevant.

- State what the reader gets in plain words. No internal mechanisms ("CI checks the claims").
- Keep the structural conventions of the page (for example lowercase titles if the design uses them). Reword descriptions only.
- Do not add claims about speed, ease or time unless they are verified.
- Numbers (bundle sizes) must be consistent with the page they link to.

## 9. Information architecture

- Order sections from what a new reader needs first to what only an experienced reader needs.
- Keep page titles and first headings stable when tests or links depend on them. Check the test suite for assertions on them before renaming.
- Keep anchors stable, or update every link to them. Run a link check that includes fragments.
- A page that only exists to say "see another page" should not exist.
- One fact, one home. Link to it from elsewhere.

## 10. Duplication between pages

Duplicate prose goes stale in different ways on different pages. When two pages explain the same thing:

- Decide which page owns it (usually the guide or the concept page).
- On the other page, say it in a sentence and link.
- Where duplication is intentional (an example README and its docs page, a CONTRIBUTING file and its docs mirror), keep both identical in substance, and update both in the same change.
