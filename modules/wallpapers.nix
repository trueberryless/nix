{ pkgs, self, ... }:
let
  wallpapersDir = self + /wallpapers;

  wallpaperPackage = pkgs.stdenv.mkDerivation {
    name = "wallpaper-collection";
    src = wallpapersDir;
    installPhase = ''
      mkdir -p $out/wallpapers
      cp -r * $out/wallpapers/ 2>/dev/null || true
    '';
  };

  randwallInterpreter = pkgs.stdenv.mkDerivation {
    name = "randwall-interpreter";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/bin
      cp ${pkgs.bash}/bin/bash $out/bin/randwall
    '';
  };

  randwall = pkgs.writeScriptBin "randwall" ''#!${randwallInterpreter}/bin/randwall
    set -e

    WALLPAPER_DIR="${wallpaperPackage}/wallpapers"

    mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \))

    if [ ''${#WALLPAPERS[@]} -eq 0 ]; then
      exit 1
    fi

    INDEX=$((RANDOM % ''${#WALLPAPERS[@]}))
    SELECTED_WALLPAPER="''${WALLPAPERS[$INDEX]}"

    /usr/bin/osascript <<EOF
    tell application "Finder"
      set desktop picture to POSIX file "$SELECTED_WALLPAPER"
    end tell

    tell application "System Events"
      tell every desktop
        set picture to "$SELECTED_WALLPAPER"
      end tell
    end tell
EOF
  '';
in
{
  environment.systemPackages = [ randwall ];

  launchd.user.agents.wallpaper-rotation = {
    serviceConfig = {
      ProgramArguments = [ "${randwall}/bin/randwall" ];
      StartCalendarInterval = [
        { Hour = 0; Minute = 0; }
        { Hour = 6; Minute = 0; }
        { Hour = 12; Minute = 0; }
        { Hour = 18; Minute = 0; }
      ];
      RunAtLoad = true;
      StandardOutPath = "/tmp/wallpaper-rotation.log";
      StandardErrorPath = "/tmp/wallpaper-rotation.error.log";
    };
  };
}
