# Voice and flow

This is the writing style in depth. It describes how the best technical documentation reads: a knowledgeable person explaining a tool to a reader they respect, in connected prose, with reasons attached to every rule. Everything here was measured against documentation that readers enjoy, and against text that sounded machine-written. Follow it on every page.

## Contents

1. The register
2. How a page opens
3. Rhythm: sentences and paragraphs
4. Connecting sentences
5. Reasons, conditions and limitations
6. The reader is the subject
7. Framing code
8. Precise words, and words to avoid
9. Headings and frontmatter descriptions
10. Lists, tables, steps and callouts
11. Emphasis, links and terminology
12. Page types and their registers
13. Closing a page
14. Tells of machine-written text
15. Before and after examples

## 1. The register

Imagine a colleague who knows the tool well and is explaining it to someone smart who has not used it. They are warm and direct. They do not talk down, do not sell, and do not rush. They tell you what a thing is, why you would want it, how to use it, and what to watch out for, in that order, and they connect each point to the last.

- Address the reader as "you". Use the project name or a noun for the thing being described ("the provider", "the CLI"). Avoid "we" unless the project's existing docs use it.
- Be plain. Prefer common words. Technical terms are fine once defined.
- Be confident where the facts are certain and silent where they are not (see `accuracy.md`). Never hedge a deterministic behaviour.
- Do not market. No "powerful", "seamless", "robust", "blazing", "comprehensive", "leverage", "unlock". Describe what happens and let the reader decide it is good.
- No exclamation marks in reference or guide prose, and no emoji.
- A little warmth is welcome: "that is why", "this way", "so you never have to". It must serve the explanation, not decorate it.

## 2. How a page opens

The first paragraph says what the thing is and why a reader would reach for it, in two or three sentences with some context. Only then the mechanics.

- Start with substance. "This page explains..." is acceptable only when followed straight away by the substance, and it is usually better to skip it.
- Give the problem before the feature. A reader who has just learned why webhooks are awkward is ready to learn what the library does about them.
- If a page needs an assumption (a token, an installed package, a running server), state it in the opening or in a short prerequisites list.
- Define any term that a newcomer may not know, the first time it appears, in a clause: "A forge is a service that hosts Git repositories together with the collaboration around them."

## 3. Rhythm: sentences and paragraphs

Natural technical prose has a range of sentence lengths, with a centre of gravity around 15 to 18 words. Machine-sounding docs sit at 10 to 11 words with a large share of very short sentences. The numbers in `measuring.md` give targets.

- Let sentences run long enough to carry a reason. A sentence of 20 to 30 words that states a rule and why it exists is often better than two sentences of 10.
- Use a short sentence deliberately, for emphasis or a turn. It should be a minority, around one in twenty, not the default unit.
- Paragraphs hold two to four sentences and one idea. Split by idea, never by sentence.
- A single-sentence paragraph is fine as a lead-in to a code block or list. It should not be the usual shape of the page.
- Vary how sentences begin. If three consecutive sentences start with the same word, restructure.
- Do not pack four facts into one sentence either. When a sentence has a main rule plus three edge cases, state the rule, then give the edge cases in the next sentences or in a callout.

## 4. Connecting sentences

Each sentence should lean on the one before it. Use connectors that state the relationship:

- Addition: "also", "in addition", "besides", "on top of that"
- Contrast: "however", "but", "instead", "whereas", "even so", "unlike"
- Cause and result: "because", "so", "which means", "for this reason", "as a result", "that is why"
- Sequence: "first", "then", "after that", "once", "from then on", "next"
- Example: "for example", "for instance", "such as", "like"
- Condition: "if", "when", "unless", "as long as", "otherwise"
- Purpose: "to avoid", "so that", "in order to" (only when "to" alone would be unclear)
- Emphasis on a limit: "keep in mind", "note that", "be aware that" (sparingly, a few per page)

A good test: remove the connector. If the paragraph becomes a list of unrelated facts, the connector was doing real work. If a paragraph has no connectors at all, it is probably a list of facts that should be rewritten.

Do not overuse any single connector, and do not decorate with transitions that carry no meaning ("moreover", "furthermore", "in conclusion").

## 5. Reasons, conditions and limitations

Every rule comes with its reason, and every limitation with what to do instead. This is the biggest single difference between text that reads as human and text that reads as generated.

Rule plus reason, joined in one paragraph:

> The forge signs the exact bytes of the request body, so you have to pass the raw body. If you parse the body and serialise it again, the bytes can change and the signature check fails.

Limitation plus alternative:

> The provider can't read branch policies, so it can't tell which merge strategies are allowed. `merge()` therefore requires a `method`.

Condition stated precisely instead of a vague "can":

> When exactly one method is allowed, the provider uses it. When several are allowed, it throws `MergeMethodRequiredError`.

- Where a reason exists in the code or upstream docs, give it. Where you do not know the reason, say only what you know. Never invent a reason to make a sentence flow. See `accuracy.md`.
- Where you attach a consequence ("so a token for one host is never sent to another"), make sure it follows from the facts.
- A limitation without an alternative leaves the reader stuck. If there is no alternative, say that plainly.

## 6. The reader is the subject

Most sentences should be about what the reader does or gets, not about the API doing things in a vacuum.

- Weak: "`webhooks.ingest()` verifies a delivery against `webhookSecret` and translates it into `ForgeEvent` objects."
- Better: "When a forge sends you a webhook, you pass the request to `webhooks.ingest()`. It checks the signature against your `webhookSecret` and translates the delivery into events that look the same on every forge."

Neither sentence is wrong. The second one starts from the reader's situation, which is why it reads naturally. Aim for roughly three to four occurrences of "you" or "your" per hundred words in guides, tutorials and getting-started pages. Concept and reference pages can be lower.

Do not force it: "The provider appends `/api/v1` itself" is a fine sentence with a non-human subject. The goal is that the reader does not disappear from the page.

## 7. Framing code

Code blocks are not self-explanatory. Frame each one.

- Before the block, one sentence says what the example shows or does: "The following handler verifies the signature and returns a 401 when it doesn't match:".
- After the block, when something non-obvious happens, one sentence says what to expect or why: "This will generate three pages, one for each author." Not every block needs an after-sentence.
- Do not end a paragraph with a colon and a block when the sentence before it is a fragment. The sentence must stand on its own.
- Keep examples short and realistic. One idea per example. Use names from the domain ("acme/widgets"), not "foo".
- Explain what a variable or option in the example means the first time it matters, in the prose around it, not in comments inside the code.
- If an example performs a real side effect (posts a comment, deletes data), say so before the block and tell the reader what to change first.
- Code in prose uses inline code for identifiers, files, options, commands and values.

## 8. Precise words, and words to avoid

Vagueness reads as unsure, and unsure reads as unreliable.

- "can" as a hedge. "A bundler can drop unused providers" leaves the reader guessing whether it does. If it does under a stated condition, write "when": "Bundlers drop the providers you don't use when you import from the root." Use "can" only for real ability or permission: "you can pass a function instead of a string".
- "may", "might", "usually", "typically", "generally", "often", "should" (as a hedge), "in most cases". Use them only when the behaviour really varies, and then say on what it depends.
- "simply", "just", "easily", "obviously", "of course", "basically". They add nothing and sound condescending when the step is hard.
- "It is important to note that", "Please note", "It should be noted". Say the thing. If it is important, a callout or the sentence position shows it.
- "In order to" where "to" works. "Utilise", "leverage", "facilitate". "A number of". "Various".
- "etc." and "and so on" at the end of a list the reader needs complete. List all items or say what the list covers.
- Passive voice that hides the actor ("is called", "is returned") when saying who does it is clearer. Passive is fine when the actor is irrelevant.
- Future tense for ordinary behaviour. "The provider retries once" not "The provider will retry once", except when describing the result of a step ("This will generate...").

## 9. Headings and frontmatter descriptions

- Headings in guides name the task: "Use a token", "Read without credentials", "Limit a credential to reads". Concept and reference headings name the thing: "Support levels", "Instance".
- Sentence case, unless the repository uses title case.
- A heading never ends with a colon. Do not number headings unless they are steps.
- Keep anchors stable. If you rename a heading, update every link to it.
- A frontmatter or meta description is a sentence that tells the reader what they will learn or be able to do: "Pass credentials to a provider, and limit what they can do." Not a list of nouns, and not a restatement of the title.

## 10. Lists, tables, steps and callouts

- Prose is the default for explanation. Lists are for items that really are parallel and independent: a set of choices, requirements, ingredients. Never use bullets to avoid connecting ideas.
- Introduce every list with a sentence that says what the items are, and avoid a list of one or two items.
- List items are complete thoughts where they carry reasons, and can be short noun phrases where they are just names.
- Numbered lists are for ordered procedures. Each step is one full instruction, with a sentence of why or what to expect when it is not obvious.
- Tables are for lookup data: headers and what they contain, options and their defaults, support by item. Do not put explanations into table cells that would be clearer as a paragraph.
- Callouts (tip, note, warning) are for asides: an edge case, a shortcut, a risk. They are not for core information, and a page should have few of them. Use a warning only for security, data loss or breaking behaviour.
- "Read more" and "see also" links belong at the end of a section, not scattered through the sentence.

## 11. Emphasis, links and terminology

- Bold is rare. Never use bold as a run-in label at the start of every paragraph. Use at most a handful of bold phrases on a page, for a term being defined or a critical warning. Italics are rarer still.
- Link on descriptive text ("the [Browser bundles](/guides/bundling) guide"), never "click here" or a bare URL. Link a term the first time it matters, not every time it appears.
- Use the same word for the same thing throughout. Do not alternate "provider", "adapter" and "driver" for one concept. Match the names the code and the UI use.
- Use the project's spelling and capitalisation for names and keep product names correct (for example, `Pushin.eu`, `GitHub`).

## 12. Page types and their registers

Different pages have different jobs. Do not write everything in one register.

- **Getting started and tutorials**: the most conversational. Walk the reader through, step by step, with context for each step. Highest density of "you". Expected results after each step.
- **Guides (how-to)**: task-oriented and narrative. A short opening saying what the reader will achieve, then sections that each answer "how do I X?", with reasons and edge cases in context.
- **Concepts**: explain the model and the why. Mostly prose. Build understanding, not procedures. Link to guides for the how.
- **Reference**: terse and uniform. Each entry follows the same shape (name, type, default, one paragraph that says what it does and when it matters). Prose is allowed to be shorter and more regular here, but it must still be correct and still avoid fragments that point at nothing. Generated reference text from source comments uses third-person verbs ("Lists the threads of a repository.").
- **Provider, integration or adapter pages**: part guide, part reference. Start with what it covers, then authentication or setup, then the behaviour that differs from the others, each with its reason, then the webhooks or configuration details, then the generated capability tables.
- **Recipes and examples**: prerequisites first, then numbered steps, then what to expect. Explain what the example demonstrates in a sentence or two.
- **Contributing docs**: workflow and facts about the repository, written for a person who wants to help. Not style rules (see `repo-files.md`).

## 13. Closing a page

- End with "Next steps" or "See also": a short list of links, each with a clause that says why a reader would go there.
- Do not add a closing paragraph that summarises what the page just said. The structure of the page already did that.
- Do not end with a motivational sentence.

## 14. Tells of machine-written text

These are what readers pick up on, even without being able to name them. Remove them.

- A long run of sentences of the same shape and length, each stating one fact.
- Fragments that point back at the previous sentence ("Use it in browser code.").
- Sentences that restate the heading or the previous sentence in other words.
- Triads for rhythm ("fast, simple and reliable") and "not just X, but Y" constructions.
- Every section opening with the same pattern ("X does Y."), or every list item starting with the same verb.
- Four facts packed into one sentence with commas and "and", then nothing connecting it to the next one.
- Heavy use of bullets and bold for content that should be explained.
- Descriptions that are lists of nouns instead of sentences.
- A summary or motivational closing.
- Unexplained rules: statements of what is and is not allowed without saying why.
- Invented reasons and filler consequences that sound plausible.

## 15. Before and after examples

Choppy chain of declaratives:

> **Before:** `createForges()` takes a list of factories. It builds the providers. It returns an object that routes calls.
>
> **After:** `createForges()` takes a list of factories, builds the providers and returns one object that routes your calls to the right one.

Fragment pointing backwards:

> **Before:** Every provider except one has a Lite factory that leaves out webhook code. Use it in browser code.
>
> **After:** A browser never receives webhook deliveries, so the code that verifies and translates them would only add weight to your bundle. To avoid that, every provider except one comes with a second factory that leaves the webhook code out. If you are building for the browser, use that factory.

Four facts in one sentence:

> **Before:** `perPage` is an upper bound; a page can hold fewer items and still have a cursor when the forge can't filter on a field, in which case the provider drops non-matching items and reads on up to ten times.
>
> **After:** `perPage` is an upper limit and not a promise. A page can hold fewer items and still have a `cursor`, because some filters can't be applied by the forge itself, so the provider reads a page and drops the items that don't match. For this reason, keep reading for as long as `cursor` is set, rather than stopping at the first short page.

The API as the subject, and the missing reason:

> **Before:** `provider.scopesFor(verb)` returns the token scopes that an operation needs.
>
> **After:** If a call fails because the token lacks a permission, it helps to tell the user which one they need. `provider.scopesFor(verb)` returns the token scopes that an operation requires on that forge, which makes it useful for a consent screen or an error message.

A bare limitation:

> **Before:** `whenChecksPass` is unavailable.
>
> **After:** The REST API doesn't enable auto-merge, so the `whenChecksPass` option isn't available. (Only write the reason if you have verified it. Otherwise write the first half only.)

Vague hedge:

> **Before:** Bundlers can drop unused providers from the root import.
>
> **After:** Bundlers drop the providers you don't use when you import from the root.

A description that is a list:

> **Before:** `Browser bundles: sizes, redirects, test modules, budgets`
>
> **After:** `Keep forges small in a browser bundle, and learn how it behaves in a browser.`

Marketing and internals in a feature blurb:

> **Before:** Each provider declares what it supports, and CI checks the claims against the tests.
>
> **After:** Every provider declares what its forge supports. Ask `provider.can()` before you call an operation, and your code never has to find out the hard way.
