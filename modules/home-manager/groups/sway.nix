{ lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    package = null;                       # Sway itself comes from the NixOS module
    config = {
      modifier = "Mod4";
      terminal = "foot";
      menu = "wmenu-run";
      input."type:keyboard".xkb_options = "ctrl:nocaps";
      input."type:touchpad" = { tap = "enabled"; natural_scroll = "enabled"; };
      bars = [ { command = "waybar"; } ];
      keybindings = lib.mkOptionDefault {
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
        "XF86AudioMute"         = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioLowerVolume"  = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioRaiseVolume"  = "exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioPlay"         = "exec playerctl play-pause";
        "XF86AudioPrev"         = "exec playerctl previous";
        "XF86AudioNext"         = "exec playerctl next";
      };
    };
  };

  programs.waybar.enable = true;
  services.mako.enable = true;
}
