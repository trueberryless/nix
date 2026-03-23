{ pkgs, ... }:
(let
  packages = with pkgs; [
    go
    gopls
    gotools
    golangci-lint
    delve
    zsh
  ];
in pkgs.runCommand "dev-go" {
  # Dependencies that should exist in the runtime environment
  buildInputs = packages;
  # Dependencies that should only exist in the build environment
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/dev-go
  wrapProgram $out/bin/dev-go \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --set DEV_SHELL go \
    --set GOPATH $HOME/go \
    --set GOBIN $HOME/go/bin
'')
