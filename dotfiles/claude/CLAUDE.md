# Git and GitHub identity

Every `git` and `gh` command you run already acts as the `trueberryless-bot` account:
commits are authored and SSH-signed as the bot, GitHub remotes authenticate with the
bot's token over HTTPS, and `gh` is logged in as the bot. This is enforced through
environment variables in Claude Code's managed settings.

- Never override this identity: no `git -c user.*`, `--author`, `GH_TOKEN=...`,
  `GH_CONFIG_DIR=...`, or `gh auth switch`/`login`, and do not unset `GIT_CONFIG_*`.
- Never fall back to the human `trueberryless` account, even if an operation fails.
- If unsure, check with `gh api user --jq .login` (must print `trueberryless-bot`).

## Pushing and pull requests

Before the first push in a repo, check the bot's access:
`gh repo view --json viewerPermission --jq .viewerPermission`.

- `WRITE`, `MAINTAIN` or `ADMIN`: push the branch to `origin` and open the PR there.
- Anything else: fork without asking. Run
  `gh repo fork --remote --remote-name bot`, push the branch to `bot`,
  and open the PR with `gh pr create --repo OWNER/REPO --head trueberryless-bot:BRANCH`.

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
