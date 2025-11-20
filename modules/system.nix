{ self, username, ... }:
###################################################################################
#
#  macOS System Configuration
#
#  All configuration options are documented here:
#    https://nix-darwin.github.io/nix-darwin/manual/
#
###################################################################################
{
  system = {
    # Version of the state that the system uses for backwards compatibility
    # Should match the nix-darwin version when configuration was first created
    stateVersion = 6;

    # Git revision of the nix-darwin configuration for tracking purposes
    # Automatically set to the current revision or marks as dirty if uncommitted changes exist
    configurationRevision = self.rev or self.dirtyRev or null;

    # The primary user account for this system
    # Used by various modules as the default user for user-specific configurations
    primaryUser = username;

    defaults = {
      menuExtraClock = {
        # Controls whether the menu bar clock displays time in 24-hour format
        Show24Hour = true;
      };

      screencapture = {
        # Sets the default location where screenshots are saved
        # Options: "clipboard", "~/Desktop", or any valid path
        target = "clipboard";
      };

      screensaver = {
        # Requires password entry when screen saver is activated
        askForPassword = true;

        # Time delay before password is required after screen saver starts
        # Value in seconds (0 = immediate)
        askForPasswordDelay = 0;
      };

      finder = {
        # Displays the full POSIX path in the Finder window title bar
        _FXShowPosixPathInTitle = false;

        # Makes all files visible in Finder, including hidden system files
        AppleShowAllFiles = true;

        # Shows file extensions for all files in Finder
        AppleShowAllExtensions = true;

        # Controls whether a warning appears when changing a file's extension
        FXEnableExtensionChangeWarning = false;

        # Adds a "Quit" option to the Finder application menu
        QuitMenuItem = true;

        # Displays the path bar at the bottom of Finder windows showing current location
        ShowPathbar = true;

        # Shows the status bar at the bottom of Finder windows with item counts and available space
        ShowStatusBar = true;
      };

      trackpad = {
        # Enables tap-to-click functionality on the trackpad
        Clicking = false;

        # Allows two-finger click or tap for right-click functionality
        TrackpadRightClick = true;

        # Enables three-finger dragging gesture for moving windows and selecting text
        TrackpadThreeFingerDrag = false;
      };

      dock = {
        # Automatically hides the Dock when not in use and shows it on mouse hover
        autohide = false;

        # Controls whether recently opened applications appear in the Dock
        show-recents = false;

        # Prevents automatic rearrangement of Spaces based on most recent use
        # When disabled, Spaces maintain their assigned order
        mru-spaces = false;

        # Groups windows by their parent application in Mission Control
        expose-group-apps = true;
      };

      NSGlobalDomain = {
        # Controls the direction of scrolling
        # Natural scrolling mimics touch device behavior (content moves with fingers)
        "com.apple.swipescrolldirection" = true;

        # Controls whether a beep sound plays when adjusting volume
        # 0 = disabled, 1 = enabled
        "com.apple.sound.beep.feedback" = 0;

        # Sets the system-wide appearance theme
        # Options: "Dark", "Light", or null for system default
        AppleInterfaceStyle = null;

        # Enables full keyboard navigation through all controls
        # Mode 3 allows Tab key to move focus between all controls, not just text fields
        AppleKeyboardUIMode = 3;

        # Controls whether pressing and holding a key repeats the character
        # When disabled, enables character picker for accented letters
        ApplePressAndHoldEnabled = true;

        # Sets the delay before a held key begins repeating
        # Lower values = shorter delay
        # Range: 15 (225ms) to 120 (1800ms)
        InitialKeyRepeat = 15;

        # Sets the speed at which keys repeat once repeating starts
        # Lower values = faster repetition
        # Range: 2 (30ms) to 120 (1800ms)
        KeyRepeat = 3;

        # Controls automatic capitalization of words at sentence beginnings
        NSAutomaticCapitalizationEnabled = false;

        # Controls automatic substitution of double hyphens with em dashes
        NSAutomaticDashSubstitutionEnabled = false;

        # Controls automatic addition of periods when double-spacing
        NSAutomaticPeriodSubstitutionEnabled = false;

        # Controls automatic conversion of straight quotes to curly quotes
        NSAutomaticQuoteSubstitutionEnabled = false;

        # Controls automatic spell checking and correction as you type
        NSAutomaticSpellingCorrectionEnabled = false;

        # Controls whether save dialogs show expanded view by default
        # Expanded view shows file browser with more options
        NSNavPanelExpandedStateForSaveMode = true;

        # Alternative setting for expanded save panel state (for compatibility)
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      # Custom settings not directly supported by nix-darwin modules
      # Uses macOS defaults system for additional configuration options
      # Reference: https://github.com/yannbertrand/macos-defaults
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          # Automatically switches to the Space containing the application when activated
          # Useful for keeping related work in separate Spaces
          AppleSpacesSwitchOnActivate = true;
        };

        NSGlobalDomain = {
          # Adds "Inspect Element" option to right-click menu in web views
          # Useful for web development and debugging
          WebKitDeveloperExtras = true;
        };

        "com.apple.finder" = {
          # Shows all files including system and hidden files
          AppleShowAllFiles = true;

          # Sorts folders before files in all view modes
          _FXSortFoldersFirst = true;

          # Sets default search scope when using Finder's search
          # "SCcf" = Search Current Folder
          # "SCev" = Search Entire Volume
          # "SCsp" = Use Previous Search Scope
          FXDefaultSearchScope = "SCev";
        };

        "com.apple.desktopservices" = {
          # Prevents creation of .DS_Store metadata files on network volumes
          # Reduces clutter on shared network drives
          DSDontWriteNetworkStores = true;

          # Prevents creation of .DS_Store metadata files on USB drives
          # Keeps USB drives clean when used across systems
          DSDontWriteUSBStores = true;
        };

        "com.apple.spaces" = {
          # Controls whether displays have separate Spaces
          # true = displays share Spaces (windows can span displays)
          # false = each display has independent Spaces
          "spans-displays" = false;
        };

        "com.apple.WindowManager" = {
          # Controls whether clicking wallpaper reveals desktop
          # 0 = disabled, 1 = enabled
          EnableStandardClickToShowDesktop = 1;

          # Controls visibility of desktop icons
          # 0 = show icons, 1 = hide icons
          StandardHideDesktopIcons = 1;

          # Controls whether desktop items are hidden (Stage Manager related)
          # 0 = show items, 1 = hide items
          HideDesktop = 1;

          # Controls widget visibility in Stage Manager
          # 0 = show widgets, 1 = hide widgets
          StageManagerHideWidgets = 1;

          # Controls standard widget visibility
          # 0 = show widgets, 1 = hide widgets
          StandardHideWidgets = 1;
        };

        "com.apple.screensaver" = {
          # Requires password entry after screensaver activation
          # 1 = enabled, 0 = disabled
          askForPassword = 1;

          # Delay before password requirement after screensaver starts
          # Value in seconds (0 = immediate)
          askForPasswordDelay = 0;
        };

        "com.apple.AdLib" = {
          # Controls whether Apple can use your information for personalized advertising
          allowApplePersonalizedAdvertising = false;
        };

        "com.apple.ImageCapture" = {
          # Prevents Photos app from automatically opening when devices are connected
          # Useful if you prefer manual photo management
          disableHotPlug = true;
        };
      };

      loginwindow = {
        # Disables the guest user account at the login window
        # Improves security by requiring authenticated accounts
        GuestEnabled = false;

        # Shows full name instead of username at the login window
        # Makes login screen more user-friendly
        SHOWFULLNAME = false;
      };
    };

    keyboard = {
      # Enables custom keyboard mapping functionality
      # Required for key remapping features to work
      enableKeyMapping = true;

      # Remaps Caps Lock key to function as Escape
      # Popular among Vim users and reduces reaching for Escape key
      remapCapsLockToEscape = false;

      # Swaps the physical positions of left Command and left Alt keys
      # Useful for users coming from Windows/Linux expecting Ctrl in corner position
      swapLeftCommandAndLeftAlt = false;

      # Custom key mappings using keyboard HID codes
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingSrc = 30064771129; # Caps Lock (0x700000039)
          HIDKeyboardModifierMappingDst = 30064771148; # Forward Delete (0x70000004C)
        }
      ];
    };
  };

  # Enables Touch ID authentication for sudo commands in the terminal
  # Allows using fingerprint instead of typing password for administrative commands
  security.pam.services.sudo_local.touchIdAuth = true;

  # Enables Zsh as a shell option
  # Required if using Zsh as the default shell on macOS
  # Creates /etc/zshrc that sources the nix-darwin environment
  programs.zsh.enable = true;
}
