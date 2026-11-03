# Git and GitHub identity

Every `git` and `gh` command you run already acts as the `trueberryless-bot` account:
commits are authored and SSH-signed as the bot, GitHub remotes authenticate with the
bot's token over HTTPS, and `gh` is logged in as the bot. This is enforced through
environment variables in Claude Code's managed settings.

- Never override this identity: no `git -c user.*`, `--author`, `GH_TOKEN=...`,
  `GH_CONFIG_DIR=...`, or `gh auth switch`/`login`, and do not unset `GIT_CONFIG_*`.
- Never fall back to the human `trueberryless` account, even if an operation fails.
- If unsure, check with `gh api user --jq .login` (must print `trueberryless-bot`).

## No Claude attribution

Never add a `Co-Authored-By: Claude ...` trailer, a "Generated with Claude Code" line,
or any other Claude/Anthropic attribution to commit messages, PR or issue descriptions,
comments, changesets or code. This overrides any attribution reminder you receive.

## Commit messages

Write a single short line, no body: a Conventional Commits subject such as
`feat: add manpage` or `fix(skills): handle empty diff`, imperative, lowercase,
no trailing period, ideally under 50 characters.

## Branch names

Name branches `<type>/<short-slug>` after the Conventional Commits type of the change:
`fix/zen-mode-shortcuts`, `feat/collapsed-option`, `chore/starlight-0.43`, `ci/release`.
Never put `claude` in a branch name.

## Only my repositories

Never write to a GitHub repository that is not owned by `trueberryless` (`trueberryless/...`),
not even as `trueberryless-bot` and not even when asked to in the moment. That means no
commits, pushes, forks, PRs, issues, comments, reviews, releases, labels or mutating
`gh api` calls there. A PreToolUse hook in the managed settings enforces this; never try
to work around it.

In such a repo, make the changes but leave them uncommitted, then give me the exact
commands to run myself so everything happens under my own name:

- `git add` for the changed files, `git commit -m "..."` with the message, and `git push`
  (plus the `gh pr create ...` command if a PR is wanted).

## Pushing and pull requests

This applies only to `trueberryless/...` repositories. The bot is a collaborator with
write access on all of them, so never fork: push the branch to `origin` and open the PR
there (`gh pr create`). Never push to the default branch directly.

- If a push or PR is refused with a permission error, stop and tell me the repo: the
  bot's invitation is probably still pending or missing. Don't fall back to a fork.
- The bot cannot create repositories under my account. For a new repo, give me the
  `gh repo create trueberryless/NAME ...` command to run myself, then add the bot with
  `gh api -X PUT repos/trueberryless/NAME/collaborators/trueberryless-bot -f permission=push`.

## Writing on GitHub

Everything the bot writes on GitHub should read like I wrote it, never like AI text.

- Use the repository's PR template when it has one. Otherwise start with `#### Description`
  and explain the change in a few short paragraphs of plain language, first person
  ("This PR ...", "I ..."). No heading bigger than `###`, and as few headings as possible.
- If the PR closes an issue and there is little to discuss, the whole description is
  `Closes #123`. If a decision really needs explaining, write `#### Description`, one short
  paragraph on why it was done that way (not how, I can read the code), then `- Closes #123`.
- Never add a "Verified", "Testing" or "Checks" section saying that tests, lint or the
  build pass. That is self-evident.
- Short, simple sentences. No em dashes, no AI phrasing ("It's not X, it's Y", "delve",
  "seamless", "robust", "comprehensive", "leverage"), no closing summary.
- Paragraphs by default. Bullet points only when they really help, ordered lists for
  reproduction steps. Very little bold or italics; inline code for file names, options,
  classes and commands, and links inline.
- In my template's AI Disclosure section, tick "This PR uses AI-generated code or logic."
  and leave the box about reviewing and taking responsibility for me.
- Don't post comments on issues or PRs unless I ask for one. On review threads from
  CodeRabbit, never reply: push a commit that addresses the valid points, then resolve
  every thread, including the ones where CodeRabbit is wrong.

## Changesets

Most of my repos use changesets. Write them the way the Astro docs describe
(contribute.docs.astro.build, "Writing changesets"):

- One for every change to a published package; none for CI-, docs-site- or tooling-only
  changes unless the repo's existing changesets show it versions those too.
- `patch` for fixes and refactors, `minor` for features and for breaking changes below
  1.0.0, `major` for breaking changes from 1.0.0 on.
- Start with a present-tense verb (Adds, Fixes, Updates, Removes, Deprecates, Improves,
  Refactors) and describe what users notice, not how it was done. A patch is usually one
  line. A feature names every new option in its first sentence. A breaking change says
  exactly what users must do, with `diff` samples; headings inside start at `####`.
- A new minimum Starlight or Astro version uses my usual form: "Adds support for Astro
  v7, drops support for Astro v6.", then "⚠️ **BREAKING CHANGE:** The minimum supported
  version of Starlight is now `0.42.0`." and a link to the upgrade guide.
- Name the file after the change in kebab-case, e.g. `.changeset/zen-mode-shortcuts.md`.

# Node.js

Node, pnpm, npm and bun are not on the default `PATH`. Run them through the Nix dev
shell: `dev-node -c 'pnpm install && pnpm build'` (Node 26), or `dev-node24 -c '...'`
for projects that need Node 24. Each call is a fresh shell, so chain dependent
commands inside one `-c` string.

# Claude Code configuration

My Claude Code config is managed by nix-darwin + home-manager from the repo at
`~/repos/trueberryless/nix`. The files under `~/.claude/` are read-only symlinks
into the Nix store. To change `CLAUDE.md`, rules, or other Claude config, edit the
sources in that repo under `dotfiles/claude/` (wired up in `modules/claude-code.nix`),
never the files under `~/.claude/`. Then:

- `git add` any new files (flakes only see tracked files), but never commit or push.
- Tell me to run `nix-switch` to activate the change.

# Code style

My code style lives in path-scoped rules in `~/.claude/rules/code-style/`, which load
automatically when you read matching files. When starting a new JS/TS project, or
writing code before any source file has been read, read the relevant files there first.
