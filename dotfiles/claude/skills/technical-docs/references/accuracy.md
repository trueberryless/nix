# Correctness and accuracy

A documentation page is a promise. Readers act on it, copy its code, and trust its explanations. A sentence that is fluent but wrong does more damage than a clumsy sentence that is right. Rewriting for readability is exactly when errors creep in, because a smooth sentence invites you to complete it with something plausible.

The rule: never write a statement you are not sure of. Check it against the code. If you cannot check it, leave it out or reduce it to the part you can check.

## Contents

1. What counts as a claim
2. Where to verify, in order of authority
3. The procedure
4. Universal and quantity words
5. Reasons and consequences
6. Time-sensitive facts and third-party behaviour
7. Code samples and names
8. Consistency across pages
9. Generated content
10. Mistakes that happened in practice
11. When you cannot verify
12. Reviewing other people's corrections

## 1. What counts as a claim

Every one of these is a claim and needs a source:

- Names: functions, options, properties, types, error classes, files, commands, environment variables, headers, subpaths, flags.
- Behaviour: what happens, what is returned, what is thrown, in what order, with which defaults.
- Conditions: "when exactly one is allowed", "if you pass X", "without Y".
- Numbers: limits, timeouts, sizes, versions, counts, dates.
- Quantifiers: every, all, any, only, never, always, none, both, the other.
- Reasons: "because the forge doesn't...", "so that...", "for this reason".
- Consequences you add yourself: "which means", "so you never", "this keeps".
- Comparisons and recommendations.
- Statements about third parties: another product's behaviour, deprecations, versions.

Sentences that merely frame or connect (a lead-in to a code block) need no source. Anything that tells the reader a fact does.

## 2. Where to verify, in order of authority

1. **The implementation.** Read the code path itself, not only a comment or a type. Comments go stale. A signature tells you what is accepted, not what happens.
2. **Tests and recordings.** They show intended and verified behaviour, including edge cases and error classes.
3. **Running it.** If the claim is cheap to check, check it: run the snippet, call the function, run the generator, print the value. A two-line script beats an hour of reasoning.
4. **Generated tables and schemas** that the project builds from the code (capability matrices, JSON schemas, API reference). They are authoritative for what they cover, and you must not contradict them.
5. **The project's other docs.** Useful for consistency, but they may be wrong too. Do not treat an old page as proof.
6. **Upstream documentation and changelogs** of third-party products, fetched from the official source, for facts about those products. Note the date of the source.

If sources disagree, the implementation wins, and you flag the stale doc or comment in your handover.

## 3. The procedure

For each page you rewrite:

1. Before writing, list the claims the old page makes (it is a free source of what the project cares about) and the behaviours the code actually has.
2. While writing, tag mentally each sentence that adds something not in the old text. Those are the risky ones.
3. After writing, go through the page sentence by sentence. For each factual sentence, find the line of code, test, table or upstream source that supports it. Open it. Do not rely on memory of having read it earlier.
4. For defaults, search for the default in code. For a thrown error, find where it is thrown and under which condition. For an option, find where it is read.
5. Run the project's tests and checks at the end, but remember that passing tests prove little about prose.

Keep the verification proportional but do it for real. A short page still needs every name and default checked.

## 4. Universal and quantity words

Words like "every", "all", "any", "only", "never", "always" and "both" are claims about every case. Check every case, usually with a search across the code, before you write one.

- "Only Tangled offers streaming" is true only if you searched all providers and found none other.
- "The in-memory forge supports everything" was wrong, because one operation is opt-in. "Almost every operation" was the truthful version.
- "Every provider except one has a lite factory" must be checked against the list of exports.
- When there are exceptions, say "almost", "most", or name the exceptions. When you are not sure whether there are exceptions, do not use the word.

Also verify enumerations: if you write "A, B and C", confirm there is no D, or write "such as".

## 5. Reasons and consequences

Reasons make prose flow, which makes them the most dangerous sentences to write. A plausible reason is not a verified reason.

- Only give a reason that you found in code comments, tests, upstream docs or a commit message, or that follows logically and necessarily from verified facts.
- Do not explain why a third party designed something a certain way unless their documentation says so.
- Do not add "which older versions sent", "for security reasons", "for performance" or similar unless you verified it.
- If you attach a consequence ("so the two stay in sync"), check that it holds in all cases. Prefer the weaker true statement over the stronger plausible one. A sentence that says "can never disagree" is a guarantee; a sentence that says "stay in sync" is a description.
- When the old text had no reason and you do not know one, write the behaviour without a reason. A bare, correct sentence is better than a smooth, invented one.

## 6. Time-sensitive facts and third-party behaviour

- Third-party products change. Authentication methods get retired, versions get dropped, limits change. When docs name such a fact, check the official source and note the date in your head. Fetch the product's changelog or API docs instead of trusting memory.
- If a reviewer says a third-party method is retired, verify it at the source before acting. If true, search the whole repository (docs, examples, READMEs, scripts, source comments) for the same method and fix the user-facing mentions. Mention the ones you could not change, such as source comments feeding generated pages, in your handover.
- Do not hardcode version numbers, prices, quotas or dates in prose unless the reader needs them. When you must, state which version they apply to.
- Describe the state you verified, in the present tense. Do not write about when something changed. "The forge doesn't accept X" is a verified present fact, while "the forge retired X in 2026" is a story that goes stale and invites a date error.
- Benchmark or size tables that the maintainer asked to keep stay as they are. Do not edit numbers you cannot regenerate, but make sure the prose around them does not overstate what they show ("not a like-for-like comparison" when the two sides do different things).

## 7. Code samples and names

- Every import path, exported name and option in a sample must exist. Check the package exports and the public entry points. Check that a constant you mention is actually exported before you say so.
- Environment variable names, header names and file paths must match the code exactly, including case.
- Samples must be internally consistent: the variable you pass is the variable you defined.
- Where practical, run or type-check the sample. At minimum, confirm each call exists with that argument order.
- If the code uses a name that is now misleading (for example a variable named after a retired credential), do not rename it in docs. Use the real name, explain in a clause, and report the mismatch.
- Do not write sample output that you did not produce or derive from the code.

## 8. Consistency across pages

A fact lives in a few places: a guide, a concept page, a provider page, an example README, a landing-page blurb. When you verify or fix one, search the whole repository for the others, including READMEs and component text, and make them agree. A reviewer who finds a wrong sentence on one page will find the same one on another.

## 9. Generated content

- Blocks between markers, tables written by scripts, JSON schemas, API reference pages and anything produced from source comments are not edited by hand.
- If generated text is wrong, fix its source (the script, the config, the comment) and regenerate. If the source is code you were not asked to change, report it instead.
- After you finish, run the generator and confirm that your edits left generated blocks byte-identical.
- Never write prose that contradicts a generated table. If the table says a capability is unsupported, the prose must not suggest otherwise.

## 10. Mistakes that happened in practice

These are real errors from a past rewrite. Each was caught only because the sentence was checked against the code. Look for the same patterns.

- **Invented usage for an option.** The text said the `fetch` option was for "a mock in a test or a proxy-aware client". The source comment said "for tests and for runtimes without one". The proxy example was invented. Use the source's own wording.
- **Overclaimed consequence.** "so the two can never disagree" was weakened to "so the two stay in sync" because the first is a guarantee that nobody had verified.
- **Invented history.** "the `X-Gitea-*` version of each header, which older instances send" had no source. It was removed.
- **Invented timing.** "add a second forge in a few minutes" had no basis and was removed.
- **Universal claim without a search.** "supports everything" and "the exception that offers streaming" both needed a search across all providers. One was wrong, the other confirmed.
- **Silent behaviour claim.** "the function doesn't tell you when a set is skipped" was only written after reading the function body, and then corrected to also cover the case where a set is switched off on purpose.
- **Wrong reason from a plausible chain.** A sentence implied that a subpath import is what keeps a bundle small, when the package already tree-shakes from the root. A maintainer caught it. Check what actually causes a behaviour before you attribute it.
- **Statements that were true before and not now.** A third-party credential type that had been retired at the source. Docs said to use it.
- **Docs describing the wrong shape.** A response was described as "a JSON list" when the code returned an object with a list inside it. Read the return statement.
- **Defaults assumed.** A recording tool was described as always having default targets, when two of ten forges had none. Read the default expressions.
- **A scope claim that was too wide.** "each field sets the provider option of the same name" was wrong for two fields. When a table has exceptions, the sentence introducing it must say "most".

## 11. When you cannot verify

In order of preference:

1. Reduce the statement to the part you verified.
2. Leave the statement out. A shorter page is fine.
3. Ask the maintainer one precise question, when the answer matters and only they know it.
4. If you keep an unverified statement because it was already in the docs, keep it unchanged, and list it in the handover as unverified. Do not make it more confident or more detailed while rewording.

Never keep a guess because it sounds plausible, and never add confident detail around a fact you only partly know.

## 12. Reviewing other people's corrections

Maintainers, users and bots (for example automated code review) leave comments on docs. Treat each as a hypothesis.

- Read the claim, then verify it against the code or the upstream source. Do not apply or reject it on tone.
- Many are right and some are wrong. Fix the right ones fully, and for wrong ones change nothing and say briefly why.
- A correct comment about one sentence points to a pattern: search for the same claim elsewhere and fix every occurrence, including examples, READMEs and component text.
- When a comment is right, rewrite to the exact truth, not to a softer version of the old claim.
- After fixing, re-run the generator, tests, docs build and link check.
- Do not reply on review threads on the maintainer's behalf unless asked. Follow the global instructions for review-bot threads.
