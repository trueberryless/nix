{ pkgs, system, ... }:
pkgs.mkShell {
  # create an environment with nodejs_20, pnpm, and yarn
  packages = with pkgs; [
    nodejs_20
    nodePackages.pnpm
    zsh
  ];

  shellHook = ''
    echo "node `node --version`"
    exec zsh
  '';
}