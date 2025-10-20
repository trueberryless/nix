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
    ".gitconfig".source = ../dotfiles/git/config;
    ".gitignore".source = ../dotfiles/git/ignore;

    ".alias".source = ../dotfiles/shell/alias;
    ".zprofile".source = ../dotfiles/shell/zprofile;
    ".zshrc".source = ../dotfiles/shell/zshrc;
    "oh-my-posh.omp.json".source = ../dotfiles/shell/oh-my-posh.omp.json;

    ".config/zed/settings.json".source = ../dotfiles/zed/settings.json;
  };
}
