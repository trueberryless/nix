{ pkgs, system, ... }: 
{
  environment.systemPackages = with pkgs; [
    aldente
    discord
    docker
    git
    home-manager
    iterm2
    jetbrains.idea-ultimate
    jetbrains.rider
    neofetch
    pnpm
    raycast
    tmux
    zoxide
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
