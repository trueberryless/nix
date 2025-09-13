# nix

This is a project with my nix configuration for a MacBook (darwin).

## Installation

Download Nix with Determinate Systems and decline the `--determinate` option with "no" (you will be prompted):

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Since git is configured with this repo, I recommend that you just download the ZIP of the repo and unpack locally, save it to `~/.config/nix/` and execute:

```bash
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ~/.config/nix
```

After that command, `nix-darwin` is installed and you can run this command from now on to rebuild your config:

```bash
sudo darwin-rebuild switch --flake ~/.config/nix
```

## Resources

- [Determinate Systems][determinate-systems]: [installer-repo][installer-repo], [Zero to Nix][zero-to-nix]
- [Blog: "Package management on macOS with nix-darwin" - Davi][davi-nix-darwin]

[determinate-systems]: https://docs.determinate.systems/
[installer-repo]: https://github.com/DeterminateSystems/nix-installer
[zero-to-nix]: https://zero-to-nix.com/
[davi-nix-darwin]: https://davi.sh/blog/2024/01/nix-darwin/
