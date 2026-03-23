{ pkgs, ... }:
let
  devShellPaths = [
    ./shells/go.nix
    ./shells/node.nix
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
