{ pkgs, ... }:
(let
  packages = with pkgs; [
    rustup
    gcc
    pkg-config
    openssl
    zsh
  ];
in pkgs.runCommand "dev-rust" {
  # Dependencies that should exist in the runtime environment
  buildInputs = packages;
  # Dependencies that should only exist in the build environment
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/dev-rust
  wrapProgram $out/bin/dev-rust \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --set DEV_SHELL rust \
    --set RUSTUP_HOME "$HOME/.rustup" \
    --set CARGO_HOME "$HOME/.cargo"
'')
