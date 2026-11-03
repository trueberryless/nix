---
name: technical-docs
description: Write, rewrite, audit or review technical documentation (docs sites, guides, concept and reference pages, provider or integration pages, recipes, examples, READMEs, CONTRIBUTING files, PR templates) so it reads like a thoughtful human explained it to a reader, with a natural flow instead of choppy, compressed, machine-sounding text, and so that every statement is correct, verified against the code and relevant to the people who use the project. Use when I ask to write, improve, reword, polish, restructure or review docs, "make the docs read more human", fix choppy or AI-sounding documentation, or check docs for accuracy, and when I paste review comments about docs (from me, maintainers or CodeRabbit). Also use when starting documentation for a new project. Not for code comments or API reference text generated from source comments unless I ask.
argument-hint: "[path | page | whole docs] (default: the docs of the current repository)"
---

# Technical documentation

Write documentation the way a good teacher explains a tool to a colleague who is smart but new to it. Warm, direct, connected, and never wrong. I set a very high bar, I review the result paragraph by paragraph, and anything that doesn't read well gets redone. Take the time to do it properly the first time. Quality matters more than speed.

Four things matter, in this order:

1. **Correctness.** A wrong sentence is worse than a missing one. Never write a statement you are not sure of. Verify against the code. See `references/accuracy.md`.
2. **Relevance.** Document what a user of the project needs to know to use it, and nothing about how the repository itself is built, tested or checked. See `references/content.md`.
3. **The current state, not the story.** Docs describe how the project works right now. They do not tell how it came to be, what it used to do or what changed. See `references/content.md` section 2, and the time words in `references/voice-and-flow.md` section 8.
4. **Readability and flow.** Text that a person enjoys reading from top to bottom, with reasons attached to rules and sentences that lean on each other. See `references/voice-and-flow.md`.

## The failure this skill exists to prevent

Text that is technically accurate but compressed: a stream of short declarative sentences about the API, each one a separate fact, with the reader almost absent. It is the typical shape of machine-written docs, and it is what I look for when I say the docs "sound like AI". It is not about banned words. It is about rhythm, connection and who the sentences are addressed to. A typical example:

> Leave out `auth` for an anonymous provider. It sends no credentials and makes public reads only. Writes, notifications and subscriptions report `false`:

and its fix, which says the same thing in connected, reader-facing prose:

> If you leave out `auth`, you get an anonymous provider. It sends no credentials and can only make public reads, so writes, notifications and subscriptions all report `false` in its capabilities:

Another typical failure is a fragment that points at the previous sentence instead of explaining ("Use it in browser code."). It gives no reason and no condition. Always say why and when.

## Current state, never history

The main docs (getting started, guides, concepts, reference, provider and integration pages, examples, contributing) describe the present and nothing else. A reader is looking at the project as it is today, and a sentence about the past makes them work out what still applies.

- Write what is true now, in the present tense, as a plain fact: "Bitbucket Cloud doesn't accept app passwords", not "Bitbucket Cloud retired app passwords, so they no longer work".
- Do not write "previously", "used to", "no longer", "now" (as in "now supports"), "newly", "recently", "as of", "since we changed", "in the old version", "originally", "the project started as" or "we decided to". Do not narrate design decisions as a story of what was tried. A reason in the present tense is welcome: "the provider can't read branch policies, so `merge()` requires a method".
- When rewriting existing docs, convert history into the current fact. If nothing current is left once the history is removed, delete the sentence.
- Exceptions, where change over time is the subject: blog posts, changelogs and release notes, and migration or upgrade guides (which still say what the reader should do today). Version availability that the reader needs to choose correctly ("requires 3.13 or later") is current state, not history, and stays.
- Deprecations are current state too. Say what is deprecated, what to use instead, and what happens if you keep using it. Leave out when and why it was deprecated unless the reader needs a date to plan.

See `references/content.md` section 2 for details and examples.

## Workflow

Follow these phases in order. Do not skip the reading and verification phases to get to writing sooner.

### 1. Learn the project and its constraints

- Find the docs system and how pages are built (framework, content folder, navigation files, components, callout syntax). Match the syntax already used in the repo.
- Find what is generated and must not be edited by hand: marked blocks (`<!-- name:start -->` and `<!-- name:end -->`), API reference pages built from source comments, tables written by scripts, contributor lists. Edit the prose around generated blocks and leave them byte-identical. Run the generator afterwards and confirm nothing changed.
- Find what tests, linters and link checkers assert about docs (page titles and first headings, anchors, link fragments, command tables that must list every script, snapshots). Keep page titles and anchors stable unless you update everything that refers to them.
- Read the repository's own conventions: spelling variant (British or American), heading case, punctuation, how code samples are formatted. Follow them. Where nothing is established, default to sentence-case headings and avoid em dashes, which read as machine-written.

### 2. Read everything before changing anything

- Read every docs page in full, not excerpts. Read the code that each page describes, so you know what is true. You cannot judge a page's correctness or relevance from the page alone.
- Take notes on what each page promises, what it duplicates from another page, and what it says that is not about using the project.
- Look at the output of the generators and the structure of reference pages, so you know which register each page type uses.

### 3. Audit the content before rewording it

Decide for each section whether to keep, trim, move or remove it, using `references/content.md`. Typical removals are descriptions of how CI checks the project, size or performance budgets, internal test setups, and contributor-only recording or release steps inside user pages. Move contributor material to the contributing docs instead of deleting it, so nothing is lost. If a decision really belongs to the maintainer (for example whether a comparison table stays), ask once, briefly, with a recommendation. Do not ask about things you can decide.

### 4. Rewrite page by page

- Apply `references/voice-and-flow.md` to every paragraph, and the page-type structure from `references/content.md`.
- Keep every claim that is still relevant. A rewrite may reorder, connect and explain, but it must not silently drop or change facts.
- Every new fact, reason or example you add is a risk. Verify it (phase 5) or leave it out.
- Prefer editing the prose around generated blocks over rewriting a whole file when the file contains generated sections.
- Do not state style rules in the project's repository files (README, CONTRIBUTING, PR template, docs contributing pages). Those are discussed in pull requests. The style lives in this skill, not in the repo. See `references/repo-files.md`.

### 5. Verify every claim

Before you finish a page, go through it sentence by sentence and confirm each factual statement against the code, the tests, the generated tables or the upstream documentation. See `references/accuracy.md` for how, and for the mistakes that this step is meant to catch. If you cannot verify a statement, remove it or soften it to what you can verify. Never keep a guess because it sounds plausible.

### 6. Run the mechanical checks

Run whatever the project provides: the generator (and confirm generated blocks did not change), linter, unit tests, the docs build, the docs tests and a link check that includes fragments. Then run `scripts/rhythm.py` on the pages you rewrote and compare with the targets in `references/measuring.md`. Fix what fails. Do not weaken a test to make it pass.

### 7. Read it again as the reader

Read each rewritten page once more from top to bottom as someone who has never seen the project. Ask:

- Does every paragraph read as one thought, with the sentences connected?
- Does every rule or limitation say why, and what to do instead?
- Is anything vague ("can", "may", "usually") where the behaviour is deterministic?
- Is anything there that the reader does not need?
- Does any sentence tell a story (what changed, what used to be) instead of stating how it works today?
- Would I be comfortable if the maintainer read this paragraph aloud?

Rewrite what fails. Repeat until it is good.

### 8. Hand over

Leave changes uncommitted unless I ask for a commit, and follow the git and GitHub rules in my global instructions. Report briefly: what changed, what was removed or moved and why, what you verified and how, what is still open (for example generated reference text that comes from source comments), and anything you were unsure about. Do not claim checks you did not run.

## When I send feedback

Treat every review comment (mine, a maintainer's, a bot's) as a claim to check, not an instruction to apply blindly:

1. Verify the comment against the code or upstream source. If it is right, fix it. If it is wrong, say so briefly and do not change anything.
2. A comment about one sentence is usually about a pattern. Search the whole docs for the same claim, example or wording and fix all occurrences. Check generated reference text and example READMEs too.
3. When a comment shows that your wording overstated something, rewrite to the exact truth. Do not just soften the wording.
4. If I say a paragraph does not read well, do not patch a word. Rewrite the paragraph, considering what the reader needs at that point, and then check its neighbours.
5. Re-run the checks from phase 6 after fixing.

## Quick reference

- Open every page with what the thing is and why a reader would use it.
- Write to "you". The reader is the subject of most sentences.
- Join sentences with connectors. Aim for 14 to 18 words per sentence on average, in paragraphs of two to four sentences.
- Attach the reason to every rule, and the alternative to every limitation.
- Introduce each code block with a sentence about what it shows. Follow it with what happens or what to expect.
- Put asides in callouts and "read more" links at the end of sections.
- Document user-facing behaviour only. Move or remove anything about how the repository is built or checked.
- Describe the current state in the present tense. No history, no "used to", "no longer" or "now" outside blog posts, changelogs and migration guides.
- Use bold and lists sparingly, and no emojis in prose.
- Never write what you have not verified.

## References

- `references/voice-and-flow.md`: the writing style in depth, with patterns, wording, before and after examples, and what to avoid.
- `references/accuracy.md`: how to verify, the mistakes to watch for, and how to handle uncertainty.
- `references/content.md`: what to document, what to cut or move, and the structure of each page type.
- `references/repo-files.md`: README, CONTRIBUTING, PR templates and other repository files.
- `references/measuring.md`: the rhythm metrics, targets and how to use `scripts/rhythm.py`.
