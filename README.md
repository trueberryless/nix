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

### Delta bot (optional)

Delta manages its own checkouts under `$NIX_CONFIG_PATH/.delta/`. To have Delta's
`git` and `gh` act as `trueberryless-bot`:

1. Create the bot SSH key and add its **public** key to the bot account as a
   **Signing key** (_GitHub > trueberryless-bot settings > SSH and GPG keys > New
   SSH key > Key type: Signing key_):

   ```bash
   ssh-keygen -t ed25519 -C 'trueberryless-bot@users.noreply.github.com' -f ~/.ssh/github-bot
   cat ~/.ssh/github-bot.pub
   ```

2. Provision a **classic** PAT with the `repo` scope, owned by the bot
   (_GitHub > trueberryless-bot settings > Developer settings > Tokens (classic) >
   Generate new token > select `repo`_).

   The `repo` scope is required because the bot acts on *your* repos (as a
   collaborator), and fine-grained PATs can only access repos owned by the bot's
   own account. The token is read by `.zshrc` inside Delta worktrees and set as
   `GH_TOKEN`:

   ```bash
   mkdir -p ~/.config/delta
   printf '%s\n' 'YOUR_BOT_PAT' > ~/.config/delta/bot-token
   chmod 600 ~/.config/delta/bot-token
   ```

   The reason the token is read from a file: `gh` on macOS resolves the keychain
   by service name (`gh:github.com`) and can return the *other* account's token
   when two accounts share a host. `GH_TOKEN` overrides stored credentials, so
   this guarantees the bot token is used inside Delta checkouts.

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
