{ ... }:
{
  # To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    # `brew install`
    brews = [
      "gh"
      "spotifyd"
    ];

    # `brew install --cask`
    casks = [
      "beeper"
      "clipbook"
      "firefox"
      "zen"
    ];
  };
}
