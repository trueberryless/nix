{ username, lib, ... }:
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  imports = [
    ./git-tools.nix
  ];

  home.activation.deltaBotHosts = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ ! -e "$HOME/.config/delta/hosts.yml" ]; then
      install -m 600 -D ${../dotfiles/delta/hosts.yml} "$HOME/.config/delta/hosts.yml"
    fi
  '';

  home.file = {
    ".gitconfig".source = ../dotfiles/vcs/gitconfig;
    ".gitconfig-tangled".source = ../dotfiles/vcs/gitconfig-tangled;
    ".gitignore".source = ../dotfiles/vcs/gitignore;
    ".config/jj/config.toml".source = ../dotfiles/vcs/jjconfig;

    ".config/delta/gitconfig".source = ../dotfiles/delta/gitconfig;

    ".alias".source = ../dotfiles/shell/alias;
    ".zprofile".source = ../dotfiles/shell/zprofile;
    ".zshrc".source = ../dotfiles/shell/zshrc;
    "oh-my-posh.omp.json".source = ../dotfiles/shell/oh-my-posh.omp.json;
  };
}
