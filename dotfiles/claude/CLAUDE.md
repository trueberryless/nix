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
