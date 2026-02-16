{ ... }:
{
  system.defaults = {
    # Dock
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      tilesize = 48;
      orientation = "bottom";
      show-recents = false;
      show-process-indicators = true;
      mineffect = "scale";
    };

    # Finder
    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      FXPreferredViewStyle = "Nlsv";
      FXDefaultSearchScope = "SCcf";
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
    };

    # System-wide
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      AppleShowScrollBars = "Automatic";
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDocumentSaveNewDocumentsToCloud = false;
      ApplePressAndHoldEnabled = false;
    };

    # Trackpad
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };

    # Screenshots
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };

    # Screensaver
    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    # Login window
    loginwindow = {
      GuestEnabled = false;
      SHOWFULLNAME = false;
    };

    # Custom preferences
    CustomUserPreferences = {
      # Disable siri
      "com.apple.Siri" = {
        "UAProfileCheckingStatus" = 0;
        "siriEnabled" = 0;
      };
      # Disable personalized ads
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
    };
  };
}
