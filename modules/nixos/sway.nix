{ pkgs, userConfig, ... }:

{
  hardware.graphics.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.symbols-only
    noto-fonts-color-emoji
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  services.udev.packages = [ pkgs.brightnessctl ];
  users.users.${userConfig.name}.extraGroups = [ "video" ];

  environment.systemPackages = with pkgs; [
    mesa-demos vulkan-tools libva-utils wayland-utils
    wl-clipboard grim slurp brightnessctl wireplumber playerctl
  ];
}
