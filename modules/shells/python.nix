{ pkgs, ... }:
(let
  packages = with pkgs; [
    python3
    uv
    zsh
  ];
in pkgs.runCommand "dev-python" {
  # Dependencies that should exist in the runtime environment
  buildInputs = packages;
  # Dependencies that should only exist in the build environment
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p $out/bin/
  ln -s ${pkgs.zsh}/bin/zsh $out/bin/dev-python
  wrapProgram $out/bin/dev-python \
    --prefix PATH : ${pkgs.lib.makeBinPath packages} \
    --run 'export UV_TOOL_DIR="$HOME/.local/share/uv/tools"' \
    --run 'export UV_TOOL_BIN_DIR="$HOME/.local/bin"' \
    --run 'export PATH="$UV_TOOL_BIN_DIR:$PATH"' \
    --set DEV_SHELL python
'')
