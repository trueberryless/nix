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
      code-cursor
      discord
      docker
      eza
      git
      google-chrome
      iterm2
      jetbrains.datagrip
      jetbrains.idea-ultimate
      jetbrains.rider
      neofetch
      nixd
      oh-my-posh
      postman
      raycast
      tmux
      tree
      youtube-music
      zed-editor
      zoxide
    ]) ++ devShells;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
