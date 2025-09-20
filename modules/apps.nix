{ pkgs, ... }: 
{
  environment.systemPackages = with pkgs; [
    aldente
    discord
    docker
    git
    iterm2
    jetbrains.idea-ultimate
    jetbrains.rider
    neofetch
    pnpm
    raycast
    tmux
    tree
    zoxide
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
