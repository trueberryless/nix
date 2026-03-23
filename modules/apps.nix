{ pkgs, ... }:
let
  devShellPaths = [
    ./shells/node20.nix
    ./shells/node22.nix
    ./shells/node24.nix
  ];
  devShells = map (path: pkgs.callPackage path { }) devShellPaths;
in {
  environment.systemPackages =
    (with pkgs; [
      aldente
      bitwarden-desktop
      discord
      docker
      eza
      git
      go
      google-chrome
      iproute2mac
      iterm2
      jetbrains.datagrip
      jetbrains.idea
      jetbrains.rider
      nixd
      oh-my-posh
      postman
      raycast
      tmux
      tree
      vscode
      zed-editor
      zoxide
    ]) ++ devShells;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
