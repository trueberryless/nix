{ pkgs, ... }:
let
  devShellPaths = [
    ./shells/go.nix
    ./shells/node.nix
    ./shells/node24.nix
    ./shells/python.nix
    ./shells/rust.nix
  ];
  devShells = map (path: pkgs.callPackage path { }) devShellPaths;
in {
  environment.systemPackages =
    (with pkgs; [
      aldente
      bitwarden-desktop
      eza
      fastfetch
      git
      go
      google-chrome
      iproute2mac
      iterm2
      jetbrains.datagrip
      jetbrains.idea
      jetbrains.rider
      jujutsu
      lazygit
      lychee
      neovim
      nixd
      oh-my-posh
      opencode
      postman
      raycast
      tmux
      tree
      zoxide
    ])
    ++ devShells;

  nixpkgs.config = {
    allowUnfree = true;
  };
}
