{ pkgs, system, ...}: 
{
  environment.systemPackages = with pkgs; [
    aldente
    discord
    docker
    iterm2
    neofetch
    oh-my-posh
    tmux
    zoxide
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
