{ pkgs, system, ...}: 
{
  environment.systemPackages = with pkgs; [
    aldente
    discord
    docker
    iterm2
    neofetch
    nerd-fonts.fira-code
    oh-my-posh
    tmux
    zoxide
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
