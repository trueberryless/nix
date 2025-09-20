{ pkgs, ... }: 
{
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
      raycast
      tmux
      tree
      zoxide
    ]) ++ [
      (import ./shells/node20.nix { inherit pkgs; })
    ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
