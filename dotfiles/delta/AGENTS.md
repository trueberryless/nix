# GitHub bot identity — apply in every thread

All `gh` operations in Delta checkouts must run as the `trueberryless-bot` account,
never as the human `trueberryless` account.

The bot credentials live at:

- Token: `~/.config/delta/bot-token` (classic PAT, `repo` scope)
- Config dir: `~/.config/delta` (bot-only `gh` config)

The token is set as `GH_TOKEN`, which takes precedence over the keychain. Do not rely
on the macOS keychain or `gh`'s stored accounts: on this machine the keychain can
resolve to the wrong account, and the default active account is **not** the bot.

Before every `gh` command, export the token and config dir in the same shell session:

```sh
export GH_TOKEN="$(cat ~/.config/delta/bot-token)"
export GH_CONFIG_DIR="$HOME/.config/delta"
```

Then run `gh`. For example:

```sh
export GH_TOKEN="$(cat ~/.config/delta/bot-token)"
export GH_CONFIG_DIR="$HOME/.config/delta"
gh pr create ...
```

Verify when in doubt:

```sh
export GH_TOKEN="$(cat ~/.config/delta/bot-token)"
export GH_CONFIG_DIR="$HOME/.config/delta"
gh api user --jq .login   # must print: trueberryless-bot
```

If `gh` prints `Bad credentials`, re-check that `GH_TOKEN` is exported and that
`~/.config/delta/bot-token` holds a valid classic PAT.

To open a pull request, first fork the repo as the bot, push the branch to the
fork, then open the PR from the fork into the original repo:

```sh
export GH_TOKEN="$(cat ~/.config/delta/bot-token)"
export GH_CONFIG_DIR="$HOME/.config/delta"
gh repo fork OWNER/REPO --clone=false
git push -u <fork-remote> BRANCH
gh pr create --repo OWNER/REPO --head ID:BRANCH --base BASE ...
```

The bot does not have Write access to the owner's repos, so a PR from a non-fork
branch will be rejected. Always fork first.
