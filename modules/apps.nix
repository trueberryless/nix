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
      discord
      docker
      git
      iterm2
      jetbrains.idea-ultimate
      jetbrains.rider
      neofetch
      postman
      raycast
      tmux
      tree
      zoxide
    ]) ++ devShells;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
