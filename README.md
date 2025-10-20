# nix

![Built with Nix](./docs/built-with-nix-badge.svg)
[![Netlify Status](https://api.netlify.com/api/v1/badges/43cc5d10-6e0d-4fb0-8664-91eceabe90ae/deploy-status)](https://app.netlify.com/projects/trueberryless-nix/deploys)

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
sudo nix-switch
```

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

Be careful which user runs commands and which config file these users will use to get available aliases. For example, the `nix-switch` alias [in this repo](/modules/sudo-alias.nix) allows the root user to run the alias, as it uses the `$SUDO_USER` to find the folder of the user which executes the command (in this case `trueberryless`). It is not possible to simply define aliases for root inside [`home-manager.nix`](/modules/home-manager.nix) as the sudo user uses a different `.zshrc` file.

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
