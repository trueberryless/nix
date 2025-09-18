{ pkgs, ... }:
let
  nixSwitch = pkgs.writeShellScriptBin "nix-switch" ''
    exec darwin-rebuild switch --flake "$(eval echo "/Users/$SUDO_USER")/.config/nix#$(hostname -s)"
  '';
in {
  environment.systemPackages = [
    nixSwitch
  ];
}