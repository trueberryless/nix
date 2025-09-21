{ pkgs, ... }:
(let
  packages = with pkgs; [
    nodejs_20
    (pnpm.override { nodejs = nodejs_20; })
    zsh
  ];
in pkgs.runCommand "dev-node20" {
  # Dependencies that should exist in the runtime environment
  buildInputs = packages;
  # Dependencies that should only exist in the build environment
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/dev-node20
  wrapProgram $out/bin/dev-node20 \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --set DEV_SHELL node20
'')
