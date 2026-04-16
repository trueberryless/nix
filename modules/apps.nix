{ pkgs, copilot-cli, system, ... }:
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
      nixd
      oh-my-posh
      postman
      podman
      raycast
      tmux
      tree
      vscode
      zed-editor
      zoxide
    ])
    ++ [ copilot-cli.packages.${system}.default ]
    ++ devShells;

  nixpkgs.config.allowUnfree = true;
}
