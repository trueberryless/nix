{ username, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  imports = [
    ./git-tools.nix
  ];

  home.file = {
    ".gitconfig".source = ../dotfiles/vcs/gitconfig;
    ".gitconfig-tangled".source = ../dotfiles/vcs/gitconfig-tangled;
    ".gitignore".source = ../dotfiles/vcs/gitignore;
    ".config/jj/config.toml".source = ../dotfiles/vcs/jjconfig;

    ".alias".source = ../dotfiles/shell/alias;
    ".zprofile".source = ../dotfiles/shell/zprofile;
    ".zshrc".source = ../dotfiles/shell/zshrc;
    "oh-my-posh.omp.json".source = ../dotfiles/shell/oh-my-posh.omp.json;
  };
}
