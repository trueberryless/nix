{ pkgs, self, ... }:
let
  # Directory in your git repo where wallpapers are stored
  # Place your wallpaper images in ./wallpapers/ relative to your flake root
  wallpapersDir = self + /wallpapers;

  # Create a package that contains all wallpapers
  wallpaperPackage = pkgs.stdenv.mkDerivation {
    name = "wallpaper-collection";
    src = wallpapersDir;
    installPhase = ''
      mkdir -p $out/wallpapers
      cp -r * $out/wallpapers/ 2>/dev/null || true
    '';
  };

  # Script to set a random wallpaper
  setRandomWallpaper = pkgs.writeShellScriptBin "set-random-wallpaper" ''
    set -e

    WALLPAPER_DIR="${wallpaperPackage}/wallpapers"

    # Get all image files (jpg, jpeg, png, heic)
    mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" \))

    if [ ''${#WALLPAPERS[@]} -eq 0 ]; then
      echo "No wallpapers found in $WALLPAPER_DIR"
      exit 1
    fi

    # Use random selection - different wallpaper each time you run the command
    INDEX=$((RANDOM % ''${#WALLPAPERS[@]}))
    SELECTED_WALLPAPER="''${WALLPAPERS[$INDEX]}"

    echo "Setting wallpaper: $(basename "$SELECTED_WALLPAPER")"
    echo "Full path: $SELECTED_WALLPAPER"

    # Set wallpaper for all displays using Finder (more reliable on macOS)
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

    echo "Wallpaper set successfully!"
  '';

in
{
  # Add the wallpaper script to system packages
  environment.systemPackages = [ setRandomWallpaper ];

  # Set up LaunchAgent using launchd.user.agents
  launchd.user.agents.wallpaper-rotation = {
    serviceConfig = {
      ProgramArguments = [ "${setRandomWallpaper}/bin/set-random-wallpaper" ];
      StartCalendarInterval = [
        { Hour = 0; Minute = 0; }   # Midnight
        { Hour = 6; Minute = 0; }   # 6 AM
        { Hour = 12; Minute = 0; }  # Noon
        { Hour = 18; Minute = 0; }  # 6 PM
      ];
      RunAtLoad = true;
      StandardOutPath = "/tmp/wallpaper-rotation.log";
      StandardErrorPath = "/tmp/wallpaper-rotation.error.log";
    };
  };
}
