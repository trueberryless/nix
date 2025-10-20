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
    ".alias".source = ../dotfiles/.alias;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".gitignore".source = ../dotfiles/.gitignore;
    ".zprofile".source = ../dotfiles/.zprofile;
    ".zshrc".source = ../dotfiles/.zshrc;
    "oh-my-posh.omp.json".source = ../dotfiles/oh-my-posh.omp.json;
  };
}
