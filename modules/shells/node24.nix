{ pkgs, ... }:
(let
  packages = with pkgs; [
    nodejs_24
    (pnpm.override { nodejs = nodejs_24; })
    (yarn.override { nodejs = nodejs_24; })
    bun
    zsh
  ];
in pkgs.runCommand "dev-node24" {
  # Dependencies that should exist in the runtime environment
  buildInputs = packages;
  # Dependencies that should only exist in the build environment
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/dev-node24
  wrapProgram $out/bin/dev-node24 \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --set DEV_SHELL node24
'')
