{pkgs, ...}: 
{
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;    
  programs.git = {
    enable = true;
    userName = "Felix Schneider";
    userEmail = "99918022+trueberryless@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };
  programs.zsh = {
    enable = true;
    shellAliases = {
      switch = "darwin-rebuild switch --flake ~/.config/nix";
    };
  };

  home.packages = with pkgs; [];

  home.sessionVariables = {
    EDITOR = "vim";
  };
}