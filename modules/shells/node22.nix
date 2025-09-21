{ pkgs, ... }:
(let
  packages = with pkgs; [
    nodejs_22
    (pnpm.override { nodejs = nodejs_22; })
    zsh
  ];
in pkgs.runCommand "dev-node22" {
  # Dependencies that should exist in the runtime environment
  buildInputs = packages;
  # Dependencies that should only exist in the build environment
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/dev-node22
  wrapProgram $out/bin/dev-node22 \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --set DEV_SHELL node22
'')
