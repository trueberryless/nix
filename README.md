# nix

![Built with Nix](./docs/built-with-nix-badge.svg)
[![Netlify Status](https://api.netlify.com/api/v1/badges/43cc5d10-6e0d-4fb0-8664-91eceabe90ae/deploy-status)](https://app.netlify.com/projects/felix-nix/deploys)

This is a project with my nix configuration for a MacBook (darwin).

## Installation

Download Nix with Determinate Systems and decline the `--determinate` option with "no" (you will be prompted):

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Install homebrew separately with this command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Since git is configured with this repo, I recommend that you just download the ZIP of the repo and unpack locally, save it to `~/.config/nix/` and execute:

```bash
sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/.config/nix#shai-hulud
```

After that command, `nix-darwin` is installed and you can run this command to rebuild your config:

```bash
sudo darwin-rebuild switch --flake ~/.config/nix
```

Afterwards, this alias will be available to rebuild your config:

```bash
nix-switch
```

### Manual configs

After applying the config, make sure to finish the setup manually:

### SSH Keys

Create the SSH keys for [GitHub](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [Tangled](https://docs.tangled.org/quick-start-guide):

- `~/.ssh/github.pub` (and its private key)
- `~/.ssh/tangled.pub` (and its private key)

### GitHub CLI Authentication

Login to `gh`, so the `git-ucommit` script is authenticated:

```bash
gh auth login
```

### GitHub bot (Claude Code)

Claude Code runs every `git` and `gh` command as `trueberryless-bot`, in any
directory, while your own terminal stays `trueberryless`. Set it up once:

1. Create the bot SSH key and add its **public** key to the bot account as a **Signing key**:

   ```bash
   ssh-keygen -t ed25519 -C 'trueberryless-bot@users.noreply.github.com' -f ~/.ssh/github-bot
   ```

2. Create a classic PAT with the `repo` and `workflow` scopes on the bot account, then:

   ```bash
   mkdir -p -m 700 ~/.config/github-bot
   printf '%s
' 'YOUR_BOT_PAT' > ~/.config/github-bot/token
   chmod 600 ~/.config/github-bot/token
   ```

[`modules/claude-code.nix`](/modules/claude-code.nix) installs Claude Code managed
settings (`/Library/Application Support/ClaudeCode/managed-settings.d/50-github-bot.json`)
whose `env` block sets:

- `GIT_CONFIG_*`: bot name, email and signing key, plus a GitHub credential helper
  that reads the bot token and rewrites SSH GitHub remotes to HTTPS. This is git's
  highest-priority config scope, so it overrides `~/.gitconfig` and repo-local config.
- `GH_CONFIG_DIR=~/.config/github-bot/gh`: a bot-only `gh` config whose `hosts.yml`
  is regenerated from the token on every switch (rerun `nix-switch` after rotating it).

It also links [`dotfiles/claude/CLAUDE.md`](/dotfiles/claude/CLAUDE.md) to
`~/.claude/CLAUDE.md`. Claude pushes directly to repos where the bot is a
collaborator and otherwise forks as the bot and opens the PR from the fork.
Check it from a Claude Code session with `gh api user --jq .login`.

### macOS Privacy

Navigate to _System Settings > Privacy & Security_ and grant the following:

- _Automation_: `randwall` needs to control `Finder` and `System Events`.
- _Accessibility_: `Raycast` and `ClipBook`
- _Full Disk Access_: `iTerm2` to prevent permission errors when managing dots in `~/.local` or `~/Library`.

## Troubleshooting

### dotfiles

If your home-manager configuration files are not getting applied, the issue could be some messed up permissions of your `.local` folder, check them with:

```bash
ls -ld ~/.local
```

If those are not owned by **you** but maybe **root** instead, change the permissions and run the rebuild again:

```bash
sudo chown -R trueberryless:staff ~/.local
```

### alias

Be careful which user runs commands and which config file these users will use to get available aliases. The `nix-switch` alias [in this repo](/dotfiles/shell/alias#L1) includes the `sudo` elevation inherently. You do not need to prepend `sudo` to it. If you switch to the root user entirely, you will lose access to these aliases as the root user uses a different `.zshrc` file and does not load your user's `~/.alias` file managed by `home-manager`.

## Resources

I want to express my heartfelt gratitude to everyone who contributes to the Nix ecosystem.

### Blog posts and documentation

- [NixOS & Flakes Book - An unofficial book for beginners][this-cute-world] - [Ryan Yin][ryan4yin]
- [Blog: "Managing dotfiles on macOS with Nix"][davi-home-manager] - [Davis Haupt][davish]

### Repositories

- [Nix][nix]
- [Determinate Systems][determinate-systems]
- [Home Manager][home-manager]
- [nix.dev][nix-dev]
- [Nix Darwin Kickstarter][nix-darwin-kickstarter] - [Ryan Yin][ryan4yin]
- [Homebrew][homebrew]
- [Zero to Nix][zero-to-nix]


[this-cute-world]: https://nixos-and-flakes.thiscute.world/
[davi-home-manager]: https://davi.sh/blog/2024/02/nix-home-manager/

[davish]: https://github.com/davish/
[ryan4yin]: https://github.com/ryan4yin

[nix]: https://github.com/NixOS/nix
[nix-dev]: https://github.com/nixos/nix.dev
[homebrew]: https://github.com/Homebrew/brew
[home-manager]: https://github.com/nix-community/home-manager
[zero-to-nix]: https://github.com/DeterminateSystems/zero-to-nix
[determinate-systems]: https://github.com/DeterminateSystems/nix-installer
[nix-darwin-kickstarter]: https://github.com/ryan4yin/nix-darwin-kickstarter
