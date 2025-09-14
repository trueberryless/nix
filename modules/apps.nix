{ pkgs, system, ... }: 
{
  environment.systemPackages = with pkgs; [
    aldente
    bartender
    discord
    docker
    iterm2
    neofetch
    raycast
    oh-my-posh
    tmux
    zoxide
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
