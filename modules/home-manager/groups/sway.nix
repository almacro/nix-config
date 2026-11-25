{ lib, ... }:

let
  lock = "swaylock -f -c 000000";

  # one line: lock after 5 min, screen off after 6, suspend after 15, and always lock before any sleep
  idle = lib.concatStringsSep " " [
    "swayidle -w"
    "timeout 300 '${lock}'"
    "timeout 360 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"'"
    "timeout 900 'systemctl suspend'"
    "before-sleep '${lock}'"
  ];
in
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
      startup = [ { command = idle; } ];
      keybindings = lib.mkOptionDefault {
        "Mod4+l"                = "exec ${lock}";
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
