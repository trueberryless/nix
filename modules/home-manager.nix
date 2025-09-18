{ pkgs, username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    jdk23
  ];

  home.file = {
    ".zshrc".source = ../dotfiles/.zshrc;
    ".gitconfig".source = ../dotfiles/.gitconfig;
  };
}