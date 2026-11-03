# README, CONTRIBUTING, PR templates and other repository files

These files are documentation too, and the same voice and accuracy rules apply. They also have one extra rule that comes from the maintainer.

## The rule: no style rules in the repository

Do not put writing or style rules into any repository file. That means no "write short sentences", "use the second person", "avoid em dashes", "describe parameters with @param", "start methods with a third-person verb", no tone guidance and no list of banned words. Such rules are discussed in pull requests, between people, when they matter. A rules list also makes the project feel rigid, and it ages badly.

This includes `CONTRIBUTING.md`, the contributing pages of the docs site, the PR template, issue templates, the README, the docs folder's own README, and comments in config files. If an existing file has such a section, remove it when you rewrite the file, and keep the factual parts around it (how generated docs work, where files live).

What does belong:

- Facts about the workflow: how to set up, which commands exist, how to run tests, what is generated and how to regenerate it.
- Technical constraints that are enforced or that explain behaviour, stated with their reason (for example "providers also run in browsers, so they don't import Node.js built-in modules"). These are architecture notes, not style.
- Process conventions the project enforces mechanically, such as the commit message format that drives releases. Keep these. Conventional Commits are a convention the tooling relies on, not a style rule.

The style knowledge lives in this skill and in the maintainer's global instructions, not in the repo.

## CONTRIBUTING

Write it as a welcoming, practical manual for someone who wants to help, in the voice from `voice-and-flow.md`. Structure that works:

1. **Welcome.** Two or three sentences: contributions of any size and skill level are welcome, and you will help with your first pull request. One line pointing to the code of conduct. An optional tip for first-time contributors.
2. **Quick guide.**
   - Prerequisites: runtime and package manager versions, and what the repository pins.
   - Setting up the local repository: fork, clone, install from the root (and why from the root if it is a workspace), run the unit tests once to confirm a green base.
   - Development: the everyday commands. If the project generates a commands table from a script, keep the generated block and its markers untouched. Intro sentence first.
   - Testing your changes: the realistic ways to try a change (write a test, run an example, use a playground), each with the command, and a sentence on when each fits.
   - Running tests: all, one file, the docs tests (and how to build first), and the single command that runs everything the CI runs.
3. **Project layout.** A table of paths and what lives there.
4. **Working on the main thing** (a provider, a plugin, a package): where to start, then the constraints that matter, each as a short paragraph with its reason (capabilities verified by tests, fixtures from real systems, generated documentation, runtime restrictions, credentials must not leak).
5. **Documentation.** Where the docs live, how to run the site, and what is generated so that nobody edits it by hand (markers, scripts, source comments), including how to regenerate. Facts, not style.
6. **Commit messages.** The convention, why it matters (for example releases are cut from it), and two or three examples including a scoped one.
7. **Pull requests.** How big, what to run before pushing, what to put in the description (what changed and why, link the issue).
8. **Reporting a problem.** Where, with what information.

Keep bold to a minimum (none in running text; at most a callout title), no emoji in headings, and keep paragraphs connected rather than a pile of bullets. Prefer a short list of commands in a code block with one-line comments over a long list of prose rules.

If the docs site has a contributing page that mirrors `CONTRIBUTING.md`, keep the two identical in substance (links adapted to site paths), and update both together. If a generated block appears in both, regenerate it.

When adding a script or command to the project, add it to the commands table source if the project has one, then regenerate. A test often fails if a hand-run script is not listed.

## README

- One-line statement of what the project is, then a short paragraph in the voice from `voice-and-flow.md`: what it is, the problem it solves, who it is for.
- Install, a short usage example that actually runs, and a pointer to the full docs. Keep it short. The README is the front door, not the manual.
- A "documentation" list where each link has a clause that says what the reader finds there.
- Related projects only if the maintainer already has them, with a clause saying how each relates.
- Contributing and licence pointers. Badges stay as they are.
- Do not repeat the docs. Link.

## Pull request template

Keep it small. A reader filling it in should not feel they are doing paperwork. A structure that works:

- Linked issue
- Context or Changes: what changed and why (and anything specific the reviewer needs, such as the affected platform and version)
- Testing: how it was tested, and a reason if no tests were added
- Docs: whether the docs need to change, and a reason if they were not

Use HTML comments for the prompts so they vanish when rendered. Mark the sections that must not be deleted. Do not add a long checklist of rules, instructions about how to write the description, or style guidance. If the maintainer has edited the template by hand, keep their version and their headings.

## Other files

- **Code of conduct** and licence files: leave them alone unless asked.
- **Docs folder README**: how the docs site is put together, how to run it, where generated text comes from. Facts about the structure, in connected prose.
- **Example READMEs**: mirror the docs page for the example. Same facts, same commands, same wording where it makes sense.
- **Fixture or data READMEs**: leave alone unless they are wrong.
- **Issue templates**: ask for the information a maintainer needs to reproduce, with no tone guidance.

## Review and generation notes

- Repository files are linted and link-checked like other docs. Run the project's link check with fragments after you change them.
- Never put secrets or real tokens in examples. Use obviously fake placeholders in the style the repo already uses.
- If the project has an AI-use policy or an AI disclosure section in its template, leave it as the maintainer wrote it.
